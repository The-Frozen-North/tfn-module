#!/bin/bash

git pull

echo
echo "Checking to see if there is a previous module. If prompted, type 'Y' to delete the current module and module folder, or 'N' to cancel." 
echo "If you are canceling, you can close the window and exit. nasher will not continue if there is a module file and folder."
echo "It will automatically continue if you do not have module built (clean slate)" 
echo
echo "WARNING: 'Y' will delete all unsaved changes! Commit or stash them before continuing."

rm -d -RI modules
rm TFN.mod

$PWD/tools/macos_arm64/nasher/nasher install --erfUtil:"$PWD/tools/macos_arm64/neverwinter/nwn_erf" --gffUtil:"$PWD/tools/macos_arm64/neverwinter/nwn_gff" --tlkUtil:"$PWD/tools/macos_arm64/neverwinter/nwn_tlk" --nssCompiler:"$PWD/tools/macos_arm64/nwnsc/nwnsc" --installDir:"$PWD" --nssFlags:"-oe -i $PWD/nwn-base-scripts" --no

rm server/config/common.env
rm server/modules/TFN.mod
rm server/database/spawns.sqlite3
rm server/database/treasures.sqlite3
rm server/database/randspellbooks.sqlite3
rm server/settings.tml
rm -d -R  server/override

mkdir server/override
mkdir server/config
mkdir server/modules

cp modules/TFN.mod server/modules/TFN.mod
cp config/common.env server/config/common.env
cp settings.tml server/settings.tml
cp database/spawns.sqlite3 server/database/spawns.sqlite3
cp database/treasures.sqlite3 server/database/treasures.sqlite3
cp database/treasures.sqlite3 server/database/randspellbooks.sqlite3
cp -r override/. server/override

cp server/env/env.2da server/override/env.2da
cp server/env/env_dm.2da server/override/env_dm.2da

rm TFN.mod

cd server
docker-compose -f docker-compose-macos.yml down 
docker-compose -f docker-compose-macos.yml up --no-recreate -d
