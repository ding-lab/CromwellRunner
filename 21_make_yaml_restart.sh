# Generate YAML config files

# Usage:
# 20_make_yaml.sh -P PARAMS

# All arguments are passed as is to src/runplan

# Note that running `runplan` with no arguments will give back useful information about anticipated runs
# perhaps add this as default?

PARAMS="Project.config.sh"

RESTART_MAP="dat/LSCC.20191104.restart-map.dat"
RESTART_ARG="-R $RESTART_MAP"

>&2 echo Writing YAML files
CMD="src/runplan -x yaml -P $PARAMS $RESTART_ARG $@ "

>&2 echo Running: $CMD
eval $CMD

