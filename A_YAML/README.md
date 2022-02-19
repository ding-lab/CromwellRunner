Typical workflow for creating YAML files based on list of cases

1. Create ../dat/cases.dat file which lists cases to run
2. Execute `bash 10_make_RUN_LIST.sh` to create
    `../dat/RUN_LIST.preliminary.dat`
3. Optionally exclude runs which have already been performed.  This is done with step `15_exclude_already_analyzed.sh`
   * if this step is not performed, then it is necessary to do the following,
    ```
        cd ../dat
        ln -s RUN_LIST.preliminary.dat RUN_LIST.dat
    ```
4. finally, run `bash 20_make_yaml.sh`.  This will create per-run configuration YAML files in the ../yaml directory.
   Review these files (spot checks, etc).

