# This file is created essentially as,
# cat config/Definitions/System/MGI.gc2541.config.sh config/Definitions/Collection/CPTAC3-GRCh38.TinDaisy.config.sh config/Definitions/Workflow/TinDaisy-hotspot.config.sh > config/Definitions/MergedDefinitions/MGI.gc2541.TinDaisy2.CPTAC3-GRCh38.sh
# with some internal formatting added.  Moving to a merged file with internal structure which follows
# the system / collection / workflow divisions for simplicity of having one configuration file

# New in TinDaisy2 - these have been added to yaml template
# * CLINVAR_ANNOTATION
# * CALL_REGIONS
# * CANONICAL_BED

###############################################################################################
# System config
# MGI system with Cromwell output to gc2541
###############################################################################################

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
CONFIG_TEMPLATE="config/Templates/cromwell-config/cromwell-config-db.MGI.template.dat"

# Path to BamMap, which is a file which defines sequence data path and other metadata
# BamMap format is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
BAMMAP="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/BamMap/MGI.BamMap.dat"
# Catalog file format is defined here: https://github.com/ding-lab/CPTAC3.case.discover/blob/master/src/make_catalog.sh
CATALOG="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"

# Assume that all references are based here
REF_ROOT="/gscmnt/gc7202/dinglab/common/Reference/A_Reference"

# CWL_ROOT is needed for CWL.  It is the container path to where project is installed
# This is also used in rungo to get git status of project for tracking purposes
# Use _C for arguments to scripts
CWL_ROOT_H="/gscuser/mwyczalk/projects/TinDaisy/TinDaisy"
CWL_ROOT_C="/usr/local/TinDaisy"

# path to CromwellRunner and its scripts.  We map local path to absolute path in container
# so all scripts know where to find these
CQ_ROOT_H="."
CQ_ROOT_C="/usr/local/CromwellRunner"

# Assume all VEP caches are here
VEP_CACHE_ROOT="/gscmnt/gc7202/dinglab/common/databases/VEP"

# TinDaisy parameters relative to CWL_ROOT
PARAM_ROOT="$CWL_ROOT_H/params"

# Use common datalog.  This is git tracked
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

# These parameters used when finding data in BamMap
ES="WXS"                            # experimental strategy

# TUMOR_ST is normally "tumor", but will be "tissue_normal" for Normal Adjacent Normal Adjacent analyses
TUMOR_ST="tumor"                    # Sample type for tumor BAM, for BAMMAP matching
# TUMOR_ST="tissue_normal"            # Sample type for Normal Adjacent analyses
NORMAL_ST='blood_normal'            # Sample type for normal BAM, for BAMMAP matching.  Default 'blood_normal'

# List of cases to analyze.  This has to be created
# may want to reconsider the use and implementation of case list
CASES_FN="dat/cases.dat"

# This one seem pretty low-level, since it is created and then consumed within CromwellRunner
# not sure where this should go - seems specific to CromwellRunner setup
# Think this is OUTPUT of config creation step
CONFIG_FILE="dat/cromwell-config-db.dat"

# RESTART_ROOT used when restarting
# this is not a restart
#RESTART_ROOT="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/tindaisy.cwl"
