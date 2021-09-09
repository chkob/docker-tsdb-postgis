#!/bin/bash

set -e
set -u

if [[ -z ${POSTGRESQL_CONF_DIR:-} ]]; then
      POSTGRESQL_CONF_DIR=${PGDATA}
fi

if [[ -n $TIME_ZONE ]]; then
  DEFAULT_TIME_DB=${TIME_ZONE}
  echo "Set database default timezone to ${DEFAULT_TIME_DB}"
  sed -i -e "s~log_timezone = \'UTC\'~log_timezone = \'${DEFAULT_TIME_DB}\'~g" "${POSTGRESQL_CONF_DIR}/postgresql.conf"
  sed -i -e "s~timezone = \'UTC\'~timezone = \'${DEFAULT_TIME_DB}\'~g" "${POSTGRESQL_CONF_DIR}/postgresql.conf"
fi
