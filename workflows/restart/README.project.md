This project develops restart functionality for LSCC run.

Notes here will need to be transferred over to workflow-specific README and this 
file reset to a clean state (to serve as template for README.project.md)

Goal is to perform a restart of CPTAC3 runs LSCC.20191104
    run directory: /gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/LSCC.20191104

# Issues and TODOs

* Integrate `RESTART_MAP` better.  Should it be defined as part of Workflow config?  Should it have its own step?

# Connfiguration
## Create restart map

Source: /gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/LSCC.20191104/dat/analysis_summary.dat

```
DAT=/gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/LSCC.20191104/dat/analysis_summary.dat
mkdir -p dat
cut -f 1,9 $DAT | grep -v case > dat/LSCC.20191104.restart-map.dat
```

## Create a cases list
```
cut -f 1 dat/LSCC.20191104.restart-map.dat > dat/cases.dat
```

## Project configuration

Edit Project.config.sh appropriately

## System configuration
```
tmux new -s tindaisy
bash 00_start_docker.sh
conda activate jq 
/usr/bin/java -Dconfig.file=/gscuser/tmooney/server.cromwell.config -jar /opt/cromwell.jar server >/dev/null &
export CROMWELL_URL=http://localhost:8000
```

## `RESTART_MAP` - past notes

```
$ head MMRF-20190925.map.dat
MMRF_1016   2c210004-7e16-49cf-8c0c-7dcee82ace2f
MMRF_1020   42bd11f4-6f55-45ef-bfbf-14044550cab6
```

`RESTART_MAP` is used by `runplan`.  From the documentation there,
```

-R RESTART_MAP: file listing workflow IDs for each case when restarting runs.  Requires RESTART_ROOT in PARAMS

Restarting of runs is supported by making available RESTART_D variable in YAML
template, which provides path to root directory of prior run.
RESTART_D="RESTART_ROOT/UUID", with RESTART_ROOT defined in PARAMS (mandatory),
and UUID obtained from RESTART_MAP file (TSV with CASE and UUID, `cq | cut -f 1-2` will work)
```

In future development, might be better to pass analysis_summary file


# Preliminary runs

## Testing 1_uncompress_restart
```
bash 1_uncompress_restart.sh -1d
```

-> This has the following error it is run the first time:
```
Uncompressing restart files
Processing 1 / 113 [ Sun Dec 29 10:38:25 CST 2019 ]: d722a4fa-bd67-4134-8a60-21eec15c5abd
cq Fatal ERROR. Exiting.
cq Fatal ERROR. Exiting.
ERROR: No TAR file in , nothing to do. Exiting
Fatal error 1: . Exiting.
```

After that it runs OK.  Not entirely consistent / repeatable, not clear why
Once first one runs, uncompress intermediate files for entire batch:
```
bash 1_uncompress_restart.sh
```

## Testing `2_make_yaml`
To test one,
```
bash 2_make_yaml.sh -1
```

To make them all,
```
bash 2_make_yaml.sh 
```

## run 3_make_config.sh

## 4_start_runs.sh

During testing, 3 or 4 runs were started which may need to be deleted

Running production with -J4 -F

Next day there are two jobs apparently unfinished (based on contents of logs directory)
* C3L-02627 - Failed to instantiate Cromwell System. Shutting down Cromwell.
    * Restarting with,
        bash 4_start_runs.sh -J1 -F C3L-02627
* C3N-02374 - Looks like it succeeded
    /gscmnt/gc2541/cptac3_analysis/cromwell-workdir/cromwell-executions/tindaisy-postcall.cwl/0074e313-d303-4159-b4e8-31d4840ffdba/call-vep_filter/execution/results/vep_filter/vep_filtered.vcf
    Zombie succeeded - cq indicates it is finished
    Look at README.md for details how to deal with
    After killing job, finalize run and compress data with,
        src/runtidy -x finalize -p LSCC.postcall.20191228 -m "Succeeded zombie manual cleanup" -F Succeeded C3N-02374
        src/datatidy -x compress -p LSCC.postcall.20191228 -m "Succeeded zombie manual cleanup" -F Succeeded C3N-02374


# Notes on using `cq`

-W $CWL needs to be passed on call to `cq -q output` so that the JSON is correctly parsed (is there wildcards in `jq`?)

