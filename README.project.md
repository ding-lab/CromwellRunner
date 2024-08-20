Goal is to evaluate tumor-only workflow for 20 DLBCL samples

Ad hoc test of tumor-only workflow for DLBCL data

Details about this download batch are here:
    /home/m.wyczalkowski/Projects/GDAN/Work/20240718.DLBCL_Validation/README.md
and on paprika here:
    /Users/m.wyczalkowski/Projects/GDAN/Work/20240703.DLBL_Validation/README.md

Initial test with tumor-only workflow is performed here, in branch 202408:
    ./Workflow/BICSEQ2.CWL/testing/cwl_call/DLBCL20-test

# Run setup
BamMap
    /home/m.wyczalkowski/Projects/GDAN/Work/20240718.DLBCL_Validation/dat/BamMap.DLBCL20.v1.dat

-> this is a new style of bammap for AWS data and has the columns,
     1	file_name	CTSP-B6FB-TTP1-A-1-0-D-A91O-36.WholeGenome.RP-1329.bam
     2	file_size	337184910854
     3	case_submitter_id	CTSP-B6FB
     4	aliquot_submitter_id	CTSP-B6FB-TTP1-A-1-0-D-A91O-36
     5	experimental_strategy	WGS
     6	tissue_type	Tumor
     7	disease_type	Mature B-Cell Lymphomas
     8	primary_site	Unknown
     9	url	s3://dlbcl-misc-bucket/Tumor-Only/CTSP-B6FB-TTP1-A-1-0-D-A91O-36.WholeGenome.RP-1329.bam
    10	path	/storage1/fs1/m.wyczalkowski/Active/Primary/GDAN-AWS/dlbcl-misc-bucket/CTSP-B6FB-TTP1-A-1-0-D-A91O-36.WholeGenome.RP-1329.bam

RunList

This is modified from RunList4 format becasuse we don't have two BAMs, just one.
Also, using Sample Name / aliquot as UUID
Note that RunList3 format is RunName, Case, SampleName
We use RunName = SampleName

RunList = /home/m.wyczalkowski/Projects/GDAN/Work/20240718.DLBCL_Validation/dat/RUN_LIST3.dat

Make soft link as dat/RUN_LIST.dat
    ln -s /home/m.wyczalkowski/Projects/GDAN/Work/20240718.DLBCL_Validation/dat/RUN_LIST3.dat RUN_LIST.dat

Note that RUNLIST has any number of columns, and these are matched by column 1 and rest passed as arguments to YAML script

Note, a lot of work takes place here,
    PARAM_SCRIPT="config/Scripts/get_pipeline_params.SomaticCNV-case-only.sh"
