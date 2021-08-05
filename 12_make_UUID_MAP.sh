BAM_MAP="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog/BamMap/storage1.BamMap.dat"
CASES="dat/WGS_CNV_Somatic.analysis_cases.dat"
OUT="dat/UUID_MAP.dat"
ES="WGS"

CMD="bash src/make_UUID_MAP.sh $@ -e $ES -o $OUT $BAM_MAP $CASES"
echo Running: $CMD
eval $CMD
