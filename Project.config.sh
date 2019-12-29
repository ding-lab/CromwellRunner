#
# Project config
#

PROJECT="LSCC.postcall.20191228"

SYSTEM_CONFIG="config/System-config/MGI.gc2541.config.sh"
COLLECTION_CONFIG="config/Collection-config/CPTAC3-GRCh38.config.sh"
WORKFLOW_CONFIG="config/Workflow-config/TinDaisy-postcall-restart.sh"

# source them all in order
source $SYSTEM_CONFIG
source $COLLECTION_CONFIG
source $WORKFLOW_CONFIG
