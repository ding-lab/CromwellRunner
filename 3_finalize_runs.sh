# Run Demo project 

source config/project_config.sh

# How to pass NOTE to runlog?  
NOTE="experimental finalization of Y2.b2 run"

CQD="$TD_ROOT/src"

bash $TD_ROOT/src/runtidy -x finalize -c $CQD -m "$NOTE" $@

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

