# Create tumor / normal RUN_LIST file based on cases provided in dat/cases.dat
cd ..

source Project.config.sh

CASES="dat/cases.dat"

# BAMMAP, ES, RUN_LIST obtained from Project.config.sh
# -D removes deprecated samples

CMD="bash src/make_RUN_LIST.sh $@ -D -e $ES -o $RUN_LIST $BAMMAP $CASES"
echo Running: $CMD
eval $CMD
