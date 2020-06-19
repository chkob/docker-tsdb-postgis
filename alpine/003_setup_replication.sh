#!/bin/bash

set -e

POSTGRES_VERSION=$(postgres --version)

if [ "x$REPLICATE_FROM" == "x" ]; then # master

  echo initiating master... 
  echo modify postgresql configuration file at ${PGDATA}
  
  if [ -z "${POSTGRESQL_CONF_DIR:-}" ]; then
        POSTGRESQL_CONF_DIR=${PGDATA}
  fi
  
  sed -i -e '$ahost replication all all md5' "${POSTGRESQL_CONF_DIR}/pg_hba.conf"
  
  sed -i -e "s/#wal_level = replica/wal_level = hot_standby/g" "${POSTGRESQL_CONF_DIR}/postgresql.conf"
  sed -i -e "s/#max_wal_senders = 10/max_wal_senders = ${PG_MAX_WAL_SENDERS}/g" "${POSTGRESQL_CONF_DIR}/postgresql.conf"
  sed -i -e "s/#wal_keep_segments = 0/wal_keep_segments = ${PG_WAL_KEEP_SEGMENTS}/g" "${POSTGRESQL_CONF_DIR}/postgresql.conf"
  sed -i -e "s/#hot_standby = on/hot_standby = on/g" "${POSTGRESQL_CONF_DIR}/postgresql.conf"
  
  if echo $POSTGRES_VERSION | grep -e "^postgres (PostgreSQL) 9\."; then
    echo "Appending a specific configuration value for Postgres 9!.."
  sed -i -e "checkpoint_segments = ${PG_CHECKPOINT_SEGMENTS}" "${POSTGRESQL_CONF_DIR}/postgresql.conf"
  fi

else # slave

  echo initiating slave...
  echo create postgresql recovery configuration file at ${PGDATA}
  
  if [ -z "${POSTGRESQL_CONF_DIR:-}" ]; then
        POSTGRESQL_CONF_DIR=${PGDATA}
  fi
  
  sed -i -e '$ahost replication all all md5' "${POSTGRESQL_CONF_DIR}/pg_hba.conf"

  if echo $POSTGRES_VERSION | grep -e "^postgres (PostgreSQL) 12\."; then
    echo "I am Postgres 12!"
    echo "Making changes on ${POSTGRESQL_CONF_DIR}/postgresql.conf"
    CONNECTION_INFO="host="${REPLICATE_FROM}" port=5432 user="${POSTGRES_USER}" password="${POSTGRES_PASSWORD}
    # echo "$CONNECTION_INFO" 
    sed -i -e "s/#primary_conninfo = \'\'/primary_conninfo = \'${CONNECTION_INFO}\'/g" "${POSTGRESQL_CONF_DIR}/postgresql.conf"
    PROMOTE_TRIGER_PATH="\/tmp\/touch_me_to_promote_to_me_master"
    # echo "${PROMOTE_TRIGER_PATH}"
    sed -i -e "s/#promote_trigger_file = \'\'/promote_trigger_file = \'${PROMOTE_TRIGER_PATH}\'/g" "${POSTGRESQL_CONF_DIR}/postgresql.conf"	
  else
    echo "I am not Postgres 12!"
    echo "Making changes on ${POSTGRESQL_CONF_DIR}/recovery.conf"
  fi

  echo "I am going to replicate from $REPLICATE_FROM"

fi