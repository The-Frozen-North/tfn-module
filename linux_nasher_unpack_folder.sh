#!/bin/bash

$PWD/tools/linux/nasher/nasher unpack --file:modules/TFN --removeDeleted --erfUtil:"$PWD/tools/linux/neverwinter/nwn_erf" --gffUtil:"$PWD/tools/linux/neverwinter/nwn_gff" --tlkUtil:"$PWD/tools/linux/neverwinter/nwn_tlk" --nssFlags:"-l"
git rm --cached src -r
git add .