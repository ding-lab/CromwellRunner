# Generate cromwell config file

# Usage:
#   3_make_config.sh PARAMS

# this usage is inconsistent with usage of 2_, a consequence of the fact that make_config.sh
# does not parse args.  Arguably, make_config functionality should be combined
# with runplan; it differs from YAML file creation because it is generated once per project

# This is sourced both here and in make_yaml.sh to fill out template parameters
#PARAMS="workflow.MutectDemo/project_config.compute1.sh"
#source $PARAMS  

PARAMS="Project.config.sh"

if [ ! -f $PARAMS ]; then 
    echo $PARAMS  does not exist
    exit 1
fi
source $PARAMS

>&2 echo Writing Cromwell config file to $CONFIG_FILE

mkdir -p $(dirname $CONFIG_FILE)
bash src/make_config.sh $CONFIG_TEMPLATE $WORKFLOW_ROOT > $CONFIG_FILE
