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

## Run 1

bash 40_start_runs.sh -1F

### Error
Fails with,
```
Running: /usr/bin/java -Xmx10g -Dconfig.file=dat/cromwell-config-db.dat -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStore=/storage1/fs1/home1/Active/home/m.wyczalkowski/lib/cromwell-jar/cromwell.truststore -jar /usr/local/cromwell/cromwell-47.jar run -t cwl -i ./yaml/C3L-01032.yaml /storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/SomaticSV/cwl/SomaticSV.cwl > ./logs/C3L-01032.out 2> ./logs/C3L-01032.err && src/runtidy -c src -x finalize -m Autofinalizing -p SomaticSV.HNSCC_PDA.compute1 C3L-01032 && src/datatidy -c src -F Succeeded -x compress -p SomaticSV.HNSCC_PDA.compute1 C3L-01032
Running: mkdir -p ./logs
ERROR: DATALOG file /storage1/fs1/m.wyczalkowski/Active/cromwell-data/CromwellRunner/datlog.dat does not exist, will not create one by default
       datalog file can be created with `datatidy -f1`
Fatal ERROR. Exiting.
Fatal ERROR. Exiting.
Fatal error 1: . Exiting.
```

-> this can be easily cleaned up
-> this should be checked prior to the run starting for real
-> is it supposed to be datalog.dat instead of datlog.dat?
-> cq works as expected

### Cleaning up

* making datalog with datatidy -f1, which was not done because this is the first time running on compute1
  * also, named changed datlog.dat -> datalog.dat

* runtidy -x finalize -F Succeeded -p SomaticSV.HNSCC_PDA.20200517 -m "Manual finalize" C3L-01032
* datatidy -x compress -F Succeeded -p SomaticSV.HNSCC_PDA.20200517 -m "Manual finalize" C3L-01032
-> this has warning,
    tar: ./call-SomaticSV.cwl/execution/rc.tmp: File removed before we read it
  * return to cleaning up SomaticSV runs

## Run 2

Restart all runs not yet started

cq | grep -v Succeeded | cut -f 1 | bash 40_start_runs.sh -F -J6 -

parallel: Error: Cannot change into non-executable dir /home/m.wyczalkowski/.parallel: No such file or directory

-> changing VOLUME_MAPPING in config/Definitions/System/compute1.SomaticSV.config.sh to
```
VOLUME_MAPPING="/storage1/fs1/m.wyczalkowski/Active /storage1/fs1/dinglab/Active /storage1/fs1/home1/Active/home/m.wyczalkowski:/home/m.wyczalkowski"
``
=> I dont understand how home directory mapping works, there seem to be two synonyms for it`

Also changing CWL_ROOT and DB_ARGS to point to /home/m.wyczalkowski

### Errors 1

C3L-02617.yaml has missing NORMAL.  Thus it dies
C3N-02727.yaml also has this error.  No one else does
-> investigate, make sure doesnt happen again, restart

### Errors 2

Getting repeated errors like this:
```
Processing 1 / 1 [ Tue May 26 15:55:57 UTC 2020 ]: C3L-03635
Running: rm -rf /storage1/fs1/m.wyczalkowski/Active/cromwell-data/cromwell-workdir/cromwell-executions/SomaticSV.cwl/24a05b01-cf32-43c4-bae7-d71dc858525a/call-SomaticSV.cwl/inputs
Running: touch /storage1/fs1/m.wyczalkowski/Active/cromwell-data/cromwell-workdir/cromwell-executions/SomaticSV.cwl/24a05b01-cf32-43c4-bae7-d71dc858525a/compressed_results.tar.gz && tar -zcf /storage1/fs1/m.wyczalkowski/Active/cromwell-data/cromwell-workdir/cromwell-executions/SomaticSV.cwl/24a05b01-cf32-43c4-bae7-d71dc858525a/compressed_results.tar.gz -C /storage1/fs1/m.wyczalkowski/Active/cromwell-data/cromwell-workdir/cromwell-executions/SomaticSV.cwl/24a05b01-cf32-43c4-bae7-d71dc858525a --exclude compressed_results.tar.gz .
tar: ./call-SomaticSV.cwl/logs: File removed before we read it
tar: ./call-SomaticSV.cwl/execution/rc.tmp: File removed before we read it
tar: ./call-SomaticSV.cwl/execution: file changed as we read it
tar: ./call-SomaticSV.cwl: file changed as we read it
Fatal ERROR. Exiting.
```
Discussion on slack suggests this is due to caching issue, suggestion was made to have pipeline write to scratch space first,
then compress/delete, and save to storage1

Scratch space we want to use: /scratch1/fs1/dinglab
Note that this will require a final step for the entire batch, or else the datatidy script has to deal with this.  Note that this implies that there are two
different workflow_roots, the scratch one and the storage one.  This will complicate making analysis summary file, restart files, etc.


### Errors 3

[ Wed May 27 00:24:36 UTC 2020 ] : Processing case C3N-02295
Running: parallel --semaphore -j6 --id 20200526040404 --joblog ./logs/C3N-02295.log --tmpdir ./logs "/usr/bin/java -Xmx10g -Dconfig.file=dat/cromwell-config-db.dat -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStore=/home/m.wyczalkowski/lib/cromwell-jar/cromwell.truststore -jar /usr/local/cromwell/cromwell-47.jar run -t cwl -i ./yaml/C3N-02295.yaml /home/m.wyczalkowski/Projects/SomaticSV/cwl/SomaticSV.cwl > ./logs/C3N-02295.out 2> ./logs/C3N-02295.err && src/runtidy -c src -x finalize -m Autofinalizing -p SomaticSV.HNSCC_PDA.compute1 C3N-02295 && src/datatidy -c src -F Succeeded -x compress -p SomaticSV.HNSCC_PDA.compute1 C3N-02295"
docker/WUDocker/start_docker.sh: line 93: 21824 User defined signal 2   bsub -q general-interactive -Is -M 32000 -R "select[mem>32000] rusage[mem=32000]" -a "docker(mwyczalkowski/cromwell-runner)" /bin/bash
[ Tue May 26 22:57:45 CDT 2020 ] start_docker.sh Fatal ERROR (140). Exiting.

-> rungo job was killed because of 24 hour time limit on compute1

This is a general problem which has two solutions I can think of:
* use technique like that adopted in GDC import code, where (effectively) the rungo job runs in a non-interactive
  docker environment 
* Use parallel to launch all jobs at once (-J 100000), then use LSF read groups to throttle the number of
  jobs which run at a time
  * this was originally implemented in import GDC code until moved to a parallel model for both katmai and MGI

-> output of cq saved in cq.run3.dat
      1 Failed
      6 Running
     37 Succeeded
     47 Unknown

