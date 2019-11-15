source /opt/lsf9/conf/lsf.conf
source config/project_config.sh

CQD="$TD_ROOT/src"

export DATALOG="/gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/cq.datalog/datalog.dat"

# -J N - specify number of jobs to run at once
# -F - finalize and compress jobs immediately upon completion
#ARGS="-J 4 -F"
#ARGS="-F"
ARGS="$ARGS -X -Xmx10g"
bash $TD_ROOT/src/rungo $ARGS -p $PROJECT -c $CQD -R $CROMWELL_JAR -W $CWL -C $CONFIG_FILE -k $CASES_FN $@

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


