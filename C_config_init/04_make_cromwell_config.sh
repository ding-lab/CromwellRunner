# Generate cromwell config file

# CONFIG_TEMPLATE defines the template used used for `cromwell run`
# CONFIG_SERVER_TEMPLATE defines the template used used for `cromwell server`

PARAMS="Project.config.sh"

if [ ! -f $PARAMS ]; then 
    echo $PARAMS  does not exist
    exit 1
fi
source $PARAMS

mkdir -p $(dirname $CONFIG_FILE)
>&2 echo Writing Cromwell config file to $CONFIG_FILE
bash src/make_config.sh $CONFIG_TEMPLATE $WORKFLOW_ROOT > $CONFIG_FILE

mkdir -p $(dirname $CONFIG_SERVER_FILE)
>&2 echo Writing Cromwell server config file to $CONFIG_SERVER_FILE
bash src/make_config.sh $CONFIG_SERVER_TEMPLATE $WORKFLOW_ROOT > $CONFIG_SERVER_FILE


