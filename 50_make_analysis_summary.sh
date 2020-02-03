# Generate YAML files

# Note that running `runplan` will give back useful information about anticipated runs
PARAMS="Project.config.sh"

CMD="src/runplan -v -x summary -P $PARAMS $@ "

>&2 echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

