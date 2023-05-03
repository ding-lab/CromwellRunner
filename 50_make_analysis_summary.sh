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

# debugging...  
BAMMAP="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/WUSTL-BamMap/HCMI.BamMap3.tsv"
CATALOG="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/HCMI.Catalog-REST.tsv"

CMD="bash src/summarize_runs.sh $@ -s $AS_NAME -B $BAMMAP -U $RUN_LIST -C $CATALOG"
#CMD="bash src/summarize_runs.sh $@ -s $AS_NAME -B $BAMMAP -P $PARAMS -U $RUN_LIST -C $CATALOG"

>&2 echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

