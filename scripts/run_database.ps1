docker-compose -f docker\database\docker-compose.yml up --build -d
Start-Sleep -Seconds 1
docker exec driver_database sh /database_setup/init.sh