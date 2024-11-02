@echo off
setlocal

:: Capture start time
for /F "tokens=1-3 delims=:." %%a in ("%TIME%") do (
    set "START_HOUR=%%a"
    set "START_MINUTE=%%b"
    set "START_SECOND=%%c"
)

del /f .build\database\prettify.sqlite3
del /f .build\database\tmapsolutions.sqlite3
del /f .build\database\areadistances.sqlite3

md .build\database
md .build\config

:: Delete existing databases, because sqlite will attempt to load it into an existing database instead of overwriting
del /f .build\database\spawns.sqlite3
del /f .build\database\treasures.sqlite3
del /f .build\database\randspellbooks.sqlite3
del /f .build\database\prettify.sqlite3
del /f .build\database\tmapsolutions.sqlite3
del /f .build\database\areadistances.sqlite3

:: These databases rely on previous information (checks existing and may skip recalculating some things so it's faster)
"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/treasures.sqlite3 < seeded_database/treasures.txt
"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/tmapsolutions.sqlite3 < seeded_database/tmapsolutions.txt
"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/randspellbooks.sqlite3 < seeded_database/randspellbooks.txt
"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/prettify.sqlite3 < seeded_database/prettify.txt
"%CD%/tools/win/sqlite/sqlite3.exe" .build/database/areadistances.sqlite3 < seeded_database/areadistances.txt

del /f .build\docker-compose-dev-seed.yml
copy docker-compose-dev-seed.yml .build\docker-compose-dev-seed.yml

del /f .build\config\common.env
copy config\common.env .build\config\common.env

cd .build

docker-compose -f docker-compose-dev-seed.yml down
docker-compose -f docker-compose-dev-seed.yml up --no-recreate

:: Delete existing database dumps, because we should always get the newly generated ones
del /f ..\seeded_database\spawns.txt
del /f ..\seeded_database\treasures.txt
del /f ..\seeded_database\randspellbooks.txt
del /f ..\seeded_database\prettify.txt
del /f ..\seeded_database\tmapsolutions.txt
del /f ..\seeded_database\areadistances.txt

"%CD%/../tools/win/sqlite/sqlite3.exe" database/treasures.sqlite3 .dump > ../seeded_database/treasures.txt
"%CD%/../tools/win/sqlite/sqlite3.exe" database/tmapsolutions.sqlite3 .dump > ../seeded_database/tmapsolutions.txt
"%CD%/../tools/win/sqlite/sqlite3.exe" database/spawns.sqlite3 .dump > ../seeded_database/spawns.txt
"%CD%/../tools/win/sqlite/sqlite3.exe" database/randspellbooks.sqlite3 .dump > ../seeded_database/randspellbooks.txt
"%CD%/../tools/win/sqlite/sqlite3.exe" database/prettify.sqlite3 .dump > ../seeded_database/prettify.txt
"%CD%/../tools/win/sqlite/sqlite3.exe" database/areadistances.sqlite3 .dump > ../seeded_database/areadistances.txt

python ../tools/replace_database_migration_numbers.py

for /F "tokens=1-3 delims=:." %%a in ("%TIME%") do (
    set "END_HOUR=%%a"
    set "END_MINUTE=%%b"
    set "END_SECOND=%%c"
)

call :TimeDiff
PAUSE

exit /b

:TimeDiff
setlocal
set /A "START_TOTAL_SECONDS=START_HOUR*3600 + START_MINUTE*60 + START_SECOND"
set /A "END_TOTAL_SECONDS=END_HOUR*3600 + END_MINUTE*60 + END_SECOND"

set /A "DIFF=END_TOTAL_SECONDS-START_TOTAL_SECONDS"
if %DIFF% lss 0 (
    set /A "DIFF+=86400"  :: Adjust for negative difference (e.g., if crossing midnight)
)

set /A "HOURS=DIFF/3600"
set /A "MINUTES=(DIFF%%3600)/60"
set /A "SECONDS=DIFF%%60"

echo Total execution time: %HOURS% hours, %MINUTES% minutes, %SECONDS% seconds.
endlocal
exit /b