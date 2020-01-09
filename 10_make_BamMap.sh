# Making BamMap which will be used to drive UMich CCRCC CRAM processing
# See README.project.md for details

# 1  sample_name                  ---
# 2  case                         ***
# 3  disease                      ---
# 4  experimental_strategy        ***
# 5  sample_type                  ***
# 6  data_path                    ---
# 7  filesize
# 8  data_format
# 9  reference                    ***
# 10  UUID                        ---
# 11  system

BAMOUT="dat/BamMap.HNSCC.UMich.MGI.dat"
mkdir -p dat

CATALOG="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"
BAM_ROOT="/gscmnt/gc2521/dinglab/mwyczalk/CPTAC3.share/cords-align"
ES="WGS"
SYSTEM="MGI"

function process_BAM {
    for CPT_PATH in $BAM_ROOT/CPT*; do

        CPT=$(basename $CPT_PATH)
        CRAM="$CPT_PATH/${CPT}.cram"

        # SIZE=$(stat --format "%s" $CRAM)
        SIZE="unknown"

        # Testing indicates greps below are unique (one result per CPT)
        BM=$(grep $CPT $CATALOG | grep $ES | grep hg19)

        SN=$(echo "$BM" | cut -f 1)
        CASE=$(echo "$BM" | cut -f 2)
        DIS=$(echo "$BM" | cut -f 3)
        ST=$(echo "$BM" | cut -f 5)

        printf "$SN\t$CASE\t$DIS\t$ES\t$ST\t$CRAM\t$SIZE\tCRAM\tGRCh38_full_analysis_set_plus_decoy_hla\tNA\t$SYSTEM\n"

    done
}

printf "# sample_name\tcase\tdisease\texperimental_strategy\tsample_type\tdata_path\tfilesize\tdata_format\treference\tUUID\tsystem\n" > $BAMOUT
process_BAM >> $BAMOUT
>&2 echo Written to $BAMOUT
