# Generate analysis summary file
# Note that running `runplan` will give back useful information about anticipated runs

PARAMS="Project.config.sh"
if [ ! -f $PARAMS ]; then 
    echo $PARAMS  does not exist
    exit 1
fi
source $PARAMS

CMD="bash src/summarize_runs.sh -B $BAMMAP -P $PARAMS -U $RUN_LIST $@ "

>&2 echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

