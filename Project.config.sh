#
# Project config
#

PROJECT="UCEC.20200909"

SYSTEM_CONFIG="config/Definitions/System/MGI.gc2541.config.sh"
COLLECTION_CONFIG="config/Definitions/Collection/CPTAC3-GRCh38.TinDaisy.config.sh"
WORKFLOW_CONFIG="config/Definitions/Workflow/TinDaisy-hotspot.config.sh"

# This should probably be moved here, currently it is in WORKFLOW_CONFIG
YAML_TEMPLATE="config/Templates/YAML/tindaisy-hotspot.template.yaml"

# source them all in order
source $SYSTEM_CONFIG
source $COLLECTION_CONFIG
source $WORKFLOW_CONFIG


