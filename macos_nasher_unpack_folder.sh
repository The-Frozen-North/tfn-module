#!/bin/bash

$PWD/tools/macos_arm64/nasher/nasher unpack --file:modules/TFN --removeDeleted --erfUtil:"$PWD/tools/macos_arm64/neverwinter/nwn_erf" --gffUtil:"$PWD/tools/macos_arm64/neverwinter/nwn_gff" --tlkUtil:"$PWD/tools/macos_arm64/neverwinter/nwn_tlk" --nssFlags:"-l"
git rm --cached src -r
git add .