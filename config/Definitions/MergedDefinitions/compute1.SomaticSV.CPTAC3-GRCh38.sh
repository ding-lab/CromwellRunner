# This file is created essentially as,
# cat config/Definitions/System/compute1.SomaticSV.config.sh config/Definitions/Collection/CPTAC3-GRCh38.config.sh config/Definitions/Workflow/SomaticSV.config.sh > compute1.SomaticSV.CPTAC3-GRCh38.sh
# with some internal formatting added

###############################################################################################
# System config: config/Definitions/System/compute1.SomaticSV.config.sh
# Compute1 system with Cromwell output to /storage1/fs1/m.wyczalkowski/Active/cromwell-data/
###############################################################################################

SYSTEM="compute1"  
LSF_CONF="/opt/ibm/lsfsuite/lsf/conf/lsf.conf"
LSF_GROUP="/mwyczalk/gdc-download"
LSFQ="general"              # for MGI, queue is "research-hpc"
LSF_ARGS="-g $LSF_GROUP -M -q $LSFQ"


# This is based on CromwellRunner
CROMWELL_JAR="/usr/local/cromwell/cromwell-47.jar"

# Workflow root - where Cromwell output goes.  This value replaces text WORKFLOW_ROOT in CONFIG_TEMPLATE,
# and is written to CONFIG_FILE
WORKFLOW_ROOT="/storage1/fs1/m.wyczalkowski/Active/cromwell-data"
CONFIG_TEMPLATE="config/Templates/cromwell-config/cromwell-config-db.compute1.template.dat"

# Path to BamMap, which is a file which defines sequence data path and other metadata
# BamMap format is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
BAMMAP="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog/BamMap/storage1.BamMap.dat"

# Assume that all references are based here
REF_ROOT="/storage1/fs1/dinglab/Active/Resources/References"

# CWL_ROOT is needed for CWL
CWL_ROOT="/home/m.wyczalkowski/Projects/SomaticSV"

# Using common datalog file
export DATALOG="/storage1/fs1/m.wyczalkowski/Active/cromwell-data/CromwellRunner/datalog.dat"

# All these volumes will be mounted, with paths in container same as on host
# Note that /home is expanded to /storage1/fs1/home1/Active/home
VOLUME_MAPPING="/storage1/fs1/m.wyczalkowski/Active /storage1/fs1/dinglab/Active /storage1/fs1/home1/Active/home/m.wyczalkowski:/home/m.wyczalkowski"


###############################################################################################
# Collection Config: config/Definitions/Collection/CPTAC3-GRCh38.config.sh
###############################################################################################
#
# IMPORTANT: TinDaisy-specific parameters are defined in CPTAC3-GRCh38.TinDaisy.config.sh
# this is for SomaticSV 
# It has a generic name because it is not specialized to any workflow

# This path below is for CPTAC3-standard GRCh38 reference
REF_PATH="$REF_ROOT/GRCh38.d1.vd1/GRCh38.d1.vd1.fa"

REF_NAME="hg38"                     # Reference, as used when matching to BAMMAP


###############################################################################################
# Workflow config: config/Definitions/Workflow/SomaticSV.config.sh
# tindaisy.cwl workflow
###############################################################################################
# 
# Dependencies:
#   CWL_ROOT
#   WORKFLOW_ROOT

CWL="$CWL_ROOT/cwl/SomaticSV.cwl"

# template used for generating YAML files
YAML_TEMPLATE="config/Templates/YAML/SomaticSV.template.yaml"

# These parameters used when finding data in BamMap
ES="WGS"                            # experimental strategy

# TUMOR_ST is normally "tumor", but will be "tissue_normal" for Normal Adjacent Normal Adjacent analyses
TUMOR_ST="tumor"                    # Sample type for tumor BAM, for BAMMAP matching
# TUMOR_ST="tissue_normal"            # Sample type for Normal Adjacent analyses
NORMAL_ST='blood_normal'            # Sample type for normal BAM, for BAMMAP matching.  Default 'blood_normal'

# This one seem pretty low-level, since it is created and then consumed within CromwellRunner
# not sure where this should go - seems specific to CromwellRunner setup
# Think this is OUTPUT of config creation step
CONFIG_FILE="dat/cromwell-config-db.dat"

# RESTART_ROOT used when restarting
#RESTART_ROOT="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/tindaisy.cwl"

# List of cases to analyze.  This has to be created
# may want to reconsider the use and implementation of case list
CASES_FN="dat/cases.dat"
