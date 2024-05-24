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

copy seeded_database\tmapsolutions.sqlite3 .build\database\tmapsolutions.sqlite3
copy seeded_database\areadistances.sqlite3 .build\database\areadistances.sqlite3
copy seeded_database\spawns.sqlite3 .build\database\spawns.sqlite3
copy seeded_database\treasures.sqlite3 .build\database\treasures.sqlite3
copy seeded_database\randspellbooks.sqlite3 .build\database\randspellbooks.sqlite3
copy seeded_database\prettify.sqlite3 .build\database\prettify.sqlite3
copy movies\prelude.wbm .build\movies\prelude.wbm
copy nasher.cfg .build\nasher.cfg

del /f TFN.mod

cd .build

"%CD%/../tools/win/nasher/nasher.exe" install  --verbose --erfUtil:"%CD%/../tools/win/neverwinter64/nwn_erf.exe" --gffUtil:"%CD%/../tools/win/neverwinter64/nwn_gff.exe" --tlkUtil:"%CD%/../tools/win/neverwinter64/nwn_tlk.exe" --nssCompiler:"%CD%/../tools/win/nwnsc/nwnsc.exe" --installDir:"%CD%" --nssFlags:"-oe -i ""%CD%/../nwn-base-scripts""" --no --clean

del /f TFN.mod
pause
