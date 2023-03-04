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
  collector database.

EXAMPLES

  Show current log/status information:
  ./collector -L     

  Show help:
  ./collector -h

"

#
# FUNCTIONS
#
function show_usage() {
  echo "$USAGE_INFO_TEXT"
}

function is_tracker_enabled() {
  local tracker_name="$1"
  [ -z "${tracker_name}" ] && { echo "Error: Tracker name is empty."; exit 1; }
  local entry_exists=`sqlite3 "${DATABASE_FILENAME}" "select count(*) from tracker_config where name ='${tracker_name}'"`
  if [ "${entry_exists}" -eq 0 ]; then 
    log $0 "Register new tracker in tracker_config: ${tracker_name} default enabled=1" 2 ${current_collection_uuid}
    sqlite3 "${DATABASE_FILENAME}" "insert into tracker_config (NAME, ENABLED) values ('${tracker_name}', 1)" 
    echo 1
    return
  else 
    local enabled=`sqlite3 "${DATABASE_FILENAME}" "select enabled from tracker_config where name='${tracker_name}'"`
    log $0 "Found tracker in config with status=${enabled}" 4 ${current_collection_uuid}
    if [ "${enabled}" -eq 1 ]; then
      echo 1
      return
    else
      echo 0
      return
    fi
  fi
}

function get_collector_sleep_interval_from_configuration() {
  local sleep_interval=`sqlite3 "${DATABASE_FILENAME}" "select value from sys_config where property='COLLECTOR_INTERVAL_SEC'"`
  [ -z "${sleep_interval}" ] && { echo 30; return; }
  echo "${sleep_interval}"
}


#
# MAIN
#
while getopts "DLh" options;do
  case "$options" in
#    l) LOGFILE="${OPTARG}"
#       logDebug "Using custom log file: ${LOGFILE}"
#       ;;
    D) delete_log
       exit 0
       ;;
    h) show_usage
       exit
       ;;
    L) show_log
       exit 0
       ;;
#    v) showVersionInfo
#       exit 0
#       ;;
    *) show_usage
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
log $0 "Creating new collection with UUID: ${current_collection_uuid}" 4 ${current_collection_uuid}

# DETECTING AVAILABLE TRACKERS
log $0 "Detecting available trackers..." 3 ${current_collection_uuid} 
tracker_array=(`ls tracker/*/*_tracker.sh`)

log $0 "Found ${#tracker_array[@]} tracker(s)..." 3 ${current_collection_uuid}

base_dir=`pwd`
for current_tracker in ${tracker_array[@]}; do
  current_tracker_basename=`basename ${current_tracker}`
  current_tracker_name=${current_tracker_basename/_tracker.sh/}
  enabled=`is_tracker_enabled ${current_tracker_name}`
  if [ "$enabled" == "0" ]; then
    log $0 "Tracker ${current_tracker_name} is disabled. Skipping start." 3 ${current_collection_uuid}
    continue
  fi
  log $0 "Starting tracker ${current_tracker}"  3 ${current_collection_uuid}
  cd `dirname ${current_tracker}`
  current_tracker_filename="./`basename ${current_tracker}`"
  echo "Starting tracker: `basename ${current_tracker}`"
  $current_tracker_filename ${current_collection_uuid}
  #./`basename ${current_tracker}`
  cd ${base_dir}
done

collector_sleep_interval_sec=`get_collector_sleep_interval_from_configuration`
echo "Sleeping ${collector_sleep_interval_sec} seconds..."
log $0 "Sleeping ${collector_sleep_interval_sec} seconds..." 4 ${current_collection_uuid}
sleep ${collector_sleep_interval_sec}

# Main loop end: run all trackers every interval
done

log $0 "Finished"

echo "`basename $0` finished."



#
# END
#
