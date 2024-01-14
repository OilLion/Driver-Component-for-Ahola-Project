#!/bin/sh

print_help () {
  printf "Script for setting up the database specified in DB_NAME with the scripts is the specified directory SQL_FILE_DIR.\n"
  printf "\033[1;37m\033[4;37mUsage:\n\033[0m    update_sql.sh <CONTAINER_NAME> <USER_NAME> <DB_NAME> <SQL_FILE_DIR>\n"
  printf "\033[1;37m\033[4;37mExample:\n\033[0m    update_sql.sh driver_database Driver Drivers ./database/init.sql\n"
}

if [[ "$1" = "--help" || "$#" -ne "4" ]]; then
  print_help
else
  container=$1;
  user=$2;
  database=$3;
  sql_dir=$4;

  docker exec $container dropdb -f -U $user $database
  docker exec $container createdb -U $user $database
  docker cp $sql_dir $container:setup_files
  docker exec $container psql -U $user -d $database -f setup_files/init.sql
  docker exec $container psql -U $user -d $database -f setup_files/data.sql
  docker exec $container psql -U $user -d $database -f setup_files/proc.sql
  docker exec $container rm -rf setup_files
fi

