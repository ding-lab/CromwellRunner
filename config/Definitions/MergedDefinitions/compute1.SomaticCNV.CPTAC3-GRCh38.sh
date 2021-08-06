###############################################################################################
# System config based on : compute1.SomaticSV.config.sh
# Compute1 system with Cromwell output to scratch volume
###############################################################################################

WORKFLOW="SomaticCNV"
SYSTEM="compute1"  
LSF_CONF="/opt/ibm/lsfsuite/lsf/conf/lsf.conf"
LSF_GROUP="/m.wyczalkowski/cromwell-runner"
#LSFQ="general"              # for MGI, queue is "research-hpc"
LSFQ="dinglab"              # for MGI, queue is "research-hpc"
LSF_ARGS="-B \"-g $LSF_GROUP\"  -M -q $LSFQ"


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

# Path to BamMap, which is a file which defines sequence data path and other metadata
# BamMap format is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
BAMMAP="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog/BamMap/storage1.BamMap.dat"

# Assume that all references are based here
REF_ROOT="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets"

# CWL_ROOT is needed for CWL.  It is the container path to where project is installed
# This is also used in rungo to get git status of project for tracking purposes
# Use _C for arguments to scripts
CWL_ROOT_H="./CWL/BICSEQ2.CWL"
CWL_ROOT_C="/usr/local/BICSEQ2.CWL"

# path to CromwellRunner and its scripts.  We map local path to absolute path in container
# so all scripts know where to find these
CQ_ROOT_H="."
CQ_ROOT_C="/usr/local/CromwellRunner"

# Using common datalog file
export DATALOG="/storage1/fs1/m.wyczalkowski/Active/cromwell-data/CromwellRunner/datalog.dat"

# Mapping home directory to /home/m.wyczalkowski is convenient because it includes environment
# definitions for interactive work.  All scripts should run without this mapping, however
# Note that /home used to be expanded to /storage1/fs1/home1/Active/home
#HOME_MAP="/storage1/fs1/home1/Active/home/m.wyczalkowski:/home/m.wyczalkowski"
HOME_MAP="$HOME"    # HOME being an environment variable

# All these volumes will be mounted, with paths in container same as on host unless otherwise specified.
VOLUME_MAPPING=" \
/storage1/fs1/m.wyczalkowski/Active \
/storage1/fs1/dinglab/Active \
$CQ_ROOT_H:$CQ_ROOT_C \
$CWL_ROOT_H:$CWL_ROOT_C \
$HOME_MAP \
/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data"

###############################################################################################
# Collection Config: config/Definitions/Collection/CPTAC3-GRCh38.config.sh
###############################################################################################
#

# This is a per-chromosome reference in a .tar.gz file
# /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs/hg38/GRCh38.d1.vd1-per_chrom_fa.tar.gz
REF_PATH="$REF_ROOT/inputs/hg38/GRCh38.d1.vd1-per_chrom_fa.tar.gz"

REF_NAME="hg38"                     # Reference, as used when matching to BAMMAP


###############################################################################################
# Workflow config: config/Definitions/Workflow/SomaticSV.config.sh
###############################################################################################
# 
# Dependencies:
#   CWL_ROOT
#   WORKFLOW_ROOT

CWL="$CWL_ROOT_C/cwl/workflows/bicseq2-cwl.case-control.cwl"

# template used for generating YAML files
YAML_TEMPLATE="config/Templates/YAML/SomaticCNV.template.yaml"

# These parameters used when finding data in BamMap
ES="WGS"                            # experimental strategy

TUMOR_ST="tumor"                    # Sample type for tumor BAM, for BAMMAP matching
NORMAL_ST='blood_normal'            # Sample type for normal BAM, for BAMMAP matching.  Default 'blood_normal'

# This one seem pretty low-level, since it is created and then consumed within CromwellRunner
# not sure where this should go - seems specific to CromwellRunner setup
# Think this is OUTPUT of config creation step
CONFIG_FILE="dat/cromwell-config-db.dat"
CONFIG_SERVER_FILE="dat/cromwell-server-config-db.dat"

# RESTART_ROOT used when restarting
#RESTART_ROOT="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/tindaisy.cwl"

# List of cases to analyze.  This has to be created
# may want to reconsider the use and implementation of case list
CASES_FN="dat/cases.dat"

# Mapping files
MAP_PATH="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs/GRCh38.d1.vd1.fa.150mer-noBedGraph.tar.gz"

# GENE BED - annotation BED file
GENE_BED_PATH="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/cached.annotation/gencode.v29.annotation.hg38.p12.bed"
