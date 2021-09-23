# Generate YAML config files

# Usage:
# 20_make_yaml.sh -P PARAMS

# All arguments are passed as is to src/runplan

# Note that running `runplan` with no arguments will give back useful information about anticipated runs
# perhaps add this as default?

PARAMS="Project.config.sh"

>&2 echo Writing YAML files
CMD="bash src/runplan -x yaml -P $PARAMS $@ "

>&2 echo Running: $CMD
eval $CMD

