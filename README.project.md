# SomaticSV calling with CromwellRunner

SomaticSV uses an ad hoc BamMap since it is being run on CRAM files obtained from UMich

Building on (hopefully) successful run on SomaticSV here: /gscuser/mwyczalk/projects/CWL/somatic_sv_workflow
    Branch cromwell

See for discussion of test processing of UMich data: 
    /gscuser/mwyczalk/projects/CWL/somatic_sv_workflow/README.project.md

Data downloaded from storate1 onto here: /gscmnt/gc2521/dinglab/mwyczalk/CPTAC3.share
Reference: `GRCh38_full_analysis_set_plus_decoy_hla`

Prior work on katmai on SomaticSV (CRAM branch) was using a Rabix-based workflow.  This proved very slow,
so trying to move everything over to MGI and cromwell.  Initial testing of a single run on Cromwell is above.
Goal here is to have CromwellRunner successfully initialize, launch, and track SomaticSV runs.

## Starting runs

Test runs completed successfully after a few tries
* In future, make sure CWL and scripts have full paths to all executables.  Do not rely on paths
* Make sure PYTHONPATH is set in script or Dockerfile

Starting runs with -J 5

### Errors

Jobs ran nicely, about 3 hours each.  The following runs had errors in log files:
* C3N-03878
* C3N-03933

Errors seem to be associated with communicating with Cromwell server at successful conclusion of run, e.g.,
    2020-01-06 07:20:03,92] [error] Failed to summarize metadata

As a result, the result data are available, but may not be reported using `cq`

At conclusion of run, copy of ./logs is saved for safe keeping as logs.20200107.tar.gz

## TODO

Future work will be to finalize SomaticSV runs and make sure CQ works as expected
