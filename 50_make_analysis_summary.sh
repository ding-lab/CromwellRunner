# Generate YAML files

# Note that running `runplan` will give back useful information about anticipated runs
PARAMS="Project.config.sh"

src/runplan -v -x summary -P $PARAMS "$@" 

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

