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

# CREATING NEW COLLECTION
current_collection_uuid=`uuidgen`
log $0 "Creating new collection with UUID: ${current_collection_uuid}" 

# DETECTING AVAILABLE TRACKERS
log $0 "Detecting available trackers..."
tracker_array=(`ls tracker/*/*_tracker.sh`)

log $0 "Found ${#tracker_array[@]} trackers..."


log $0 "Finished"

echo $0 finished.
