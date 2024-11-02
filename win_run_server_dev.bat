del /f .build\database\spawns.sqlite3
del /f .build\database\treasures.sqlite3
del /f .build\database\randspellbooks.sqlite3
del /f .build\database\prettify.sqlite3
del /f .build\database\tmapsolutions.sqlite3
del /f .build\database\areadistances.sqlite3

md .build\database
md .build\config

copy seeded_database\tmapsolutions.sqlite3 .build\database\tmapsolutions.sqlite3
copy seeded_database\areadistances.sqlite3 .build\database\areadistances.sqlite3
copy seeded_database\spawns.sqlite3 .build\database\spawns.sqlite3
copy seeded_database\treasures.sqlite3 .build\database\treasures.sqlite3
copy seeded_database\randspellbooks.sqlite3 .build\database\randspellbooks.sqlite3
copy seeded_database\prettify.sqlite3 .build\database\prettify.sqlite3

del /f .build\docker-compose-dev.yml
copy docker-compose-dev.yml .build\docker-compose-dev.yml

del /f .build\config\common.env
copy config\common.env .build\config\common.env

cd .build

docker-compose -f docker-compose-dev.yml down
docker-compose -f docker-compose-dev.yml up --no-recreate -d