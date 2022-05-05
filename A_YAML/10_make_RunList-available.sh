# Create tumor / normal RUN_LIST file based on cases provided in dat/cases.dat
cd ..

# For DLBCL, run with -W
source Project.config.sh

#CASES="dat/DLBCL.cases.dat"
CASES="dat/cases.dat"    # looking at in-house cases only
#CASES="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.cases.tsv"
RUN_LIST_TMP="dat/RUN_LIST.tmp"
RUN_LIST="dat/RUN_LIST.dat"

# This is created with fgrep -f <(cut -f 2 DLBCL.BamMap3.tsv) DLBCL.Catalog3.tsv > DLBCL.in-house.Catalog3.tsv
CATALOG_IH="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.in-house.Catalog3.tsv"
#CATALOG_IH="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.Catalog3.tsv"

# BAMMAP, ES, RUN_LIST obtained from Project.config.sh
# -D removes deprecated samples
# SAMPLE_TYPE_ARGS, when defined, will identify the samples to use (e.g., germline or tumor/normal)
CMD="bash src/make_RunList3.sh $@ $SAMPLE_TYPE_ARGS -W -r aligned -C $CATALOG_IH -e $ES -o $RUN_LIST_TMP $CASES"
echo Running: $CMD
eval $CMD

CMD="grep -v MISSING $RUN_LIST_TMP > $RUN_LIST"
echo Running: $CMD
eval $CMD
