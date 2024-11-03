#!/bin/bash

git pull

echo
echo "Checking to see if there is a previous module. If prompted, type 'Y' to delete the current module and module folder."
echo "If you are canceling, you can close the window and exit. nasher will not continue if there is a module file and folder."
echo "It will automatically continue if you do not have module built (clean slate)" 
echo
echo "WARNING: Continuing will rebuild the module from source, deleting all unsaved changes! Commit or stash your changes, or exit out."

rm -d -RI .build\modules

mkdir -p .build
mkdir -p .build/override

rm -rf .build/override
cp -r override/. .build/override/

desc=`cat mod_desc.txt`
timestamp=`git log -1 --format=%cd --date=format:"%d %b %y"`
hash=`git rev-parse HEAD`
hash=${hash:0:6}
desc="$desc
Last Updated: $timestamp ($hash)"

$PWD/tools/linux/nasher/nasher install --clean --erfUtil:"$PWD/tools/linux/neverwinter/nwn_erf" --gffUtil:"$PWD/tools/linux/neverwinter/nwn_gff" --tlkUtil:"$PWD/tools/linux/neverwinter/nwn_tlk" --nssCompiler:"$PWD/tools/linux/nwnsc/nwnsc" --installDir:"$PWD/.build" --nssFlags:"-oe -i $PWD/nwn-base-scripts" --no --modDescription="$desc"

if [[ ! -f .build/modules/TFN.mod ]] ; then
    echo 'Module does not exist, aborting.'
    exit
fi

# rm server/config/common.env
rm server/modules/TFN.mod
rm -d -R  server/override

mkdir server/override
mkdir server/config
mkdir server/modules
mkdir server/database

cp .build/modules/TFN.mod server/modules/TFN.mod
cp config/common.env server/config/common.env
cp -r override/. server/override

# Delete existing databases
rm server/database/spawns.sqlite3
rm server/database/treasures.sqlite3
rm server/database/randspellbooks.sqlite3
rm server/database/prettify.sqlite3
rm server/database/tmapsolutions.sqlite3
rm server/database/areadistances.sqlite3

$PWD/tools/linux/sqlite/sqlite3 server/database/treasures.sqlite3 < seeded_database/treasures.txt
$PWD/tools/linux/sqlite/sqlite3 server/database/tmapsolutions.sqlite3 < seeded_database/tmapsolutions.txt
$PWD/tools/linux/sqlite/sqlite3 server/database/randspellbooks.sqlite3 < seeded_database/randspellbooks.txt
$PWD/tools/linux/sqlite/sqlite3 server/database/prettify.sqlite3 < seeded_database/prettify.txt
$PWD/tools/linux/sqlite/sqlite3 server/database/spawns.sqlite3 < seeded_database/spawns.txt
$PWD/tools/linux/sqlite/sqlite3 server/database/areadistances.sqlite3 < seeded_database/areadistances.txt

cp server/env/env.2da server/override/env.2da
cp server/env/env_dm.2da server/override/env_dm.2da

cd server
docker-compose down 
docker-compose up --no-recreate -d
