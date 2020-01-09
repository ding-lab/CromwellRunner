#
# Project config
#

PROJECT="SomaticSV.HNSCC.20200102"

SYSTEM_CONFIG="config/System-config/MGI.gc2541.SomaticSV.config.sh"
COLLECTION_CONFIG="config/Collection-config/CPTAC3-GRCh38-UMich.config.sh"
WORKFLOW_CONFIG="config/Workflow-config/SomaticSV.config.sh"

# source them all in order
source $SYSTEM_CONFIG
source $COLLECTION_CONFIG
source $WORKFLOW_CONFIG
