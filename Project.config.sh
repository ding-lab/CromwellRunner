#
# Project config
#

PROJECT="SomaticSV.HNSCC_PDA.compute1"

SYSTEM_CONFIG="config/Definitions/System/compute1.SomaticSV.config.sh"
COLLECTION_CONFIG="config/Definitions/Collection/CPTAC3-GRCh38.config.sh"
WORKFLOW_CONFIG="config/Definitions/Workflow/SomaticSV.config.sh"

# source them all in order
source $SYSTEM_CONFIG
source $COLLECTION_CONFIG
source $WORKFLOW_CONFIG
