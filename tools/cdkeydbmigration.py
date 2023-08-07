import sqlite3
import subprocess
import os

# This will need changing to run on your system. Sorry :(
# Maybe including this binary in the tools would have been better
path_to_nwn_compressedbuf = r"../../utils/neverwinter.windows.i386/nwn_compressedbuf.exe"

stat_migration_variable_truncations = {
"stat_assassination_attempts_thwa":"stat_assassination_attempts_thwarted",
"stat_attacks_of_opportunity_hit_":"stat_attacks_of_opportunity_hit_by",
"stat_attacks_of_opportunity_miss":"stat_attacks_of_opportunity_missed",
"stat_henchman_item_gold_value_as":"stat_henchman_item_gold_value_assigned",
}

def decompress_compressedbuf(bytes):
	# Niv's utilty operates seemingly only on files
	with open("tmp_compressedbuf", "wb") as f:
		f.write(bytes)
	subprocess.call(f"\"{path_to_nwn_compressedbuf}\" -d \"CPDB\" -i tmp_compressedbuf -o tmp_decompressedbuf")
	with open("tmp_decompressedbuf", "r") as f:
		c = f.read()
	#raise Exception
	os.unlink("tmp_compressedbuf")
	os.unlink("tmp_decompressedbuf")
	print(f"Decompressed some bytes to {c}")
	if len(c) == 0:
		raise ValueError("nwn_compressedbuf likely failed!")
	return c

def migratedb(dbfilepath, variablenameglob, newtablename, truncations={}):
	"Operate on dbfilepath. Search for bioware campaign variables with variablenameglob, copy all of those to newtablename."
	con = sqlite3.connect(dbfilepath)
	cur = con.cursor()
	
	# Make sure this sqlite3 database actually has a bioware database component
	# ... which is just a table named "db"
	res = cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='db';")
	if res.fetchone() is not None:
		# This has been set in all player DBs when they enter for a long long time
		res = cur.execute("SELECT payload FROM db where varname='player_name'")
		if res.fetchone() is not None:
			cur.execute(f"CREATE TABLE IF NOT EXISTS {newtablename} (var TEXT PRIMARY KEY, value TEXT);")
			cur.execute(f"CREATE INDEX IF NOT EXISTS idx_var ON {newtablename}(var);")	
			
			res = cur.execute(f"SELECT varname, vartype, payload, compressed FROM db WHERE varname GLOB '{variablenameglob}';")
			results = res.fetchall()
			for varname, vartype, payload, compressed in results:
				#print(varname, vartype, payload, compressed)
				if compressed:
					payload = decompress_compressedbuf(payload)
					
				newvarname = truncations.get(varname, varname)
					
				params = (newvarname, payload, payload)
				cur.execute(f"INSERT INTO {newtablename} (var, value) VALUES (?, ?) ON CONFLICT (var) DO UPDATE SET value = ?;", params)
				
				cur.execute(f"DELETE FROM db WHERE varname=?", [varname])
				if newvarname != varname:
					print(f"Migrated truncated {varname} -> {newvarname}")
				else:
					print(f"Migrated variable {varname}")
				
			con.commit()
			return
	print(f"{dbfilepath} seems not to have a bioware db table or isn't a player's cdkey db, ignored")
	
def main():
	# For now, this is what we want to do
	#dbpath = "../server/database"
	dbpath = "../database"
	dbs = os.listdir(dbpath)
	for item in dbs:
		if not item.endswith(".sqlite3"):
			continue
		realfp = os.path.join(dbpath, item)
		
		migratedb(realfp, "stat_*", "playerstats", stat_migration_variable_truncations)
		migratedb(realfp, "nui*", "nuiconfig")
		
if __name__ == "__main__":
	main()
	