PARAMS="Project.config.sh"

if [ ! -f $PARAMS ]; then 
    echo $PARAMS  does not exist
    exit 1
fi

source $PARAMS
source $LSF_CONF

DB_ARGS="-Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStore=/home/m.wyczalkowski/lib/cromwell-jar/cromwell.truststore"

# WORKFLOW_RUN_ARGS are workflow-specific arguments to be passed to rungo
# -F - finalize and compress jobs immediately upon completion
# spawning cromwell server (-S) happens only if -F is defined by user
ARGS="$WORKFLOW_RUN_ARGS -F -S $CONFIG_SERVER_FILE"

ARGS="$ARGS -X -Xmx10g -G $CWL_ROOT_H -D \"$DB_ARGS\" -c $CQ_ROOT_C "

CMD="bash src/rungo $ARGS $LSF_ARGS -c src -p $PROJECT -R $CROMWELL_JAR -W $CWL -C $CONFIG_FILE $@"
>&2 echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


