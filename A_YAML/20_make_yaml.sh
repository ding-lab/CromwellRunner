# Generate YAML config files.  This should work for both one- and two-datafile workflows

# First, create RUNLIST4-format file from RUNLIST9 file
# RUNLIST9
#     1  disease
#     2  run_name
#     3  case
#     4  datafile1_name
#     5  datafile1_aliquot
#     6  datafile1_uuid
#     7  datafile2_name
#     8  datafile2_aliquot
#     9  datafile2_uuid

# RUNLIST4
#    run_name
#    case
#    datafile1_uuid
#    datafile2_uuid
# Also, RUNLIST9 has a header line while RUNLIST4 does not

# Usage: 20_make_yaml.sh dat/WGS_CNV_Somatic.run_list.tsv

cd ..
PARAMS="Project.config.sh"
source $PARAMS

#RL9=$1
#shift 1
#
#if [ -z $RL9 ]; then
#    >&2 echo ERROR: RL9 parameter not passed
#    exit 1
#fi
#if [ -z $RUN_LIST ]; then
#    >&2 echo ERROR: RUN_LIST parameter not defined in $PARAMS
#    exit 1
#fi
#if [ ! -e $RL9 ]; then
#    >&2 echo ERROR: RL9 $RL9 not found
#    exit 1
#fi

#tail -n +2 $RL9 | cut -f 2,3,6,9 > $RUN_LIST
#>&2 echo Written to $RUN_LIST

# dat/RUN_LIST.dat is already created

>&2 echo Writing YAML files
CMD="bash src/runplan -P $PARAMS -p $PARAM_SCRIPT -U $RUN_LIST -Y $YAML_TEMPLATE $@ "

>&2 echo Running: $CMD
eval $CMD

