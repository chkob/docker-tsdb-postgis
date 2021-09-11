#!/bin/bash

set -e
set -u

function create_template_databases() {
    local database=$1
    echo "  Creating template database '$database' and also add extensions"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        CREATE DATABASE ${database} 
          WITH 
          OWNER = ${POSTGRES_USER}
          ENCODING = 'UTF8'
          LC_COLLATE = 'en_US.utf8'
          LC_CTYPE = 'en_US.utf8'
          TABLESPACE = pg_default
          CONNECTION LIMIT = -1
          IS_TEMPLATE true;
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

if [ -n "$POSTGRES_POSGIS_TEMPLATE_DATABASES" ]; then
    echo "Multiple database creation requested: $POSTGRES_POSGIS_TEMPLATE_DATABASES"
    for postgis_template_db in $(echo $POSTGRES_POSGIS_TEMPLATE_DATABASES | tr ',' ' '); do
        create_template_databases $postgis_template_db
    done
    echo "Multiple databases created"
fi
