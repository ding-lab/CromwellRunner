# Generate YAML config files

# Note that running `runplan` will give back useful information about anticipated runs

# This is sourced both here and in make_yaml.sh to fill out template parameters


PARAMS="workflow.MutectDemo/project_config.compute1.sh"
source $PARAMS  # we just care about TD_ROOT - is that true?

#RESTART_MAP="dat/MMRF-20190925.map.dat"

>&2 echo Writing YAML files
#src/runplan -P $PARAMS -x yaml -R $RESTART_MAP "$@" 
src/runplan -P $PARAMS -x yaml "$@" 

