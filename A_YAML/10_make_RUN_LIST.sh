# Create tumor / normal RUN_LIST file based on cases provided in dat/cases.dat
cd ..

source Project.config.sh

CASES="dat/cases.dat"
RUN_LIST_PRELIM="dat/RUN_LIST.preliminary.dat"

# BAMMAP, ES, RUN_LIST obtained from Project.config.sh
# -D removes deprecated samples
# SAMPLE_TYPE_ARGS, when defined, will identify the samples to use (e.g., germline or tumor/normal)
CMD="bash src/make_RUN_LIST.sh $@ $SAMPLE_TYPE_ARGS -D -e $ES -o $RUN_LIST_PRELIM $BAMMAP $CASES"
echo Running: $CMD
eval $CMD
