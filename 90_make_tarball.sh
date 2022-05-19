# Make a tarball of all files in an analysis summary file
# This is not typically needed, but useful to share results 
# Note that 

PROJECT="25.GDAN_DLBCL-135"

AS="dat/analysis_summary-final.dat"

# the output file can get large
OUTD="/storage1/fs1/m.wyczalkowski/Active/tmp"
mkdir -p $OUTD
TAR="$OUTD/TinDaisy.${PROJECT}.outputs.tar.gz"

# Based on discussion here: https://stackoverflow.com/questions/18681595/tar-a-directory-but-dont-store-full-absolute-paths-in-the-archive

ROOT_DIR="/storage1/fs1/m.wyczalkowski/Active/cromwell-data/cromwell-workdir/cromwell-executions/tindaisy2.6.cwl"
# length of string above: 103

CMD="tar -czf $TAR -C $ROOT_DIR -T <(tail -n +2 $AS | cut -f 4 | cut -c 104-)"

>&2 echo RUNNING: $CMD
eval $CMD
