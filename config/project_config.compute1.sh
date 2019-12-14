# TinDaisy Project Config file
#
# This file is common to all steps in project
# Contains all per-system configuration
# Contains only definitions, no execution code

# testing of mutect demo on compute1 using cromwell 47
# Assume LSF Volume mapping /storage1/fs1/m.wyczalkowski:/data

# System: compute1

PROJECT="MutectDemo"

CROMWELL_JAR="/usr/local/cromwell/cromwell-47.jar"

# Root directory.  Where TinDaisy is installed
# *** CONTINUE HERE ***
# * do we want this to be scratch?
# * do we want this to link to data partition?
# * do we want this just for testing for now (./dat)?
TD_ROOT="/home/m.wyczalkowski/Projects/TinDaisy/TinDaisy"

# Workflow root - where Cromwell output goes.  This value replaces text WORKFLOW_ROOT in CONFIG_TEMPLATE,
# and is written to CONFIG_FILE
# On compute1 are putting WORKFLOW_ROOT on scratch disk for performance
WORKFLOW_ROOT="/scratch/cromwell"
CONFIG_TEMPLATE="config/cromwell-config-db.template.dat"
CONFIG_FILE="dat/cromwell-config-db.dat"

# List of cases to analyze.  This has to be created
CASES_FN="dat/cases.dat"

# Path to BamMap, which is a file which defines sequence data path and other metadata
# BamMap format is defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
BAMMAP="/home/m.wyczalkowski/Projects/CPTAC3/CPTAC3.catalog/BamMap/compute1.BamMap.dat"

# This path below is for CPTAC3-standard GRCh38 reference
REF_PATH="/data/Active/Resources/References/GRCh38.d1.vd1/GRCh38.d1.vd1.fa"

# See katmai:/diskmnt/Datasets/dbSNP/SomaticWrapper/README.md for discussion of dbSnP references
# Updating to dbSnP-COSMIC version 20190416
DBSNP_DB="/data/Active/Resources/Databases/dbSnP-COSMIC/GRCh38.d1.vd1/dbSnP-COSMIC.GRCh38.d1.vd1.20190416.vcf.gz"

# VEP Cache is used for VEP annotation and vcf_2_maf.
# If not defined, online lookups will be used by VEP annotation. These are slower and do not include allele frequency info (MAX_AF) needed by AF filter.
# For performance reasons, defining vep_cache_gz is suggested for production systems
VEP_CACHE_GZ="/data/Active/Resources/Databases/VEP/compressed/vep-cache.90_GRCh38.tar.gz"

# template used for generating YAML files
YAML_TEMPLATE="config/MutectDemo.yaml"

# These parameters used when finding data in BamMap
ES="WXS"                            # experimental strategy

# TUMOR_ST is normally "tumor", but will be "tissue_normal" for Normal Adjacent Normal Adjacent analyses
TUMOR_ST="tumor"                    # Sample type for tumor BAM, for BAMMAP matching
# TUMOR_ST="tissue_normal"            # Sample type for Normal Adjacent analyses
NORMAL_ST='blood_normal'            # Sample type for normal BAM, for BAMMAP matching.  Default 'blood_normal'
REF_NAME="hg38"                     # Reference, used when matching to BAMMAP


