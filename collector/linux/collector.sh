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
DEFAULT_COLLECTOR_HEARTBEAT_SEC=5
DEFAULT_TRACKER_INTERVAL_SEC=30

USAGE_INFO_TEXT="

  collector by Jens Heine <binbash@gmx.net> 2023
           and Andreas Stoecker <a.stoecker@gmx.net>

USAGE

   collector [OPTIONS]

OPTIONS
        -D              : Delete/clear log table in database
        -h              : Show usage information
        -k              : Shutdown collector by setting kill switch in 
                          sys_config table to 1
        -L              : Show latest log information from database

  If you start with no options, the collector will create/check the collector
  database and then run all trackers to collect information into the
  collector database.

EXAMPLES

  Start collector in background:
  ./collector &

  Show current log/status information:
  ./collector -L     

  Show help:
  ./collector -h

  Stop collector:
  ./collector -k

"

#
# FUNCTIONS
#
function show_usage() {
  echo "$USAGE_INFO_TEXT"
}

#
# Checks if the tracker has the flag SHOULD_RUN set to 1 in the tracker_config table
# and if enabled=1 and is_running=0
#
function check_if_tracker_should_start() {
  local tracker_name="$1"
  [ -z "${tracker_name}" ] && { echo "Error: Tracker name is empty."; exit 1; }
  local entry_exists=`sqlite3 "${DATABASE_FILENAME}" "select count(*) from tracker_config where name ='${tracker_name}'"`
  if [ "${entry_exists}" -eq 0 ]; then 
    log $0 "Register new tracker in tracker_config: ${tracker_name} default enabled=1" 2 ${current_collection_uuid}
    sqlite3 "${DATABASE_FILENAME}" "insert into tracker_config (NAME, ENABLED, INTERVAL_SEC) values ('${tracker_name}', 1, ${DEFAULT_TRACKER_INTERVAL_SEC})" 
    echo 1
    return
  else 
    local enabled=`sqlite3 "${DATABASE_FILENAME}" "select enabled from tracker_config where name='${tracker_name}'"`
    log $0 "Found tracker in config with status=${enabled}" 4 ${current_collection_uuid}
    if [ "${enabled}" -eq 0 ]; then
      echo 1
      return
    else
      local should_run=`sqlite3 "${DATABASE_FILENAME}" "select should_run from v_tracker_config_calc where name='${tracker_name}'"`
      log $0 "Found tracker in config with should_run=${should_run}" 4 ${current_collection_uuid}
      if [ "${should_run}" -eq 1 ]; then
        local is_running=`sqlite3 "${DATABASE_FILENAME}" "select is_running from tracker_config where name='${tracker_name}'"`
        log $0 "Found tracker in config with is_running=${is_running}" 4 ${current_collection_uuid}
        if [ "${is_running}" -eq 0 ]; then
          echo 1
          return
        fi
      fi
    fi
  fi
  echo 0
}

function get_collector_sleep_interval_from_configuration() {
  local sleep_interval=`sqlite3 "${DATABASE_FILENAME}" "select value from sys_config where property='COLLECTOR_INTERVAL_SEC'"`
  [ -z "${sleep_interval}" ] && { echo ${DEFAULT_COLLECTOR_HEARTBEAT_SEC}; return; }
  echo "${sleep_interval}"
}

function check_collector_shutdown_switch() {
  local shutdown=`sqlite3 "${DATABASE_FILENAME}" "select value from sys_config where property='COLLECTOR_SHUTDOWN_SWITCH'"`
  [ "1" == "${shutdown}" ] && log $0 "Found COLLECTOR_SHUTDOWN_SWITCH set to 1" 3 
  echo ${shutdown:-0}
}



#
# MAIN
#
while getopts "DLhk" options;do
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
    k) if [ "`check_collector_shutdown_switch`" == "0" ]; then
         echo "Setting COLLECTOR_SHUTDOWN_SWITCH to 1"
         echo "Please wait for collector to shutdown..."
         sqlite3 ${DATABASE_FILENAME} "update sys_config set value='1' where property='COLLECTOR_SHUTDOWN_SWITCH'"
       else
         echo "COLLECTOR_SHUTDOWN_SWITCH is already set to 1."
         echo "Maybe there is no collector running."
       fi
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

# Check collector database structure
./create_database.sh

log $0 "Starting"

# Main loop: run all trackers every interval
while [ "`check_collector_shutdown_switch`" == "0" ]; do

# CREATING NEW COLLECTION
current_collection_uuid=`uuidgen`
log $0 "Creating new collection with UUID: ${current_collection_uuid}" 4 ${current_collection_uuid}

# DETECTING AVAILABLE TRACKERS
log $0 "Detecting available trackers..." 3 ${current_collection_uuid} 
tracker_array=(`ls tracker/*/*_tracker.sh`)

log $0 "Found ${#tracker_array[@]} tracker(s)..." 3 ${current_collection_uuid}

base_dir=`pwd`
log $0 "Resetting is_running to 0 for all trackers in tracker_config" 4 ${current_collection_uuid}
sqlite3 "${DATABASE_FILENAME}" "update tracker_config set IS_RUNNING=0"
for current_tracker in ${tracker_array[@]}; do
  current_tracker_basename=`basename ${current_tracker}`
  current_tracker_name=${current_tracker_basename/_tracker.sh/}
  start_tracker=`check_if_tracker_should_start ${current_tracker_name}`
  if [ "$start_tracker" == "0" ]; then
    log $0 "Tracker ${current_tracker_name} is disabled,running or the run interval is not reached. Skipping start." 3 ${current_collection_uuid}
    continue
  fi

  log $0 "Starting tracker ${current_tracker}"  3 ${current_collection_uuid}
  sqlite3 "${DATABASE_FILENAME}" "update tracker_config set LAST_EXECUTION=datetime(CURRENT_TIMESTAMP, 'localtime'), IS_RUNNING=1 where name='${current_tracker_name}'"
  cd `dirname ${current_tracker}`
  current_tracker_filename="./`basename ${current_tracker}`"
#  echo "Starting tracker: `basename ${current_tracker}`"
  $current_tracker_filename ${current_collection_uuid}
  cd ${base_dir}
  sqlite3 "${DATABASE_FILENAME}" "update tracker_config set IS_RUNNING=0 where name='${current_tracker_name}'"
done

collector_sleep_interval_sec=`get_collector_sleep_interval_from_configuration`
#echo "Sleeping ${collector_sleep_interval_sec} seconds..."
log $0 "Sleeping ${collector_sleep_interval_sec} seconds..." 4 ${current_collection_uuid}
sleep ${collector_sleep_interval_sec}

# Main loop end: run all trackers every interval
done

log $0 "Finished"

echo "`basename $0` finished."



#
# END
#
