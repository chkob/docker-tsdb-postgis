#!/bin/bash

set -e
set -u

function create_user_and_database() {
    local owner=$(echo $1 | tr '@' ' ' | awk  '{print $1}')
    local database=$(echo $1 | tr '@' ' ' | awk  '{print $2}')
    echo "  Creating user and database '$database' and add extensions also grant permission to '$owner'"
    local found_user=`echo "SELECT 1 FROM pg_roles WHERE rolname='${owner}';" | psql -qAt -d ${POSTGRES_USER}`
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        CREATE DATABASE ${database} 
          WITH 
          OWNER = ${POSTGRES_USER}
          ENCODING = 'UTF8'
          LC_COLLATE = 'en_US.utf8'
          LC_CTYPE = 'en_US.utf8'
          TABLESPACE = pg_default
          CONNECTION LIMIT = -1;
EOSQL

    # adding extensions
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d "$database" <<-EOSQL
      CREATE EXTENSION IF NOT EXISTS adminpack;
      CREATE EXTENSION IF NOT EXISTS hstore;
      CREATE EXTENSION IF NOT EXISTS btree_gist;
      CREATE EXTENSION IF NOT EXISTS pg_trgm;
      CREATE EXTENSION IF NOT EXISTS postgis;
      CREATE EXTENSION IF NOT EXISTS postgis_topology;
      CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
      CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL

    echo "found_user = '$found_user'"
    if [ "$found_user" = "1" ]; then
      psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        GRANT ALL PRIVILEGES ON DATABASE ${database} TO ${owner};
EOSQL
    else
      psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
      CREATE USER ${owner};
      GRANT ALL PRIVILEGES ON DATABASE ${database} TO ${owner};
EOSQL
    fi
}


    echo "Add extension to : '$POSTGRES_USER'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d "$POSTGRES_USER" <<-EOSQL
      CREATE EXTENSION IF NOT EXISTS adminpack;
      CREATE EXTENSION IF NOT EXISTS hstore;
      CREATE EXTENSION IF NOT EXISTS btree_gist;
      CREATE EXTENSION IF NOT EXISTS pg_trgm;
      CREATE EXTENSION IF NOT EXISTS postgis;
      CREATE EXTENSION IF NOT EXISTS postgis_topology;
      CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
      CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
    for user_db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
        create_user_and_database $user_db
    done
    echo "Multiple databases created"
fi
