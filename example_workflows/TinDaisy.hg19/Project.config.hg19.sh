#
# Project config
#
# Variant callling on hg19 dataset

PROJECT="PDA.TargetedSequencing.20200131"

SYSTEM_CONFIG="config/Definitions/System/MGI.gc2541.config.sh"
COLLECTION_CONFIG="config/Definitions/Collection/CPTAC3-hg19.config.sh"
WORKFLOW_CONFIG="config/Definitions/Workflow/TinDaisy-WXS.config.sh"

# source them all in order
source $SYSTEM_CONFIG
source $COLLECTION_CONFIG
source $WORKFLOW_CONFIG

