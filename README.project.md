# Motivation

This work is to conclude analysis for DLBCL working group.

List of 64 runs to perform obtained through Missing Analysis workflow here:
    /home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/README.project.md

List is constructed by identifying all tumor/normal pairs possible given available data, then removing analyses which have been
performed.  This was done with both UUID and aliquot ID, to account for the fact that past processing used the submitted aligned UUIDs rather
than harmonized UUIDs.

Run list is copied to dat/RUN_LIST.dat from,
    /home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/dat/results/WGS_Somatic_Variant_TD/DLBCL/D_oldrun.run_list.dat
which contains 64 runs to perform.  For details see,
    /home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/README.project.md

# Past work

This work is essentially identical analysis as done here: 31.DLBCL_FFEP_WGS_47
/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/TinDaisy/31.DLBCL_FFEP_WGS_47
Note that classification filter is enabled even though this is WGS.

# New features


Using catalog derived from REST API rather than GraphQL (Catalog3)
  * New REST-derived file:
    RESTCAT=/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.GDC_REST.20230409-AWG.tsv
  * For now Catalog3 is available, with about 10 missing cases, here:
    CAT3=/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/CTSP_DLBCL.Catalog3.tsv


# Setup

$ bash 10_make_rl4.sh ../dat/D_oldrun.run_list.dat
Written to ../dat/RUN_LIST.dat

# Tracking

$ date && bash src/cq | cut -f 3 | sort | uniq -c
Thu Apr 27 16:44:12 UTC 2023
     11 Running
     34 Succeeded
     19 Unknown

$ date && bash src/cq | cut -f 3 | sort | uniq -c
Fri Apr 28 22:15:19 UTC 2023
     10 Running
     40 Succeeded
     14 Unknown

Mon May  1 16:34:39 UTC 2023
      9 Running
     51 Succeeded
      4 Unknown

Tue May  2 14:07:00 UTC 2023
      7 Running
     47 Succeeded
     10 Unknown

Wed May  3 19:49:56 UTC 2023
      1 Failed
      2 Running
     51 Succeeded
     10 Unknown

???? -> why the increase in unknowns?

## Understanding the unknowns and failures
CTSP-AD1J	Unassigned	Unknown
CTSP-AD1Z	Unassigned	Unknown
CTSP-AD23	Unassigned	Unknown
CTSP-AD24	Unassigned	Unknown
CTSP-AD4C	Unassigned	Unknown
CTSP-AD4C	Unassigned	Unknown
CTSP-AD1J	Unassigned	Unknown
CTSP-AD1Z	Unassigned	Unknown
CTSP-AD23	Unassigned	Unknown
CTSP-AD24	Unassigned	Unknown
CTSP-AD1G   fdced96d-6806-4aa8-9cfb-268d30a636d7    Failed

### Failed CTSP-AD1G
From CTSP-AD1G.out
```
[2023-05-03 01:56:43,37] [info] DispatchedConfigAsyncJobExecutionActor [^[[38;5;2mfdced96d^[[0mmnp_filter:NA:1]: Status change from - to Running
...
[2023-05-03 05:05:40,98] [info] DispatchedConfigAsyncJobExecutionActor [^[[38;5;2mfdced96d^[[0mmnp_filter:NA:1]: Status change from Running to Done
[2023-05-03 05:05:41,08] [info] WorkflowManagerActor: Workflow fdced96d-6806-4aa8-9cfb-268d30a636d7 failed (during ExecutingWorkflowState): java.lang.Exception: The compute backend terminated the job. If this termination is unexpected, examine likely causes such as preemption, running out of disk or memory on the compute instance, or exceeding the backends maximum job duration.
```

Note that mnp_filter only has 2Gb allocated.  This might be a problem?

### Unknown CTSP-AD1J
CTSP-AD1J.err:
Exception in thread "MainThread" java.nio.file.NoSuchFileException: /home/m.wyczalkowski/Projects/CromwellRunner/TinDaisy/34.DLBCL_64/yaml/CTSP-AD1J.yaml
-> file does not in fact exist

For all the other unknowns, same error - YAML file not existing

Solution will be to restart all the Unknown and Failed runs
    -> double MNP Filter memory

This will be run B




