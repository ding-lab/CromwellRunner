

# This file below is for MGI
# source /opt/lsf9/conf/lsf.conf

# below is for compute1
source /opt/ibm/lsfsuite/lsf/conf/lsf.conf

source config/project_config.compute1.sh

# CQD="$TD_ROOT/src"


# -J N - specify number of jobs to run at once
# -F - finalize and compress jobs immediately upon completion
# -G - git project details of TD_ROOT`
#ARGS="-J 4 -F"
ARGS="-F"
ARGS="$ARGS -X -Xmx10g -G $TD_ROOT"
bash $TD_ROOT/src/rungo $ARGS -p $PROJECT -c $CQD -R $CROMWELL_JAR -W $CWL -C $CONFIG_FILE -k $CASES_FN $@

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


