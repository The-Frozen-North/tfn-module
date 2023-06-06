#!/bin/bash

docker-compose -f docker-compose-dev-seed.yml down
docker-compose -f docker-compose-dev-seed.yml up --no-recreate

rm database/randspellbooks.sqlite3
rm database/treasures.sqlite3
rm database/spawns.sqlite3
rm database/prettify.sqlite3
rm database/tmapsolutions.sqlite3

cp seeded_database/spawns.sqlite3 database/spawns.sqlite3
cp seeded_database/treasures.sqlite3 database/treasures.sqlite3
cp seeded_database/randspellbooks.sqlite3 database/randspellbooks.sqlite3
cp seeded_database/prettify.sqlite3 database/prettify.sqlite3
cp seeded_database/tmapsolutions.sqlite3 database/tmapsolutions.sqlite3