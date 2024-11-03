#!/bin/bash

echo
echo "Checking to see if there is a previous module. If prompted, type 'Y' to delete the current module and module folder." 
echo "If you are canceling, you can close the window and exit. nasher will not continue if there is a module file and folder."
echo "It will automatically continue if you do not have module built (clean slate)" 
echo
echo "WARNING: Continuing will rebuild the module from source, deleting all unsaved changes! Commit or stash your changes, or exit out."

rm -rf .build/modules

mkdir -p .build

rm -rf .build/override
cp -r override .build/override

mkdir -p .build/database
mkdir -p .build/movies
mkdir -p .build/modules
mkdir -p .build/config

rm .build/docker-compose-dev.yml
cp docker-compose-dev.yml .build/docker-compose-dev.yml

rm .build/docker-compose-dev-seed.yml
cp docker-compose-dev-seed.yml .build/docker-compose-dev-seed.yml

rm .build/config/common.env
cp config/common.env .build/config/common.env

# Delete existing databases
rm .build/database/spawns.sqlite3
rm .build/database/treasures.sqlite3
rm .build/database/randspellbooks.sqlite3
rm .build/database/prettify.sqlite3
rm .build/database/tmapsolutions.sqlite3
rm .build/database/areadistances.sqlite3

$PWD/tools/linux/sqlite/sqlite3 .build/database/treasures.sqlite3 < seeded_database/treasures.txt
$PWD/tools/linux/sqlite/sqlite3 .build/database/tmapsolutions.sqlite3 < seeded_database/tmapsolutions.txt
$PWD/tools/linux/sqlite/sqlite3 .build/database/randspellbooks.sqlite3 < seeded_database/randspellbooks.txt
$PWD/tools/linux/sqlite/sqlite3 .build/database/prettify.sqlite3 < seeded_database/prettify.txt
$PWD/tools/linux/sqlite/sqlite3 .build/database/spawns.sqlite3 < seeded_database/spawns.txt
$PWD/tools/linux/sqlite/sqlite3 .build/database/areadistances.sqlite3 < seeded_database/areadistances.txt

cp movies/prelude.wbm .build/movies/prelude.wbm

$PWD/tools/linux/nasher/nasher install  --verbose --erfUtil:"$PWD/tools/linux/neverwinter/nwn_erf" --gffUtil:"$PWD/tools/linux/neverwinter/nwn_gff" --tlkUtil:"$PWD/tools/linux/neverwinter/nwn_tlk" --nssCompiler:"$PWD/tools/linux/nwnsc/nwnsc" --installDir:"$PWD/.build" --nssFlags:"-oe -i $PWD/nwn-base-scripts" --yes
