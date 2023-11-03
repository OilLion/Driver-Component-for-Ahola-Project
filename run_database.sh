#!/bin/sh

docker-compose -f docker-compose.yml up -d
docker exec driver_database /database_setup/init.sh