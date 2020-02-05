#
# System config
# MGI system with Cromwell output to gc2541
#

SYSTEM="MGI"
#SYSTEM="compute1"  # not yet implemented

# LSF_CONF for MGI
LSF_CONF="/opt/lsf9/conf/lsf.conf"
# LSF_CONF for compute1
# LSF_CONF="/opt/ibm/lsfsuite/lsf/conf/lsf.conf"


CROMWELL_JAR="/usr/local/cromwell/cromwell-47.jar"

# Workflow root - where Cromwell output goes.  This value replaces text WORKFLOW_ROOT in CONFIG_TEMPLATE,
# and is written to CONFIG_FILE
WORKFLOW_ROOT="/gscmnt/gc2541/cptac3_analysis"
CONFIG_TEMPLATE="config/Templates/cromwell-config/cromwell-config-db.MGI.template.dat"

# Path to BamMap, which is a file which defines sequence data path and other metadata
# BamMap format is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
# for UMich HNSCC data, doing ad hoc BamMap
BAMMAP="/gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/SomaticSV/dat/BamMap.HNSCC.UMich.MGI.dat"

# Assume that all references are based here
REF_ROOT="/gscmnt/gc7202/dinglab/common/Reference/A_Reference"

# Assume all DBSNP filters are here
DBSNP_ROOT="/gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/B_Filter"

# Assume all VEP caches are here
VEP_CACHE_ROOT="/gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/D_VEP"

# TD_ROOT is needed for CWL
# This is modified for SomaticSV
TD_ROOT="/gscuser/mwyczalk/projects/CWL/somatic_sv_workflow"
# TinDaisy parameters relative to TD_ROOT
PARAM_ROOT="$TD_ROOT/params" # N/A for SomaticSV

# Using ad hoc datalog file
#export DATALOG="/gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/cq.datalog/datalog.dat"
export DATALOG="./logs/datalog.dat"

