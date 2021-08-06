# Create UUID_MAP
# This is necessary only when more than one tumor sample per case

source Project.config.sh

# BAMMAP, CASES_FN, ES obtained from Project.config.sh
OUT="dat/UUID_MAP.dat"

CMD="bash src/make_UUID_MAP.sh $@ -e $ES -o $OUT $BAMMAP $CASES_FN"
echo Running: $CMD
eval $CMD
