# Create UUID_MAP
cd ..

source Project.config.sh

CASES="dat/cases.dat"

# BAMMAP, CASES_FN, ES obtained from Project.config.sh
OUT="dat/RUN_LIST.dat"

CMD="bash src/make_RUN_LIST.sh $@ -e $ES -o $OUT $BAMMAP $CASES"
echo Running: $CMD
eval $CMD
