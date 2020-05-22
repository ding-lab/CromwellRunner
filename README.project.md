Develop and run SomaticSV on compute1

Running 91 HNSCC and PDA jobs.  See 
    shiso:/Users/mwyczalk/Projects/CPTAC3/CPTAC3.Cases/20200408.HNSCC_PDA_tasks/README.md

cases list copied to config/cases.dat, but please confirm

See BRANCH.somaticsv for details about development in somaticsv branch

Complete run of SomaticSV on case C3L-01032 using Cromwell is here:
/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/SomaticSV/testing/cwl_call-compute1-TEST

# Configuration files from MGI

MGI: /gscmnt/gc2560/core/genome/cromwell/cromwell.truststore
compute1: /storage1/fs1/bga/Active/gmsroot/gc2560/core/genome/cromwell/cromwell.truststore

# Starting local server

## MGI
    CONFIG="/gscuser/tmooney/server.cromwell.config"
    /usr/bin/java -Dconfig.file=$CONFIG -jar $CROMWELL server >/dev/null &

## compute1
    CONFIG copied to ./config


DATALOG is going on 

# Caution

There are duplicate matches to a lot of cases when making YAML because of -core samples
* confirm that these are not in fact deprecated
* Consider moving "core1" to another column in BamMap
* May need to pass list of UUIDs when makign YAML
* For now, just test analysis
