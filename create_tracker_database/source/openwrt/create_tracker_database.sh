#
# create_tracker_database.sh
#
# 20230225 written by jens heine <binbash@gmx.net>, andreas stöcker <a.stoecker@gmx.net>
#

#
# Dependencies
#
# sqlite3, uuidgen
#

#
# Variables
#
DB_FILENAME='tracker.db'
DB_CREATE_SCRIPT_FILENAME='create_tracker_database.sql'
DB_CREATE_SYS_CONFIG_SCRIPT_FILENAME='create_sys_config.sql'

#
# Main
#
echo "Running $0"

echo "Checking netracker database..."
sqlite3 ${DB_FILENAME} < ${DB_CREATE_SCRIPT_FILENAME}

echo "Checking sys_config table..."
sqlite3 ${DB_FILENAME} < ${DB_CREATE_SYS_CONFIG_SCRIPT_FILENAME}

echo "Checking tracker UUID..."
UUID=`sqlite3 ${DB_FILENAME} "select * from sys_config where property='TRACKER_UUID'"`
if "${UUID}"; then
  echo "UUID exists."
else
  echo "UUID is missing, inserting new UUID..."
  UUID=`uuidgen`
  sqlite3 ${DB_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('TRACKER_UUID', '${UUID}')"
fi

echo Done



