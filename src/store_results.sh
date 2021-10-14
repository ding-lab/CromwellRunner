#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'

Move WorkflowRoot data directory from scratch volume to storage volume at the end of the run
and create new analysis_summary file

Usage:
  store_results.sh [options] AS_SCRATCH

Optional options
-h: print usage information
-d: dry run: print commands but do not modify data or write to data log
-1: stop after one case processed.
-o AS_OUT: Output analysis summary file. Default: dat/analysis_summary.stored.dat
-b SCRATCH_BASE: Base directory of output, where WorkflowRoot = SCRATCH_BASE/UUID.  Required, must exist
-B DEST_BASE: Destination path, analogous to SCRATCH_BASE.  Required, must exist

AS_SCRATCH is the scratch analysis summary file

Algorithm:
  * For each UUID in AS_SCRATCH with a path matching SCRATCH_BASE
    * mv SCRATCH_BASE/UUID DEST_BASE
  * Replace all instances of string SCRATCH_BASE with DEST_BASE in the file AS_SCRATCH, writing AS_OUT
EOF

source src/cromwell_utils.sh

while getopts ":hd1o:b:B:" opt; do
  case $opt in
    h) 
      echo "$USAGE"
      exit 0
      ;;
    d)  # echo work command instead of evaluating it
      DRYRUN="d"
      ;;
    1) 
      JUSTONE=1
      ;;
    o) 
      AS_OUT="$OPTARG"
      ;;
    b) 
      SCRATCH_BASE="$OPTARG"
      ;;
    B) 
      DEST_BASE="$OPTARG"
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      >&2 echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      >&2 echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

AS_SCRATCH=$1
confirm $AS_SCRATCH
confirm_dir $SCRATCH_BASE
confirm_dir $DEST_BASE

# Loop over all UUID in analysis summary file
UUIDS=$(grep "$SCRATCH_BASE" $AS_SCRATCH | cut -f 10 | sort -u)

for UUID in $UUIDS ; do
    echo Processing $UUID

    CMD="mv $SCRATCH_BASE/$UUID $DEST_BASE"
    run_cmd "$CMD" $DRYRUN
done

CMD="sed \"s+$SCRATCH_BASE+$DEST_BASE+\" $AS_SCRATCH > $AS_OUT"
run_cmd "$CMD" $DRYRUN

>&2 echo Moved data from $SCRATCH_BASE
>&2 echo to $DEST_BASE

>&2 echo Analysis summary written to $AS_OUT
