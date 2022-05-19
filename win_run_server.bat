git pull

git -C nwn-assets pull || git clone https://github.com/urothis/nwn-assets.git nwn-assets

@echo off
echo.
echo Checking to see if there is a previous module. If prompted, type 'Y' to delete the current module and module folder, or 'N' to cancel. 
echo If you are canceling, you can close the window and exit. nasher will not continue if there is a module file and folder.
echo It will automatically continue if you do not have module built (clean slate) 
echo.
echo WARNING: 'Y' will delete all unsaved changes! Commit or stash them before continuing.
@echo on

del modules /S
rd modules\TFN
rd modules

del /f TFN.mod

%CD%/tools/win/nasher/nasher.exe install  --verbose --erfUtil:"%CD%/tools/win/neverwinter64/nwn_erf.exe" --gffUtil:"%CD%/tools/win/neverwinter64/nwn_gff.exe" --tlkUtil:"%CD%/tools/win/neverwinter64/nwn_tlk.exe" --nssCompiler:"%CD%/tools/win/nwnsc/nwnsc.exe" --installDir:"%CD%" --nssFlags:"-oe -i %CD%/nwn-base-scripts" --no

del /f server\config\common.env
del /f server\modules\TFN.mod
del /f server\database\spawns.sqlite3
del /f server\database\treasures.sqlite3
del /f server\settings.tml
rmdir /s /q  server\override
copy modules\TFN.mod server\modules\TFN.mod
copy config\common.env server\config\common.env
copy settings.tml server\settings.tml
copy database\spawns.sqlite3 server\database\spawns.sqlite3
copy database\treasures.sqlite3 server\database\treasures.sqlite3
copy database\treasures.sqlite3 server\database\treasures.sqlite3
robocopy override server\override

copy server\env\env.2da server\override\env.2da
copy server\env\env_dm.2da server\override\env_dm.2da

del /f TFN.mod

cd server
docker-compose down 
docker-compose up --no-recreate -d
pause