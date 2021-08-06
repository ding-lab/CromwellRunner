##
# Project config
#

PROJECT="SomaticCNV-821"

# From ../12
#SYSTEM_CONFIG="config/Definitions/System/MGI.gc2541.config.sh"
#COLLECTION_CONFIG="config/Definitions/Collection/CPTAC3-GRCh38.TinDaisy.config.sh"
#WORKFLOW_CONFIG="config/Definitions/Workflow/TinDaisy-hotspot.config.sh"

#The above were used to create merged config file below

# Merged config
#MERGED_CONFIG="config/Definitions/MergedDefinitions/MGI.gc2541.TinDaisy2.CPTAC3-GRCh38.sh"
#MERGED_CONFIG="config/Definitions/MergedDefinitions/compute1.SomaticSV.CPTAC3-GRCh38.sh"
MERGED_CONFIG="config/Definitions/MergedDefinitions/compute1.SomaticCNV.CPTAC3-GRCh38.sh"
source $MERGED_CONFIG
