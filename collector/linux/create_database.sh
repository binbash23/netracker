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
DB_CREATE_SCRIPT_FILENAME='../create_collector_database.sql'

#
# Main
#
echo "Running `basename $0`"

[ -z "${DATABASE_FILENAME}" ] && { echo "Database filename not set."; exit 1; }

echo "Checking collector database structure..."
sqlite3 ${DATABASE_FILENAME} < ${DB_CREATE_SCRIPT_FILENAME}

echo -n "Checking sys_config property OS                        :"
ROW=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='OS'"`
if [ ! -z "${ROW}" ]; then
  echo " OK"
else
  echo " MISSING"
  echo "Creating property..."
  sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('OS', 'linux')"
fi

echo -n "Checking sys_config property DATABASE_CREATE_DATE      :"
ROW=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='DATABASE_CREATE_DATE'"`
if [ ! -z "${ROW}" ]; then
  echo " OK"
else
  echo " MISSING"
  echo "Creating property..."
  sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('DATABASE_CREATE_DATE', datetime(CURRENT_TIMESTAMP, 'localtime'))"
fi

echo -n "Checking sys_config property DATABASE_UUID             :"
UUID=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='DATABASE_UUID'"`
if [ ! -z "${UUID}" ]; then
  echo " OK"
else
  echo " MISSING"
  echo "Creating property..."
  UUID=`uuidgen`
sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('DATABASE_UUID', '${UUID}')"
fi

echo -n "Checking sys_config property COLLECTOR_INTERVAL_SEC    :"
COLLECTOR_INTERVAL_SEC=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='COLLECTOR_INTERVAL_SEC'"`
if [ ! -z "${COLLECTOR_INTERVAL_SEC}" ]; then
  echo " OK"
else
  echo " MISSING"
  echo "Creating property..."
sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('COLLECTOR_INTERVAL_SEC', '${DEFAULT_COLLECTOR_HEARTBEAT_SEC}')"
fi

echo -n "Checking sys_config property COLLECTOR_SHUTDOWN_SWITCH :"
COLLECTOR_SHUTDOWN_SWITCH=`sqlite3 ${DATABASE_FILENAME} "select * from sys_config where property='COLLECTOR_SHUTDOWN_SWITCH'"`
if [ ! -z "${COLLECTOR_SHUTDOWN_SWITCH}" ]; then
  sqlite3 ${DATABASE_FILENAME} "update sys_config set value='0' where property='COLLECTOR_SHUTDOWN_SWITCH'"
  echo " OK"
else
  echo " MISSING"
  echo "Creating property..."
sqlite3 ${DATABASE_FILENAME} "insert into sys_config (PROPERTY, VALUE) values ('COLLECTOR_SHUTDOWN_SWITCH', '0')"
fi

echo -n "Setting DATABASE journal mode                          : "
sqlite3 ${DATABASE_FILENAME} "pragma journal_mode=WAL"
# fast but unsafe mode:
#sqlite3 ${DATABASE_FILENAME} "pragma journal_mode=OFF"

echo -n "Setting DATABASE synchronous mode                      : "
sqlite3 ${DATABASE_FILENAME} "pragma synchronous=NORMAL"
# fast but unsafe
#sqlite3 ${DATABASE_FILENAME} "pragma synchronous=OFF"
# Show current state:
sqlite3 ${DATABASE_FILENAME} "pragma synchronous"


echo "Checking collector database structure finished."
#echo "`basename $0` ready."



