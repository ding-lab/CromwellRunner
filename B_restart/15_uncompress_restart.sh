cd ..
source Project.config.sh

# Uncompress intermediate files from past run which will serve as input into 
# post-merge restart.  

RESTART_WORKFLOW_ROOT="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/TinDaisy/27.DLBCL_105-refilter/dat-MGIdb/25b.restart-workflowRoot.dat"
RESULT_LIST="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/TinDaisy/27.DLBCL_105-refilter/dat-MGIdb/postmerge_result_list.dat"

>&2 echo Uncompressing restart files
CMD="bash src/uncompress_restart.sh -U $RESTART_WORKFLOW_ROOT -P $RESULT_LIST $@"
>&2 echo Running $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi
