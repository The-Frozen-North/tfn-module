del /f .build\docker-compose-dev.yml
copy docker-compose-dev.yml .build\docker-compose-dev.yml

del /f .build\config\common.env
copy config\common.env .build\config\common.env

cd .build

docker-compose -f docker-compose-dev.yml down
docker-compose -f docker-compose-dev.yml up --no-recreate -d