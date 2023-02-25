#!/bin/bash
#
# tracker.sh jens heine <binbash@gmx.net>, andreas stoecker <a.stoecker@gmx.net>
#
#

DB_FILENAME='tracker.db'

cat /proc/net/arp | tail -n +2 | 
while read -r line; do 
  #echo "$line"
  line_array=($line)
  #echo "Array:  ${line_array[@]}"
  #echo "Array:  '${line_array[4]}'"
  #eval "${line_array[4]}"
  sqlite3 ${DB_FILENAME} "pragma synchronous=0"

  echo "insert into arpevent (UUID, IP, HW_TYPE, FLAGS, HW_ADDRESS, MASK, DEVICE) values ('`uuidgen`', '${line_array[0]}', '${line_array[1]}','${line_array[2]}','${line_array[3]}','*','dummy')"
  sqlcommand="insert into arpevent (UUID, IP, HW_TYPE, FLAGS, HW_ADDRESS, MASK, DEVICE) values ('`uuidgen`', '${line_array[1]}', '${line_array[1]}','${line_array[2]}','${line_array[3]}','*','dummy')"
  sqlite3 ${DB_FILENAME} "$sqlcommand"
done


