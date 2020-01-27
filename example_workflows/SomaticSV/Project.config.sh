#
# Project config
#

PROJECT="SomaticSV.HNSCC.evidence"

# These are copied from example_workflows/SomaticSV
SYSTEM_CONFIG="config/MGI.gc2541.SomaticSV.config.sh"
COLLECTION_CONFIG="config/CPTAC3-GRCh38-UMich.config.sh"
WORKFLOW_CONFIG="config/SomaticSV.config.sh"

# source them all in order
source $SYSTEM_CONFIG
source $COLLECTION_CONFIG
source $WORKFLOW_CONFIG
