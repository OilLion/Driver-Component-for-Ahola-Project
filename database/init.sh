#!/bin/sh

createdb -U Driver 'Drivers'
psql -U Driver -d Drivers -f /database_setup/init.sql
psql -U Driver -d Drivers -f /database_setup/default_data.sql