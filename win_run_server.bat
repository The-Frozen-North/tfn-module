git pull

@echo off
echo.
echo Checking to see if there is a previous module. If prompted, type 'Y' to delete the current module and module folder.
echo If you are canceling, you can close the window and exit. nasher will not continue if there is a module file and folder.
echo It will automatically continue if you do not have module built (clean slate) 
echo.
echo WARNING: Continuing will rebuild the module from source, deleting all unsaved changes! Commit or stash your changes, or exit out.
@echo on

del .build\modules /S
rd .build\modules\TFN
rd .build\modules

md .build

rmdir /s /q  .build\override
robocopy override .build\override

rem Fetch a timestamp and commit hash from git, and append it to mod_desc.txt
rem This is more painful than it probably needed to be
FOR /F "tokens=* USEBACKQ" %%g IN (`git log -1 --format^=%%cd --date^=format:"%%d %%b %%y"`) do (SET "timestamp=%%g")
FOR /F "tokens=* USEBACKQ" %%g IN (`git rev-parse HEAD`) do (SET "hash=%%g")
set "hash=%hash:~,6%"


Setlocal EnableDelayedExpansion
set LF=^


rem THE TWO EMPTY LINES ABOVE ARE REQUIRED!
rem DO NOT REMOVE THE WHITESPACE IN THE NAME OF MAKING THE MODULE DESCRIPTION GET WRITTEN PROPERLY
set content=
for /f "delims=" %%x in ('type mod_desc.txt') do set "content=!content!%%x!LF!"
set "content=!content!Last Updated: %timestamp% (%hash%)"

endlocal

cd .build

"%CD%/../tools/win/nasher/nasher.exe" install  --verbose --erfUtil:"%CD%/../tools/win/neverwinter64/nwn_erf.exe" --gffUtil:"%CD%/../tools/win/neverwinter64/nwn_gff.exe" --tlkUtil:"%CD%/../tools/win/neverwinter64/nwn_tlk.exe" --nssCompiler:"%CD%/../tools/win/nwnsc/nwnsc.exe" --installDir:"%CD%" --nssFlags:"-oe -i ""%CD%/../nwn-base-scripts""" --no --modDescription "!content!"

cd ..

del /f server\config\common.env
del /f server\modules\TFN.mod
del /f server\database\spawns.sqlite3
del /f server\database\treasures.sqlite3
del /f server\database\randspellbooks.sqlite3
del /f server\database\prettify.sqlite3
del /f server\database\tmapsolutions.sqlite3
del /f server\database\areadistances.sqlite3
del /f server\settings.tml
rmdir /s /q  server\override
md server\modules
md server\database
md server\config
copy .build\modules\TFN.mod server\modules\TFN.mod
copy config\common.env server\config\common.env
copy settings.tml server\settings.tml

:: Delete existing databases, because sqlite will attempt to load it into an existing database instead of overwriting
del /f server\database\spawns.sqlite3
del /f server\database\treasures.sqlite3
del /f server\database\randspellbooks.sqlite3
del /f server\database\prettify.sqlite3
del /f server\database\tmapsolutions.sqlite3
del /f server\database\areadistances.sqlite3

"%CD%/tools/win/sqlite/sqlite3.exe" server/database/treasures.sqlite3 < seeded_database/treasures.txt
"%CD%/tools/win/sqlite/sqlite3.exe" server/database/tmapsolutions.sqlite3 < seeded_database/tmapsolutions.txt
"%CD%/tools/win/sqlite/sqlite3.exe" server/database/randspellbooks.sqlite3 < seeded_database/randspellbooks.txt
"%CD%/tools/win/sqlite/sqlite3.exe" server/database/prettify.sqlite3 < seeded_database/prettify.txt
"%CD%/tools/win/sqlite/sqlite3.exe" server/database/spawns.sqlite3 < seeded_database/spawns.txt
"%CD%/tools/win/sqlite/sqlite3.exe" server/database/areadistances.sqlite3 < seeded_database/areadistances.txt

robocopy override server\override

copy server\env\env.2da server\override\env.2da
copy server\env\env_dm.2da server\override\env_dm.2da

del /f .build\TFN.mod

cd server
docker-compose -f docker-compose.yml down 
docker-compose -f docker-compose.yml up --no-recreate -d

PAUSE
