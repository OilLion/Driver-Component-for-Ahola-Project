#!/bin/sh

docker-compose -f docker/database/docker-compose.yml up --build -d
sleep 1
docker exec driver_database /database_setup/init.sh 
