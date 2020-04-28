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
BAMMAP="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/BamMap/MGI.BamMap.dat"

# Assume that all references are based here
REF_ROOT="/gscmnt/gc7202/dinglab/common/Reference/A_Reference"

# Assume all DBSNP filters are here
DBSNP_ROOT="/gscmnt/gc7202/dinglab/common/databases/dbSNP_Filter"

# Assume all VEP caches are here
VEP_CACHE_ROOT="/gscmnt/gc7202/dinglab/common/databases/VEP"

# TD_ROOT is needed for CWL
TD_ROOT="/gscuser/mwyczalk/projects/TinDaisy/TinDaisy"
# TinDaisy parameters relative to TD_ROOT
PARAM_ROOT="$TD_ROOT/params"

# Use common datalog.  This is git tracked
export DATALOG="/gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/cq.datalog/datalog.dat"

