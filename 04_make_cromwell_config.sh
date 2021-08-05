# Generate cromwell config file

# This is sourced both here and in make_yaml.sh to fill out template parameters
# CONFIG_TEMPLATE defines the specific template used

PARAMS="Project.config.sh"

if [ ! -f $PARAMS ]; then 
    echo $PARAMS  does not exist
    exit 1
fi
source $PARAMS

>&2 echo Writing Cromwell config file to $CONFIG_FILE

mkdir -p $(dirname $CONFIG_FILE)
bash src/make_config.sh $CONFIG_TEMPLATE $WORKFLOW_ROOT > $CONFIG_FILE
