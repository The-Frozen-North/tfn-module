#!/bin/bash

echo
echo "Checking to see if there is a previous module. If prompted, type 'Y' to delete the current module and module folder, or 'N' to cancel." 
echo "If you are canceling, you can close the window and exit. nasher will not continue if there is a module file and folder."
echo "It will automatically continue if you do not have module built (clean slate)" 
echo
echo "WARNING: 'Y' will delete all unsaved changes! Commit or stash them before continuing."

rm -d -RI modules
rm TFN.mod

$PWD/tools/macos_arm64/nasher/nasher install  --verbose --erfUtil:"$PWD/tools/macos_arm64/neverwinter/nwn_erf" --gffUtil:"$PWD/tools/macos_arm64/neverwinter/nwn_gff" --tlkUtil:"$PWD/tools/macos_arm64/neverwinter/nwn_tlk" --nssCompiler:"$PWD/tools/macos_arm64/nwnsc/nwnsc" --installDir:"$PWD" --nssFlags:"-oe -i $PWD/nwn-base-scripts" --no

rm TFN.mod