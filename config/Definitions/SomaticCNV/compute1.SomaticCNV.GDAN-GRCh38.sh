###############################################################################################
# System config based on : compute1.SomaticSV.config.sh
# Compute1 system with Cromwell output to scratch volume
###############################################################################################

WORKFLOW="SomaticCNV"
SYSTEM="compute1"  
HAS_SCRATCH=1		# 1 if data needs to be copied from scratch to storage at end of batch, otherwise 0
LSF_CONF="/opt/ibm/lsfsuite/lsf/conf/lsf.conf"
LSF_GROUP="/m.wyczalkowski/cromwell-runner"
LSFQ="dinglab"
COMPUTE_GROUP="compute-dinglab"
LSF_ARGS="-B \"-g $LSF_GROUP -G $COMPUTE_GROUP \" -M -q $LSFQ"

# This is in CromwellRunner container
CROMWELL_JAR="/usr/local/cromwell/cromwell-47.jar"

# Workflow root - where Cromwell output goes.  This value replaces text WORKFLOW_ROOT in CONFIG_TEMPLATE,
# and is written to CONFIG_FILE
#WORKFLOW_ROOT="/storage1/fs1/m.wyczalkowski/Active/cromwell-data"

# Writing to scratch
WORKFLOW_ROOT="/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data"
# This is template for cromwell run
CONFIG_TEMPLATE="config/Templates/cromwell-config/cromwell-config-db.compute1.template.dat"
# this is template for cromwell server
CONFIG_SERVER_TEMPLATE="config/Templates/cromwell-config/server-cromwell-config.compute1.dat"

# For moving data from scratch to storage upon completion
# This is analogous to WORKFLOW_ROOT
STORAGE_ROOT="/storage1/fs1/m.wyczalkowski/Active/cromwell-data"

# Path to BamMap, which is a file which defines sequence data path and other metadata
# BamMap format is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
#BAMMAP="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/SomaticCNV/07.ATAC_17/X_get_cased/GDAN.catalog/Catalog3/ATAC.BamMap3.merged.tsv"
CATALOG="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.Catalog3.tsv"
BAMMAP="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.BamMap3.tsv"

# Assume that all references are based here
REF_ROOT="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets"

# CWL_ROOT is needed for CWL.  It is the container path to where project is installed
# This is also used in rungo to get git status of project for tracking purposes
# Use _C for arguments to scripts
# We are making the assumption that the workflow project directory is in ./Workflow directory
PWD=$(pwd)
CWL_ROOT_H_LOC="$PWD/Workflow/BICSEQ2.CWL"
CWL_ROOT_H=$CWL_ROOT_H_LOC
CWL_ROOT_C="/usr/local/BICSEQ2.CWL"

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

# This is a per-chromosome reference in a .tar.gz file
# /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs/hg38/GRCh38.d1.vd1-per_chrom_fa.tar.gz
REF_PATH="$REF_ROOT/inputs/hg38/GRCh38.d1.vd1-per_chrom_fa.tar.gz"

REF_NAME="hg38"                     # Reference, as used when matching to BAMMAP


###############################################################################################
# Workflow config
###############################################################################################
# 
# Dependencies:
#   CWL_ROOT
#   WORKFLOW_ROOT

CWL="$CWL_ROOT_C/cwl/workflows/bicseq2-cwl.case-control.cwl"

# template used for generating YAML files
YAML_TEMPLATE="config/Templates/YAML/SomaticCNV.template.yaml"

# pipeline-specific script to obtain parameters to fill in YAML file, get_pipeline_params.XXX.sh
PARAM_SCRIPT="config/Scripts/get_pipeline_params.SomaticCNV.sh"

# this is specific to SomaticCNV workflow to delete large staged BAMs
WORKFLOW_RUN_ARGS="-P config/Templates/prune_list/SomaticCNV.stage_files_delete.dat"

# For moving data from scratch to final storage upon completion
# Relevant only if HAS_SCRATCH=1
SCRATCH_BASE="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl"
DEST_BASE="$STORAGE_ROOT/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl"


# These parameters used when finding data in BamMap
ES="WGS"                            # experimental strategy

# Output of cromwell config creation step
CONFIG_FILE="dat/cromwell-config-db.dat"
CONFIG_SERVER_FILE="dat/cromwell-server-config-db.dat"

# RESTART_ROOT used when restarting
#RESTART_ROOT="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl"

# List of runs to analyze
RUN_LIST="dat/RUN_LIST.dat"

# Mapping files
MAP_PATH="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs/GRCh38.d1.vd1.fa.150mer-noBedGraph.tar.gz"

# GENE BED - annotation BED file
GENE_BED_PATH="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/cached.annotation/gencode.v29.annotation.hg38.p12.bed"
