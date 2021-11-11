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

function expand_SomaticCNV_results {

    DATAD=$1

    if [ ! -d $DATAD ]; then
        >&2 echo ERROR: $DATAD is not a directory
        exit 1
    else
        >&2 echo OK: $DATAD is a directory
    fi

    if [ -d $DATAD/call-annotation/execution ]; then
        >&2 echo WARNING: /call-annotation/execution exists, looks like results are uncompressed.  Moving on
        return
    else
        >&2 echo OK: /call-annotation/execution does not exist.  Candidate for expand
    fi
 
    if [ ! -f $DATAD/$TAR_NAME ]; then
        >&2 echo ERROR: TAR file $TAR_NAME does not exist
        exit 1
    else
        >&2 echo OK: TAR file $TAR_NAME exists
    fi
        
    # CMD="tar -C $DATAD -zxf $DATAD/$TAR_NAME ./call-segmentation/execution ./call-annotation/execution"
    CMD="tar -C $DATAD -zxf $DATAD/$TAR_NAME ./call-segmentation/execution ./call-annotation/execution ./call-normalize_normal/execution/norm/results/excess_zeros ./call-normalize_tumor/execution/norm/results/excess_zeros"

    >&2 echo RUNNING: $CMD
    eval $CMD

    rc=$?
    if [[ $rc != 0 ]]; then
        >&2 echo Fatal ERROR $rc: $!.  Exiting.
        exit $rc;
    fi

}

while read DATAD; do

    expand_SomaticCNV_results $DATAD
    echo "-----" 

done <$DAT

