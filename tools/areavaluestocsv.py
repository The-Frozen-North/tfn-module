import re

# Intended for use with: dev_arealootval, dev_allarealoot

class LootCategoryManager(object):
	"Splitting the output by object types made this complicated, having something to sort all of these is helpful"
	def __init__(self):
		# We want to be able to output:
		# Tier + objecttype + objectquality (what we were fed)
		# Objecttype + objectquality, combined across all tiers (eg: gold/numitems from all boss placeables)
		# Tier + objecttype (eg t5 item count from all placeables)
		
		# tier + objectquality (t5 item count from all things tagged boss) seems less useful
		self._objectqualities = set()
		self._objecttypes = set()
		self._tiers = set()
		# This is horrible, but eh
		self._values = {}
	def add(self, objecttype, objectquality, tier, amount, isnumitems):
		self._objecttypes.add(objecttype)
		self._objectqualities.add(objectquality)
		self._tiers.add(tier)
		if not isnumitems:
			self._values[f"{objecttype}_{objectquality}_{tier}"] = self._values.get(f"{objecttype}_{objectquality}_{tier}", 0.0) + float(amount)
		else:
			self._values[f"{objecttype}_{objectquality}_{tier}_numitems"] = self._values.get(f"{objecttype}_{objectquality}_{tier}_numitems", 0.0) + float(amount)
	def output(self):
		# Output a dict. The main writer should be able to fill in any blank fields
		# with zeroes
		out = {}
		# Tier + objecttype + objectquality (what we were fed)
		for objtype in self._objecttypes:
			for objquality in self._objectqualities:
				for tier in self._tiers:
					out[f"{objtype}_{objquality}_{tier}_numitems"] = self._values.get(f"{objtype}_{objquality}_{tier}_numitems", 0.0)
					out[f"{objtype}_{objquality}_{tier}_val"] = self._values.get(f"{objtype}_{objquality}_{tier}", 0.0)
		# Objecttype + objectquality, combined across all tiers (eg: gold/numitems from all boss placeables)
		for objtype in self._objecttypes:
			for objquality in self._objectqualities:
				totalvalue = 0.0
				totalitems = 0.0
				for tier in self._tiers:
					totalvalue += self._values.get(f"{objtype}_{objquality}_{tier}", 0.0)
					totalitems += self._values.get(f"{objtype}_{objquality}_{tier}_numitems", 0.0)
				out[f"{objtype}_{objquality}_numitems"] = totalitems
				out[f"{objtype}_{objquality}_val"] = totalvalue
		# Tier + objecttype (eg t5 item count from all placeables)
		for objtype in self._objecttypes:
			for tier in self._tiers:
				totalvalue = 0.0
				totalitems = 0.0
				for objquality in self._objectqualities:
					totalvalue += self._values.get(f"{objtype}_{objquality}_{tier}", 0.0)
					totalitems += self._values.get(f"{objtype}_{objquality}_{tier}_numitems", 0.0)
				out[f"{objtype}_{tier}_numitems"] = totalitems
				out[f"{objtype}_{tier}_val"] = totalvalue
		# Just tier.
		for tier in self._tiers:
			totalvalue = 0.0
			totalitems = 0.0
			for objtype in self._objecttypes:
				for objquality in self._objectqualities:
					totalvalue += self._values.get(f"{objtype}_{objquality}_{tier}", 0.0)
					totalitems += self._values.get(f"{objtype}_{objquality}_{tier}_numitems", 0.0)
			out[f"{tier}_numitems"] = totalitems
			out[f"{tier}_val"] = totalvalue
		# Just type.
		for objtype in self._objecttypes:
			totalvalue = 0.0
			totalitems = 0.0
			for tier in self._tiers:
				for objquality in self._objectqualities:
					totalvalue += self._values.get(f"{objtype}_{objquality}_{tier}", 0.0)
					totalitems += self._values.get(f"{objtype}_{objquality}_{tier}_numitems", 0.0)
			out[f"{objtype}_numitems"] = totalitems
			out[f"{objtype}_val"] = totalvalue
			
		return out
		
				
		

class AreaLoot(object):
	def __init__(self, name, tag):
		self.name = name
		self.tag = tag
		self.data = LootCategoryManager()
		self.rawgold = 0
		self.totalitemvalue = 0
	def csvline(self, keyorder):
		dataoutput = self.data.output()
		l = [self.name, self.tag]
		for key in keyorder:
			l.append(dataoutput.get(key, 0.0))
		l += [self.rawgold, self.totalitemvalue]
		l = [str(x) for x in l]
		return (",".join(l)) + "\n"
		
def _splitPrefix(prefix):
	"Split a prefix into object type and object quality"
	# Could just do a simple split on _ but that would fail if any object qualities contain underscores
	#eg: _cre_boss -> ("cre", "boss")
	# 	 _plc_medium
	m = re.match("_(...)_(.*)$", prefix)
	if m is not None:
		return m.groups()
	m = re.match("_(...)$", prefix)
	if m is not None:
		return (m.groups()[0], "")
		
	if prefix == "":
		return ("???", "")
	
	raise ValueError(f"Failed to split prefix {prefix}")
		
		
def main(logfp="./../logs/nwserverLog1.txt"):
	currentArea = None
	areas = []
	globalArea = AreaLoot("ALL AREAS", "__global")
	
	while True:
		with open(logfp, "r") as log:
			for line in log:
				line = line.strip()
				m = re.search("========= BEGIN FOR AREA: (.*) with tag (.*) =========", line)
				if m is not None:
					areaname = m.groups()[0]
					areatag = m.groups()[1]
					currentArea = AreaLoot(areaname, areatag)
					continue
				# This can now spit out a lot of lines when calculating gold per placeables
				# but this happens before any area headers are in the log
				if currentArea is None: continue
				m = re.search("Expected value of prefix \"(.*)\" tier (\\d) items: (.*)", line)
				if m is not None:
					prefix = m.groups()[0]
					objtype, objquality = _splitPrefix(prefix)
					tier = "t" + m.groups()[1]
					value = m.groups()[2].strip()
					currentArea.data.add(objtype, objquality, tier, value, False)
					globalArea.data.add(objtype, objquality, tier, value, False)
					continue
				m = re.search("Expected number of prefix \"(.*)\" tier (\\d) items: (.*)", line)
				if m is not None:
					prefix = m.groups()[0]
					objtype, objquality = _splitPrefix(prefix)
					tier = "t" + m.groups()[1]
					value = m.groups()[2].strip()
					currentArea.data.add(objtype, objquality, tier, value, True)
					globalArea.data.add(objtype, objquality, tier, value, True)
					continue
				m = re.search("Expected raw gold: (.*)", line)
				if m is not None:
					value = float(m.groups()[0].strip())
					currentArea.rawgold = value
					globalArea.rawgold += value
				m = re.search("Total item value: (.*)", line)
				if m is not None:
					value = float(m.groups()[0].strip())
					currentArea.totalitemvalue = value
					globalArea.totalitemvalue += value
					areas.append(currentArea)
		canreadnextlog = True
		logdigit = logfp[-5]
		# I kinda want to do this without using os, because its file ops might look dodgy to people
		# who aren't familiar with them
		try:
			int(logdigit)
		except:
			# log digit is not a digit, we can't read more
			canreadnextlog = False
		if canreadnextlog:
			nextlog = logfp[:-5] + str(int(logdigit)+1) + ".txt"
			try:
				f = open(nextlog)
				f.close()
				logfp = nextlog
			except:
				canreadnextlog = False
		if not canreadnextlog:
			break
			
	# Work out what keys and what order
	keys = []
	
	sortedobjtypes = sorted(globalArea.data._objecttypes)
	sortedobjqualities = sorted(globalArea.data._objectqualities)
	
	# Just items by tier, like we used to have when this was simple
	keys += [f"t{x}_numitems" for x in range(1, 6)]
	keys += [f"t{x}_val" for x in range(1, 6)]
	# Just object type
	keys += [f"{objtype}_numitems" for objtype in sortedobjtypes]
	keys += [f"{objtype}_val" for objtype in sortedobjtypes]
	# By objecttype/tier
	for objtype in sortedobjtypes:
		keys += [f"{objtype}_t{x}_numitems" for x in range(1, 6)]
		keys += [f"{objtype}_t{x}_val" for x in range(1, 6)]
	# By objecttype/objectquality
	for objtype in sortedobjtypes:
		for objquality in sortedobjqualities:
			keys += [f"{objtype}_{objquality}_numitems"]
			keys += [f"{objtype}_{objquality}_val"]
	# Tier + objecttype + objectquality
	for objtype in sortedobjtypes:
		for objquality in sortedobjqualities:
			keys += [f"{objtype}_{objquality}_t{x}_numitems" for x in range(1, 6)]
			keys += [f"{objtype}_{objquality}_t{x}_val" for x in range(1, 6)]

		
	areas.insert(0, globalArea)
	
	# Remove all 0.0 columns, they're not useful
	usefulkeys = set()
	for area in areas:
		l = [area.name, area.tag, str(area.rawgold), str(area.totalitemvalue)]
		datavalues = area.data.output()
		for key in keys:
			if key not in usefulkeys:
				if datavalues.get(key, 0.0) != 0.0:
					usefulkeys.add(key)
					
	i = 0
	while i < len(keys):
		thiskey = keys[i]
		if thiskey not in usefulkeys:
			#print(f"Remove useless key: {thiskey}")
			keys.remove(thiskey)
			continue
		i += 1
	
	with open("areavalues.csv", "w") as f:
		f.write(f"areaname,areatag,rawgold,totalitemvalue,{','.join(keys)}\n")
		for area in areas:
			l = [area.name, area.tag, str(area.rawgold), str(area.totalitemvalue)]
			datavalues = area.data.output()
			for key in keys:
				l.append(str(datavalues.get(key, 0.0)))
			f.write(",".join(l) + "\n")
			
if __name__ == "__main__":
	main()