#
# collector.sh
#
# 20230226 written by jens heine <binbash@gmx.net>, andreas stöcker <a.stoecker@gmx.net>
#

#set -x

#
# Source main library
#
. collector.library

#
# Main
#
echo "Running $0"

[ -z "${DATABASE_FILENAME}" ] && { echo "Database filename not set."; exit 1; }

echo "Checking database ${DATABASE_FILENAME}..."
./create_database.sh

log $0 "Starting"

log $0 "Finished"

echo $0 finished.
