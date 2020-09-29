# script specific to compute 1 to move all data from scratch volume to storage volume
# at the end of the run
# Also, update dat/analysis_summary.dat file
# write dat/analysis_summary.unstaged.dat

#SCRATCH_ROOT=/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data
SCRATCH_BASE=/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/SomaticSV.cwl
#DEST_ROOT=/storage1/fs1/m.wyczalkowski/Active/cromwell-data
DEST_BASE=/storage1/fs1/m.wyczalkowski/Active/cromwell-data/cromwell-workdir/cromwell-executions/SomaticSV.cwl


function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo Fatal error.  Exiting.
            exit $rc;
        fi;
    done
}

# We will move all relevant $SCRATCH_BASE/UUID directories to $DEST_BASE

AS="dat/analysis_summary.dat"
AS_DEST="dat/analysis_summary.final.dat"

UUIDS=$(grep "$SCRATCH_BASE" $AS | cut -f 9 | sort -u)

for UUID in $UUIDS ; do
    echo Processing $UUID

    CMD="mv $SCRATCH_BASE/$UUID $DEST_BASE"
    >&2 echo $CMD
    eval $CMD
    test_exit_status
done

CMD="sed \"s+$SCRATCH_BASE+$DEST_BASE+\" $AS > $AS_DEST"
>&2 echo $CMD
eval $CMD

>&2 echo Moved data from $SCRATCH_BASE
>&2 echo to $DEST_BASE

>&2 echo Analysis summary written to $AS_DEST
