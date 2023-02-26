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
DB_CREATE_SCRIPT_FILENAME='../create_database.sql'

#
# Main
#
echo "Running $0"

[ -z "${DATABASE_FILENAME}" ] && { echo "Database filename not set."; exit 1; }

echo "Checking/creating database structure..."
sqlite3 ${DATABASE_FILENAME} < ${DB_CREATE_SCRIPT_FILENAME}

echo -n "Checking sys_config property: OS..."
ROW=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='OS'"`
if [ ! -z "${ROW}" ]; then
  echo " OK"
else
  echo
  echo "Creating OS property..."
  sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('OS', 'linux')"
fi

echo -n "Checking sys_config property: DATABASE_CREATE_DATE..."
ROW=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='DATABASE_CREATE_DATE'"`
if [ ! -z "${ROW}" ]; then
  echo " OK"
else
  echo
  echo "DATABASE_CREATE_DATE is missing, inserting new DATABASE_CREATE_DATE..."
  sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('DATABASE_CREATE_DATE', datetime(CURRENT_TIMESTAMP, 'localtime'))"
fi

echo -n "Checking sys_config property: DATABASE_UUID..."
UUID=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='DATABASE_UUID'"`
if [ ! -z "${UUID}" ]; then
  echo " OK"
else
  echo
  echo "DATABASE_UUID is missing, inserting new DATABASE_UUID..."
  UUID=`uuidgen`
sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('DATABASE_UUID', '${UUID}')"
fi

echo $0 finished.



