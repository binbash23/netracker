#!/bin/bash
#
# tracker.sh jens heine <binbash@gmx.net>, andreas stoecker <a.stoecker@gmx.net>
#
#

#
# Variables
# 
DB_FILENAME='tracker.db'

#
# Main
#
echo "Running $0"

cat /proc/net/arp | tail -n +2 | 
while read -r line; do 
  line_array=($line)
  sqlite3 ${DB_FILENAME} "pragma synchronous=0"
  sqlcommand="insert into arpevent (UUID, IP, HW_TYPE, FLAGS, HW_ADDRESS, MASK, DEVICE) values ('`uuidgen`', '${line_array[0]}', '${line_array[1]}','${line_array[2]}','${line_array[3]}','*','dummy')"
  #echo "$sqlcommand"
  echo -n .
  sqlite3 ${DB_FILENAME} "$sqlcommand"
done

echo 
echo Done

