PARAMS="Project.config.sh"
source $PARAMS

if [ ! $HAS_SCRATCH ]; then
    >&2 echo ERROR: Scratch space not defined for this system.  Stopping, no files modified
    exit 1
fi

# AS must match output of 50_
AS="dat/analysis_summary.scratch.dat"
AS_OUT="dat/analysis_summary.stored.dat"

# These are defined in PARAMS
>&2 echo Moving data from $SCRATCH_BASE to $DEST_BASE

CMD="bash src/store_results.sh $@ -b $SCRATCH_BASE -B $DEST_BASE -o $AS_OUT $AS"
>&2 echo Running: $CMD
eval "$CMD"

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


