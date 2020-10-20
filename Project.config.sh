##
# Project config
#

PROJECT="03.WGS_CNV_Somatic.Y3.208"

#SYSTEM_CONFIG="config/Definitions/System/compute1.SomaticSV.config.sh"
#COLLECTION_CONFIG="config/Definitions/Collection/CPTAC3-GRCh38.config.sh"
#WORKFLOW_CONFIG="config/Definitions/Workflow/SomaticSV.config.sh"
#
## source them all in order
#source $SYSTEM_CONFIG
#source $COLLECTION_CONFIG
#source $WORKFLOW_CONFIG

# Merged config

MERGED_CONFIG="config/Definitions/MergedDefinitions/compute1.SomaticSV.CPTAC3-GRCh38.sh"
source $MERGED_CONFIG
