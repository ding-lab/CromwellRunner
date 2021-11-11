# DAT is a filename to list of workflowRoot paths
# and may be created with `cq -x workflowRoot | cut -f 3`

DAT=$1
if [ -z $DAT ]; then
	>&2 echo ERROR: workflowRoot paths file not specified
	exit 1
fi
if [ ! -f $DAT ]; then
	>&2 echo ERROR: $DAT does not exist
	exit 1
fi

TAR_NAME=compressed_results.tar.gz

function expand_TinDaisy_results {

    DATAD=$1

    if [ ! -d $DATAD ]; then
        >&2 echo ERROR: $DATAD is not a directory
        exit 1
    else
        >&2 echo OK: $DATAD is a directory
    fi

    if [ -d $DATAD/call-snp_indel_proximity_filter/execution ]; then
        >&2 echo WARNING: /call-snp_indel_proximity_filter/execution exists, looks like results are uncompressed.  Moving on
        return
    else
        >&2 echo OK: /call-snp_indel_proximity_filter/execution does not exist.  Candidate for expand
    fi
 
    if [ ! -f $DATAD/$TAR_NAME ]; then
        >&2 echo ERROR: TAR file $TAR_NAME does not exist
        exit 1
    else
        >&2 echo OK: TAR file $TAR_NAME exists
    fi

        
    CMD="tar -C $DATAD -zxf $DATAD/$TAR_NAME ./call-snp_indel_proximity_filter/execution/output ./call-vcf2maf/execution/result.maf ./call-canonical_filter/execution/output"

    >&2 echo RUNNING: $CMD
    eval $CMD

    rc=$?
    if [[ $rc != 0 ]]; then
        >&2 echo Fatal ERROR $rc: $!.  Exiting.
        exit $rc;
    fi

}

while read DATAD; do

    expand_TinDaisy_results $DATAD
    echo "-----" 

done <$DAT

