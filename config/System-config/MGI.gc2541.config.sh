#
# System config
# MGI system with Cromwell output to gc2541
#
CROMWELL_JAR="/gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/cromwell.jar/44/cromwell-44.jar"

# Workflow root - where Cromwell output goes.  This value replaces text WORKFLOW_ROOT in CONFIG_TEMPLATE,
# and is written to CONFIG_FILE
WORKFLOW_ROOT="/gscmnt/gc2541/cptac3_analysis"
CONFIG_TEMPLATE="config/cromwell-config-db.template.dat"

# Path to BamMap, which is a file which defines sequence data path and other metadata
# BamMap format is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
BAMMAP="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/BamMap/MGI.BamMap.dat"

# Assume that all references are based here
REF_ROOT="/gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/A_Reference"

# Assume all DBSNP filters are here
DBSNP_ROOT="/gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/B_Filter"

# Assume all VEP caches are here
VEP_CACHE_ROOT="/gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/D_VEP"

# TD_ROOT is needed for CWL
TD_ROOT="/gscuser/mwyczalk/projects/TinDaisy/TinDaisy/params"
# TinDaisy parameters relative to TD_ROOT
PARAM_ROOT="$TD_ROOT/params"

# Using common datalog file
export DATALOG="/gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/cq.datalog/datalog.dat"

