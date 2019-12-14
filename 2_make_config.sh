# Generate cromwell config file

# This is sourced both here and in make_yaml.sh to fill out template parameters
PARAMS="workflow.MutectDemo/project_config.compute1.sh"
source $PARAMS  

>&2 echo Writing Cromwell config file to $CONFIG_FILE

mkdir -p $(dirname $CONFIG_FILE)
src/make_config.sh $CONFIG_TEMPLATE $WORKFLOW_ROOT > $CONFIG_FILE
