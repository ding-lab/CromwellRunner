###############################################################################################
# System config
# Compute1 system with Cromwell output to scratch volume
###############################################################################################

WORKFLOW="TinDaisy"
SYSTEM="compute1"
HAS_SCRATCH=1		# 1 if data needs to be copied from scratch to storage at end of batch, otherwise 0
LSF_CONF="/opt/ibm/lsfsuite/lsf/conf/lsf.conf"
LSF_GROUP="/m.wyczalkowski/cromwell-runner"
LSFQ="dinglab"              
COMPUTE_GROUP="compute-dinglab"
LSF_ARGS="-B \"-g $LSF_GROUP -G $COMPUTE_GROUP \" -M -q $LSFQ"

# This is in CromwellRunner container
# 
CROMWELL_JAR="/app/cromwell-78-38cd360.jar"  # used for mammoth, v78
# CROMWELL_JAR="/usr/local/cromwell/cromwell-47.jar"    # used for MGI
#CROMWELL_JAR="/opt/cromwell.jar"   # not sure what this is used for 

# Workflow root - where Cromwell output goes.  Writing to scratch1
#WORKFLOW_ROOT="/storage1/fs1/m.wyczalkowski/Active/cromwell-data"
WORKFLOW_ROOT="/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data"
# This is template for cromwell run
CONFIG_TEMPLATE="config/Templates/cromwell-config/cromwell-config-db.compute1.template.dat"
# this is template for cromwell server, used only for MGI-based server
CONFIG_SERVER_TEMPLATE="config/Templates/cromwell-config/server-cromwell-config.compute1.MGI_server.dat"

# For moving data from scratch to storage upon completion
# This is analogous to WORKFLOW_ROOT
STORAGE_ROOT="/storage1/fs1/m.wyczalkowski/Active/cromwell-data"

# Path to BamMap, which is a file which defines sequence data path and other metadata
# BamMap format is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
CATALOG="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.Catalog3.tsv"
BAMMAP="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.BamMap3.tsv"

# Assume that all references are based here
REF_ROOT="/storage1/fs1/dinglab/Active/Resources/References"

# CWL_ROOT is needed for CWL.  It is the container path to where project is installed
# This is also used in rungo to get git status of project for tracking purposes
# Use _C for arguments to scripts
# We are making the assumption that the workflow project directory is in ./Workflow directory
PWD=$(pwd)
CWL_ROOT_H_LOC="$PWD/Workflow/TinDaisy"
# CWL_ROOT_H=$(readlink -f $CWL_ROOT_H_LOC)
CWL_ROOT_H=$CWL_ROOT_H_LOC
CWL_ROOT_C="/usr/local/TinDaisy"

# path to CromwellRunner and its scripts.  We map local path to absolute path in container
# so all scripts know where to find these
CQ_ROOT_H="$PWD"
CQ_ROOT_C="/usr/local/CromwellRunner"

# Assume all VEP caches are here
VEP_CACHE_ROOT="/storage1/fs1/m.wyczalkowski/Active/Primary/Resources/Databases/VEP"

# TinDaisy parameters relative to CWL_ROOT
PARAM_ROOT="$CWL_ROOT_H/params"

# Use common datalog file
export DATALOG="$WORKFLOW_ROOT/CromwellRunner/datalog.dat"

# Mapping home directory to /home/<USERNAME> is convenient because it includes environment
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
# Collection config
#
# * CPTAC3
# * GRCh38.d1.vd1

# Dependencies
# * REF_ROOT    -- base directory of reference
# * VEP_CACHE_ROOT -- base directory of VEP cache
# * PARAM_ROOT  -- base directory of various TinDaisy parameter files
###############################################################################################

# This path below is for CPTAC3-standard GRCh38 reference
REF_PATH="$REF_ROOT/GRCh38.d1.vd1/GRCh38.d1.vd1.fa"

# VEP Cache is used for VEP annotation and vcf_2_maf.
# If not defined, online lookups will be used by VEP annotation. These are slower and do not include allele frequency info (MAX_AF) needed by AF filter.
# For performance reasons, defining vep_cache_gz is suggested for production systems
VEP_CACHE_VERSION="99"  # Must match the filename below
ASSEMBLY="GRCh38"       # Must match the filename below
VEP_CACHE_GZ="$VEP_CACHE_ROOT/v99/vep-cache.99_GRCh38.tar.gz"

REF_NAME="hg38"                     # Reference, as used when matching to BAMMAP

# Defining this turns on pindel parallel
CHRLIST="$PARAM_ROOT/chrlist/GRCh38.d1.vd1.chrlist.txt"

# This is optionally used by VEP custom annotation feature to provide information about clinvar and enable clinvar rescue
CLINVAR_ANNOTATION="/storage1/fs1/m.wyczalkowski/Active/Primary/Resources/Databases/ClinVar/GRCh38/20200706/clinvar_20200706.vcf.gz"
CALL_REGIONS="$PARAM_ROOT/chrlist/GRCh38.callRegions.bed.gz"
CANONICAL_BED="$PARAM_ROOT/chrlist/GRCh38.callRegions.bed"

###############################################################################################
# Workflow
# tindaisy.cwl workflow
# 
# Dependencies:
#   CWL_ROOT
#   WORKFLOW_ROOT
###############################################################################################

CWL_FILENAME="tindaisy2.6.1-postmerge_refilter.cwl"
CWL="$CWL_ROOT_H/cwl/workflows/$CWL_FILENAME"

# template used for generating YAML files
YAML_TEMPLATE="config/Templates/YAML/TinDaisy/tindaisy2.6.1-postmerge-refilter.template.yaml"

# pipeline-specific script to obtain parameters to fill in YAML file, get_pipeline_params.XXX.sh
PARAM_SCRIPT="config/Scripts/get_pipeline_params.TinDaisy.sh"

# this is required for workflows with staged BAMs 
WORKFLOW_RUN_ARGS="-P config/Templates/prune_list/TinDaisy.stage_files_delete.dat"

# For moving data from scratch to final storage upon completion
# Relevant only if HAS_SCRATCH=1
SCRATCH_BASE="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/$CWL_FILENAME"
DEST_BASE="$STORAGE_ROOT/cromwell-workdir/cromwell-executions/$CWL_FILENAME"

# These parameters used when finding data in BamMap
ES="WGS"                            # experimental strategy

# This isn't currently used when creating RUN_LIST, but it could be...
# # TUMOR_ST is normally "tumor", but will be "tissue_normal" for Normal Adjacent Normal Adjacent analyses
# TUMOR_ST="tumor"                    # Sample type for tumor BAM, for BAMMAP matching
# # TUMOR_ST="tissue_normal"            # Sample type for Normal Adjacent analyses
# NORMAL_ST='blood_normal'            # Sample type for normal BAM, for BAMMAP matching.  Default 'blood_normal'

# Output of cromwell config creation step
CONFIG_FILE="dat/cromwell-config-db.dat"
CONFIG_SERVER_FILE="dat/cromwell-server-config-db.dat"

# RESTART_ROOT used when restarting
RESTART_ROOT="/storage1/fs1/m.wyczalkowski/Active/cromwell-data/cromwell-workdir/cromwell-executions/tindaisy2.6.cwl"

# List of runs to analyze
RUN_LIST="dat/RUN_LIST.dat"
