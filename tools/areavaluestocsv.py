import re

# Log sample
"""
[Sat Jul  9 16:39:09] ========= BEGIN FOR AREA: Neverwinter - Beggar's Nest - Great Graveyard - Tomb with tag beg_tomb =========
[Sat Jul  9 16:39:09] Expected value of tier 1 items:       69.749069214
[Sat Jul  9 16:39:09] Expected number of tier 1 items:        1.803833365
[Sat Jul  9 16:39:09] Expected value of tier 2 items:      237.465255737
[Sat Jul  9 16:39:09] Expected number of tier 2 items:        0.595264912
[Sat Jul  9 16:39:09] Expected value of tier 3 items:        1.287710667
[Sat Jul  9 16:39:09] Expected number of tier 3 items:        0.000901917
[Sat Jul  9 16:39:09] Expected value of tier 4 items:        0.000000000
[Sat Jul  9 16:39:09] Expected number of tier 4 items:        0.000000000
[Sat Jul  9 16:39:09] Expected value of tier 5 items:        0.000000000
[Sat Jul  9 16:39:09] Expected number of tier 5 items:        0.000000000
[Sat Jul  9 16:39:09] Expected raw gold:       35.474998474
[Sat Jul  9 16:39:09] Total item value:      308.502044678
"""

class AreaLoot(object):
	def __init__(self, name, tag):
		self.name = name
		self.tag = tag
		self.numitems = {}
		self.goldvalues = {}
		self.rawgold = 0
		self.totalitemvalue = 0
	def csvline(self):
		l = [self.name, self.tag]
		for tier, num in self.numitems.items():
			l.append(num)
		for tier, num in self.goldvalues.items():
			l.append(num)
		l += [self.rawgold, self.totalitemvalue]
		l = [str(x) for x in l]
		return (",".join(l)) + "\n"
		
		
def main(logfp="./../logs/nwserverLog1.txt"):
	currentArea = None
	areas = []
	with open(logfp, "r") as log:
		for line in log:
			line = line.strip()
			m = re.search("========= BEGIN FOR AREA: (.*) with tag (.*) =========", line)
			if m is not None:
				areaname = m.groups()[0]
				areatag = m.groups()[1]
				currentArea = AreaLoot(areaname, areatag)
				continue
			m = re.search("Expected value of tier (\\d) items: (.*)", line)
			if m is not None:
				tier = int(m.groups()[0])
				value = float(m.groups()[1].strip())
				currentArea.goldvalues[tier] = value
				continue
			m = re.search("Expected number of tier (\\d) items: (.*)", line)
			if m is not None:
				tier = int(m.groups()[0])
				value = float(m.groups()[1].strip())
				currentArea.numitems[tier] = value
				continue
			m = re.search("Expected raw gold: (.*)", line)
			if m is not None:
				value = float(m.groups()[0].strip())
				currentArea.rawgold = value
			m = re.search("Total item value: (.*)", line)
			if m is not None:
				value = float(m.groups()[0].strip())
				currentArea.totalitemvalue = value
				areas.append(currentArea)
	
	with open("areavalues.csv", "w") as f:
		f.write("areaname,areatag,numt1,numt2,numt3,numt4,numt5,valt1,valt2,valt3,valt4,valt5,rawgold,totalitemvalue\n")
		for area in areas:
			f.write(area.csvline())
			
if __name__ == "__main__":
	main()