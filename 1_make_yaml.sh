# Generate YAML and cromwell config files

# Note that running `runplan` will give back useful information about anticipated runs

# This is sourced both here and in make_yaml.sh to fill out template parameters
PARAMS="config/project_config.sh"
source $PARAMS  # we just care about TD_ROOT

>&2 echo Writing YAML files
$TD_ROOT/src/runplan -x yaml "$@" 

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

