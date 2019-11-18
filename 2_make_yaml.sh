# Generate YAML and cromwell config files

# Note that running `runplan` will give back useful information about anticipated runs

# This is sourced both here and in make_yaml.sh to fill out template parameters
PARAMS="config/project_config.MMRF-restart.sh"
source $PARAMS  # we just care about TD_ROOT

RESTART_MAP="dat/MMRF-20190925.map.dat"

>&2 echo Writing YAML files
$TD_ROOT/src/runplan -P $PARAMS -x yaml -R $RESTART_MAP "$@" 

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

>&2 echo Writing Cromwell config file to $CONFIG_FILE

mkdir -p $(dirname $CONFIG_FILE)
$TD_ROOT/src/make_config.sh $CONFIG_TEMPLATE $WORKFLOW_ROOT > $CONFIG_FILE

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

