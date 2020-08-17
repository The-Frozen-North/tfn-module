cd devserver
docker-compose -f docker-compose-dev-nt.yml down
docker-compose -f docker-compose-dev-nt.yml up --no-recreate -d