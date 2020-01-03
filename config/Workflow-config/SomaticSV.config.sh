#
# Workflow
# tindaisy.cwl workflow
# 
# Dependencies:
#   TD_ROOT
#   WORKFLOW_ROOT

CWL="$TD_ROOT/cwl/SomaticSV.cwl"

# template used for generating YAML files
YAML_TEMPLATE="config/Templates/yaml.template/SomaticSV.template.yaml"

# These parameters used when finding data in BamMap
ES="WGS"                            # experimental strategy

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
#RESTART_ROOT="$WORKFLOW_ROOT/cromwell-workdir/cromwell-executions/tindaisy.cwl"
