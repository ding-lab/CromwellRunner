DAT="paths.dat"

TAR_NAME=compressed_results.tar.gz

# NOTE: call-normalize_normal/execution/norm/results/excess_zeros/excess_zeros_observed.dat
# and the tumor counterpart must also be expanded, otherwise this error condition will not be caught

>&2 echo WARNING: current implementation ignores excess_zeros_observed flag

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
        
    CMD="tar -C $DATAD -zxf $DATAD/$TAR_NAME ./call-segmentation/execution ./call-annotation/execution"

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

