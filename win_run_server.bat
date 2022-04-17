git pull

git -C nwn-assets pull || git clone https://github.com/urothis/nwn-assets.git nwn-assets

%CD%/tools/win/nasher/nasher.exe install  --verbose --erfUtil:"%CD%/tools/win/neverwinter64/nwn_erf.exe" --gffUtil:"%CD%/tools/win/neverwinter64/nwn_gff.exe" --tlkUtil:"%CD%/tools/win/neverwinter64/nwn_tlk.exe" --nssCompiler:"%CD%/tools/win/nwnsc/nwnsc.exe" --installDir:"%CD%" --nssFlags:"-oe -i %CD%/nwn-assets/nwscript" --yes

del /f server\config\common.env
del /f server\modules\and_the_Wailing_Death.mod
del /f server\database\spawns.sqlite3
del /f server\database\treasures.sqlite3
del /f server\settings.tml
rmdir /s /q  server\override
copy modules\and_the_Wailing_Death.mod server\modules\and_the_Wailing_Death.mod
copy config\common.env server\config\common.env
copy settings.tml server\settings.tml
copy database\spawns.sqlite3 server\database\spawns.sqlite3
copy database\treasures.sqlite3 server\database\treasures.sqlite3
robocopy override server\override

cd server
docker-compose down 
docker-compose up --no-recreate -d
pause