###############################################################################################
# System config based on : compute1.SomaticSV.config.sh
# Compute1 system with Cromwell output to scratch volume
# mammoth Cromwell DB server
###############################################################################################

WORKFLOW="SomaticSV"
SYSTEM="compute1"  
HAS_SCRATCH=1		# 1 if data needs to be copied from scratch to storage at end of batch, otherwise 0
LSF_CONF="/opt/ibm/lsfsuite/lsf/conf/lsf.conf"
LSF_GROUP="/m.wyczalkowski/cromwell_runner-SomaticSV"
LSFQ="dinglab"
COMPUTE_GROUP="compute-dinglab"
LSF_ARGS="-B \"-g $LSF_GROUP -G $COMPUTE_GROUP \" -M -q $LSFQ"

# This is in CromwellRunner container
# CROMWELL_JAR="/usr/local/cromwell/cromwell-47.jar" # Used for MGI server
CROMWELL_JAR="/app/cromwell-78-38cd360.jar"          # used for mammoth

# Workflow root - where Cromwell output goes.  Writing to scratch1
WORKFLOW_ROOT="/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data"
# This is template for cromwell run
CONFIG_TEMPLATE="config/Templates/cromwell-config/cromwell-config-db.compute1.mammoth_server.template.dat"
## this is template for cromwell server, used only for MGI-based server
#CONFIG_SERVER_TEMPLATE="config/Templates/cromwell-config/server-cromwell-config.compute1.MGI_server.dat"

# For moving data from scratch to storage upon completion
# This is analogous to WORKFLOW_ROOT
STORAGE_ROOT="/storage1/fs1/m.wyczalkowski/Active/cromwell-data"

# CatalogRoot will differ for GDAN vs. CPTAC3. GDAN also requires a project name, e.g., MILD
# CPTAC3
#CATALOG_ROOT="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"

# GDAN
PROJECT="HCMI"
CATALOG_ROOT="/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"

# Path to BamMap and Catalog, which define sequence data path and other metadata
# BamMap v3 format defined here: https://docs.google.com/document/d/1uSgle8jiIx9EnDFf_XHV3fWYKFElszNLkmGlht_CQGE/edit
# Catalog format has changed with the REST catalog format
CATALOG="$CATALOG_ROOT/Catalog3/${PROJECT}.Catalog-REST.tsv"


BAMMAP="$CATALOG_ROOT/Catalog3/WUSTL-BamMap/$PROJECT.BamMap3.tsv"

# Assume that all references are based here
REF_ROOT="/storage1/fs1/dinglab/Active/Resources/References"

# CWL_ROOT is needed for CWL.  It is the container path to where project is installed
# This is also used in rungo to get git status of project for tracking purposes
# Use _C for arguments to scripts
# We are making the assumption that the workflow project directory is in ./Workflow directory
PWD=$(pwd)
CWL_ROOT_H_LOC="$PWD/Workflow/SomaticSV"
CWL_ROOT_H=$CWL_ROOT_H_LOC
CWL_ROOT_C="/usr/local/SomaticSV"

# path to CromwellRunner and its scripts.  We map local path to absolute path in container
# so all scripts know where to find these
CQ_ROOT_H="$PWD"
CQ_ROOT_C="/usr/local/CromwellRunner"

# Using common datalog file
export DATALOG="$WORKFLOW_ROOT/CromwellRunner/datalog.dat"

# Mapping home directory to /home/m.wyczalkowski is convenient because it includes environment
# definitions for interactive work.  All scripts should run without this mapping, however
# Note that /home used to be expanded to /storage1/fs1/home1/Active/home
HOME_MAP="$HOME"

# All these volumes will be mounted, with paths in container same as on host unless otherwise specified.
VOLUME_MAPPING=" \
/storage1/fs1/m.wyczalkowski/Active \
/storage1/fs1/dinglab/Active \
$CQ_ROOT_H:$CQ_ROOT_C \
$CWL_ROOT_H:$CWL_ROOT_C \
$HOME_MAP \
/scratch1/fs1/dinglab
"

###############################################################################################
# Collection Config: config/Definitions/Collection/CPTAC3-GRCh38.config.sh
###############################################################################################
#

# This path below is for CPTAC3-standard GRCh38 reference
REF_PATH="$REF_ROOT/GRCh38.d1.vd1/GRCh38.d1.vd1.fa"

REF_NAME="hg38"                     # Reference, as used when matching to BAMMAP


###############################################################################################
# Workflow config
###############################################################################################
# 
# Dependencies:
#   CWL_ROOT
#   WORKFLOW_ROOT

CWL_FILE="SomaticSV.cwl" # Note, this is running v1.2 of pipeline.  Does not have tumor-only support
CWL="$CWL_ROOT_C/cwl/$CWL_FILE" 

# template used for generating YAML files
YAML_TEMPLATE="config/Templates/YAML/SomaticSV.template.yaml"

# pipeline-specific script to obtain parameters to fill in YAML file, get_pipeline_params.XXX.sh
PARAM_SCRIPT="config/Scripts/get_pipeline_params.SomaticSV.sh"

# this is specific to workflows with staged BAMs to delete them. Not currently used in SomaticSV
# WORKFLOW_RUN_ARGS="-P config/Templates/prune_list/SomaticSV.stage_files_delete.dat"

# For moving data from scratch to final storage upon completion
# Relevant only if HAS_SCRATCH=1
SCRATCH_BASE="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/$CWL_FILE"
DEST_BASE="$STORAGE_ROOT/cromwell-workdir/cromwell-executions/$CWL_FILE"

# Output of cromwell config creation step
CONFIG_FILE="dat/cromwell-config-db.dat"

# RESTART_ROOT used when restarting
#RESTART_ROOT="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/tindaisy.cwl"

# List of runs to analyze
RUN_LIST="dat/RUN_LIST.dat"

