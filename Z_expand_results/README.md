the `datatidy -x compress` step of the SomaticCNV pipeline (part of
finalization step) sometimes compresses all results, and doesn't leave the
workflow outputs readily visible.  This has also been observed in TinDaisy
runs.  Not clear why this happens, and this should be investigated and
resolved.  For now, these are instructions for uncompressing any data which is
compressed after a run.

Note that different workflows require a different approach

1. make list of all workflowRoot paths
`bash src/cq -q workflowRoot | cut -f 3 > workflowRootPaths.dat`

2. ` bash A_expand_results.SomaticCNV.sh ../workflowRootPaths.dat `

# notes for SomaticCNV

Results of `cq -q outputs` - this is what we expect to see

C3L-00898   abc0e40c-7c54-4f87-925a-604ea6af19b0    /scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl/abc0e40c-7c54-4f87-925a-604ea6af19b0/call-annotation/execution/glob-8d2a4c6350ac0f3eef6344d845feb79b/case.gene_level.log2.seg
C3L-00898   abc0e40c-7c54-4f87-925a-604ea6af19b0    /scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl/abc0e40c-7c54-4f87-925a-604ea6af19b0/call-normalize_normal/execution/norm/results/excess_zeros/excess_zeros_observed.dat
C3L-00898   abc0e40c-7c54-4f87-925a-604ea6af19b0    /scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl/abc0e40c-7c54-4f87-925a-604ea6af19b0/call-segmentation/execution/glob-6325c75b329988a6d0f698dd56fdc192/case.cnv
-> in some cases, `excess_zeros` also need to be recovered

# Notes for TinDaisy
C3L-01039.BIOTEXT_1wwzAvq   e51a025e-88c5-4014-8979-1a30b705c699    /scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/tindaisy2.cwl/e51a025e-88c5-4014-8979-1a30b705c699/call-snp_indel_proximity_filter/execution/output/ProximityFiltered.vcf
C3L-01039.BIOTEXT_1wwzAvq   e51a025e-88c5-4014-8979-1a30b705c699    /scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/tindaisy2.cwl/e51a025e-88c5-4014-8979-1a30b705c699/call-vcf2maf/execution/result.maf
C3L-01039.BIOTEXT_1wwzAvq   e51a025e-88c5-4014-8979-1a30b705c699    /scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/tindaisy2.cwl/e51a025e-88c5-4014-8979-1a30b705c699/call-canonical_filter/execution/output/HotspotFiltered.vcf
