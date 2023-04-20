# There are several run list inputs: RUNLIST4, RUNLIST8, and RUNLIST9
# First task is to create RUNLIST4-format file from either RUNLIST8 
#   (RUNLIST9 code is available below)
# RUNLIST4 is used for YAML file creation

# RUNLIST4 - no header line.  Column definitions
#    run_name
#    case
#    datafile1_uuid
#    datafile2_uuid

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

# Usage: 10_make_rl4.sh dat/WGS_CNV_Somatic.run_list.tsv

# This should be consistent with RUN_LIST in config
RUN_LIST_OUT="../dat/RUN_LIST.dat"

RL9=$1  # this is the input, can be 8 or 9 column
shift 1

if [ -z $RL9 ]; then
    >&2 echo ERROR: RL9/RL8 parameter not passed
    exit 1
fi
if [ ! -e $RL9 ]; then
    >&2 echo ERROR: RL9/RL8 $RL9 not found
    exit 1
fi

# this is RL9
# tail -n +2 $RL9 | cut -f 2,3,6,9 > $RUN_LIST_OUT  # RL9

# RL8
tail -n +2 $RL9 | awk 'BEGIN{OFS="\t"}{print $1,$1,$5,$8}' > $RUN_LIST_OUT  # RL8
>&2 echo Written to $RUN_LIST_OUT

