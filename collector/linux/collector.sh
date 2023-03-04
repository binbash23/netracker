#
# collector.sh
#
# 20230226 written by jens heine <binbash@gmx.net>, andreas stöcker <a.stoecker@gmx.net>
#

#set -x

#
# SOURCE LIBRARIES
#
. collector.library

#
# VARIABLES
#
COLLECTOR_SLEEP_INTERVAL=30
USAGE_INFO_TEXT="

  collector by Jens Heine <binbash@gmx.net> 2023
           and Andreas Stoecker <a.stoecker@gmx.net>

USAGE

   collector [OPTIONS]

OPTIONS
        -D              : Delete/clear log table in database
        -h              : Show usage information
        -L              : Show latest log information from database

  If you start with no options, the collector will create/check the collector
  database and then run all trackers to collect information into the
  colelctor database.

EXAMPLES

  Show current log/status information:
  ./collector -L     

  Show help:
  ./collector -h

"

#
# FUNCTIONS
#
function showUsage() {
  echo "$USAGE_INFO_TEXT"
}

#
# MAIN
#
while getopts "DLh" options;do
  case "$options" in
#    l) LOGFILE="${OPTARG}"
#       logDebug "Using custom log file: ${LOGFILE}"
#       ;;
    D) deleteLog
       exit 0
       ;;
    h) showUsage
       exit
       ;;
    L) showLog
       exit 0
       ;;
#    v) showVersionInfo
#       exit 0
#       ;;
    *) showUsage
       exit 0
       ;;
  esac
done


echo "Running `basename $0`"

[ -z "${DATABASE_FILENAME}" ] && { echo "Database filename not set."; exit 1; }

echo "Checking database ${DATABASE_FILENAME}..."
./create_database.sh

log $0 "Starting"

# Main loop: run all trackers every interval
while true; do

# CREATING NEW COLLECTION
current_collection_uuid=`uuidgen`
log $0 "Creating new collection with UUID: ${current_collection_uuid}" 

# DETECTING AVAILABLE TRACKERS
log $0 "Detecting available trackers..."
tracker_array=(`ls tracker/*/*_tracker.sh`)

log $0 "Found ${#tracker_array[@]} trackers..."

base_dir=`pwd`
for current_tracker in ${tracker_array[@]}; do
  log $0 "Starting tracker ${current_tracker}"
  cd `dirname ${current_tracker}`
  current_tracker_filename="./`basename ${current_tracker}`"
  echo "Starting tracker: `basename ${current_tracker}`"
  $current_tracker_filename
  #./`basename ${current_tracker}`
  cd ${base_dir}
done

echo "Sleeping $COLLECTOR_SLEEP_INTERVAL seconds..."
sleep $COLLECTOR_SLEEP_INTERVAL

# Main loop end: run all trackers every interval
done

log $0 "Finished"

echo "`basename $0` finished."
