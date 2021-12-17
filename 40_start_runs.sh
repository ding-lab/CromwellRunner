PARAMS="Project.config.sh"

if [ ! -f $PARAMS ]; then 
    echo $PARAMS  does not exist
    exit 1
fi

source $PARAMS
source $LSF_CONF

DB_ARGS="-Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStore=/home/m.wyczalkowski/lib/cromwell-jar/cromwell.truststore"

# This is pretty ad hoc, but test to make sure DATALOG file exists and exit with an error if not.
# Alternative is this errors out after the Cromwell run, and data does not get cleaned up
if [ -z $DATALOG ]; then
    >&2 echo ERROR: DATALOG not defined
    exit
fi
if [ ! -f $DATALOG ]; then
    >&2 echo ERROR: DATALOG does not exist: $DATALOG
    exit
fi

# WORKFLOW_RUN_ARGS are workflow-specific arguments to be passed to rungo
# -F - finalize and compress jobs immediately upon completion
# spawning cromwell server (-S) happens only if -F is defined by user
ARGS="$WORKFLOW_RUN_ARGS -F -S $CONFIG_SERVER_FILE"

ARGS="$ARGS -X -Xmx10g -D \"$DB_ARGS\" -c $CQ_ROOT_C "

CMD="bash src/rungo $ARGS $LSF_ARGS -c src -p $PROJECT -R $CROMWELL_JAR -W $CWL -C $CONFIG_FILE $@"
>&2 echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


