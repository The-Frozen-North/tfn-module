import re

# area_init spits out some treasure/tier target gold value info
# This just pulls them into a csv for easy viewing


class AreaTreasureData(object):
	def __init__(self, tag):
		self.areatag = tag
		self.targetgold = ""
		self.percentreached = ""
		self.horse = ""
	def output(self):
		return {"areatag":self.areatag, "targetgold":str(self.targetgold), "percentreached":str(self.percentreached), "horse":self.horse}
		
		

def main(logfp="./../logs/nwserverLog1.txt"):
	data = {}
	with open(logfp, "r") as f:
		for line in f:
			m = re.search("Area (.*) has non-keep placeables that provide (.*) percent of its target gold amount of (.*), horse=(.*)", line)
			if m is not None:
				areatag = m.groups()[0]
				percent = m.groups()[1]
				target = m.groups()[2]
				horse = m.groups()[3]
				if areatag not in data:
					data[areatag] = AreaTreasureData(areatag)
				data[areatag].percentreached = percent
				data[areatag].targetgold = target
				data[areatag].horse = horse
				
	keys = ["areatag", "targetgold", "percentreached", "horse"]
	
	with open("treasuredensity.csv", "w") as f:
		f.write(",".join(keys) + "\n")
		for areatag, areadata in data.items():
			areakeys = areadata.output()
			line = [areakeys.get(x, "") for x in keys]
			f.write(",".join(line) + "\n")
			
if __name__ == "__main__":
	main()