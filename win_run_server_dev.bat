del /f database\spawns.sqlite3
del /f database\treasures.sqlite3
del /f database\randspellbooks.sqlite3
del /f database\prettify.sqlite3
del /f database\tmapsolutions.sqlite3

copy seeded_database\tmapsolutions.sqlite3 database\tmapsolutions.sqlite3
copy seeded_database\spawns.sqlite3 database\spawns.sqlite3
copy seeded_database\treasures.sqlite3 database\treasures.sqlite3
copy seeded_database\randspellbooks.sqlite3 database\randspellbooks.sqlite3
copy seeded_database\prettify.sqlite3 database\prettify.sqlite3

docker-compose -f docker-compose-dev.yml down
docker-compose -f docker-compose-dev.yml up --no-recreate -d