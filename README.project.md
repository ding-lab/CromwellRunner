Processing 193 WXS cases.  These are obtained on shiso:/Users/mwyczalk/Projects/CPTAC3/CPTAC3.Cases/20190729.Batch4
Switching to Cromwell 44

See dat/README.cases for details about cases

Run 1 of case C3L-00001 - 0f4f3439-d9b6-4889-a0d2-8ce00c8954ad
Completed successfully.  Note that there is an -orig version of this output directory for testing

See dat/README.md for details about batches
* Batch A,B,C,D ran successfully

Long run of Batch E died for unexplained reasons:
* Saving output of cq to cq.out for debugging
* C3N-00223 failed to launch because of some Cromwell instantiation error.  No WorkflowID assigned
    * This will have output deleted and start from scratch
* C3L-02508 C3L-02549 C3N-00495 C3N-00545 Died in Running state.  Not clear what the error was
    * They have status Running but are now dead
    * Will finalize them with,
    *   runtidy -x finalize -F Running -m "Died but status remains Running" C3L-02508 C3L-02549 C3N-00495 C3N-00545
* Launching new runs without modifying cases.dat file:
    * grep -v Succeeded cq.out | cut -f 1 | bash 2_start_runs.sh -
* Delete old output directories?  Want to use wipe.  Here are the runs which died:
    C3L-02508   461d12ec-3560-4b51-8eab-4303cb6dd837    
    C3L-02549   9c964e2d-57fc-4805-849b-98142c29ab62   
    C3N-00495   a0537eb0-92b3-42db-9aa0-3dee9d775667  
    C3N-00545   6afb01fd-f7a5-4a39-a338-920fc2a23370 
* First, register with,
    datatidy -F Running -x original -m "Manual registration of failed run with status Running" 461d12ec-3560-4b51-8eab-4303cb6dd837 9c964e2d-57fc-4805-849b-98142c29ab62 a0537eb0-92b3-42db-9aa0-3dee9d775667 6afb01fd-f7a5-4a39-a338-920fc2a23370
* Note that the above registration will not be necessary because runtidy will pass along "-F" argument to force registration
* Next, wipe these with,
    datatidy -F Running -x wipe -m "Wiping failed runs which had status Running" 461d12ec-3560-4b51-8eab-4303cb6dd837 9c964e2d-57fc-4805-849b-98142c29ab62 a0537eb0-92b3-42db-9aa0-3dee9d775667 6afb01fd-f7a5-4a39-a338-920fc2a23370 

After this the runs proceeded smoothly.  However, one job remained with a status of Running with no log updates for >24 hours.
    > C3N-00495       9425f21c-eacc-49d5-aef9-c3cd4b3c4bf2    Running
During this time only 3 jobs were actually running, decreasing throughput.  With the help of @tmooney via slack I was able to kill the bad job as follows:
    * Went to the tmux terminal which is running `rungo` and did CTRL-Z to pause it
    * Did `ps auxf` and examined output:
```
mwyczalk 131980  0.0  0.0  11340  2856 ?        T    Aug19   0:00 bash 2_start_runs.sh -
mwyczalk 131981  0.0  0.0  11464  3148 ?        T    Aug19   0:00  \_ bash /gscuser/mwyczalk/projects/TinDaisy/TinDaisy/src/rungo -J 4 -F -c /gscuser/mwyczalk/projects/TinDaisy/TinDaisy/src -R /gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/crom
mwyczalk 183453  0.1  0.0  30636 17128 ?        T    21:57   0:04      \_ perl /gscmnt/gc2508/dinglab/mwyczalk/miniconda3/envs/jq/bin/parallel --semaphore -j4 --id 20190819162209 --joblog ./logs/C3N-00737.log --tmpdir ./logs /usr/bin/java -Dconfig.
mwyczalk 132123  0.0  0.0  32964 16696 ?        T    Aug19   0:35 perl /gscmnt/gc2508/dinglab/mwyczalk/miniconda3/envs/jq/bin/parallel --semaphore -j4 --id 20190819162209 --joblog ./logs/C3N-00495.log --tmpdir ./logs /usr/bin/java -Dconfig.file=dat
mwyczalk 132134  0.0  0.0  11316  2788 ?        T    Aug19   0:00  \_ /bin/bash -c /usr/bin/java -Dconfig.file=dat/cromwell-config-db.dat -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStore=/gscmnt/gc2560/core/genome/cromwell/cro
mwyczalk 132135  1.9  0.1 12425760 810732 ?     Tl   Aug19  34:52      \_ /usr/bin/java -Dconfig.file=dat/cromwell-config-db.dat -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStore=/gscmnt/gc2560/core/genome/cromwell/cromwell.tru
...
```
Based on this, did `kill 132123`, which corresponds to the top-level process associated with C3N-00495.  After that did `fg` to resume the `parallel` run, and a new job started up immediately.

TODO: finalize and wipe the old C3N-00495 run.  this will have to be restarted later.
(Also to investigate: why did C3N-00495 go zombie twice?)

8/21/19: the following two jobs have status Failed:
    C3N-01071   5cbe926b-d6b1-4388-9e2a-34650d7e8081    Failed
    C3N-01072   e5f97f37-63fa-4923-9da3-94263d30e567    Failed
    C3N-01175   d1b0e247-6b45-4a14-a4ce-1f7d9641dcd2    Failed
    C3N-01176   53c7cead-b6e8-498e-a112-cb89efaf74d2    Failed
Errors are the result of missing file /gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/B_Filter/dbSnP-COSMIC.GRCh38.d1.vd1.20190416.vcf.gz
This happened when data were being moved to gc7272.  A soft link was made to restore this file.
TODO: The runs can be restarted, perhaps from the merged file

8/23/19: the following jobs appear to be running but are actually dead.  Parallel has quit.
    C3N-02421   061a266b-19d8-48fe-a8f1-3835f023ecc1    Running
    C3N-02423   3b52557f-a336-4f9b-857b-feb3180ca165    Running
    C3N-02424   e9982882-48d0-47a8-a659-682f1e3ac061    Running
    C3N-02433   9a677fc6-1153-4e22-af09-cf7f531c41de    Running

To summarize, we want to finalize and wipe the following runs:
    C3N-00495   9425f21c-eacc-49d5-aef9-c3cd4b3c4bf2    Running
    C3N-02421   061a266b-19d8-48fe-a8f1-3835f023ecc1    Running
    C3N-02423   3b52557f-a336-4f9b-857b-feb3180ca165    Running
    C3N-02424   e9982882-48d0-47a8-a659-682f1e3ac061    Running
    C3N-02433   9a677fc6-1153-4e22-af09-cf7f531c41de    Running
    C3N-01071   5cbe926b-d6b1-4388-9e2a-34650d7e8081    Failed
    C3N-01072   e5f97f37-63fa-4923-9da3-94263d30e567    Failed
    C3N-01175   d1b0e247-6b45-4a14-a4ce-1f7d9641dcd2    Failed
    C3N-01176   53c7cead-b6e8-498e-a112-cb89efaf74d2    Failed

commands:
    runtidy -x finalize -F Running -m "Died but status remains Running" C3N-00495   C3N-02421   C3N-02423   C3N-02424   C3N-02433   
    runtidy -x finalize -F Failed -m "Finalizing failed run" C3N-01071 C3N-01072 C3N-01175 C3N-01176

    datatidy -F Running -x wipe -m "Wiping failed runs which had status Running" C3N-00495   C3N-02421   C3N-02423   C3N-02424   C3N-02433
    datatidy -F Failed -x wipe -m "Wiping failed runs " C3N-01071 C3N-01072 C3N-01175 C3N-01176

    cq | grep -v Succeeded | cut -f 1 | bash 2_start_runs.sh -

8/26/19: all jobs has succeeded
    $ cq | cut -f 3 | sort | uniq -c
        166 Succeeded

Combine all batches back together, by cases.dat pointing to cases-193.dat
$ cq | cut -f 3 | sort | uniq -c
    193 Succeeded

Note that it is not necessary to finalize these runs since they already have done so.  They are also compressed.

To do to finish up: 
* Combine all cases back together ( see dat/README.cases)
  -> cases.dat points to cases-193.dat
* Create an analysis summary file for submission to CPTAC3
  * bash 4_make_analysis_summary.sh
    => ./dat/analysis_summary.dat is generated
* Submit for CPTAC3 Submission:
    * Submit form link: https://docs.google.com/forms/d/e/1FAIpQLSfw5EXIeUEw_pIEjyGhOCJaIAA9MT4Ub5Qlhthudy6RLBVRYw/viewform?usp=sf_link
    * Pipeline link: https://github.com/ding-lab/TinDaisy
    * Analysis Summary: /gscuser/mwyczalk/projects/TinDaisy/CromwellRunner/Y2.b4/dat/analysis_summary.dat
    * Processing Description: /gscuser/mwyczalk/projects/TinDaisy/TinDaisy-Core/docs/processing_description.md

* TODO notes for next time:
  * Copy datalog (logs/datalog.dat) to the workflow root directory, so that it is associated with the data and not the batches
  * Tidy up documentation, including updating workflow and sections about what happens when something goes wrong
  * Think through how to deal with sub-batches.  Don't want to be messing with cases.dat all the time


