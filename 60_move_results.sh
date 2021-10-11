# script specific to compute 1 to move all data from scratch volume to storage volume
# at the end of the run
#
# Algorithm: for each entry in analysis summary with a path matching SCRATCH_BASE, move the workflow root to DEST_BASE
# Also, update dat/analysis_summary.dat file
# and write to dat/analysis_summary.final.dat

AS="dat/analysis_summary.dat"
AS_DEST="dat/analysis_summary.final.dat"

PARAMS="Project.config.sh"
source $PARAMS

>&2 echo Moving from $SCRATCH_BASE to $DEST_BASE

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

# Loop over all UUID in analysis summary file
UUIDS=$(grep "$SCRATCH_BASE" $AS | cut -f 10 | sort -u)

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
