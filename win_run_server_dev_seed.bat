del /f .build\database\prettify.sqlite3
del /f .build\database\tmapsolutions.sqlite3
del /f .build\database\areadistances.sqlite3

md .build\database
md .build\config

copy seeded_database\randspellbooks.sqlite3 .build\database\randspellbooks.sqlite3
copy seeded_database\prettify.sqlite3 .build\database\prettify.sqlite3
copy seeded_database\areadistances.sqlite3 .build\database\areadistances.sqlite3

del /f .build\docker-compose-dev-seed.yml
copy docker-compose-dev-seed.yml .build\docker-compose-dev-seed.yml

del /f .build\config\common.env
copy config\common.env .build\config\common.env

cd .build

docker-compose -f docker-compose-dev-seed.yml down
docker-compose -f docker-compose-dev-seed.yml up --no-recreate

del /f ..\seeded_database\spawns.sqlite3
del /f ..\seeded_database\treasures.sqlite3
del /f ..\seeded_database\randspellbooks.sqlite3
del /f ..\seeded_database\prettify.sqlite3
del /f ..\seeded_database\tmapsolutions.sqlite3
del /f ..\seeded_database\areadistances.sqlite3

copy database\tmapsolutions.sqlite3 ..\seeded_database\tmapsolutions.sqlite3
copy database\spawns.sqlite3 ..\seeded_database\spawns.sqlite3
copy database\treasures.sqlite3 ..\seeded_database\treasures.sqlite3
copy database\randspellbooks.sqlite3 ..\seeded_database\randspellbooks.sqlite3
copy database\prettify.sqlite3 ..\seeded_database\prettify.sqlite3
copy database\areadistances.sqlite3 ..\seeded_database\areadistances.sqlite3