the `datatidy -x compress` step of the SomaticCNV pipeline (part of finalization step) sometimes
compresses all results, and doesn't leave the workflow outputs readily visible.  Not clear
why this happens, revisit when storage1 cache issues have settled down.  For now, these
are instructions for uncompressing any data which is compressed after a run.

Note that this is specific to SomaticCNV

1. make list of all workflowRoot paths
`cq -q workflowRoot | cut -f 3 > workflowRootPaths.dat`

2. ` bash 1_expand_results.sh workflowRootPaths.dat `

# notes

Example expanded WorkflowDir for run with excess zero (C3L-00898) is,
	/storage1/fs1/m.wyczalkowski/Active/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl/9844f802-3785-4a9b-8232-af1afeffa21e/analysis
See /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/SomaticCNV/02.all_cases_rerun/postanalysis.merge_02_02b/README.md for details

-> can we use existing lists of outputs for this?
   no, that's only provided by CWL

Outputs for this case
C3L-00898   abc0e40c-7c54-4f87-925a-604ea6af19b0    /scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl/abc0e40c-7c54-4f87-925a-604ea6af19b0/call-annotation/execution/glob-8d2a4c6350ac0f3eef6344d845feb79b/case.gene_level.log2.seg
C3L-00898   abc0e40c-7c54-4f87-925a-604ea6af19b0    /scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl/abc0e40c-7c54-4f87-925a-604ea6af19b0/call-normalize_normal/execution/norm/results/excess_zeros/excess_zeros_observed.dat
C3L-00898   abc0e40c-7c54-4f87-925a-604ea6af19b0    /scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl/abc0e40c-7c54-4f87-925a-604ea6af19b0/call-segmentation/execution/glob-6325c75b329988a6d0f698dd56fdc192/case.cnv

-> maybe just focus on uncompressing .../call-normalize_normal/execution/norm/results/excess_zeros

-> 1_expand_results.sh updated to expand this
