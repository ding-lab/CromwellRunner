Two types of workflows are supported: those where a list of cases is provided and TinDaisy is to figure out tumor / normal pairing,
or where a run list is provided, which lists all input pairs for each run explicitly.

# Run-list workflow

This is the main one.  Generally, starting with run_name, case, UUIDs already generated.

To be compatible with YAML creation, require the following columns (RUNLIST4 format)
    run_name
    case
    datafile1_uuid
    datafile2_uuid

Also, require that BamMap v3 format is available

Example:
```
bash 20_make_yaml.sh dat/A_canonical_run_list.dat
```
