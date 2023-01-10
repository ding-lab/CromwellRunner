# Generate YAML config files.  This should work for both one- and two-datafile workflows

# There are several run list inputs: RUNLIST4, RUNLIST8, and RUNLIST9

# First task is to create RUNLIST4-format file from either RUNLIST8 or RUNLIST9 file
# RUNLIST4 is used for YAML file creation
# TODO: move RL4 creation to separate script

# RUNLIST4 - no header line.  Column definitions
#    run_name
#    case
#    datafile1_uuid
#    datafile2_uuid

# RUNLIST9 - columns from header line:
#     1  disease
#     2  run_name
#     3  case
#     4  datafile1_name
#     5  datafile1_aliquot
#     6  datafile1_uuid
#     7  datafile2_name
#     8  datafile2_aliquot
#     9  datafile2_uuid

# RUNLIST8. Columns from header line:
# https://github.com/ding-lab/CPTAC3.MissingAnalysis.git
#     1  run_name
#     2  run_metadata
#     3  datafile1_name
#     4  datafile1_aliquot
#     5  datafile1_uuid
#     6  datafile2_name
#     7  datafile2_aliquot
#     8  datafile2_uuid
# Here, case is not explicitly specified.  Use run_name for case

# Usage: 20_make_yaml.sh dat/WGS_CNV_Somatic.run_list.tsv

cd ..  # This complicates things
PARAMS="Project.config.sh"
source $PARAMS

RL9=$1  # this is the input, can be 8 or 9 column
shift 1

if [ -z $RL9 ]; then
    >&2 echo ERROR: RL9/RL8 parameter not passed
    exit 1
fi
if [ -z $RUN_LIST ]; then
    >&2 echo ERROR: RUN_LIST parameter not defined in $PARAMS
    exit 1
fi
if [ ! -e $RL9 ]; then
    >&2 echo ERROR: RL9/RL8 $RL9 not found
    exit 1
fi

# this is RL9
# tail -n +2 $RL9 | cut -f 2,3,6,9 > $RUN_LIST  # RL9

# RL8
tail -n +2 $RL9 | awk 'BEGIN{OFS="\t"}{print $1,$1,$5,$8}' > $RUN_LIST  # RL8
>&2 echo Written to $RUN_LIST

### The above and below should be split into two different scripts

>&2 echo Writing YAML files
XARGS="-d"  # debugging
CMD="bash src/runplan $XARGS -P $PARAMS -p $PARAM_SCRIPT -U $RUN_LIST -Y $YAML_TEMPLATE $@ "

>&2 echo Running: $CMD
eval $CMD

