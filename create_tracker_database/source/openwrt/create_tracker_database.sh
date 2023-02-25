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

echo Done
