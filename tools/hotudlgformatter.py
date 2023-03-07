# HotU dialogue formatter

# HotU dlg files are written in a different way
# Everything characters SAY is in quotes, everything characters DO is not
# This changes to fit in with the way everything else in TFN is structured

# From:
# The character does something. "The character says something."

# To:
# <StartAction>[The character does something.]</Start> The character says something.

# Some text will probably need more help. This should just handle the bulk of it okay.
# It is very crude at best.

# This requires Python 3.x to run. If you can't, then you can always do things by hand, I guess.

# Edited files get a _e on the end of their name.

import json
from struct import unpack
from os.path import join, isfile, basename

class TLK(object):
	"Crude class that reads strings from tlks only. Ignore sounds and other stuff that isn't needed to do this."
	def __init__(self, fp):
		f = open(fp, "rb")
		content = f.read()
		f.close()
		self.LanguageID = unpack("<I", content[8:12])[0]
		self.StringCount = unpack("<I", content[12:16])[0]
		self.StringEntriesOffset = unpack("<I", content[16:20])[0]
		currentbyte = 20
		stringnum = 0
		self.dict = {}
		while 1:
			textscrap = content[currentbyte:currentbyte+40]
			#can ignore most of this stuff
			offsettostring = unpack("<I", textscrap[28:32])[0]
			stringlength = unpack("<I", textscrap[32:36])[0]
			self.dict[stringnum] = content[self.StringEntriesOffset+offsettostring:self.StringEntriesOffset+offsettostring+stringlength]
			stringnum += 1
			if stringnum == self.StringCount:
				break
			currentbyte += 40
				
	def __getitem__(self, item):
		return self.dict[item]
		

def processfile(dlgpath, tlk):
	with open(dlgpath, "r") as f:
		tree = json.load(f)
	for list in ["EntryList", "ReplyList"]:
		for item in tree[list]["value"]:
			text = item["Text"]
			strref = int(text.get("id", -1))
			valuestruct = text.get("value", {})
			raw = valuestruct.get("0", "")
			# If text already set, assume it is correct
			# Everything in HotU will be using strrefs
			if raw != "":
				continue
			if strref == -1:
				continue
			string = tlk[strref]
			if len(string) < 1:
				continue
			if b"<StartAction>" in string:
				continue
			# There is probably an easier regex way. But this approach does get the job done...
			newstring = ""
			
			if string[0] == "\"":
				indialogue = False
				inaction = False
			else:
				inaction = True
				indialogue = False
				newstring = "<StartAction>["
				
			# This is a wild guess. I don't actually know the encoding used in TLK files
			# but for English text it hopefully turns out okay
			string = string.decode("utf8")
			
			for char in string:
				if char == "\"":
					if inaction:
						newstring += "]</Start>"
						inaction = False
						indialogue = True
					else:
						newstring += "<StartAction>["
						inaction = True
						indialogue = False
				else:
					newstring += char
			
			if inaction:
				newstring += "]</Start>"
				
			newstring = newstring.strip()
				
			if newstring.startswith("<StartAction>[]</Start>"):
				newstring = newstring[23:]
			if newstring.endswith("<StartAction>[]</Start>"):
				newstring = newstring[:-23]
			if newstring.endswith("<StartAction>[] </Start>"):
				newstring = newstring[:-24]
			if newstring.endswith("<StartAction> []</Start>"):
				newstring = newstring[:-23]
				
			newstring = newstring.replace(" ]", "] ")
			
			text["value"] = {"0":newstring}
	with open(dlgpath[:-9] + "_e.dlg.json", "w") as f:
		json.dump(tree, f, indent=1)

if __name__ == "__main__":
	while 1:
		tlkpath = input("Enter path to dialog.tlk: ")
		if isfile(tlkpath):
			break
		print(f"{tlkpath} is not a file.")
	tlk = TLK(tlkpath)
	
	while 1:
		dlgname = input("Enter dlg name (without .dlg.json) to convert, or blank to exit: ")
		dlgname = basename(dlgname)
		if dlgname == "":
			break
		dlgpath = join("../src/dlg", dlgname + ".dlg.json")
		if isfile(dlgpath):
			processfile(dlgpath, tlk)
		else:
			print(f"{dlgpath} is not a file.")
