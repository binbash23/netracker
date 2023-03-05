#!/bin/bash
#
# tracker.sh jens heine <binbash@gmx.net>, andreas stoecker <a.stoecker@gmx.net>
#
#

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
  
# Create netevent table if not exists
sqlite3 ${DATABASE_FILENAME} < "$DB_CREATE_SCRIPT_FILENAME"

while read -a line_array; do 
  sqlcommand="insert into t_netevent (UUID, COLLECTION_UUID, INTERFACE, STATUS, IPV4) values ('`uuidgen`', '${COLLECTION_UUID}', '${line_array[0]}', '${line_array[1]}','${line_array[2]}')"
  log $0 "Found net entry INTERFACE:${line_array[0]}, STATUS: ${line_array[1]}" 4 ${COLLECTION_UUID}
  sqlite3 ${DATABASE_FILENAME} "$sqlcommand"
done < <(ip -br -f inet a)

log $0 "Finished $0" 3 ${COLLECTION_UUID}

exit 0

