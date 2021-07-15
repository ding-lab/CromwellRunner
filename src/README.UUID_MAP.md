Making UUID map based partly on ..//15_PanCan569/UUID_MAP

CCRCC ITH samples will have multiple runs per case.  As a result, we modify
UUID_MAP_4 to have the following columns
* RUN_NAME - unique name for this run.  E.g., C3L-00103.HET_oymKX
* CASE - the actual case name.  Need not be unique
* TUMOR_UUID
* NORMAL_UUID

RUN_NAME will be the same as CASE for for cases which do not have multiple tumor samples
(e.g., heterogeneity studies)

UUID_MAP has 3 columns,
* RUN_NAME - unique name for this run.  E.g., C3L-00103.HET_oymKX
* TUMOR_UUID
* NORMAL_UUID

Note that for the purpose of CromwellRunner, RUN_NAME will serve as CASE, i.e.,
a unique identifier of the input data into a run
