# Driver Component

This repository hosts the code and documentation for the Driver team in the international
project with Ahola.

# Build and Deployment

## Initial Setup 

### Backend

The backend can be set up using the provided `docker-compose.yml` file in `./docker`:
  ```sh
  docker-compose --project-directory . -f ./docker/docker-compose.yml up -d --build
  ```
Alternatively it can be set up with the `setup_backed.sh` or `setup_backend.ps1` scripts.

## Troubleshooting

### Database

The database can be started independantly with the `./docker/database/docker-compose.yml` file.

If the database needs to be reset, or updated with a new table schema, the `setup_database.sh`
script can be used:

  ```sh
  ./scripts/setup_db.sh driver_database Driver Drivers ./database/init.sql
  ```

This drops the specified database, creates a new one with the same name
and executes the specified `.sql` file in it. See `setup_database.sh --help` for info.