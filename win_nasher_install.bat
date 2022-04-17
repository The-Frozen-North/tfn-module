git -C nwn-assets pull || git clone https://github.com/urothis/nwn-assets.git nwn-assets

%CD%/tools/win/nasher/nasher.exe install  --verbose --erfUtil:"%CD%/tools/win/neverwinter64/nwn_erf.exe" --gffUtil:"%CD%/tools/win/neverwinter64/nwn_gff.exe" --tlkUtil:"%CD%/tools/win/neverwinter64/nwn_tlk.exe" --nssCompiler:"%CD%/tools/win/nwnsc/nwnsc.exe" --installDir:"%CD%" --nssFlags:"-oe -i %CD%/nwn-assets/nwscript" --yes
PAUSE