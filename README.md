# CromwellRunner

CromwellRunner is a lightweight interactive workflow manager for managing
[Cromwell](https://cromwell.readthedocs.io/en/stable/) workflows on MGI and RIS
compute1 systems at Washington University.  For a batch of cases it provides a
set of interactive tools to stage, launch, interrogate, and finalize sets of
jobs and workflow results.  It provides some functionality to discover and restart
failed jobs, restart runs from intermediate results of past runs, and finalize
completed runs to reduce disk use.

CromwellRunner was originally developed to manage runs of the
[TinDaisy](https://github.com/ding-lab/TinDaisy) variant caller, but it has
since been generalized and can be used with arbitrary workflows.  It is used
regularly for [SomaticSV](https://github.com/ding-lab/SomaticSV.git) runs in addition to TinDaisy.

CromwellRunner consists of the following utilities:
* `cq` - query cromwell server
* `datatidy` - manage cromwell run results 
* `rungo` - launch cromwell jobs 
* `runplan` - initialize cromwell jobs
* `runtidy` - Organize cromwell job logs

These utilities are used to initialize, launch, inspect, clean up, restart,
and log Cromwell runs, particularly for batches of tens and hundreds of runs.

CromwellRunner is executed by a series of scripts, whose filenames start with
numbers indicating order of execution, and which are run from the command line 
with no required arguments.  All parameters are defined in configuration scripts
which are defined in the `Projects.config.dat` file.

Note that we are generally running [CWL
language](https://www.commonwl.org/v1.2/Workflow.html) scripts on the [Cromwell
workflow management system](https://cromwell.readthedocs.io/en/stable/).  This
is a combination which is relatively well supported on both the MGI and
compute1 systems at Wash U but which remains under continuous development.  CromwellRunner
has been used to process batches of over a thousand cases.

Docker image used: `mwyczalkowski/cromwell-runner:v78`, has v78 of Cromwell

Note that Cromwell Runner now used the Catalog3 format files, as described
below.  These files are available for both CPTAC3 and GDAN projects.

## Releases

### `release2`

* Generate RUN_LIST files from Catalog3 and BamMap3-format data to enable GDAN ATAC 
* New feature, `cq -q du` to query size of workflow directory
* Cromwell updated to v78 
* Using mammoth cromwell server and getting rid of local cromwell server
  * Support for local / MGI cromwell server is maintened in case need to backtrack

# Getting started

CromwellRunner is run regularly on MGI and compute1 environments at Wash U.
Typically, installation as described below will be performed for each batch of
runs, aka a "project".  Instructions below assume a Linux command line environment.
Details specific to this batch are recorded in the `README.project.md` file for future
reference.

Installation instructions below. 

## Basic concepts

Important things to be aware of when running CromwellRunner.

## Workflows

The following pipelines are currently run regularly with CromwellRunner:
* [TinDaisy2](https://github.com/ding-lab/TinDaisy) - a somatic indel variant caller 
* [TinJasmine](https://github.com/ding-lab/TinJasmine) - a germline indel variant caller 
* [SomaticSV](https://github.com/ding-lab/SomaticSV) - a somatic structural variant caller 
* [SomaticCNV](https://github.com/mwyczalkowski/BICSEQ2.CWL) - a somatic copy number caller

Differences between pipelines are isolated to configuration files and new CWL pipelines can be readily added.
The links above provide the URL needed when cloning these workflows below.

### Configuration

CromwellRunner configuration parameters are defined in the master configuration file, which is itself
specified in `Project.config.sh`.  An example configuration file is,
`config/Definitions/TinDaisy/compute1.TinDaisy2.6.2-CPTAC3-WES-GRCh38.sh`

The following changes should be made to the configuration file by a new user:
* Change job group to your own
* Change destionation location to your own

### Job Group

The number of runs which CromwellRunner executes at a time is controlled through
the LSF Job Group.  It is necessary to create one before jobs can be submitted on
MGI or compute1.  Below are the basics to get started.  
Refer to [RIS documentation](https://docs.ris.wustl.edu/doc/compute/recipes/job-execution-examples.html?highlight=bjgroup#job-groups)
for additional details.

User `bob` (use your own user ID) will create a job group named
`/bob/cromwell_runner` which can run five jobs (runs) at a time with,
```
bgadd -L 5 /bob/cromwell_runner
```
You can see the number of jobs running for this group with,
```
bjgroup -s /bob/cromwell_runner
```
And change to 10 the number of jobs which can run at once with,
```
bgmod -L 10 /bob/cromwell_runner
```

Job group is defined by the `LSF_GROUP` parameter in the master configuration file

### `RUN_LIST` and YAML configuration files

The list of runs which constitue this batch is defined by the `RUN_LIST` file,
which consists of the columns,
* `RUN_NAME` - the name of this run, which must be unique in this batch
* `CASE` - the case name associated with this run.  This corresponds to an individual participant or patient
* `TUMOR_UUID` - UUID associated with tumor BAM file (see BamMap discussion for UUID details)
* `NORMAL_UUID` - UUID associated with normal BAM file

When there is only one tumor BAM file for each case, then the `RUN_NAME` can be the same as
`CASE`.  In instances when there are multiple tumor BAMs per case, the `RUN_NAME` must
be differnet for each run.

The common workflow of creating a `RUN_LIST` file based on a list of cases is implemented
in `A_YAML/10_make_RUN_LIST.sh`.  This searches the BamMap file to identify all tumor and normal
samples associated with each run, and creates a run for each tumor file found.

YAML configuration files define all the parameters needed for each workflow run.  They are created
by the script `A_YAML/20_make_yaml.sh` using templates and parameters defined via the `Project.config.sh`
configuration file.

When Cromwell starts a run, that run is issued a unique Workflow ID.  Multiple
runs with the same input parameters will each have a different workflow ID.

### Cromwell server and docker

On both MGI and compute1 environments, it is necessary to run CromwellRunner
within a docker container which contains the necessary runtime libraries and
executables.  This image is named `mwyczalkowski/cromwell-runner:v78` and is
created in the `./docker` directory.

The [Cromwell
database](https://cromwell.readthedocs.io/en/stable/Configuring/#database)
provides a way to obtain information about running and completed workflows, and
is central to the interactive functionality of CromwellRunner.  The database
is specified by a cromwell configuration file, which is generated from a template with,
```
C_config_init/04_make_cromwell_config.sh
```

Currently used is an instance running on Ding Lab server `mammoth`, though the MGI server can also be used.
Interactive funcionality requires a local instance of the Cromwell server to be
running to connect to the Cromwell database.  

### Logging and output directories

Logs are written to various places:
* `logs/RUN_NAME.err` and `.out` - output of Cromwell
* `logs/RUN_NAME.LSF.err` and `.out` - output of LSF processes

Output of the actual workflows, both logs and data files, are written to the Workflow Root 
directory of each run.  Such output directories can be very large, and may need to be cleaned up
and/or compressed after each successful run.  CromwellRunner provides tools to manage this.

CromwellRunner itself maintains two log files, `logs/runlog.dat` and a datalog
file.  The run log file is used to track the progress of individual runs and
the association between the run name and the workflow ID.  The datalog file
maintain a log of all operations (e.g., compression or deletion) involving
workflow output in the workflow root directories. 

Instantiate run log files with, `C_config_init/10_make_data_run_logs.sh`.

### Cleaning up after runs
Cromwell makes copies of all input files before starting, and this can result in very large workflow directories.
To reduce disk use and simplify the running of large batches, Cromwell Runner can delete these input files
at the conclusion of each run.  It can also compress the output directories to further save space.  This is accomplished
with the `-F` flag to `src/rungo` (typically defined in `40_start_runs.sh`).

Staging of input BAM files is done to reduce disk space: if a workflow has four tools which each have two BAM files as input,
Cromwell will create four copies of each BAM.  Staging is a preliminary step which provides one copy of each BAM file to each tool
which needs it, resulting in one copy of the BAM rather than four.

Additional files besides the inputs to be deleted for each pipeline are defined
in per-pipeline files like
`config/Templates/prune_list/TinDaisy.stage_files_delete.dat`.  Staged BAM
files need to be deleted using this method.

Runs which fail will typically have to be cleaned up using the `src/runtidy`
and `src/datatidy` utilities.  Instructions for doing this are below.



### Script basics

CromwellRunner is executed by a series of scripts, whose filenames start with
numbers indicating order of execution (e.g., `40_start_runs.sh`).  Not all
scripts should be run - for instance, scripts involving restarts are used only
when the run is initiated from the intermediate state of a prior run.

Number scripts are run from the command line with no required arguments.  All
parameters are obtained from configuration scripts which are defined in
`Projects.config.dat`.

The numbered scripts themselves convenience wrappers around CromwellRunner utilities
which can also be called directly.  Details of the utilities are below, and each has extensive
documentation available by calling with `-h` argument.  

Cromwell utilities take several other arguments which are useful for debugging
and validating runs.  The argument `-d` will perform a "dry run", printing out
commands and doing parameter validation without affecting files or jobs.  In
instancers where a job loops over a list of inputs, the `-1` argument will stop
the execution after one job invoked.  `-1d` are useful together for inspecting
a command before launching it.

## Running CromwellRunner

Typically, CromwellRunner is cloned once for each project, or batch of runs.
This preserves the runtime environment for later inspection, allows for simpler
tracking of provenance, and simplifies ongoing development.  That is the model
demonstrated here.

A number of example configuration files are provided with the distrbution,
which will need to be modified as appropriate.

### Installation
Clone CromwellRunner into a project-specific directory with,
```
git clone --recurse-submodules https://github.com/ding-lab/CromwellRunner.git PROJECT_NAME
```
where `PROJECT_NAME` is a name for this particular batch.


Next, clone the relevant workflow into `PROJECT_NAME/Workflow` directory.  
```
cd PROJECT_NAME
mkdir Workflow && cd Workflow
git clone --recurse-submodule WORKFLOW_LINK
```
where `WORKFLOW_LINK` is the GitHub URL of the appropriate workflow:
* TinDaisy2: `https://github.com/ding-lab/TinDaisy.git`
* TinJasmine: `https://github.com/ding-lab/TinJasmine.git`
* SomaticSV: `https://github.com/ding-lab/SomaticSV.git`
* SomaticCNV: `https://github.com/mwyczalkowski/BICSEQ2.CWL.git`

#### Ignore file mode changes
Possibly,
```
git submodule foreach git config core.fileMode false
git submodule foreach git submodule foreach git config core.fileMode false
```

### Define system configuration files

The file `Project.config.sh` is read by all the scripts and points to the
principal (`MERGED_CONFIG`) configuration file.  Each of these configuration
files provide all the definitions needed for the execution of a specific
pipeline (e.g., TinDaisy) on a given computer system (`compute1`) for a given
project (`CPTAC3`).  A number of example configuration files are provided, and
these will be modified as necessary.

Specific steps:

```
* Edit configuration file `Project.config.sh`
   * Provide project name in value `PROJECT`
   * Define the path to the workflow configuration file as `MERGED_CONFIG` 
     * A number of such files have been defined for different computer systems and workflows
```

Next, create the Cromwell server and run configuration files with,
```
cd C_config_init
bash 04_make_cromwell_config.sh
```

### Define run list and make YAML run configuration files

A `RUN_LIST` file contains the the name and input files for each run of a batch.  It is used to create YAML
configuration files, and provides default values to utilities such as `cq` and `40_start_runs.sh`.

A run list consists of the following 4 columns:
* run name - a unique name for this run
* case name - need not be unique
* tumor UUID
* normal UUID

There are a number of approaches for creating a `RUN_LIST`.  
For CPTAC3, the logic of identifying runs for a variety of workflows (including those not yet implemented in CromwellRunner) is provided in [CPTAC3 Missing Analysis](https://github.com/ding-lab/CPTAC3.MissingAnalysis.git).
(Note, this generates a 6 or 9-column run list variant).

In the example below, a run list is created by generating a run for each tumor found for
a list of cases.  In this way, cases with multiple tumor samples will generate
one run for each.

Paths are obtained for each UUID by a lookup to a BamMap file.  Note,
CromwellRunner has transitioned to the [Catalog3
format](https://docs.google.com/document/d/1uSgle8jiIx9EnDFf_XHV3fWYKFElszNLkmGlht_CQGE/edit),
which are available for
[CPTAC3](https://github.com/ding-lab/CPTAC3.catalog/tree/master/Catalog3) and
[GDAN (`catalog3`
branch)](https://github.com/ding-lab/GDAN.catalog/tree/catalog3/Catalog3).

The per-run YAML configuration files are created, one for each `RUN_LIST`
entry,  with `A_YAML/20_make_yaml.sh`.  Specific parameters are obtained from
the `RUN_LIST` as well as project configuration files.  The YAML file itself is
generated from a workflow-specific template, in which run-specific parameters
are populated.  This YAML file then contains all of the input parameters into a
specific workflow run.

Example workflow which starts with a list of cases, creates a run list of all tumor/normal pairs,
excludes runs already performed (CPTAC3 specific DCC Analysis Summary tracking) and creates
YAML files:
```
cd A_YAML
bash x10_make_RunList-available.sh
bash x15_exclude_already_analyzed.sh
bash 20_make_yaml.sh
```

### Start docker and Cromwell server

Cromwell Runner uses Cromwell database server on mammoth to allow jobs to be
queried in various ways.  Other Cromwell database configurations (including MGI
server) have been implemented.  [File-based
database](https://github.com/ding-lab/TinDaisy/tree/master/testing/cromwell-simple-compute1)
configurations are possible but not suggested in a production environment.

Create Cromwell configuration file with,
```
C_config_init/04_make_cromwell_config.sh
```

Start docker with,
```
bash 00_start_docker.sh
```
Note that this has to be done anytime the Cromwell database is to be queried, for instance when running `cq` (described below).


Create new run logs with,
```
cd C_config_init
bash 10_make_data_run_logs.sh
```
It is necessary for the Cromwell server to be running for this to succeed, and it may take up to a minute
for the server to start.  If the server does not start, debug with `bash 10_make_data_run_logs.sh -d`.

### Start runs

Starting a batch of runs should be done with care.  Besides double-checking the configuration parameters,
it is recommended to proceed by 
1. start one run in debug mode (`-1d`) and examining the logs
2. launching one run and letting it execute to completion before proceeding with the rest of the batch.  This
is particularly important changes were made to the project configuration file

Things to double-check:
* Is `WORKFLOW_ROOT` set to an allocation large enough to contain the output data?  Note that each run may take
  up to 1Tb of disk space in this volume during job execution.  On compute1 this should be scratch space
* Confirm that `LSF_GROUP` is defined correctly and has a reasonable job limit (new installs should start low, 3-5).

Start one dry run with,
```
bash 40_start_runs.sh -1d
```
Examine for errors and check that output "looks right".  Then, start one run with,
```
bash 40_start_runs.sh -1
```
Evaluate log output, principally in `logs/RUN_NAME.out`.  If this is a new install, allow this to run to completion to confirm
pipeline is stable.  Once that is confirmed, launch the rest of the runs with,
```
tail -n +2 dat/RUN_LIST.dat | cut -f 1 | bash 40_start_runs.sh -
```
Here, running starting all but the first run in the list.  This will submit each run individually to the 
queue, and as many will start running as the job group limit allows.

### Test progress of runs
While a batch of runs is being processed, status and progress may be measured with the `src/cq` utility.
This queries the Cromwell server about each run and displays a variety of diagnostics.  As such, it must be
started from within a docker container,
```
bash 00_start_docker.sh
```
then,
```
bash src/cq
```
will provide the status and workflow ID (if available) of all runs in `RUN_LIST`

Runs which conclude successfully should (provided `-F` flag is provided `40_start_runs.sh`) delete large
temporary files and compress other intermediate results.  This can be checked by evaluating size of
the workflow root directory (`cq -q du`).  

### Clean up and restart failed runs

Jobs which failed for whatever reason, or which were not cleaned up with `-F` flag to `rungo`,
should be cleaned up update logs and minimize disk used.
Runs may fail for a variety reasons, including issues associated with configuration, disk space,
filesystem, database, and network.  Such runs are typically restarted and 
CromwellRunner utilities are designed to simplify such tasks.  Note that at this time Cromwell Runner does not support
automatically restarting a CWL job from an intermediate state - rather, the job is rerun from scratch.

Runs with a status of `Failed` can be identified by searching output of `cq`, i.e.,
```
bash src/cq | grep Failed | cut -f 1
```
It is convenient to save the run names to be further processed, e.g., to file `Failed-runs.dat`.

### Cleaning up runs manually

#### Succeeded runs
Runs which succeed need to be finalized and compressed, which is done with (assuming list of runs to process is in `runs.dat`):
```
P="ProjectName"
cat runs.dat | bash src/runtidy -x finalize -p $P -F Succeeded -m "Manual cleanup" -
cat runs.dat | bash src/datatidy -x compress -p $P -F Succeeded -m "Manual cleanup" -
```

#### Failed runs
Runs which fail need to be finalized and typically wiped, which deletes the entire workflow directory.  Note that details
about this run will be preserved in the run logs, data logs, and in the Cromwell database. 
```
P="ProjectName"
cat runs.dat | bash src/runtidy -x finalize -p $P -F Failed -m "Manual cleanup" -
cat runs.dat | bash src/datatidy -x wipe -p $P -F Failed -m "Manual cleanup" -
```
Note that wiping is destructive and permanent step, so be careful.

### Store runs and create analysis summary
When all runs have completed successfully, the results need to be reported and,
if these are on a temporary scratch space, stored in a permanent location.

The `50_make_analysis_summary.sh` script will create a file named
`dat/analysis_summary.dat`, which lists the outputs of each run along with the
input data.  

For runs on a system with `WORKFLOW_ROOT` on scratch storage (compute1
typically), the script `60_store_results.sh` will move results listed in the
analysis summary file from the location given by `SCRATCH_BASE` to `DEST_BASE`,
and update the analysis summary file to reflect this.  This step is called
storing the results, and is typically a move from `scratch1` to `storage1`.

```
bash 50_make_analysis_summary.sh
bash 60_store_results.sh
```


# Configuration file details

CromwellRunner configuration system provides parameters to,
* configure YAML files based on case names, BamMap files, and workflow parameters
* Configure cromwell configuration files
* launch cromwell instances
* collect and process results

We divide parameters into four families 
* Project parameters
  * parameters which are expected to change with every project, such as project name
* System parameters
  * expected to change between e.g. MGI and compute1
  * path to e.g. TinDaisy installation directory
  * path to cromwell workflow storage location
* Collection parameters
  * Associated with collections such as CPTAC3 and MMRF
  * Reference dependencies here
  * External databases
* Workflow parameters
  * Will differ depending on e.g. whether this is tindaisy.cwl or SomaticSV.cwl
  * Defines CWL 
  * Defines YAML template
  * Defines details related to finding BAMs in BamMap

We want parameter families inasmuch as possible to be independent of one another, so that parameters
in one group can be varied independently of those in another.  

In the case of paths to e.g. dbSnP DB, which will differ between system and reference, the system parameters
will include `DBSNP_ROOT`, which will yield reference specific path defined in collection as e.g., `DBSNP_ROOT/dbSnP-COSMIC.REF.vcf.gz`

## Example Workflows

The base directory contains sipmple scripts which take advantage of functionality in `./src`.  
Other example configuration files and scripts used for specific workflows are saved in appropriate projects in `../example_workflows`.  
These are generally copied to `./config` to be modified and used for specific runs.  Configuration files in this
directory are not saved to git, though relevant examples can be copied to `../example_workflows`

Template directory contains cromwell and YAML configuration templates.  These are not generally modified per run by hand.

# Additional details
*TODO*: Add the following discussions

* Cromwell Server - A way of getting status about current and past Cromwell runs
  Runs locally because of database integrity issues
* Compute1 issues
  * scratch1 space - faster and more reliable than storage1, but requires move step at end
* Creating a YAML template with `cwltool --make-template`
* Guidance on now to restart runs

# Cromwell utility details

Cromwell generates two classes of output 
* Data output in workflowRoot directory, as defined by WORKFLOW_ROOT in config/project_config.sh
* Run output files (`CASE.*`) in LOGD directory, consisting of Cromwell stdout and stderr
  (possibly log file generated by GNU `parallel` or LSF). 

Cromwell runner provides the following utilities to help deal with this output as well
as run setup, launching, and querying.
* `cq` - query cromwell server
* `datatidy` - manage cromwell run results 
* `rungo` - launch cromwell jobs 
* `runplan` - initialize cromwell jobs
* `runtidy` - Organize cromwell job logs

## `cq`

General purpose utility for querying Cromwell Server.  Run `bash src/cq -h` for documentation.

## `rungo`

Utility for launching cromwell jobs.  Interfaces with LSF / `bsub`.

## `runplan`

Utility for creating YAML files and checking run configuration.

## `runtidy`

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

## `datatidy`

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

`-1` flag to `rungo` (and most other scripts) will execute just the first case and exit.  `-d` flag is "dry run",
and will print out commands without executing them.  Both these flags, often in combination, are useful to test configuration
files and syntax prior to launching a real run.

## Run names vs. WorkflowID

Cromwell generates a unique WorkflowID (e.g., 2424f34e-adcb-4160-a05f-e102650acb83) for every run which
starts.  The typical workflow requires run names (often a case name, e.g., `C3L-01234`) to initialize, launch, and finalize runs, but some utilities
(`cq` and `runDataCleaner.sh`) allow WorkflowIDs to be substituted for run names.  Mapping from run name
to WorkflowID is performed in one of two ways:
1. If Cromwell log file `logs/RUN_NAME.out` exists, parse it to find WorkflowID
2. Alternatively, parse `logs/runlog.dat` file, and return most recent WorkflowID associated with the run name.
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
* `RunName`
* `WorkflowID`
* `Status`
* `StartTime`
* `EndTime`
* `Note` - optional, may indicate whether a restart, etc.

Once logs are stashed, association between WorkflowID and RunName is made with the RunLog.  Note that can have
mutiple entries per case and/or WorkflowID (possibly with different Status); the most recent one is the one
used for WorkflowID / Case association.

### DATAD/datalog.dat

Keeps track of run data and any cleaning that may take place following run completion.  There is one DataLog
per cromwell data directory, and is appended to 1) when a run is finalized and 2) when run data is cleaned.
DataLog has the following fields
* `RunName`
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

