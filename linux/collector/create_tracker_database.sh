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

#set -x

#
# Source main library
#
. collector.library

#
# Variables
#
DB_CREATE_SCRIPT_FILENAME='create_tracker_database.sql'

#
# Main
#
echo "Running $0"

[ -z "${DATABASE_FILENAME}" ] && { echo "Database filename not set."; exit 1; }

echo "Checking netracker database..."
sqlite3 ${DATABASE_FILENAME} < ${DB_CREATE_SCRIPT_FILENAME}

#echo "Checking sys_config table..."
#sqlite3 ${DATABASE_FILENAME} < ${DB_CREATE_SYS_CONFIG_SCRIPT_FILENAME}

echo "Checking tracker database os..."
ROW=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='OS'"`
if [ ! -z "${ROW}" ]; then
  echo "Property OS exists."
else
  echo "Creating OS property..."
  sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('OS', 'linux')"
fi

echo "Checking tracker database create_date..."
ROW=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='DATABASE_CREATE_DATE'"`
if [ ! -z "${ROW}" ]; then
  echo "DATABASE_CREATE_DATE exists."
else
  echo "DATABASE_CREATE_DATE is missing, inserting new DATABASE_CREATE_DATE..."
  sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('DATABASE_CREATE_DATE', datetime(CURRENT_TIMESTAMP, 'localtime'))"
fi

echo "Checking DATABASE_UUID..."
UUID=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='DATABASE_UUID'"`
if [ ! -z "${UUID}" ]; then
  echo "DATABASE_UUID exists."
else
  echo "DATABASE_UUID is missing, inserting new DATABASE_UUID..."
  UUID=`uuidgen`
sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('DATABASE_UUID', '${UUID}')"
fi

echo $0 finished.



