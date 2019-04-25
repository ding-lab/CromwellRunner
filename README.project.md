Running Yige's 5 CCRCC cases as defined here: https://github.com/ding-lab/ccRCC_drug.catalog

The CRAM run failed right away because .bai files not found

B2,C2,D2 completed successfully
A1,E2 Completed processing through VEP Filter, then hung on vcf_2_maf steps.

RCC_A1  c9528f73-a1b9-4788-be2d-1b140fa6f111    null
RCC_B2  d04a179c-8b87-473b-a8ee-82f057b8c24a    /gscmnt/gc2541/cptac3_analysis/cromwell-workdir/cromwell-executions/tindaisy.cwl/d04a179c-8b87-473b-a8ee-82f057b8c24a/call-vep_filter/execution/results/vep_filter/vep_filtered.vcf
RCC_C2  7e0f5873-d190-4c0a-98c9-f8606d4bf6a9    /gscmnt/gc2541/cptac3_analysis/cromwell-workdir/cromwell-executions/tindaisy.cwl/7e0f5873-d190-4c0a-98c9-f8606d4bf6a9/call-vep_filter/execution/results/vep_filter/vep_filtered.vcf
RCC_D2  dfb4ad1d-ec84-4ebf-adde-597f5ae920bd    /gscmnt/gc2541/cptac3_analysis/cromwell-workdir/cromwell-executions/tindaisy.cwl/dfb4ad1d-ec84-4ebf-adde-597f5ae920bd/call-vep_filter/execution/results/vep_filter/vep_filtered.vcf
RCC_E2  8cda2476-b9c1-4845-8321-dad4ea4ecef5    null
RCC_C2_CRAM 081c2ed5-4e8f-4e41-9c3c-5876df0a7023    null

# can reconstruct output files for A1 and E2 even while running:
RCC_A1 /gscmnt/gc2541/cptac3_analysis/cromwell-workdir/cromwell-executions/tindaisy.cwl/c9528f73-a1b9-4788-be2d-1b140fa6f111/call-vep_filter/execution/results/vep_filter/vep_filtered.vcf
RCC_E2 /gscmnt/gc2541/cptac3_analysis/cromwell-workdir/cromwell-executions/tindaisy.cwl/8cda2476-b9c1-4845-8321-dad4ea4ecef5/call-vep_filter/execution/results/vep_filter/vep_filtered.vcf
