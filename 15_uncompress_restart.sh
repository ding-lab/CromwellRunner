source Project.config.sh

# Uncompress intermediate files from past run which will serve as input into 
# post-merge restart.  We will do this for all workflows in RESTART_MAP
# Details about RESTART_MAP here: workflows/restart/README.md

# This is sourced both here and in make_yaml.sh to fill out template parameters

export DATALOG

RESTART_MAP="dat/restart_map.dat"
RESULT_LIST="dat/uncompress_result_list.dat"

>&2 echo Uncompressing restart files
cut -f 2 $RESTART_MAP | bash src/datatidy -x uncompress_restart -P $RESULT_LIST "$@" -

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi
