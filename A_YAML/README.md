We require a run list to be provided, which lists all input pairs for each run explicitly.

To be compatible with YAML creation, require the following columns (RUNLIST4 format)
    run_name
    case
    datafile1_uuid
    datafile2_uuid

However, the format is more flexible if you edit parameters scripts in config/Scripts, which get 
the entire line of the RUN_LIST once the run name is matched.

Example:
```
bash 20_make_yaml.sh 
```
