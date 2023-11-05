#!/bin/sh

print_help () {
  printf "Script for replacing the database specified in DB_NAME with the\n%b\
database specified in the init.sql file in the SQL_INIT_DIR.\n"
  printf "Usage:\nupdate_sql.sh <CONTAINER_NAME> <USER_NAME> <DB_NAME> <SQL_INIT_FILE>\n"
  printf "Example:\nupdate_sql.sh driver_database Driver Drivers ./database/init.sql\n"
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
  docker exec $container touch sql_file.sql
  docker exec $container sh -c "echo '`cat $sql_dir/init.sql`' > sql_init.sql"
  docker cp $sql_dir $container:setup_files
  docker exec $container psql -U $user -d $database -f setup_files/init.sql
  docker exec $container psql -U $user -d $database -f setup_files/data.sql
  docker exec $container rm -rf setup_files
fi

