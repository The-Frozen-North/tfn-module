#!/bin/bash

docker-compose -f docker-compose-dev-seed.yml down
docker-compose -f docker-compose-dev-seed.yml up --no-recreate

rm seeded_database/randspellbooks.sqlite3
rm seeded_database/treasures.sqlite3
rm seeded_database/spawns.sqlite3
rm seeded_database/prettify.sqlite3
rm seeded_database/tmapsolutions.sqlite3

cp database/spawns.sqlite3 seeded_database/spawns.sqlite3
cp database/treasures.sqlite3 seeded_database/treasures.sqlite3
cp database/randspellbooks.sqlite3 seeded_database/randspellbooks.sqlite3
cp database/prettify.sqlite3 seeded_database/prettify.sqlite3
cp database/tmapsolutions.sqlite3 seeded_database/tmapsolutions.sqlite3