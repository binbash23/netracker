#!/bin/bash
#
# jens heine <binbash@gmx.net>, andreas stoecker <a.stoecker@gmx.net>
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
DB_CREATE_SCRIPT_FILENAME="create_table_hostevent.sql"

#
# MAIN
#
if [ -z "${1}" ]; then
  COLLECTION_UUID=`uuidgen`
else
  COLLECTION_UUID="${1}"
fi

log $0 "Running $0" 3 ${COLLECTION_UUID}
  
# Create neccessary table(s) if not exist
sqlite3 ${DATABASE_FILENAME} < "$DB_CREATE_SCRIPT_FILENAME"

while read -a line_array; do 
  sqlcommand="insert into hostevent (UUID, COLLECTION_UUID, IP, DNS_NAME, STATUS) values ('`uuidgen`', '${COLLECTION_UUID}', '${line_array[1]}', '${line_array[2]}','${line_array[4]}')"
  log $0 "Found host entry IP:${line_array[0]}, DNS_NAME: ${line_array[1]}" 4 ${COLLECTION_UUID}
  sqlite3 ${DATABASE_FILENAME} "$sqlcommand"
done < <(nmap 192.168.1.0/24 -sn -oG -|grep -v '#')

log $0 "Finished $0" 3 ${COLLECTION_UUID}

exit 0

