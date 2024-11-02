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

md .build\database
md .build\movies
md .build\modules

:: Delete existing databases, because sqlite will attempt to load it into an existing database instead of overwriting
del /f .build\database\spawns.sqlite3
del /f .build\database\treasures.sqlite3
del /f .build\database\randspellbooks.sqlite3
del /f .build\database\prettify.sqlite3
del /f .build\database\tmapsolutions.sqlite3
del /f .build\database\areadistances.sqlite3

"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/treasures.sqlite3 < seeded_database/treasures.txt
"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/tmapsolutions.sqlite3 < seeded_database/tmapsolutions.txt
"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/randspellbooks.sqlite3 < seeded_database/randspellbooks.txt
"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/prettify.sqlite3 < seeded_database/prettify.txt
"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/spawns.sqlite3 < seeded_database/spawns.txt
"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/areadistances.sqlite3 < seeded_database/areadistances.txt

copy movies\prelude.wbm .build\movies\prelude.wbm
copy nasher.cfg .build\nasher.cfg

del /f TFN.mod

cd .build

"%CD%/../tools/win/nasher/nasher.exe" install  --verbose --erfUtil:"%CD%/../tools/win/neverwinter64/nwn_erf.exe" --gffUtil:"%CD%/../tools/win/neverwinter64/nwn_gff.exe" --tlkUtil:"%CD%/../tools/win/neverwinter64/nwn_tlk.exe" --nssCompiler:"%CD%/../tools/win/nwnsc/nwnsc.exe" --installDir:"%CD%" --nssFlags:"-oe -i ""%CD%/../nwn-base-scripts""" --no --clean

del /f TFN.mod
pause
