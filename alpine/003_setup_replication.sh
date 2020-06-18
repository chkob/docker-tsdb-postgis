#!/bin/bash

if [ "x$REPLICATE_FROM" == "x" ]; then # master

  echo initiating master... 
  echo modify postgresql configuration file at ${PGDATA}
  
  if [ -z "${POSTGRESQL_CONF_DIR:-}" ]; then
        POSTGRESQL_CONF_DIR=${PGDATA}
  fi
  
  sed -i -e '$ahost replication all all md5' "${POSTGRESQL_CONF_DIR}/pg_hba.conf"

else # slave

  echo initiating slave...
  echo create postgresql recovery configuration file at ${PGDATA}
  
  if [ -z "${POSTGRESQL_CONF_DIR:-}" ]; then
        POSTGRESQL_CONF_DIR=${PGDATA}
  fi
  
  sed -i -e '$ahost replication all all md5' "${POSTGRESQL_CONF_DIR}/pg_hba.conf"

fi