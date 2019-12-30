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

## Testing 4_start_runs.sh

Get error:
```
The 'general' queue does not support Docker.
Request aborted by esub. Job not submitted.
```

Not sure where `general` queue is defined.  Used to be when starting docker (step 0)?

