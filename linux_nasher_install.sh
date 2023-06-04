#!/bin/bash

echo
echo "Checking to see if there is a previous module. If prompted, type 'Y' to delete the current module and module folder." 
echo "If you are canceling, you can close the window and exit. nasher will not continue if there is a module file and folder."
echo "It will automatically continue if you do not have module built (clean slate)" 
echo
echo "WARNING: Continuing will rebuild the module from source, deleting all unsaved changes! Commit or stash your changes, or exit out."

rm -d -RI modules
rm TFN.mod

$PWD/tools/linux/nasher/nasher install  --verbose --erfUtil:"$PWD/tools/linux/neverwinter/nwn_erf" --gffUtil:"$PWD/tools/linux/neverwinter/nwn_gff" --tlkUtil:"$PWD/tools/linux/neverwinter/nwn_tlk" --nssCompiler:"$PWD/tools/linux/nwnsc/nwnsc" --installDir:"$PWD" --nssFlags:"-oe -i $PWD/nwn-base-scripts" --no

rm TFN.mod