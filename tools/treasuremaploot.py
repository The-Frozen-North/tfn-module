import random

def dice(sides, numdice):
	result = 0
	for x in range(0, numdice):
		result += random.randint(1, sides)
	return result

def treasuremaploots(downgradechance, trials = 1e6):
	trials = int(trials)
	numhigh = 0
	numlow = 0
	for x in range(0, trials):
		isdowngraded = 0
		rollsforthismap = dice(2, 2)
		for roll in range(0, rollsforthismap):
			if roll > 0 and not isdowngraded and random.random() < downgradechance:
				isdowngraded = 1
			if isdowngraded:
				numlow += 1
			else:
				numhigh += 1
	
	return (numhigh/trials, numlow/trials)

def main():
	results = treasuremaploots(0.93)
	print(f"Low: {results[0]} boss, {results[1]} downgraded")
	results = treasuremaploots(0.81)
	print(f"Medium: {results[0]} boss, {results[1]} downgraded")
	results = treasuremaploots(0.64)
	print(f"High: {results[0]} boss, {results[1]} downgraded")
	results = treasuremaploots(0.42)
	print(f"Master: {results[0]} boss, {results[1]} downgraded")
	
if __name__ == "__main__":
	main()