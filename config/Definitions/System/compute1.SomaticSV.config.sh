#
# System config
# Compute1 system with Cromwell output to /storage1/fs1/m.wyczalkowski/Active/cromwell-data/
#

SYSTEM="compute1"  
LSF_CONF="/opt/ibm/lsfsuite/lsf/conf/lsf.conf"
LSF_GROUP="/m.wyczalkowski/cromwell-runner"
LSFQ="general"              # for MGI, queue is "research-hpc"
LSF_ARGS="-B \"-g $LSF_GROUP\"  -M -q $LSFQ"


# This is based on CromwellRunner
CROMWELL_JAR="/usr/local/cromwell/cromwell-47.jar"

# Workflow root - where Cromwell output goes.  This value replaces text WORKFLOW_ROOT in CONFIG_TEMPLATE,
# and is written to CONFIG_FILE
#WORKFLOW_ROOT="/storage1/fs1/m.wyczalkowski/Active/cromwell-data"

# Writing to scratch
WORKFLOW_ROOT="/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data"
CONFIG_TEMPLATE="config/Templates/cromwell-config/cromwell-config-db.compute1.template.dat"

# Path to BamMap, which is a file which defines sequence data path and other metadata
# BamMap format is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
BAMMAP="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog/BamMap/storage1.BamMap.dat"

# Assume that all references are based here
REF_ROOT="/storage1/fs1/dinglab/Active/Resources/References"

# CWL_ROOT is needed for CWL.  It is the container path to where project is installed
CWL_ROOT="/home/m.wyczalkowski/Projects/SomaticSV"
#CWL_ROOT="/usr/local/SomaticSV"

# Using common datalog file
export DATALOG="/storage1/fs1/m.wyczalkowski/Active/cromwell-data/CromwellRunner/datalog.dat"

# All these volumes will be mounted, with paths in container same as on host
# Note that /home used to be expanded to /storage1/fs1/home1/Active/home
# however,  we no longer map home
VOLUME_MAPPING=" \
/storage1/fs1/m.wyczalkowski/Active \
/storage1/fs1/dinglab/Active \
/storage1/fs1/home1/Active/home/m.wyczalkowski:/home/m.wyczalkowski \
/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data"

