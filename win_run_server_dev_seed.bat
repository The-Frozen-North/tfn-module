docker-compose -f docker-compose-dev-seed.yml down
docker-compose -f docker-compose-dev-seed.yml up --no-recreate

del /f seeded_database\spawns.sqlite3
del /f seeded_database\treasures.sqlite3
del /f seeded_database\randspellbooks.sqlite3
del /f seeded_database\prettify.sqlite3
del /f seeded_database\tmapsolutions.sqlite3
del /f seeded_database\areadistances.sqlite3

copy database\tmapsolutions.sqlite3 seeded_database\tmapsolutions.sqlite3
copy database\spawns.sqlite3 seeded_database\spawns.sqlite3
copy database\treasures.sqlite3 seeded_database\treasures.sqlite3
copy database\randspellbooks.sqlite3 seeded_database\randspellbooks.sqlite3
copy database\prettify.sqlite3 seeded_database\prettify.sqlite3
copy database\areadistances.sqlite3 seeded_database\areadistances.sqlite3