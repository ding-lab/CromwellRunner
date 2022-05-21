# Generate YAML config files

# All arguments are passed as is to src/runplan

cd ..
PARAMS="Project.config.sh"
source $PARAMS
RESTART_MAP="dat/restart_map.dat"
RESTART_ARG="-R $RESTART_MAP"

>&2 echo Writing YAML files
CMD="bash src/runplan -P $PARAMS -p $PARAM_SCRIPT -U $RUN_LIST -Y $YAML_TEMPLATE $RESTART_ARG $@ "
#CMD="bash src/runplan -x yaml -P $PARAMS $RESTART_ARG $@ "

>&2 echo Running: $CMD
eval $CMD

