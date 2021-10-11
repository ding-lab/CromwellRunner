#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Usage: summarize_runs.sh [options] [RUN_NAME1 [ RUN_NAME2 ... ]]
  Summarize completed runs

Options:
-h: print usage information
-1: Quit after evaluating one case
-P PARAMS: parameters file which holds varibles for substution in template.  Not read by this script but passed to PARAMS_SCRIPT
-g: Issue warnings rather than quitting for testing
-s SUMMARY_OUT: output analysis summary file for task `summary`.  If '-', write to STDOUT
-c CROMWELL_QUERY: explicit path to cromwell query utility `cq`.  Default "cq" 
-U RUN_LIST: file with lines composed of RUN_NAME, CASE_NAME, and one or more UUIDs corresponding to data to be
   processed.  Required.
-G: this is a workflow with just one input UUID (otherwise, tumor and normal UUIDs are provided in RUN_LIST)
-B BAM_MAP: path to BamMap file

Obtain run inputs and result data to generate an analysis summary file
  - Defined here: https://docs.google.com/document/d/1Ho5cygpxd8sB_45nJ90d15DcdaGCiDqF0_jzIcc-9B4/edit

If RUN_NAME1 is - then read RUN_NAME from STDIN.  If RUN_NAME1 is not defined, read from first column of RUN_NAME file

Restarting of runs is supported by making available RESTART_D variable in YAML
template, which provides path to root directory of prior run.
RESTART_D="RESTART_ROOT/UUID", with RESTART_ROOT defined in PARAMS (mandatory),
and UUID obtained from RESTART_MAP file (TSV with CASE and UUID, `cq | cut -f 1-2` will work)
This is not currently implemented

Format of BamMap is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
EOF

source src/cromwell_utils.sh

SCRIPT=$(basename $0)

SUMMARY_OUT="./dat/analysis_summary.dat"
PARAMS="Project.config.sh"
CROMWELL_QUERY="bash src/cq"
TUMOR_NORMAL=1

while getopts ":h1P:gs:c:U:GB:" opt; do
  case $opt in
    h)  
      echo "$USAGE"
      exit 0
      ;;
    1)  
      JUSTONE=1
      ;;
    P)  
      PARAMS="$OPTARG"
      ;;
    g) 
      ONLYWARN=1
      ;;
    s)  
      SUMMARY_OUT="$OPTARG"
      ;;
    c) 
      CROMWELL_QUERY="$OPTARG"
      ;;
    U) 
      RUN_LIST="$OPTARG"
      ;;
    G) 
      TUMOR_NORMAL=0
      ;;
    B) 
      BAM_MAP="$OPTARG"
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

function complain {
    MSG="$1"
    WARN=$2
    if [ -z $WARN ]; then
        >&2 echo ERROR: $MSG
        exit 1
    else
        >&2 echo WARNING: $MSG  Continuing
    fi

}

function init_summary {
    if [ -z $RUN_LIST ]; then
        >&2 echo ERROR: RUN_LIST not defined \(-U\)
        >&2 echo "$USAGE"
        exit 1
    fi
    confirm $RUN_LIST $ONLYWARN

    if [ -z $BAM_MAP ]; then
        >&2 echo ERROR: BAM_MAP not defined \(-B\)
        >&2 echo "$USAGE"
        exit 1
    fi
    confirm $BAM_MAP $ONLYWARN

# Summary prep and header written
    if [ $TUMOR_NORMAL ]; then
        if [ -z $RESTART_MAP ]; then
            HEADER=$(printf "# run_name\tcase\tdisease\tresult_path\tfile_format\ttumor_name\ttumor_uuid\tnormal_name\tnormal_uuid\tcromwell_workflow_id\n") 
        else
            HEADER=$(printf "# run_name\tcase\tdisease\tresult_path\tfile_format\ttumor_name\ttumor_uuid\tnormal_name\tnormal_uuid\tcromwell_workflow_id\trestart_dir\n") 
        fi
    else
        if [ -z $RESTART_MAP ]; then
            HEADER=$(printf "# run_name\tcase\tdisease\tresult_path\tfile_format\tsample_name\tsample_uuid\tcromwell_workflow_id\n") 
        else
            HEADER=$(printf "# run_name\tcase\tdisease\tresult_path\tfile_format\tsample_name\tsample_uuid\tcromwell_workflow_id\trestart_dir\n") 
        fi
    fi

    if [ $SUMMARY_OUT == "-" ]; then
        echo "$HEADER"
    else
        SD=$(dirname $SUMMARY_OUT)
        if [ ! -d $SD ]; then
            >&2 echo Making output directory for analysis summary: $SD
            mkdir -p $SD
            test_exit_status
        fi
        echo "$HEADER" > $SUMMARY_OUT
        test_exit_status
    fi 
}

# given a UUID, return sample name based on lookup in BAM_MAP
function get_sample_name {
    UUID=$1

    SN=$(awk -v uuid=$UUID 'BEGIN{FS="\t";OFS="\t"}{if ($10 == uuid) print $1}' $BAM_MAP)
    if [ -z "$SN" ]; then
        >&2 echo ERROR: UUID $UUID not found in $BAM_MAP
        exit 1
    fi
    if [ $(echo "$SN" | wc -l) != "1" ]; then
        >&2 echo "ERROR: multiple samples found for UUID $UUID: $SN"
        exit 1
    fi
    echo $SN
}

# given a UUID, return disease based on lookup in BAM_MAP
# This is very similar to get_sample_name
# Return multiple values based on https://stackoverflow.com/questions/2488715/idioms-for-returning-multiple-values-in-shell-scripting
#get_vars () {
#  #...
#  echo "value1" "value2"
#}
#
#read var1 var2 < <(get_vars)
function get_sample_case_disease {
    UUID=$1

    CD=$(awk -v uuid=$UUID 'BEGIN{FS="\t";OFS="\t"}{if ($10 == uuid) print $2,$3}' $BAM_MAP)
    if [ -z "$CD" ]; then
        >&2 echo ERROR: UUID $UUID not found in $BAM_MAP
        exit 1
    fi
    if [ $(echo "$CD" | wc -l) != "1" ]; then
        >&2 echo "ERROR: multiple samples found for UUID $UUID: $CD"
        exit 1
    fi
    echo $CD
}

function make_summary {
    RUN_NAME=$1

    # find RUN_NAME in RUN_LIST; the matching line provides arguments to PARAM_SCRIPT
    SARGS=$(awk -v run_name=$RUN_NAME '{if ($1 == run_name) print}' $RUN_LIST)

    if [ $TUMOR_NORMAL ]; then
        TUMOR_UUID=$(echo "$SARGS" | cut -f 3)
        TUMOR_SN=$(get_sample_name $TUMOR_UUID)
        NORMAL_UUID=$(echo "$SARGS" | cut -f 4)
        NORMAL_SN=$(get_sample_name $NORMAL_UUID)
        read CASE DIS < <(get_sample_case_disease $TUMOR_UUID)
    else
        SAMPLE_UUID=$(echo "$SARGS" | cut -f 3)
        SAMPLE_SN=$(get_sample_name $SAMPLE_UUID)
        read CASE DIS < <(get_sample_case_disease $SAMPLE_UUID)
    fi

    # Evaluate only runs which have status Succeeded
    STATUS=$( $CROMWELL_QUERY -V -q status $RUN_NAME )
    test_exit_status
    if [ "$STATUS" != "Succeeded" ]; then
        if [ $ONLYWARN ]; then
            >&2 echo WARNING: $RUN_NAME status is $STATUS.  Continuing
        else
            >&2 echo Skipping $RUN_NAME because status = $STATUS
            return
        fi
    fi

    RESULT_FILES=$($CROMWELL_QUERY -V -q outputs $RUN_NAME)
    test_exit_status

    # Iterate over all result files - there may be more than one
    for RF in $RESULT_FILES; do

        confirm $RF $ONLYWARN  # complain if result file does not exist

        # if result file does not exist and we have ONLYWARN turned on, skip writing file (so that output has only existing files)
        if [ ! -s $RF ]; then
            >&2 echo WARNING: $RF does not exist.  Skipping
            continue
        fi

        WID=` $CROMWELL_QUERY -V -q wid $RUN_NAME `
        test_exit_status

        # https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
        BASE="${RF##*/}"
        EXT="${BASE##*.}"
        # File format is just upper case of EXT for now
        FILE_FORMAT=${EXT^^}        # https://stackoverflow.com/questions/11392189/how-to-convert-a-string-from-uppercase-to-lowercase-in-bash

        # If RESTART_MAP is defined, get RESTART_D as RESTART_ROOT/UUID
        if [ ! -z $RESTART_MAP ]; then
            RESTART_D=$(get_restartd $RUN_NAME $RESTART_MAP)
            test_exit_status
            OUTLINE=$(printf "$RUN_NAME\t$CASE\t$DIS\t$RF\t$FILE_FORMAT\t$TUMOR_SN\t$TUMOR_UUID\t$NORMAL_SN\t$NORMAL_UUID\t$WID\t$RESTART_D\n" )
        else
            OUTLINE=$(printf "$RUN_NAME\t$CASE\t$DIS\t$RF\t$FILE_FORMAT\t$TUMOR_SN\t$TUMOR_UUID\t$NORMAL_SN\t$NORMAL_UUID\t$WID\n" )
        fi

        if [ $SUMMARY_OUT == "-" ]; then
            echo "$OUTLINE"
        else
            echo "$OUTLINE" >> $SUMMARY_OUT
            test_exit_status
        fi 
    done
}

# this allows us to get run names in one of three ways:
# 1: summarize_runs.sh RUN_NAME1 RUN_NAME2 ...
# 2: cat cases.dat | summarize_runs.sh -
# 3: read from RUN_LIST file
# Note that if no run names defined, assume RUN_NAME='-'
if [ "$#" == 0 ]; then
    confirm "$RUN_LIST" $ONLYWARN
    RUN_NAMES=$(cat $RUN_LIST | cut -f 1)
elif [ "$1" == "-" ] ; then
    RUN_NAMES=$(cat - )
else
    RUN_NAMES="$@"
fi

init_summary

for L in $RUN_NAMES; do
    RUN_NAME=$(echo "$L" | cut -f 1)

    >&2 echo Processing $RUN_NAME 

    make_summary $RUN_NAME  

    if [ $JUSTONE ]; then
        >&2 echo Quitting after one
        break
    fi
done

if [ $SUMMARY_OUT != "-" ]; then
    >&2 echo Written to $SUMMARY_OUT
fi
