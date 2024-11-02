#!/bin/bash

rm .build/database/prettify.sqlite3
rm .build/database/areadistances.sqlite3
rm .build/database/tmapsolutions.sqlite3

mkdir -p .build/database
mkdir -p .build/config

# Delete existing databases, because sqlite will attempt to load it into an existing database instead of overwriting
rm .build/database/spawns.sqlite3
rm .build/database/treasures.sqlite3
rm .build/database/randspellbooks.sqlite3
rm .build/database/prettify.sqlite3
rm .build/database/tmapsolutions.sqlite3
rm .build/database/areadistances.sqlite3

# These databases rely on previous information (checks existing and may skip recalculating some things so it's faster)
$PWD/tools/linux/sqlite/sqlite3 .build/database/treasures.sqlite3 < seeded_database/treasures.txt
$PWD/tools/linux/sqlite/sqlite3 .build/database/tmapsolutions.sqlite3 < seeded_database/tmapsolutions.txt
$PWD/tools/linux/sqlite/sqlite3 .build/database/randspellbooks.sqlite3 < seeded_database/randspellbooks.txt
$PWD/tools/linux/sqlite/sqlite3 .build/database/prettify.sqlite3 < seeded_database/prettify.txt
$PWD/tools/linux/sqlite/sqlite3 .build/database/areadistances.sqlite3 < seeded_database/areadistances.txt

rm .build/docker-compose-dev-seed.yml
cp docker-compose-dev-seed.yml .build/docker-compose-dev-seed.yml

rm .build\config\common.env
cp config/common.env .build/config/common.env

cd .build

docker-compose -f docker-compose-dev-seed.yml down
docker-compose -f docker-compose-dev-seed.yml up --no-recreate

# Delete existing database dumps, because we should always get the newly generated ones
rm ../seeded_database/spawns.txt
rm ../seeded_database/treasures.txt
rm ../seeded_database/randspellbooks.txt
rm ../seeded_database/prettify.txt
rm ../seeded_database/tmapsolutions.txt
rm ../seeded_database/areadistances.txt

$PWD/../tools/linux/sqlite/sqlite3 database/treasures.sqlite3 .dump > ../seeded_database/treasures.txt
$PWD/../tools/linux/sqlite/sqlite3 database/tmapsolutions.sqlite3 .dump > ../seeded_database/tmapsolutions.txt
$PWD/../tools/linux/sqlite/sqlite3 database/spawns.sqlite3 .dump > ../seeded_database/spawns.txt
$PWD/../tools/linux/sqlite/sqlite3 database/randspellbooks.sqlite3 .dump > ../seeded_database/randspellbooks.txt
$PWD/../tools/linux/sqlite/sqlite3 database/prettify.sqlite3 .dump > ../seeded_database/prettify.txt
$PWD/../tools/linux/sqlite/sqlite3 database/areadistances.sqlite3 .dump > ../seeded_database/areadistances.txt

python3 ../tools/replace_database_migration_numbers.py