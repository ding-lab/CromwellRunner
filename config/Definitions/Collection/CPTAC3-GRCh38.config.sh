#
# Collection config
#
# * CPTAC3
# * GRCh38.d1.vd1

# Dependencies
# * REF_ROOT    -- base directory of reference
# * DBSNP_ROOT  -- base directory of dbSnP-COSMIC database
# * VEP_CACHE_ROOT -- base directory of VEP cache
# * PARAM_ROOT  -- base directory of various TinDaisy parameter files


# This path below is for CPTAC3-standard GRCh38 reference
REF_PATH="$REF_ROOT/GRCh38.d1.vd1/GRCh38.d1.vd1.fa"

# See katmai:/home/mwyczalk_test/Projects/TinDaisy/sw1.3-compare/README.dbsnp.md for discussion of dbSnP references
# Updating to dbSnP-COSMIC version 20190416
DBSNP_DB="$DBSNP_ROOT/dbSnP-COSMIC.GRCh38.d1.vd1.20190416.vcf.gz"

# VEP Cache is used for VEP annotation and vcf_2_maf.
# If not defined, online lookups will be used by VEP annotation. These are slower and do not include allele frequency info (MAX_AF) needed by AF filter.
# For performance reasons, defining vep_cache_gz is suggested for production systems
VEP_CACHE_VERSION="99"  # Must match the filename below
ASSEMBLY="GRCh38"       # Must match the filename below
VEP_CACHE_GZ="$VEP_CACHE_ROOT/v99/vep-cache.99_GRCh38.tar.gz"

REF_NAME="hg38"                     # Reference, as used when matching to BAMMAP

# Defining this turns on pindel parallel
CHRLIST="$PARAM_ROOT/chrlist/GRCh38.d1.vd1.chrlist.txt"

