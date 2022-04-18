#!/bin/bash

git pull

git -C nwn-assets pull || git clone https://github.com/urothis/nwn-assets.git nwn-assets

echo
echo "Checking to see if there is a previous module. If prompted, type 'Y' to delete the current module and module folder, or 'N' to cancel." 
echo "If you are canceling, you can close the window and exit. nasher will not continue if there is a module file and folder."
echo "It will automatically continue if you do not have module built (clean slate)" 
echo
echo "WARNING: 'Y' will delete all unsaved changes! Commit or stash them before continuing."

rm -d -RI modules
rm and_the_Wailing_Death.mod

$PWD/tools/linux/nasher/nasher install --erfUtil:"$PWD/tools/linux/neverwinter/nwn_erf" --gffUtil:"$PWD/tools/linux/neverwinter/nwn_gff" --tlkUtil:"$PWD/tools/linux/neverwinter/nwn_tlk" --nssCompiler:"$PWD/tools/linux/nwnsc/nwnsc" --installDir:"$PWD" --nssFlags:"-oe -i $PWD/nwn-assets/nwscript" --no

rm server/config/common.env
rm server/modules/and_the_Wailing_Death.mod
rm server/database/spawns.sqlite3
rm server/database/treasures.sqlite3
rm server/settings.tml
rm -d -R  server/override
cp modules/and_the_Wailing_Death.mod server/modules/and_the_Wailing_Death.mod
cp config/common.env server/config/common.env
cp settings.tml server/settings.tml
cp database/spawns.sqlite3 server/database/spawns.sqlite3
cp database/treasures.sqlite3 server/database/treasures.sqlite3
cp override/. server/override

cp server/env/env.2da server/override/env.2da
cp server/env/env_dm.2da server/override/env_dm.2da

rm and_the_Wailing_Death.mod

cd server
docker-compose down 
docker-compose up --no-recreate -d