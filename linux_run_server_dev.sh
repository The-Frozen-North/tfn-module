#!/bin/bash

rm .build/docker-compose-dev.yml
cp docker-compose-dev.yml .build/docker-compose-dev.yml

rm .build/config/common.env
cp config/common.env .build/config/common.env

cd .build

docker-compose -f docker-compose-dev.yml down
docker-compose -f docker-compose-dev.yml up --no-recreate -d