# Ad hoc utility for making UUID_MAP files. 
# Here, we distinguish CASE from RUN_NAME; in most cases, these will be the same,
# but for cases with multiple samples for tumor, the run name will consist of 
# the case name with a suffix; for instance, C3N-02030.WGS.T.LMD_1JZV5R

# There are two files which are output: UUID_MAP_4.dat which has the columns,
# * RUN_NAME   CASE    TUMOR_UUID  NORMAL_UUID
# and UUID_MAP.dat, which is what is passed to the various scripts and has the columns,
# * RUN_NAME   TUMOR_UUID  NORMAL_UUID
#
# If using UUID_MAP and there are instances where CASE != RUN_NAME, need to replace the contents of the file cases.dat
# with RUN_NAME


Note that each case will have a number of samples
# Output format:
# RUN_NAME   CASE    TUMOR_UUID  NORMAL_UUID

# We'll make assumption that sample_name in BamMap is unique and use that as the unique pway to identify 
# runs of same case.  for tumor sample_name = C3L-00103.WXS.T.HET_oymKX.hg38, run name looks like C3L-00103.HET_oymKX
# Also assume that there is just one normal per sample

CASES="../dat/cases.dat"  # these are the real cases
#BAMMAP="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/BamMap/MGI.BamMap.dat"
BAMMAP="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog/BamMap/storage1.BamMap.dat"
OUT="../dat/UUID_MAP_4.dat"
OUT2="../dat/UUID_MAP.dat"
rm -f $OUT
touch $OUT

REF_NAME="hg38"
#ES="WXS"
ES="WGS"

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
    # BAMMAP, ES, REF_NAME  as global
    CASE=$1
    ST="blood_normal"
    # BAMMAP, ES, REF_NAME  as global

    LINE_A=$(awk -v c=$CASE -v ref=$REF_NAME -v es=$ES -v st=$ST 'BEGIN{FS="\t";OFS="\t"}{if ($2 == c && $4 == es && $5 == st && $9 == ref) print}' $BAMMAP)

    if [ -z "$LINE_A" ]; then
        >&2 echo ERROR: $REF_NAME $CASE $ES $ST sample not found in $BAMMAP
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
    # BAMMAP, ES, REF_NAME  as global

    LINE_A=$(awk -v c=$CASE -v ref=$REF_NAME -v es=$ES -v st=$ST 'BEGIN{FS="\t";OFS="\t"}{if ($2 == c && $4 == es && $5 == st && $9 == ref) print}' $BAMMAP)

    if [ -z "$LINE_A" ]; then
        >&2 echo ERROR: $REF_NAME $CASE $ES $ST sample not found in $BAMMAP
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
 
while read CASE; do

    # Assume there is just blood normal per case
    NORMAL_SN=$(get_blood_normal_sample_name $CASE)
    test_exit_status
    NORMAL_UUID=$(grep $NORMAL_SN $BAMMAP | cut -f 10)  
    test_exit_status

    TUMOR_SNS=$(get_tumor_sample_names $CASE )
    test_exit_status

    for TSN in $TUMOR_SNS; do
        T_UUID=$(grep $TSN $BAMMAP | cut -f 10)

        # Change C3L-00103.WXS.T.HET_oymKX.hg38 to C3L-00103.HET_oymKX
        RUN_NAME=$(echo $TSN | sed 's/WXS.T.//' | sed 's/.hg38//')
        test_exit_status
        printf "$RUN_NAME\t$CASE\t$T_UUID\t$NORMAL_UUID\n" >> $OUT
    done

done < $CASES

cut -f 1,3,4 $OUT > $OUT2
>&2 echo Written to $OUT and $OUT2
