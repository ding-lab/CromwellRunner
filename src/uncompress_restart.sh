#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Uncompress intermediate CromwellRunner results for restart

Usage:
 uncompress_restart.sh [options] 

Optional options
-h: print usage information
-d: dry run: print commands but do not modify data or write to data log
-1: stop after one case processed.
-U WORKFLOW_ROOT_LIST: Required list of paths of workflow roots to uncompress
-P RESULT_LIST: required list of result files to keep when pruning, typically the principal outputs of workflow
    Example line:
        ./call-canonical_filter/execution/output/HotspotFiltered.vcf
EOF

source src/cromwell_utils.sh

SCRIPT=$(basename $0)
SCRIPT_PATH=$(dirname $0)

while getopts ":hd1U:P:" opt; do
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
    U)
      WORKFLOW_ROOT_LIST="$OPTARG"
      ;;
    P)
      RESULT_LIST="$OPTARG"
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

function do_uncompress {
    WR=$1
    FILES="$2"

    TARC="$WR/compressed_results.tar.gz"
    TARP="$WR/pruned_results.tar.gz"

    if [ -f $TARC ]; then
        TAR=$TARC
    elif [ -f $TARP ]; then
        TAR=$TARP
    else
        >&2 echo ERROR: No TAR file in $WR, nothing to do.  Exiting
        exit 1
    fi

    CMD="tar -zxf $TAR -C $WR $FILES"
    run_cmd "$CMD" $DRYRUN
}

function do_uncompress_restart {
    WR=$1
    RESULT_LIST=$2

    RESULTS=$(sed '/^[[:blank:]]*#/d;s/#.*//' $RESULT_LIST)
#    FILES="./call-pindel_vaf_length_depth_filters/execution/results/vaf_length_depth_filters/filtered.vcf \
#        ./call-varscan_snv_vaf_length_depth_filters/execution/results/vaf_length_depth_filters/filtered.vcf \
#        ./call-varscan_indel_vaf_length_depth_filters/execution/results/vaf_length_depth_filters/filtered.vcf \
#        ./call-strelka_vaf_length_depth_filters/execution/results/vaf_length_depth_filters/filtered.vcf \
#        ./call-strelka_indel_vaf_length_depth/execution/results/vaf_length_depth_filters/filtered.vcf \
#        ./call-mutect_vaf_length_depth/execution/results/vaf_length_depth_filters/filtered.vcf"

    do_uncompress $WR "$RESULTS"
}


IDS_SEEN=0

confirm $WORKFLOW_ROOT_LIST
confirm $RESULT_SLIT

while read WR; do
    IDS_SEEN=$(($IDS_SEEN + 1))

    >&2 echo Processing $IDS_SEEN [ $(date) ]: $RID
    do_uncompress_restart $WR $RESULT_LIST

    if [ $JUSTONE ]; then
        break
    fi

done <$WORKFLOW_ROOT_LIST
