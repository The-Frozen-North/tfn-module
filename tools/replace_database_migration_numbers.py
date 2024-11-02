import os

migration_schema_line = "INSERT INTO migrations VALUES('schema',1234567890);"
migration_other_line = "INSERT INTO migrations VALUES('20191203190521',1234567890);"

files = [
    'seeded_database/treasures.txt',
    'seeded_database/tmapsolutions.txt',
    'seeded_database/spawns.txt',
    'seeded_database/randspellbooks.txt',
    'seeded_database/prettify.txt',
    'seeded_database/areadistances.txt'
]

for file in files:
    if os.path.exists(file):
        with open(file, 'r') as f:
            content = f.readlines()
        
        updated_content = []
        for line in content:
            if line.startswith("INSERT INTO migrations VALUES('schema'"):
                updated_content.append(migration_schema_line + '\n')
            elif line.startswith("INSERT INTO migrations VALUES('20191203190521'"):
                updated_content.append(migration_other_line + '\n')
            else:
                updated_content.append(line)
        
        with open(file, 'w') as f:
            f.writelines(updated_content)
    else:
        print(f"File not found, could not update migration number: {file}")