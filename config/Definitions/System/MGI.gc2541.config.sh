#
# System config
# MGI system with Cromwell output to gc2541
#

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

# Assume all DBSNP filters are here
DBSNP_ROOT="/gscmnt/gc7202/dinglab/common/databases/dbSNP_Filter"

# Assume all VEP caches are here
VEP_CACHE_ROOT="/gscmnt/gc7202/dinglab/common/databases/VEP"

# CWL_ROOT is needed for CWL
CWL_ROOT="/gscuser/mwyczalk/projects/TinDaisy/TinDaisy"
# TinDaisy parameters relative to CWL_ROOT
PARAM_ROOT="$CWL_ROOT/params"

# Use common datalog.  This is git tracked
export DATALOG="/gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/cq.datalog/datalog.dat"

