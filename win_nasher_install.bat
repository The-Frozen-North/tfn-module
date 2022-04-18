git -C nwn-assets pull || git clone https://github.com/urothis/nwn-assets.git nwn-assets

del modules /S
rd modules\and_the_Wailing_Death
rd modules

del /f and_the_Wailing_Death.mod

%CD%/tools/win/nasher/nasher.exe install  --verbose --erfUtil:"%CD%/tools/win/neverwinter64/nwn_erf.exe" --gffUtil:"%CD%/tools/win/neverwinter64/nwn_gff.exe" --tlkUtil:"%CD%/tools/win/neverwinter64/nwn_tlk.exe" --nssCompiler:"%CD%/tools/win/nwnsc/nwnsc.exe" --installDir:"%CD%" --nssFlags:"-oe -i %CD%/nwn-assets/nwscript" --no

del /f and_the_Wailing_Death.mod

PAUSE