# Generate YAML config files from RUNLIST4 file

pushd ..

PARAMS="Project.config.sh"
source $PARAMS

>&2 echo Writing YAML files
XARGS="-d"  # debugging
CMD="bash src/runplan $XARGS -P $PARAMS -p $PARAM_SCRIPT -U $RUN_LIST -Y $YAML_TEMPLATE $@ "

>&2 echo Running: $CMD
eval $CMD

popd
