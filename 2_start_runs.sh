source /opt/lsf9/conf/lsf.conf
source config/project_config.sh

CWL="$TD_ROOT/cwl/workflows/tindaisy.cwl"
CQD="$TD_ROOT/src"

# -J N - specify number of jobs to run at once
# -F - finalize and compress jobs immediately upon completion
#ARGS="-J 4 -F"
ARGS="-F"
ARGS="$ARGS -X -Xmx4g"
bash $TD_ROOT/src/rungo $ARGS -c $CQD -R $CROMWELL_JAR -W $CWL -C $CONFIG_FILE $@

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


