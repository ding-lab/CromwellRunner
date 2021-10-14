# Exclude any runs for which the tumor has already been analyzed, based on 
# DCC analysis summary files
cd ..

source Project.config.sh

# SomaticSV
#DCC="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog/DCC_Analysis_Summary/WGS_SV.DCC_analysis_summary.dat"
#TUMOR_COL=12

# SomaticCNV 
DCC="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog/DCC_Analysis_Summary/WGS_CNV_Somatic.DCC_analysis_summary.dat"
TUMOR_COL=12

RUN_LIST="dat/RUN_LIST.142.dat"
OUTA="./dat/tumor_uuid_to_run.dat"

CMD="comm -23 <(cut -f 3 $RUN_LIST | sort) <(cut -f $TUMOR_COL $DCC | sort) > $OUTA"
>&2 echo Running: $CMD
eval $CMD

# Next, create updated RUN_LIST.dat which excludes the runs we've already done
RUN_LIST_NEW="dat/RUN_LIST.refined.dat"

grep -f $OUTA $RUN_LIST > $RUN_LIST_NEW
>&2 echo Written to $RUN_LIST_NEW



