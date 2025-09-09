#!/bin/bash

docker-compose -f docker-compose-macos-dev-seed.yml down
docker-compose -f docker-compose-macos-dev-seed.yml up --no-recreate