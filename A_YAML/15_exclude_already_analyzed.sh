# Exclude any runs for which the tumor has already been analyzed, based on 
# DCC analysis summary files
cd ..

source Project.config.sh

# SomaticSV
#DCC="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog/DCC_Analysis_Summary/WGS_SV.DCC_analysis_summary.dat"
#TUMOR_COL=12

# SomaticCNV 
#DCC="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog/DCC_Analysis_Summary/WGS_CNV_Somatic.DCC_analysis_summary.dat"
#TUMOR_COL=12

# TinDaisy
DCC="/gscmnt/gc2521/dinglab/mwyczalk/projects.CPTAC3/CPTAC3.catalog/DCC_Analysis_Summary/WXS_Somatic_Variant_TD.DCC_analysis_summary.dat"
TUMOR_COL=12

RUN_LIST_PRELIM="dat/RUN_LIST.preliminary.dat"
OUTA="./dat/tumor_uuid_to_run.dat"

CMD="comm -23 <(cut -f 3 $RUN_LIST_PRELIM | sort) <(cut -f $TUMOR_COL $DCC | sort) > $OUTA"
>&2 echo Running: $CMD
eval $CMD

# RUN_LIST is the final version of this file and is defined in Project.config.sh
RUN_LIST_NEW=$RUN_LIST

grep -f $OUTA $RUN_LIST_PRELIM > $RUN_LIST_NEW
>&2 echo Written to $RUN_LIST_NEW



