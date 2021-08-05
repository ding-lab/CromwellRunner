#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Utility for making UUID_MAP files, which permit multiple runs for a given case when multiple tumor samples are present

Usage:
  make_UUID_MAP.sh [options] BAM_MAP CASE_NAMES

Options:
-h: Print this help message
-o OUT: output file.  Default: UUID_MAP.dat
-r REF_NAME: reference name, for matching in BAM_MAP. Default: hg38
-e ES: Experimental strategy, for matching in BAM_MAP. Default: WXS

Iterate over all CASEs in CASE_NAMES and create a RUN_NAME associated with each
tumor sample for that case.  Assume only one normal exists.

Output file UUID_MAP.dat has the columns,
* RUN_NAME   CASE    TUMOR_UUID  NORMAL_UUID

In instances where there is only one tumor sample, RUN_NAME and CASE are the same.
For cases with multiple samples for tumor, the run name will consist of 
the case name with a suffix; for instance, C3L-00103.HET_oymKX

Note, the file cases.dat is should be updated to be a list of RUN_NAME; an easy way to do this is just to use UUID_MAP 
in places of cases.dat

We'll make assumption that sample_name in BamMap is unique and use that as the unique way to identify 
runs of same case.  for tumor sample_name = C3L-00103.WXS.T.HET_oymKX.hg38, run name looks like C3L-00103.HET_oymKX

Assume that each run requires a tumor and normal sample
EOF

OUT="UUID_MAP.dat"
REF_NAME="hg38"
ES="WXS"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":ho:r:e:" opt; do
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

# Return one sample name associated with normal.  Error if more than one
function get_blood_normal_sample_name {
    # BAM_MAP, ES, REF_NAME  as global
    CASE=$1
    ST="blood_normal"
    # BAM_MAP, ES, REF_NAME  as global

    LINE_A=$(awk -v c=$CASE -v ref=$REF_NAME -v es=$ES -v st=$ST 'BEGIN{FS="\t";OFS="\t"}{if ($2 == c && $4 == es && $5 == st && $9 == ref) print}' $BAM_MAP)

    if [ -z "$LINE_A" ]; then
        >&2 echo ERROR: $REF_NAME $CASE $ES $ST sample not found in $BAM_MAP
        exit 1
    fi

    SNS=$(echo "$LINE_A" | cut -f 1)

    if [ $(echo "$LINE_A" | wc -l) != "1" ]; then
        >&2 echo "ERROR: multiple $ST samples found for case $CASE: $SNS"
        exit 1
    fi

    printf "$SNS" 

}

# Return all sample names associated with tumor
function get_tumor_sample_names {
    CASE=$1
    ST="tumor"
    # BAM_MAP, ES, REF_NAME  as global

    LINE_A=$(awk -v c=$CASE -v ref=$REF_NAME -v es=$ES -v st=$ST 'BEGIN{FS="\t";OFS="\t"}{if ($2 == c && $4 == es && $5 == st && $9 == ref) print}' $BAM_MAP)

    if [ -z "$LINE_A" ]; then
        >&2 echo ERROR: $REF_NAME $CASE $ES $ST sample not found in $BAM_MAP
        exit 1
    fi

    SNS=$(echo "$LINE_A" | cut -f 1)

    # confirm sample names are unique
    SNA_N=$(echo "$SNS" | wc -l)
    SNA_UN=$(echo "$SNS" | sort -u | wc -l)
    if [ "$SNA_N" != "$SNA_UN" ] ; then
        >&2 echo "ERROR: non-unique $ST sample names for case $CASE : $SNS"
    fi

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
 
while read CASE; do

    # Assume there is just blood normal per case
    NORMAL_SN=$(get_blood_normal_sample_name $CASE)
    test_exit_status
    NORMAL_UUID=$(grep $NORMAL_SN $BAM_MAP | cut -f 10)  
    test_exit_status

    TUMOR_SNS=$(get_tumor_sample_names $CASE )
    test_exit_status

    for TSN in $TUMOR_SNS; do
        T_UUID=$(grep $TSN $BAM_MAP | cut -f 10)

        # Change C3L-00103.WXS.T.HET_oymKX.hg38 to C3L-00103.HET_oymKX
        RUN_NAME=$(echo $TSN | sed "s/${ES}.T.//" | sed 's/.hg38//')
        test_exit_status
        printf "$RUN_NAME\t$CASE\t$T_UUID\t$NORMAL_UUID\n" >> $OUT
    done

done < $CASES

>&2 echo Written to $OUT 
