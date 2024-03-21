We require a run list to be provided, which lists all input pairs for each run explicitly.

To be compatible with YAML creation, require the following columns in the file ../dat/RUN_LIST.dat
    run_name
    case
    datafile1_uuid
    datafile2_uuid

Also, require that BamMap v3 format is available

Example:
```
bash 20_make_yaml.sh 
```
