import re

# area_init spits out some treasure/tier density values
# This just pulls them into a csv for easy viewing


class AreaTreasureData(object):
	def __init__(self, tag):
		self.areatag = tag
		self.size = ""
		self.treasure_counts = {}
	def output(self):
		out = {"tag":self.areatag, "size":self.size}
		try:
			sizeflt = float(self.size)
		except ValueError:
			sizeflt = 0.0
		for treasuretier, treasurecount in self.treasure_counts.items():
			if int(treasurecount) > 0:
				areaper = sizeflt/float(treasurecount)
			else:
				areaper = "0"
			out[treasuretier + "_count"] = str(treasurecount)
			out[treasuretier + "_areapertreasure"] = str(areaper)
		return out
		
		

def main(logfp="./../logs/nwserverLog1.txt"):
	data = {}
	with open(logfp, "r") as f:
		for line in f:
			# We don't really care about grabbing its calculated density, it's trivial to just do it in python instead!
			m = re.search("Area (.*) has (\\d*) ([a-z]*) treasures", line)
			if m is not None:
				areatag = m.groups()[0]
				treasurecount = m.groups()[1]
				treasuretier = m.groups()[2]
				if areatag not in data:
					data[areatag] = AreaTreasureData(areatag)
				data[areatag].treasure_counts[treasuretier] = treasurecount
			m = re.search("Area (.*) has (.*) total size", line)
			if m is not None:
				areatag = m.groups()[0]
				size = m.groups()[1]
				if areatag not in data:
					data[areatag] = AreaTreasureData(areatag)
				data[areatag].size = size
				
	keys = ["tag", "size", "low_count", "med_count", "high_count", "low_areapertreasure", "med_areapertreasure", "high_areapertreasure"]
	
	with open("treasuredensity.csv", "w") as f:
		f.write(",".join(keys) + "\n")
		for areatag, areadata in data.items():
			areakeys = areadata.output()
			line = [areakeys.get(x, "") for x in keys]
			f.write(",".join(line) + "\n")
			
if __name__ == "__main__":
	main()