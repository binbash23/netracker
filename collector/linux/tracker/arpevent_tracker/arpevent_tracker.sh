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
DB_CREATE_SCRIPT_FILENAME="create_table_arpevent.sql"

#
# MAIN
#
log $0 "Running $0"

if [ -z "${1}" ]; then
  COLLECTION_UUID=`uuidgen`
else
  COLLECTION_UUID="${1}"
fi
  
# Create arpevent table if not exists
sqlite3 ${DATABASE_FILENAME} < "$DB_CREATE_SCRIPT_FILENAME"

while read -a line_array; do 
  #sqlite3 ${DATABASE_FILENAME} "pragma synchronous=0"
  sqlcommand="insert into arpevent (UUID, COLLECTION_UUID, IP, HW_TYPE, FLAGS, HW_ADDRESS, MASK, DEVICE) values ('`uuidgen`', '${COLLECTION_UUID}', '${line_array[0]}', '${line_array[1]}','${line_array[2]}','${line_array[3]}','${line_array[4]}','${line_array[5]}')"
  log $0 "Found arp entry IP:${line_array[0]}, MAC: ${line_array[3]}" 4
  sqlite3 ${DATABASE_FILENAME} "$sqlcommand"
done < <(tail -n +2 /proc/net/arp)

log $0 "Finished $0"

exit 0

