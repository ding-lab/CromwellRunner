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

Started with -J 3

### Error 1

```
Check the content of stderr for potential additional information: /gscmnt/gc2541/cptac3_analysis/cromwell-workdir/cromwell-executions/SomaticSV.cwl/24bb4237-ce71-4135-a3fd-c86a8db3155f/call-SomaticSV.cwl/execution/stderr.
 [First 300 bytes]:/usr/local/somatic_sv_workflow/process_sample.sh: line 94: configManta.py: command not found
Fatal error 127: . Exiting.
```

### Errors

Several runs died because of incorrect paths to scripts (src not appended)

Restarting 1/3/20 with -1, just to make sure one completes.  Run takes about 3.5 hours
