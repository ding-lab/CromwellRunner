#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Utility for making RUN_LIST file from a list of cases.

Usage:
  make_RUN_LIST.sh [options] BAM_MAP CASE_NAMES

Options:
-h: Print this help message
-o OUT: output file.  Default: UUID_MAP.dat
-r REF_NAME: reference name, for matching in BAM_MAP. Default: hg38
-e ES: Experimental strategy, for matching in BAM_MAP. Default: WXS
-G GST: Run in germline mode, with given sample type used

Iterate over all CASEs in CASE_NAMES and create a RUN_NAME associated with each
tumor sample for that case.  Assume only one normal exists.

By default, a tumor/normal RUN_LIST is created.  This has the output with the columns,
* RUN_NAME   CASE    TUMOR_UUID  NORMAL_UUID

If germline mode (-G) is defined, the output has the columns
* RUN_NAME   CASE    SAMPLE_UUID
where the sample chosen is defined by ST (e.g., 'tumor' or 'blood_normal')

In instances where there is only one tumor sample, RUN_NAME and CASE are the same.
For cases with multiple samples for tumor, the run name will consist of 
the case name with a suffix; for instance, C3L-00103.HET_oymKX

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
EOF

OUT="UUID_MAP.dat"
REF_NAME="hg38"
ES="WXS"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":ho:r:e:G:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    o) 
      OUT=$OPTARG
      ;;
    r) 
      REF_NAME=$OPTARG
      ;;
    e) 
      ES=$OPTARG
      ;;
    G) 
      GST=$OPTARG
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


if [ "$#" -ne 2 ]; then
    >&2 echo Error: Wrong number of arguments
    echo "$USAGE"
    exit 1
fi

BAM_MAP=$1
CASES=$2

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
# It is an error if no matches are found
# If more than one match is found,
#   * if MULTI_OK is 1, check to make sure that sample names unique
#       * return all matches if they are unique
#       * Error if sample names not all unique
#   * if MULTI_OK is not 1, exit with an error
#   
function get_sample_names {
    # BAM_MAP, ES, REF_NAME  as global
    CASE=$1
    ST=$2
    MULTI_OK=$3
    # BAM_MAP, ES, REF_NAME  as global

    LINE_A=$(awk -v c=$CASE -v ref=$REF_NAME -v es=$ES -v st=$ST 'BEGIN{FS="\t";OFS="\t"}{if ($2 == c && $4 == es && $5 == st && $9 == ref) print}' $BAM_MAP)

    if [ -z "$LINE_A" ]; then
        >&2 echo ERROR: $REF_NAME $CASE $ES $ST sample not found in $BAM_MAP
        exit 1
    fi

    SNS=$(echo "$LINE_A" | cut -f 1)

    if [ $(echo "$LINE_A" | wc -l) != "1" ]; then
        if [ $MULTI_OK == 1 ]; then
            # confirm sample names are unique
            SNA_N=$(echo "$SNS" | wc -l)
            SNA_UN=$(echo "$SNS" | sort -u | wc -l)
            if [ "$SNA_N" != "$SNA_UN" ] ; then
                >&2 echo "ERROR: non-unique $ST sample names for case $CASE : $SNS"
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
    # BAM_MAP, ES, REF_NAME  as global
    CASE=$1
    ST="blood_normal"
    # BAM_MAP, ES, REF_NAME as global
    # MULTI_OK is 0, since expect single normal
    SNS=$(get_sample_names $CASE $ST 0 )

    printf "$SNS" 

}

# Return all sample names associated with tumor
function get_tumor_sample_names {
    CASE=$1
    ST="tumor"
    # MULTI_OK is 1, since multiple tumors samples OK
    SNS=$(get_sample_names $CASE $ST 1 )

    printf "$SNS"
}

if [ ! -e $BAM_MAP ]; then 
    >&2 echo ERROR: BAM_MAP does not exist: $BAM_MAP
    exit
fi
if [ ! -e $CASES ]; then 
    >&2 echo ERROR: CASES does not exist: $CASES
    exit
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
function get_tumor_run_name {
    TSN=$1
    # Change C3L-00103.WXS.T.HET_oymKX.hg38 to C3L-00103.HET_oymKX
    RUN_NAME=$(echo $TSN | sed "s/${ES}.T.//" | sed 's/.hg38//')
    test_exit_status

    echo "$RUN_NAME"
}

function get_any_run_name {
    TSN=$1
    # Change C3L-00103.WXS.T.HET_oymKX.hg38 to C3L-00103.HET_oymKX
    RUN_NAME=$(echo $TSN | sed "s/${ES}\.T\.//" | sed 's/.hg38//')
    test_exit_status

    echo "$RUN_NAME"
}

while read CASE; do

    if [ -z $GST ]; then    # do tumor / normal
        # Assume there is just blood normal per case
        NORMAL_SN=$(get_blood_normal_sample_name $CASE)
        test_exit_status
        NORMAL_UUID=$(grep $NORMAL_SN $BAM_MAP | cut -f 10)  
        test_exit_status

        TUMOR_SNS=$(get_tumor_sample_names $CASE )
        test_exit_status

        for TSN in $TUMOR_SNS; do
            T_UUID=$(grep $TSN $BAM_MAP | cut -f 10)
            RUN_NAME=$(get_tumor_run_name $TSN)

            test_exit_status
            printf "$RUN_NAME\t$CASE\t$T_UUID\t$NORMAL_UUID\n" >> $OUT
        done
    else
        # note, this may need some work
        # Get sample names for case based on GST as sample type, and multiple samples OK
        SNS=$(get_sample_names $CASE $GST 1 ) # here, GST has to be name
        test_exit_status
        for SN in $SNS; do
            S_UUID=$(grep $SN $BAM_MAP | cut -f 10)

            # Change C3L-00103.WXS.T.HET_oymKX.hg38 to C3L-00103.HET_oymKX
            RUN_NAME=$(get_any_run_name $SN )  # but here, has to be a code
            test_exit_status
            printf "$RUN_NAME\t$CASE\t$S_UUID\n" >> $OUT
        done
    fi
        

done < $CASES

>&2 echo Written to $OUT 
