#!/bin/bash

rm database/randspellbooks.sqlite3
rm database/treasures.sqlite3
rm database/spawns.sqlite3
rm database/prettify.sqlite3
rm database/tmapsolutions.sqlite3
rm database/areadistances.sqlite3

cp seeded_database/spawns.sqlite3 database/spawns.sqlite3
cp seeded_database/treasures.sqlite3 database/treasures.sqlite3
cp seeded_database/randspellbooks.sqlite3 database/randspellbooks.sqlite3
cp seeded_database/prettify.sqlite3 database/prettify.sqlite3
cp seeded_database/tmapsolutions.sqlite3 database/tmapsolutions.sqlite3
cp seeded_database/areadistances.sqlite3 database/areadistances.sqlite3

docker-compose -f docker-compose-dev.yml down
docker-compose -f docker-compose-dev.yml up --no-recreate -d