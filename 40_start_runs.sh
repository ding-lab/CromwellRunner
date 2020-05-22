PARAMS="Project.config.sh"

if [ ! -f $PARAMS ]; then 
    echo $PARAMS  does not exist
    exit 1
fi

source $PARAMS
source $LSF_CONF

DB_ARGS="-Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStore=/storage1/fs1/home1/Active/home/m.wyczalkowski/lib/cromwell-jar/cromwell.truststore"

# -J N - specify number of jobs to run at once
# -F - finalize and compress jobs immediately upon completion
# -G - git project details of CWL_ROOT`
#ARGS="-J 4 -F"
#ARGS="-F"
ARGS="$ARGS -X -Xmx10g -G $CWL_ROOT -D \"$DB_ARGS\""
#CMD="bash src/rungo $ARGS -c src -p $PROJECT -R $CROMWELL_JAR -W $CWL -C $CONFIG_FILE -k $CASES_FN $@"
CMD="bash src/rungo $ARGS -c src -p $PROJECT -R $CROMWELL_JAR -W $CWL -C $CONFIG_FILE $@"
>&2 echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


