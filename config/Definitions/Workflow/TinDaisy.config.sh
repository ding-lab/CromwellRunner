#
# Workflow
# tindaisy.cwl workflow
# 
# Dependencies:
#   CWL_ROOT
#   WORKFLOW_ROOT

CWL="$CWL_ROOT/cwl/workflows/tindaisy-hotspot-proximity.cwl"
# CWL output is used to find the principal output of workflow, i.e., what is reported with `cq output`.
# It is a concatenation of the CWL filename and 'id' in 'outputs' section of CWL
# this is no longer being used as `cq outputs` is preferred over `cq output`
# CWL_OUTPUT="tindaisy.cwl.output_vcf"

# template used for generating YAML files
# This is being specified in Project.config.sh now
#YAML_TEMPLATE="config/Templates/YAML/tindaisy.template.yaml"

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
RESTART_ROOT="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/tindaisy.cwl"
