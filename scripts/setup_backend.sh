#! /bin/sh
 
docker-compose --project-directory . -f ./docker/docker-compose.yml up -d --build
