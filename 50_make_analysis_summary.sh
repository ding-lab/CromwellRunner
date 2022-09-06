# Generate analysis summary file
# Note that running `runplan` will give back useful information about anticipated runs

# Write to ./dat/analysis_summary.scratch.dat
# Implicitly, assuming that data will be moved from scratch, but naming wi

PARAMS="Project.config.sh"
if [ ! -f $PARAMS ]; then 
    echo $PARAMS  does not exist
    exit 1
fi
source $PARAMS

if [ $HAS_SCRATCH ]; then
    AS_NAME="./dat/analysis_summary.scratch.dat"
else
    AS_NAME="./dat/analysis_summary.dat"
fi
CMD="bash src/summarize_runs.sh $@ -s $AS_NAME -B $BAMMAP -P $PARAMS -U $RUN_LIST -C $CATALOG"

# This is specific to a particular flag thrown by WGS SomaticCNV pipeline.  Should be a more general way to write
if grep -q excess_zero $AS_NAME; then
    >&2 echo WARNING: Excess zeros observed in $AS_NAME:
    grep -q excess_zero $AS_NAME
    >&2 echo Quitting 
    exit 1
fi

>&2 echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

