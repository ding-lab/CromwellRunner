###############################################################################################
# System config
# MGI system with Cromwell output to gc2541
###############################################################################################

WORKFLOW="TinDaisy"
SYSTEM="MGI"
LSF_CONF="/opt/lsf9/conf/lsf.conf"
LSFQ="research-hpc"

# Compute1 options
# SYSTEM="compute1"  
# LSF_CONF="/opt/ibm/lsfsuite/lsf/conf/lsf.conf"
# LSFQ="general"              

LSF_GROUP="/mwyczalk/cromwell-runner"
LSF_ARGS="-B \"-g $LSF_GROUP\"  -M -q $LSFQ"

CROMWELL_JAR="/usr/local/cromwell/cromwell-47.jar"

# Workflow root - where Cromwell output goes.  This value replaces text WORKFLOW_ROOT in CONFIG_TEMPLATE,
# and is written to CONFIG_FILE
WORKFLOW_ROOT="/gscmnt/gc2541/cptac3_analysis"
# This is template for cromwell run
CONFIG_TEMPLATE="config/Templates/cromwell-config/cromwell-config-db.MGI.template.dat"
# this is template for cromwell server
CONFIG_SERVER_TEMPLATE="config/Templates/cromwell-config/server-cromwell-config.MGI.dat"

# Path to BamMap, which is a file which defines sequence data path and other metadata
# BamMap format is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
BAMMAP="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/BamMap/MGI.BamMap.dat"

# CATALOG file is also needed for TinDaisy
CATALOG="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"

# Assume that all references are based here
REF_ROOT="/gscmnt/gc7202/dinglab/common/Reference/A_Reference"

# CWL_ROOT is needed for CWL.  It is the container path to where project is installed
# This is also used in rungo to get git status of project for tracking purposes
# Use _C for arguments to scripts
CWL_ROOT_H_LOC="./CWL/TinDaisy"
CWL_ROOT_H=$(readlink -f $CWL_ROOT_H_LOC)
CWL_ROOT_C="/usr/local/TinDaisy"

# path to CromwellRunner and its scripts.  We map local path to absolute path in container
# so all scripts know where to find these
CQ_ROOT_H="."
CQ_ROOT_C="/usr/local/CromwellRunner"

# Assume all VEP caches are here
VEP_CACHE_ROOT="/gscmnt/gc7202/dinglab/common/databases/VEP"

# TinDaisy parameters relative to CWL_ROOT
PARAM_ROOT="$CWL_ROOT_H/params"

# Use common datalog file
export DATALOG="/gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/cq.datalog/datalog.dat"

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
CLINVAR_ANNOTATION="/gscmnt/gc7202/dinglab/common/databases/ClinVar/GRCh38/20200706/clinvar_20200706.vcf.gz"
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

CWL="$CWL_ROOT_H/cwl/workflows/tindaisy2.cwl"

# template used for generating YAML files
YAML_TEMPLATE="config/Templates/YAML/tindaisy2.template.yaml"

# pipeline-specific script to obtain parameters to fill in YAML file, get_pipeline_params.XXX.sh
PARAM_SCRIPT="config/Scripts/get_pipeline_params.TinDaisy.sh"

# These parameters used when finding data in BamMap
ES="WXS"                            # experimental strategy

# Not sure if below is still necessary...
# # TUMOR_ST is normally "tumor", but will be "tissue_normal" for Normal Adjacent Normal Adjacent analyses
# TUMOR_ST="tumor"                    # Sample type for tumor BAM, for BAMMAP matching
# # TUMOR_ST="tissue_normal"            # Sample type for Normal Adjacent analyses
# NORMAL_ST='blood_normal'            # Sample type for normal BAM, for BAMMAP matching.  Default 'blood_normal'


# Output of cromwell config creation step
CONFIG_FILE="dat/cromwell-config-db.dat"
CONFIG_SERVER_FILE="dat/cromwell-server-config-db.dat"

# RESTART_ROOT used when restarting
#RESTART_ROOT="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/tindaisy.cwl"

# List of runs to analyze
RUN_LIST="dat/RUN_LIST.dat"
