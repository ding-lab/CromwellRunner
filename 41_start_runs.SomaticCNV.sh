# Specific to SomaticCNV due to the RESULTS_LIST argument

PARAMS="Project.config.sh"

if [ ! -f $PARAMS ]; then 
    echo $PARAMS  does not exist
    exit 1
fi

source $PARAMS
source $LSF_CONF

DB_ARGS="-Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStore=/home/m.wyczalkowski/lib/cromwell-jar/cromwell.truststore"

# this is specific to SomaticCNV workflow to delete large staged BAMs
# Remove this section for non-SomaticCNV
RESULT_LIST="config/Templates/prune_list/SomaticCNV.stage_files_delete.dat"
ARGS="-P $RESULT_LIST"

# -F - finalize and compress jobs immediately upon completion
ARGS="$ARGS -F"

# spawning cromwell server (-S) happens only if -F is defined by user
ARGS="$ARGS -X -Xmx10g -G $CWL_ROOT_H -D \"$DB_ARGS\" -c $CQ_ROOT_C -S $SYSTEM"

CMD="bash src/rungo $ARGS $LSF_ARGS -c src -p $PROJECT -R $CROMWELL_JAR -W $CWL -C $CONFIG_FILE $@"
>&2 echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


