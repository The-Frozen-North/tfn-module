#!/bin/bash

git pull

echo
echo "Checking to see if there is a previous module. If prompted, type 'Y' to delete the current module and module folder."
echo "If you are canceling, you can close the window and exit. nasher will not continue if there is a module file and folder."
echo "It will automatically continue if you do not have module built (clean slate)" 
echo
echo "WARNING: Continuing will rebuild the module from source, deleting all unsaved changes! Commit or stash your changes, or exit out."

rm -d -RI modules
rm TFN.mod

desc=`cat mod_desc.txt`
timestamp=`git log -1 --format=%cd --date=format:"%d %b %y"`
hash=`git rev-parse HEAD`
hash=${hash:0:6}
desc="$desc
Last Updated: $timestamp ($hash)"

$PWD/tools/linux/nasher/nasher install --clean --erfUtil:"$PWD/tools/linux/neverwinter/nwn_erf" --gffUtil:"$PWD/tools/linux/neverwinter/nwn_gff" --tlkUtil:"$PWD/tools/linux/neverwinter/nwn_tlk" --nssCompiler:"$PWD/tools/linux/nwnsc/nwnsc" --installDir:"$PWD" --nssFlags:"-oe -i $PWD/nwn-base-scripts" --no --modDescription="$desc"

if [[ ! -f TFN.mod ]] ; then
    echo 'Module does not exist, aborting.'
    exit
fi

# rm server/config/common.env
rm server/modules/TFN.mod
rm -d -R  server/override
rm server/database/randspellbooks.sqlite3
rm server/database/treasures.sqlite3
rm server/database/spawns.sqlite3
rm server/database/prettify.sqlite3
rm server/database/tmapsolutions.sqlite3
rm server/database/areadistances.sqlite3

mkdir server/override
mkdir server/config
mkdir server/modules

cp modules/TFN.mod server/modules/TFN.mod
cp config/common.env server/config/common.env
cp -r override/. server/override

cp seeded_database/spawns.sqlite3 server/database/spawns.sqlite3
cp seeded_database/treasures.sqlite3 server/database/treasures.sqlite3
cp seeded_database/randspellbooks.sqlite3 server/database/randspellbooks.sqlite3
cp seeded_database/prettify.sqlite3 server/database/prettify.sqlite3
cp seeded_database/tmapsolutions.sqlite3 server/database/tmapsolutions.sqlite3
cp seeded_database/areadistances.sqlite3 server/database/areadistances.sqlite3

cp server/env/env.2da server/override/env.2da
cp server/env/env_dm.2da server/override/env_dm.2da

rm TFN.mod

cd server
docker-compose down 
docker-compose up --no-recreate -d
