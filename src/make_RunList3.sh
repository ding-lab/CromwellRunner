#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Utility for making RunList file from a list of cases and Catalog3 data

Usage:
  make_RunList3.sh [options] CASE_NAMES

Options:
-h: Print this help message
-v: verbose output
-C CATALOG: Catalog3 file.  Required
-o OUT: output file.  Default: UUID_MAP.dat
-r ALIGNMENT: Alignment, for matching in CATALOG. Default: harmonized
-e ES: Experimental strategy, for matching in CATALOG. Default: WXS
-G GERMLINE_ST: Run in germline mode, with given sample type used
-T TUMOR_ST: Sample type to use for tumor.  Default: tumor
-N NORMAL_ST: Sample type to use for tumor.  Default: blood_normal
-W: In case of missing data print warning and mark data as such

Iterate over all CASEs in CASE_NAMES and create a RUN_NAME associated with each
tumor sample for that case.  Assume only one normal exists.

By default, a tumor/normal RUN_LIST is created.  This has the output with the columns,
* RUN_NAME   CASE    TUMOR_UUID  NORMAL_UUID

If germline mode (-G) is defined, the output has the columns
* RUN_NAME   CASE    SAMPLE_UUID
where the sample chosen is defined by GERMLINE_ST (e.g., 'tumor' or 'blood_normal')

In instances where there is only one tumor sample, RUN_NAME and CASE are the same.
For cases with multiple samples for tumor, the run name will consist of 
the case name with a suffix; for instance, C3L-00103.HET_oymKX

If -W (WARN_MISSING) is defined, and if a given file is not available in CATALOG file, it is marked as "MISSING"
It is assumed that if a file is in Catalog it is available in house.  May wish to use a in-house catalog
file which contains entries only for datasets available in house, which can be created with,
    fgrep <(cut -f 2 BAMMAP) CATALOG > in-house.CATALOG.dat

<OUTDATED>
We'll make assumption that sample_name in BamMap is unique and use that as the
unique way to identify runs of same case.  Currently the run name is derived from
the tumor sample name 
        RUN_NAME=$(echo $TUMOR_SN | sed "s/${ES}.T.//" | sed 's/.hg38//')
This is very specific to how CPTAC3 names samples and should be generalized
It is obtained as ANN_SUFFIX here: https://github.com/ding-lab/CPTAC3.case.discover/blob/master/src/make_catalog.sh#L579
  and aims to provide a unique name to sample names when a case has more than one tumor sample,
  with annotation details provided by GDC

for tumor sample_name =
C3L-00103.WXS.T.HET_oymKX.hg38, run name looks like C3L-00103.HET_oymKX
</OUTDATED>
EOF

OUT="UUID_MAP.dat"
ALIGNMENT="harmonized"
ES="WXS"
TUMOR_ST="tumor"
NORMAL_ST="blood_normal"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":ho:C:r:e:G:T:N:Wv" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    o) 
      OUT=$OPTARG
      ;;
    C) 
      CATALOG=$OPTARG
      ;;
    r) 
      ALIGNMENT=$OPTARG
      ;;
    e) 
      ES=$OPTARG
      ;;
    G) 
      GERMLINE_ST=$OPTARG
      ;;
    T) 
      TUMOR_ST=$OPTARG
      ;;
    N) 
      NORMAL_ST=$OPTARG
      ;;
    W)
      WARN_MISSING=1
      ;;
    v)
      VERBOSE=1
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG"
      echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument."
      echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))


if [ "$#" -ne 1 ]; then
    >&2 echo Error: Wrong number of arguments
    echo "$USAGE"
    exit 1
fi

CASES=$1

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

# Return one or more sample names associated with given sample type
# Usage:
#    SNS=$(get_sample_names CASE ST MULTI_OK )
# ST is sample type, "blood_normal" or "tumor" typically
# It is an error if no matches are found (change to a warning with -W flag)
# If more than one match is found,
#   * if MULTI_OK is 1, check to make sure that sample names unique
#       * return all matches if they are unique
#       * Error if sample names not all unique
#   * if MULTI_OK is not 1, exit with an error
#   
# Catalog3 format
#     1  dataset_name
#     2  case
#     3  disease
#     4  experimental_strategy
#     5  sample_type
#     6  specimen_name
#     7  filename
#     8  filesize
#     9  data_format
#    10  data_variety
#    11  alignment
#    12  project
#    13  uuid
#    14  md5
#    15  metadata

function get_sample_names {
    # CATALOG, ES, ALIGNMENT  as global
    CASE=$1
    ST=$2
    MULTI_OK=$3
    # CATALOG, ES, ALIGNMENT  as global

    LINE_A=$(awk -v c=$CASE -v ref=$ALIGNMENT -v es=$ES -v st=$ST 'BEGIN{FS="\t";OFS="\t"}{if ($2 == c && $4 == es && $5 == st && $11 == ref) print}' $CATALOG)

    if [ -z "$LINE_A" ]; then
        if [ -z "$WARN_MISSING" ]; then
            >&2 echo ERROR: $ALIGNMENT $CASE $ES $ST sample not found in $CATALOG
            exit 1
        else
            >&2 echo WARNING: $ALIGNMENT $CASE $ES $ST sample not found in $CATALOG .  Marking sample_name \"MISSING\"
            printf "MISSING"
            return
        fi
    fi

    SNS=$(echo "$LINE_A" | cut -f 1)

    if [ $(echo "$LINE_A" | wc -l) != "1" ]; then
        if [ $MULTI_OK == 1 ]; then
            # confirm sample names are unique
            SNA_N=$(echo "$SNS" | wc -l)
            SNA_UN=$(echo "$SNS" | sort -u | wc -l)
            if [ "$SNA_N" != "$SNA_UN" ] ; then
                >&2 echo "ERROR: non-unique $ST sample names for case $CASE : $SNS"
                exit 1      # Quitting because malformed RunList otherwise
            fi
        else
            >&2 echo "ERROR: multiple $ST samples found for case $CASE: $SNS"
            exit 1
        fi
    fi

    printf "$SNS" 

}

# Return one sample name associated with normal.  Error if more than one
function get_blood_normal_sample_name {
    # CATALOG, ES, ALIGNMENT  as global
    CASE=$1
    ST="blood_normal"
    # CATALOG, ES, ALIGNMENT as global
    # MULTI_OK is 0, since expect single normal
    SNS=$(get_sample_names $CASE $ST 0 )
    test_exit_status

    printf "$SNS" 

}

# Return all sample names associated with tumor
function get_tumor_sample_names {
    CASE=$1
    ST="tumor"
    # MULTI_OK is 1, since multiple tumors samples OK
    SNS=$(get_sample_names $CASE $ST 1 )
    test_exit_status

    printf "$SNS"
}

function log {
    if [ $VERBOSE ]; then
        >&2 echo "$1"
    fi
}

if [ -z $CATALOG ]; then 
    >&2 echo ERROR: CATALOG not defined
    exit 1
fi
if [ ! -e $CATALOG ]; then 
    >&2 echo ERROR: CATALOG does not exist: $CATALOG
    exit 1
fi
if [ ! -e $CASES ]; then 
    >&2 echo ERROR: CASES does not exist: $CASES
    exit 1
fi

rm -f $OUT
touch $OUT

# convert a tumor sample name like 
#   C3L-00103.WXS.T.HET_oymKX.hg38 
# to the corresponding run name,
#   C3L-00103.HET_oymKX
# the ANN_SUFFIX (annotation suffix, e.g., HET_oymKX) is recovered from the sample name
# ad hoc.  This string is initially generated here during catalog creation: 
#   https://github.com/ding-lab/CPTAC3.case.discover/blob/master/src/make_catalog.sh
# However, is not easily available in a BamMap file except with some ad hoc parsing of sample name
# The aim is to provide a unique name to sample names when a case has more than one tumor sample,
#   with annotation details provided by GDC
# In the future, it will be more convenient to simply parse the catalog file annotation
function get_tumor_run_name {
    TSN=$1
    # Change C3L-00103.WXS.T.HET_oymKX.hg38 to C3L-00103.HET_oymKX
    # This doesn't play well with e.g. Tbm  but whatever
    RUN_NAME=$(echo $TSN | sed "s/${ES}.T.//" | sed 's/.hg38//')
    test_exit_status

    echo "$RUN_NAME"
}

function get_any_run_name {
    TSN=$1
    # Change C3L-00103.WXS.T.HET_oymKX.hg38 to C3L-00103.HET_oymKX
    # This doesn't play well with e.g. Tbm but whatever
    RUN_NAME=$(echo $TSN | sed "s/${ES}\.T\.//" | sed "s/${ES}\.N\.//" | sed "s/${ES}\.A\.//" | sed 's/.hg38//')
    test_exit_status

    echo "$RUN_NAME"
}

while read CD; do

    CASE=$(echo "$CD" | cut -f 1)

    log "DEBUG: CASE = $CASE"
    if [ -z $GERMLINE_ST ]; then    # do tumor / normal
        # Assume there is just blood normal per case
        log "DEBUG: tumor / normal mode.  NORMAL_ST = $NORMAL_ST, TUMOR_ST = $TUMOR_ST"
        NORMAL_SN=$(get_sample_names $CASE $NORMAL_ST 0 )
        test_exit_status
        log "DEBUG: NORMAL_SN = $NORMAL_SN"
        unset NORMAL_UUID
        NORMAL_UUID=$(grep $NORMAL_SN $CATALOG | cut -f 13)   # TODO: Deal gracefully with missing value (-W)
        test_exit_status
        if [ -z "$NORMAL_UUID" ]; then
            NORMAL_UUID="MISSING"
        fi
        log "DEBUG: NORMAL_UUID = $NORMAL_UUID"

        # MULTI_OK is 1, since multiple tumors samples OK
        TUMOR_SNS=$(get_sample_names $CASE $TUMOR_ST 1 )
        test_exit_status
        log "DEBUG: TUMOR_SNS = $TUMOR_SNS"

        if [ "$TUMOR_SNS" == "MISSING" ]; then
            printf "${CASE}-bad_run\t$CASE\tMISSING\t$NORMAL_UUID\n" >> $OUT
        else
            for TSN in $TUMOR_SNS; do
                T_UUID=$(awk -v tsn=$TSN 'BEGIN{FS="\t";OFS="\t"}{if ($1 == tsn) print}' $CATALOG | cut -f 13)

                RUN_NAME=$(get_tumor_run_name $TSN)
                log "DEBUG: RUN_NAME = $RUN_NAME"

                test_exit_status
                printf "$RUN_NAME\t$CASE\t$T_UUID\t$NORMAL_UUID\n" >> $OUT
            done
        fi
    else
        # note, this may need some work
        # Get sample names for case based on GERMLINE_ST as sample type, and multiple samples OK
        log "DEBUG: Germline mode : $GERMLINE_ST"
        SNS=$(get_sample_names $CASE $GERMLINE_ST 1 ) # here, GERMLINE_ST has to be name
        test_exit_status
        log "DEBUG: SNS = $SNS"


        if [ $TUMOR_SNS == "MISSING" ]; then
            printf "${CASE}-bad_run\t$CASE\tMISSING\n" >> $OUT
        else
            for SN in $SNS; do
                S_UUID=$(awk -v sn=$SN 'BEGIN{FS="\t";OFS="\t"}{if ($1 == sn) print}' $CATALOG | cut -f 13)
                log "DEBUG: S_UUID = $S_UUID"

                # Change C3L-00103.WXS.T.HET_oymKX.hg38 to C3L-00103.HET_oymKX
                RUN_NAME=$(get_any_run_name $SN )  # but here, has to be a code
                log "DEBUG: RUN_NAME = $RUN_NAME"
                test_exit_status
                printf "$RUN_NAME\t$CASE\t$S_UUID\n" >> $OUT
            done
        fi
    fi
        

done < $CASES

>&2 echo Written to $OUT 
