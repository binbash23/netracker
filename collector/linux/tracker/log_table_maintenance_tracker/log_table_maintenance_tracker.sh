#!/bin/bash
#
# jens heine <binbash@gmx.net>, andreas stoecker <a.stoecker@gmx.net>
#
#
#set -x

#
# SOURCE LIBRARIES
#
. ../../collector.library

#
# VARIABLES
# 
DATABASE_FILENAME="../../${DATABASE_FILENAME}"
DB_CREATE_SCRIPT_FILENAME="create_tracker.sql"

#
# MAIN
#
if [ -z "${1}" ]; then
  COLLECTION_UUID=`uuidgen`
else
  COLLECTION_UUID="${1}"
fi

log $0 "Running $0" 3 ${COLLECTION_UUID}
  
LOG_TABLE_MAX_DAYS=`sqlite3 ${DATABASE_FILENAME} "select value from sys_config where property='LOG_TABLE_MAX_DAYS'"`

# Set default value to 0 (endless)
LOG_TABLE_MAX_DAYS=${LOG_TABLE_MAX_DAYS:-0}

if [ "${LOG_TABLE_MAX_DAYS}" == "0" ]; then
  log $0 "Deleting no log entries from log table because LOG_TABLE_MAX_DAYS is set to 0..." 4 ${COLLECTION_UUID}
else
  log $0 "Deleting log entries from log table older than ${LOG_TABLE_MAX_DAYS} days..." 4 ${COLLECTION_UUID}
  sqlite3 ${DATABASE_FILENAME} "delete from log where CREATE_DATE > CURRENT_DATE - ${LOG_TABLE_MAX_DAYS}"
fi

log $0 "Finished $0" 3 ${COLLECTION_UUID}

exit 0

