#!/bin/bash
# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

# Start local instance of cromwell server (rather than relying on default MGI production server)
# This gets around problems with database queries circa summer 2019
# With this server running, database queries are to http://localhost:8000
# Only one server should be running at once.  

# Usage: spawn_cromwell_server.sh SERVER 
# where SERVER is MGI or compute1

source src/cromwell_utils.sh

read -r -d '' USAGE <<'EOF'
Start local instance of cromwell server listening on http://localhost:8000

Usage:
  spawn_cromwell_server.sh [options] CONFIG

Options:
-h: Print this help message
-d: dry run
-s N: sleep for N seconds after starting server to let it initialize before exiting
-C: test if server currently running, exit without starting if it is

Additional processing details and background
EOF

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hds:C" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    d)  
      DRYRUN="d"
      ;;
    s) 
      SLEEP_N=$OPTARG
      ;;
    C)  
      CONFIRM_SERVER=1
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG"
      echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument."
      echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 1 ]; then
    >&2 echo Error: Wrong number of arguments
    exit
fi
CROMWELL_URL="http://localhost:8000"

function check_server {

    Q="curl $CURL_ARG -s -X GET \"$CROMWELL_URL/engine/v1/version\" -H \"accept: application/json\"  "
    if [ "$DEBUG" ]; then
        >&2 echo DEBUG: check_server Q = $Q
    fi

# If server is running
    R=$( eval $Q )
    RC=$?
    if [ "$DEBUG" ]; then
        >&2 echo DEBUG: check_server status \$R = $R , return code = $RC 
    fi

    if [ $RC == 0 ]; then
        printf "OK"
    else
        printf "ERROR"
    fi
}

if [ ! -z $CONFIRM_SERVER ]; then
    STATUS=$(check_server)
    if [ "$STATUS" == "OK" ]; then
        >&2 echo NOTE: Cromwell server appears to be running.  Not starting
        exit 0
    fi
    >&2 echo NOTE: Cromwell server not running.  Starting
fi

CONFIG=$1
if [ ! -e $CONFIG ]; then
    >&2 echo ERROR: CONFIG not found $CONFIG 
    exit
fi

# Reverting to MGI
JAVA="/usr/bin/java"
#CROMWELL_JAR="/opt/cromwell.jar"
CROMWELL="/usr/local/cromwell/cromwell-47.jar"

#JAVA="/opt/java/openjdk/bin/java"
#CROMWELL="/app/cromwell-78-38cd360.jar"

CMD="$JAVA -Dconfig.file=$CONFIG -jar $CROMWELL server >/dev/null & "
echo Starting local instance of cromwell server
run_cmd "$CMD" $DRYRUN

if [ ! -z $SLEEP_N ]; then
    >&2 echo Waiting for $SLEEP_N sec
    sleep $SLEEP_N
fi
