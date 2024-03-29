#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Usage: get_pipeline_params.TinJasmine.sh [options] SAMPLE_NAME CASE SAMPLE_UUID 
  Review, initialize, and summarize runs

Options:
-h: print usage information
-P PARAMS: parameters file which holds varibles for substution in template, read via `source $PARAMS`.  Required
-g: Issue warnings rather than quitting for testing
-R RESTART_UUID: UUID for past workflow for restarting runs

get_pipeline_params.TinDaisy.sh returns a list of parameters in the form, "KEY1:VALUE1 KEY2:VALUE2 ..."

The following parameters are returned
    * SAMPLE_BAM
    * REF_PATH
    * RESTART_D
    * SAMPLE_BARCODE
    * PARAM_ROOT
    * VEP_CACHE_GZ
    * VEP_CACHE_VERSION
    * ASSEMBLY
    * CHRLIST
    * CANONICAL_BED

Source of info:
    * SAMPLE_BAM is defined by lookup of SAMPLE_UUID in BamMap 
    * RESTART_D is defined when -R flag is set
    * SAMPLE_BARCODE is defined by lookup of UUID in Catalog file
    * Remainder defined in PARAMS file

Restarting of runs is supported by making available RESTART_D variable in YAML
template, which provides path to root directory of prior run.
RESTART_D="RESTART_ROOT/RESTART_UUID", with RESTART_ROOT defined in PARAMS

Format of BamMap is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
EOF

source src/cromwell_utils.sh

SCRIPT=$(basename $0)

YAMLD="./yaml"
PYTHON="/usr/bin/python"

while getopts ":hP:gR:" opt; do
  case $opt in
    h)  
      echo "$USAGE"
      exit 0
      ;;
    P)  
      PARAMS="$OPTARG"
      ;;
    g) 
      ONLYWARN=1
      ;;
    R) 
      RESTART_UUID="$OPTARG"
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

SAMPLE_NAME=$1
CASE=$2
SAMPLE_UUID=$3

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

# init_params reads PARAMS and confirms existence of necessary files
# Parameters processed here are not passed to TemplateParser.py directly
function init_params_common {
    if [ -z $PARAMS ]; then
        >&2 echo ERROR: Parameter file  not defined \(-P\)
        >&2 echo "$USAGE"
        exit 1
    fi
    confirm $PARAMS $ONLYWARN

    source $PARAMS

    if [ -z $BAMMAP ]; then
        complain "BAMMAP not defined in $PARAMS" $ONLYWARN
        BAMMAP="undefined"
    else
        confirm $BAMMAP $ONLYWARN
    fi
}

# add KEY:VALUE pairs to BATCH_PARAM_KV
# It is an error if a given value is not defined, unless EMPTY_OK is 1
function push_params_kv {
    KEY=$1
    VALUE=$2
    EMPTY_OK=$3  # this doesn't work, since this fills $2 when $2 is empty

    if [ -z $VALUE ]; then
        if [ $EMPTY_OK == 1 ]; then
            >&2 echo NOTE: Value associated with key $KEY is empty, proceeding
        else
            >&2 echo ERROR: Value associated with key $KEY is empty
            exit 1
        fi
    fi
    BATCH_PARAM_KV="$BATCH_PARAM_KV ${KEY}:${VALUE}"
    # BATCH_PARAM_KV is a global
}

# go through and set BATCH_PARAMS_KV for each parameter needed for this workflow
function init_params_kv {
    BATCH_PARAM_KV=""
    push_params_kv REF_PATH $REF_PATH
    push_params_kv PARAM_ROOT $PARAM_ROOT
    push_params_kv VEP_CACHE_GZ $VEP_CACHE_GZ
    push_params_kv VEP_CACHE_VERSION $VEP_CACHE_VERSION
    push_params_kv ASSEMBLY $ASSEMBLY
    push_params_kv CHRLIST $CHRLIST
    push_params_kv CANONICAL_BED $CANONICAL_BED
    if [ ! -z $VAF_RESCUE_BED ]; then
        push_params_kv VAF_RESCUE_BED $VAF_RESCUE_BED 
    fi
}

# Goal of kv parameter parsing is to build up a string PARAM_KV consisting of "key1:value1" pairs, e.g.,
# PARAM_KV="TUMOR_BAM:/path/to/file NORMAL_BAM:/path/to/file ..."
# such a string consists of parameters common to the entire batch and those specific to a particular case
init_params_common
init_params_kv

# Usage:
#   get_BAM UUID
#   Obtain BAM information based on UUID lookup in BAMMAP 
# Returns "BAM_path sample_name UUID Disease"
function get_BAM {
    UUID=$1
    # BAMMAP is global

    # BamMap columns
    #     1  sample_name
    #     2  case
    #     3  disease
    #     4  experimental_strategy
    #     5  sample_type
    #     6  data_path
    #     7  filesize
    #     8  data_format
    #     9  reference
    #    10  UUID
    #    11  system

    LINE_A=$(grep $UUID $BAMMAP)

    if [ -z "$LINE_A" ]; then
        >&2 echo ERROR: ES $UUID sample not found in $BAMMAP
        exit 1
    elif [ $(echo "$LINE_A" | wc -l) != "1" ]; then
        >&2 echo ERROR: $UUID sample has multiple matches in $BAMMAP
        exit 1
    fi

    # Sample Name and UUID will be needed for analysis summary
    SN=$(echo "$LINE_A" | cut -f 1)
    DIS=$(echo "$LINE_A" | cut -f 3)
    BAM=$(echo "$LINE_A" | cut -f 6)
    UUID=$(echo "$LINE_A" | cut -f 10)

    printf "$BAM\t$SN\t$UUID\t$DIS"
}

# Obtain aliquot name associated with given UUID from Catalog file
#  Catalog files come from here: https://github.com/ding-lab/CPTAC3.catalog
#  and aliquot names are column 6
# TODO: allow aliquot names to be obtained even if Catalog file does not exist
#  An option is pass a fake catalog file with two columns, UUID and Aliquot, and 
#  check here how many columns the catalog file has.
function get_aliquot {
    UUID=$1
    CATALOG=$2
#$ header CPTAC3.Catalog.dat
#     1  # sample_name
#     2  case
#     3  disease
#     4  experimental_strategy
#     5  short_sample_type
#     6  aliquot
#     7  filename
#     8  filesize
#     9  data_format
#    10  result_type
#    11  UUID
#    12  MD5
#    13  reference
#    14  sample_type

    LINE_A=$(grep $UUID $CATALOG)
    if [ -z "$LINE_A" ]; then
        >&2 echo ERROR: UUID $UUID not found in $CATALOG
        exit 1
    elif [ $(echo "$LINE_A" | wc -l) != "1" ]; then
        >&2 echo ERROR: UUID $UUID has multiple matches in $CATALOG
        exit 1
    fi
    ALIQUOT=$(echo "$LINE_A" | cut -f 6)
    printf "$ALIQUOT"
}

# Returns base directory of prior run and confirms it exists
# Error if CASE does not appear in RESTART_MAP exactly once
function get_restartd {
    RESTART_UUID=$1

    RESTART_D="$RESTART_ROOT/$RESTART_UUID"
    if [ ! -s $RESTART_D ]; then
        if [ $ONLYWARN ]; then
            >&2 echo WARNING: $RESTART_D is not an existing directory.  Continuing
        else
            >&2 echo ERROR: $RESTART_D is not an existing directory
            exit 1
        fi
    fi
    printf "$RESTART_D"
}

SAMPLE=$(get_BAM $SAMPLE_UUID)
test_exit_status

SAMPLE_BAM=$(echo "$SAMPLE" | cut -f 1)

PARAM_KV="$BATCH_PARAM_KV SAMPLE_BAM:$SAMPLE_BAM"

# If RESTART_MAP is defined, get RESTART_D as RESTART_ROOT/UUID
if [ ! -z $RESTART_UUID ]; then
    RESTART_D=$(get_restartd $RESTART_UUID)
    test_exit_status
    PARAM_KV="$PARAM_KV RESTART_D:$RESTART_D"
fi

# Get barcode for tumor and normal
# If $CATALOG is defined, obtain NORMAL_BARCODE and _TUMOR based on aliquot column using lookup of UUID
# if CATALOG not defined, NORMAL_BARCODE = NORMAL and TUMOR_BARCODE = TUMOR
if [ ! -z $CATALOG ]; then
    SAMPLE_BARCODE=$(get_aliquot $SAMPLE_UUID $CATALOG) 
else
    >&2 echo NOTE: CATALOG not defined in Project Config file, using placeholder sample barcode
    SAMPLE_BARCODE="SAMPLE"
fi
# note that SomaticSV does not need barcodes, but it is not clear how to define this necessity
PARAM_KV="$PARAM_KV SAMPLE_BARCODE:$SAMPLE_BARCODE"
    
echo $PARAM_KV
