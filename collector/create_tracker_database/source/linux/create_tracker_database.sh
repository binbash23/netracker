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

#
# Main
#
echo "Running $0"

echo "Checking netracker database..."
sqlite3 ${DB_FILENAME} < ${DB_CREATE_SCRIPT_FILENAME}

#echo "Checking sys_config table..."
#sqlite3 ${DB_FILENAME} < ${DB_CREATE_SYS_CONFIG_SCRIPT_FILENAME}

echo "Checking tracker database os..."
ROW=`sqlite3 ${DB_FILENAME} "select * from sys_config where property='TRACKER_OS'"`
if [ ! -z "${ROW}" ]; then
  echo "TRACKER_OS exists."
else
  echo "TRACKER_OS is missing, inserting new TRACKER_OS..."
  sqlite3 ${DB_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('TRACKER_OS', 'linux')"
fi

echo "Checking tracker database create_date..."
ROW=`sqlite3 ${DB_FILENAME} "select * from sys_config where property='TRACKER_DATABASE_CREATE_DATE'"`
if [ ! -z "${ROW}" ]; then
  echo "TRACKER_DATABASE_CREATE_DATE exists."
else
  echo "TRACKER_DATABASE_CREATE_DATE is missing, inserting new TRACKER_DATABASE_CREATE_DATE..."
  sqlite3 ${DB_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('TRACKER_DATABASE_CREATE_DATE', datetime(CURRENT_TIMESTAMP, 'localtime'))"
fi

echo "Checking tracker UUID..."
UUID=`sqlite3 ${DB_FILENAME} "select * from sys_config where property='TRACKER_UUID'"`
if [ ! -z "${UUID}" ]; then
  echo "UUID exists."
else
  echo "UUID is missing, inserting new UUID..."
  UUID=`uuidgen`
  sqlite3 ${DB_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('TRACKER_UUID', '${UUID}')"
fi

echo Done



