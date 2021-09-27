# Generate YAML config files

# All arguments are passed as is to src/runplan

cd ..
PARAMS="Project.config.sh"
source $PARAMS

>&2 echo Writing YAML files
CMD="bash src/runplan -P $PARAMS -p $PARAM_SCRIPT -U $RUN_LIST -Y $YAML_TEMPLATE $@ "

>&2 echo Running: $CMD
eval $CMD

