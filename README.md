# CromwellRunner

CromwellRunner is a lightweight interactive workflow manager for managing Cromwell workflows on MGI and RIS compute1 systems at Washington University. 
For a batch of cases it provides a set of interactive tools to stage, launch, interrogate, and finalize sets of jobs and workflow results.
It provides functionality to discover and restart failed jobs, restart runs from intermediate results of past runs, and finalize completed runs to reduce disk use.

CromwellRunner was originally developed to manage runs of the TinDaisy variant caller.  Workflow management functionality
is being isolated in this project to allow for use with arbitrary workflows.

## Organizational structure

Example workflows are in ./workflows directory.  These provide configuration data and simple scripts which 
take advantage of functionality in ./src.  Different workflows are provided to illustrate use and provide simpler ways
to get started.

## Installation

Currently scripts here rely on TinDaisy, whose path is defined as `TD_ROOT`


# Below is documentation from pre-compute1 reorganization

## Git organization
### for production runs

Copy relevant workflow from workflows.

Make notes about project in README.project.md

Define `Project.config.dat`


# Quick start - CPTAC3, one case

Set up environment.  This is currently specific to MGI
```
tmux new -s C3L-02395
bash 00_start_docker.sh MGI
bash 05_start_cromwell_db_server.sh
export CROMWELL_URL=http://localhost:8000
conda activate jq
export PATH="$PATH:./src"
```

Create `dat/cases.dat` with cases of interest

mkdir dat
vi dat/cases.dat
    < manual edits >
vi config/project_config.sh

Confirm samples are correct with:
runplan

bash 1_make_yaml.sh

 preliminary testing
bash 2_start_runs.sh -d

If this is a new project, need to create runlog file with,
runtidy -f1

Finally,
bash 2_start_runs.sh

Examining how it is running:
Within a few minutes Cromwell output will start appearing in logs/C3L-02395.out



# TODO
* Add discussion of cases.dat
* Move discussion below of TinDaisy-specific stuff to TinDaisy project.

# Data prep

## Index BAMs
BAM files and reference need to be indexed.  This is frequently done prior to analysis
```
samtools index BAM
java -jar picard.jar CreateSequenceDictionary R=REF.fa O=REF.dict
```
where for instance `REF="all_sequences"`

## dbSnP-COSMIC
TODO: describe this in more detail.

dbSnP-COSMIC VCF needs to have chromosome names which match the reference, otherwise it will
silently not match anything.  Note that dbSnP-COSMIC.GRCh38.d1.vd1.20190416.vcf.gz has chrom names like `chr1`

## chrlist

This is a list of all chromosomes of interest, used for pindel.  Can be created from the reference's .fai file, retaining
only the names of the chromosomes of interest (typically 1-Y)

## Confirm YAML file

It might be good to quickly check the existence of all files in YAML file with the following,
```
grep path $YAML | cut -f 2 -d : | xargs ls -l
```



# Run procedure

## Installation

### Configure conda environment

Create a conda environment named `jq` with the following packages:
* `jq`
* `parallel`
* `tmux`

This may work:
```
conda install jq parallel tmux
```

**TODO** move TinDaisy instructions out from this documentation

### Install TinDaisy and CromwellRunner
CromwellRunner is a set of scripts and configuration files designed to simplify running TinDaisy.  Both need to be installed.

```
git clone https://github.com/ding-lab/TinDaisy
git clone https://github.com/ding-lab/CromwellRunner.git PROJECT_NAME
```
where `PROJECT_NAME` is an arbitrary name for this particular run or batch.

### Configuration

Optionally add the following line to `~/.bashrc` 
```
export PATH="$PATH:$TD_ROOT/src"
```
where `TD_ROOT` is as defined in `config/project_config.sh` below. This lets `cq` and other utilities be available for command line work

## Run Preparation
1. Review `config/CPTAC3-template.yaml`.  This contains configuration files and other parameters for the TinDaisy
   workflow.  Note the following parameters:
   * `chrlist: GRCh38.d1.vd1.chrlist.txt` is a list of all chromosomes, used for pindel analysis.  Will change for different references
   * `assembly` and `vep_cache_version` correspond to VEP database used for annotation
2. Review `config/project_config.dat`.  For MGI, it has the following definitions
```
    * REF_PATH   - /gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/A_Reference/GRCh38.d1.vd1.fa
    * REF_NAME   - short name of reference, for matching to BamMap
    * TD_ROOT    - /gscuser/mwyczalk/projects/TinDaisy/TinDaisy 
    * DBSNP_DB   - /gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/B_Filter/dbSnP-COSMIC.GRCh38.d1.vd1.20190416.vcf.gz
                   see katmai:/home/mwyczalk_test/Projects/TinDaisy/sw1.3-compare/README.dbsnp.md for details
    * VEP_CACHE_GZ - /gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/D_VEP/vep-cache.90_GRCh38.tar.gz
    * WORKFLOW_ROOT - /gscmnt/gc2541/cptac3_analysis
    * BAMMAP     - BamMap file listing paths to sequence data.  See details below
```
   `WORKFLOW_ROOT` defines where output of Cromwell goes, which can be large
   For Normal Adjacent analyses, also need to define `TUMOR_ST` as `tissue_adjacent` rather than `tumor`
3. Create file `dat/cases.dat`, which lists all cases we'll be processing
   Note that entries here will be used to find BAMs in BamMap to populate YAML files

## Start runs

Start runs.  Here, assuming that will use `parallel` to run N Cromwell instances on MGI at once. Note that order
here is important so that processes are not stranded after you log out

5. Run `tmux new` on known machine (e.g., `virtual-workstation1`).  
6. `0_start_docker.sh` - this is required on MGI to start cromwell jobs and run `cq`
7. `conda activate jq` - as described above
5. `1_make_yaml.sh` - this will generate start configuration (YAML) files for all cases in `cases.dat` and one Cromwell config file
8. Optionally edit `2_run_tasks.sh` to define the number of cromwell jobs to run at once: `ARGS="-J N"`
    * Alternatively, pass `-J N` as argument to `2_` in the next step
9. Start runs with `2_run_tasks.sh`.  
   May want to test with `2_run_tasks.sh -1 -d` first, which will do a dry run of one case (see Debugging seciton below).
   If `parallel` prints a bunch of citation information, run `parallel --citation` - this typically has to be done just once per system
   You can detach from `tmux` now and jobs will continue

## Check on runs 
6. Note that as of summer 2019 the default MGI Cromwell database server is not working, and a local service must be launched to
    query database-connected runs (required for `cq` and other run management tools).  To start and define the server,
    * `0_start_docker.sh`
    * `0b_start_server.sh`
    * `conda activate jq`
    * `export CROMWELL_URL=http://localhost:8000`
    * Confirm the URL with, `cq -q url`
10. `cq` will list status of all runs.  `cq` is a utility in `TinDaisy/src` with a lot of options; run `cq -h` to learn more.  

## Finalize runs

11. Run `3_finalize_runs.sh`
    Note, this is not required if 2_run_task.sh run with -F flag, which automatically finalizes all runs upon completion
11. Run `4_make_analysis_summary.sh` to collect all results
12. Clean run directories with `datatidy` utility.  Note that this may not need to be done for runs which successfully complete
    which are started with the -F flag, which also compresses all run output and deletes input files

# Additional details

## BamMap

A BamMap is a file developed in Ding Lab for CPTAC3 project used by TinDaisy `runplan` to create YAML per-run configuration files.  
A BamMap is a catalog of samples, their metadata, and their paths, with one BAM file per line.
* [Format of BamMap](https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh)
* [Example of a real BamMap](https://github.com/ding-lab/CPTAC3.catalog/blob/master/MGI.BamMap.dat)

It is a tab-separated file with the following columns:
```
BamMap columns
1  sample_name                  ---
2  case                         ***
3  disease                      ---
4  experimental_strategy        ***
5  sample_type                  ***
6  data_path                    ---
7  filesize
8  data_format
9  reference                    ***
10  UUID                        ---
11  system
```
Fields marked `***` are used to find the appropriate sample, and fields marked `---` are then read.

### Making your own BamMap

Non-CPTAC3 data will typically not have a BamMap constructed as above.  It is possible to make a synthetic BamMap by generating fields as follows:
* `sample_name` is an arbitrary human-readable name for this sample.  Example: `C3L-00032.WXS.T.hg38`
* `case` is unique name of this subject
* `disease` is an arbitrary disease code
* `experimental_strategy` takes the values `WXS`, `WGS`, `RNA-Seq`, or `miRNA-Seq`
* `sample_type` takes the values `tumor`, `tissue_normal`, `blood_normal`.  
* `data_path` is the full path to the sequence data (BAM file).  Note that the index file must be available as the BAM path with `.bai` appended
* `reference` is typically `hg19` or `hg38`, though other values can be used
* `UUID` is a unique identifier of a specific sample.  It need not be used


**TODO** provide comprehensive description of all utilities in TinDaisy:
* `cq` - general purpose query utility
* `runplan` - create and review run configuration files 
* `rungo` - start Cromwell runs
* `runtidy` - manage run output files
* `datatidy` - manage data output 

Cromwell generates two classes of output 
* Data output in workflowRoot directory, as defined by WORKFLOW_ROOT in config/project_config.sh
* Run output files (`CASE.*`) in LOGD directory, consisting of Cromwell stdout and stderr
  (possibly log file generated by GNU `parallel`). 

## runtidy

The utility `runtidy` is concerned with the run output files, which are used to
obtain a WorkflowID for a given run.  

Stashing a run consists of moving the run output files (and possibly YAML file)
to a directory STASHD/WorkflowID.  This is done to clean output directory and
allow for multiple runs for one case (e.g. to restart failed run).Stashing or
finalizing a run twice will print a warning.  If this WorkflowID does not exist
in runlog file exit with an error, since not having this entry will make it
hard to map CASE to WorkflowID in future.  Stashing also copies or moves YAML
files to stash directory; if status is Succeeded the YAML is moved, copied
otherwise (-Y to always move YAML files).

Registering a run creates an entry in run log file; this file tracks which case
is associated with which Workflow ID.  Runs are stashed only when
they have completed execution, but can be registered any time any number of times.

A run log file has the following columns
    * `Case`
    * `WorkflowID`
    * `Status`
    * `StartTime`
    * `EndTime`
    * `Note` - optional, may indicate whether a restart, etc.

Finalizing involves registering with run log file, stashing, and also
registering data output using `datatidy`

By default, only runs with status (as obtained from `cq`) of `Succeeded` or
`Failed` are evaluated for `stash` and `finalize` tasks.  To stash and finalize
runs with some other status, EXPECTED_STATUS must be defined; then, all cases
must have a status (as obtained from `cq`) same as EXPECTED_STATUS. (This is to
help prevent inadvertant data loss from stashing running jobs)

## datatidy

Cromwell workflow output (data output in workflow root directory) can be large
and it is useful to reduce disk usage by deleting staged and intermediate data
and compressing other output.  The role of `datatidy` is to manage and track
workflow output deletion.  Tracking is done using a data log file, and workflow
data deletion policy is given by a "tidy level".  All tasks other than `query`
are noted in the data log.

The task `original` marks the run output as having tidy level `original`, i.e.
data as generated by a completed execution.  By default, only runs with
status (as obtained from `cq`) of `Succeeded` or `Failed` are marked as
`original`, the others are ignored.  To mark runs with some other status as
`original` define EXPTECTED_STATUS.

Tasks which delete any data require EXPECTED_STATUS to be defined.
To help avoid inadvertantly deleting data, all cases must have a status (as
obtained from `cq`) same as EXPECTED_STATUS.

A data log file has the following columns:
    Case        - Case of run
    WorkflowID  - WorkflowID of run
    Path        - Path to workflowRoot directory of this run
    TidyDate    - Date this entry generated (this is not necessarily date of run)
    TidyLevel   - One of: `original`, `inputs`, `compress`, `prune`, `final`, `wipe`
    Note        - Arbitrary note about this run or cleaning

## Debugging

`-1` flag to `2_run_tasks.sh` (and most other scripts) will execute just the first case and exit.  `-d` flag is "dry run",
and will print out commands without executing them.  Both these flags, often in combination, are useful to test configuration
files and syntax prior to launching a real run.

## Cases vs. WorkflowID

Cromwell generates a unique WorkflowID (e.g., 2424f34e-adcb-4160-a05f-e102650acb83) for every run which
starts.  The typical workflow requires CASE names to initialize, launch, and finalize runs, but some utilities
(`cq` and `runDataCleaner.sh`) allow WorkflowIDs to be substituted for CASE names.  Mapping from CASE name
to WorkflowID is performed in one of two ways:
1. If Cromwell log file `logs/CASE.out` exists, parse it to find WorkflowID
2. Alternatively, parse `logs/runlog.dat` file, and return most recent WorkflowID associated with the case
Mapping from WorkflowID to case is based on `logs/runlog.dat` file.

## Usage of `cq` and other scripts

The general model for command line scripts here is to allow various ways to specify the runs of interest.
We want to make the default easy, while allowing for identifying one or more runs by CASE and/or WorkflowID.
At this time only `cq` fully implements this model.

## Logs
Stashing of a log involves moving all output in `logs/` (CASE.out, CASE.err, CASE.log) and `yaml/CASE.yaml` to directory `logs/WID`

### logs/runlog.dat

Keeps track of all runs which have been assigned a WorkflowID by cromwell. Consists of status entries, oldest on bottom,
with the following fields:
* `CASE`
* `WorkflowID`
* `Status`
* `StartTime`
* `EndTime`
* `Note` - optional, may indicate whether a restart, etc.

Once logs are stashed, association between WorkflowID and CASE is made with the RunLog.  Note that can have
mutiple entries per case and/or WorkflowID (possibly with different Status); the most recent one is the one
used for WorkflowID / Case association.

### DATAD/datalog.dat

Keeps track of run data and any cleaning that may take place following run completion.  There is one DataLog
per cromwell data directory, and is appended to 1) when a run is finalized and 2) when run data is cleaned.
DataLog has the following fields
* `CASE`
* `WorkflowID`
* `Date`
* `TidyLevel` - see below
* `Note` - optional, to indicate purpose of cleaning

## Tidy Levels

Levels of cleaning of run data in DATD for a given run are described by tidy levels.  DataLog keeps track of all 
cleaning steps for auditing and allocation management purposes.
* `original` - Status indicating data is as generated by completed workflow
* `inputs` - `inputs` subdirectories in all steps deleted.  This is assumed to occur for all levels below
* `compress` - All data in intermediate steps compressed but not deleted
* `prune` - All intermediate per-step data deleted.  Final per-step data and logs retained, compressed
* `final` - Keep only final outputs of each run
* `wipe` - Delete everything
In all cases except wipe, final results (as defined by CWL workflow output) are retained in original paths.


# Additional development notes 

## Connect to db
Cromwell database on MGI is at https://genome-cromwell.gsc.wustl.edu/.  Can do a lot of manual queries here
This is currently not working (as of summer 2019), so need to start local server instance and connect to localhost
as described in step 5 above.

Description of connection to Cromwell:
https://confluence.ris.wustl.edu/pages/viewpage.action?spaceKey=CI&title=Cromwell#Cromwell-ConnectingtotheDatabase

## Disk space

Complete run data size of `C3L-00104` run, `/gscmnt/gc2741/ding/cptac/cromwell-workdir/cromwell-executions/tindaisy.cwl/6abf1c89-aac2-4b40-8ff4-8616fa728853`
-> 147G

This may not even account for all files, since some directories start with - and may not be reported.  For instance, with 50Gb tumor (?) bams staged
four times for four callers, would expect 200+Gb for that file alone.

### Cleanup notes
Running `rm -rf */inputs` reduces disk use to 663M
Compressing `call-mutect/execution/mutect_call_stats.txt` reduces file size from 435M to 95M

`call-parse_varscan_snv/execution/results/varscan/filter_snv_out/varscan.out.som_snv.Germline*.vcf` are two files which take up 27M and 29M, and
are not used

`call-run_strelka2/execution/results/strelka2/strelka_out/workspace` is a temp directory which is 97M in size, can be compressed or deleted

-> It is possible to reduce size of completed job significantly with a cleanup script

### Memory issues

Observed a failure of run_pindel with BusError (seems to correlate with memory
issues) (run 59433723-3ce6-4a1c-ad99-f17368c401ea) when run with 16Gb memory.
Increased memory in run_pindel CWL to 24000Mb

Note that metadata output seems to indicate how much memory is used.  This can be used to tune memory requirements
more precisely per-step.

### CPU issues

Both run_pindel and run_strelka2 have adjustable numbers of threads / CPUs to run at once.
This can be assessed using `cq -q timing`.  Current testing suggests 5 and 4 threads for pindel and strelka2, respectively,
seems to make run times roughly uniform.  Mutect and varscan don't seem to have an option to adjust thread counts.

## Zombie jobs
**TODO** generalize these notes

12 hours later only 2 jobs are running at once, suggesting there are 8 zombie succeeded jobs.  These can be identified with,
```
$ ls */*.out | cut -f 2 -d '/' | cut -f 1 -d '.' | cq - | grep Succeeded
MMRF_1078       53f104b8-6108-4a72-ac85-faeb9a91c3c9    Succeeded
MMRF_1518       b1146a19-baeb-40fa-b5cb-a0d2b66af663    Succeeded
MMRF_1577       55d20393-d2b3-4dd9-b3ff-b15f79f684b9    Succeeded
MMRF_1596       61e06fde-aa8e-4719-a2e1-0b9e54c78618    Succeeded
MMRF_1603       ab08b7c6-79b1-4b82-87e9-0e8dbc55096e    Succeeded
MMRF_1655       316cad9a-c7d6-4deb-b362-30d45ed9ac21    Succeeded
MMRF_1725       04347069-d4ad-4f0e-9538-a01515a9260b    Succeeded
```


Description of how to kill zombie and clean it up:
1. `tmux attach -t MMRF2`
2. CTRL-Z to pause this, then `ps -eaf | grep MMRF_1795`
    Look for job with `/usr/bin/java -Xmx10g -jar ...cromwell-44.jar`
3. kill 106451 (the first PID listed)
4. `fg` to bring command to foreground
5. `cq` now indicates 10 jobs are running

### Doing again
The following script will do the above and write cases to zombies.dat
ls */*.out | cut -f 2 -d '/' | cut -f 1 -d '.' | cq - | grep Succeeded | cut -f 1 > zombies.dat
    MMRF_2064
    MMRF_2197
    MMRF_2214
    MMRF_2292
    MMRF_2427
    MMRF_2428
    MMRF_2429

Note that jobs which concluded their cromwell run but which are being finalized or compressed 
will show up on this list; best to test for zombies twice several minutes apart, or exclude 
recent files

pause running job
PID=$(ps -eaf | grep MMRF_2197 | grep cromwell.jar | grep -v compress | tr -s ' ' | cut -f 2 -d ' ')
kill $PID

Finalize and compress
export DATALOG="/gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/cq.datalog/datalog.dat"
cat zombies3.dat | runtidy -x finalize -p MMRF_WXS_restart -m "Succeeded zombie manual cleanup" -F Succeeded   -
cat zombies3.dat | datatidy -x compress -p MMRF_WXS_restart -m "Succeeded zombie manual cleanup" -F Succeeded   -

