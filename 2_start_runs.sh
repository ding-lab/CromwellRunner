source /opt/lsf9/conf/lsf.conf
source config/project_config.sh



CWL="$TD_ROOT/cwl/workflows/tindaisy.cwl"

# -J N - specify number of jobs to run at once
#ARGS="-J 6"
bash $TD_ROOT/src/rungo $ARGS -R $CROMWELL_JAR -c $CWL -C $CONFIG $@

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


