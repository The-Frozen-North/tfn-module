#!/bin/bash

docker-compose -f docker-compose-macos-dev.yml down
docker-compose -f docker-compose-macos-dev.yml up --no-recreate -d
