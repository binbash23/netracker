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
  
# Create neccessary table(s) if not exist
sqlite3 ${DATABASE_FILENAME} < "$DB_CREATE_SCRIPT_FILENAME"

# collect available networks from t_netevent table if exists
available_networks_array=(`sqlite3 ${DATABASE_FILENAME} "select distinct ipv4 from t_netevent where STATUS='UP' and CREATE_DATE=(select max(CREATE_DATE) from t_netevent)"`)
#available_networks_array=(`sqlite3 ${DATABASE_FILENAME} "select distinct '\"'||ipv4||'\"' from t_netevent where STATUS='UP' "`)
#available_networks_array=(`sqlite3 ${DATABASE_FILENAME} "select distinct ipv4 from t_netevent where STATUS='UP' "`)

#echo "-> "${available_networks_array[@]}

networks_string="${available_networks_array[@]}"

log $0 "Available networks to scan: ${networks_string}" 4 ${COLLECTION_UUID}


for current_network in "${available_networks_array[@]}"; do
  while read -a line_array; do 
    sqlcommand="insert into t_hostevent (UUID, COLLECTION_UUID, IP, DNS_NAME, STATUS) values ('`uuidgen`', '${COLLECTION_UUID}', '${line_array[1]}', '${line_array[2]}','${line_array[4]}')"
    log $0 "Found host entry IP:${line_array[0]}, DNS_NAME: ${line_array[1]}" 4 ${COLLECTION_UUID}
    sqlite3 ${DATABASE_FILENAME} "$sqlcommand"
  done < <(nmap "${current_network}" -sn -oG -|grep -v '#')
done

log $0 "Finished $0" 3 ${COLLECTION_UUID}

exit 0

