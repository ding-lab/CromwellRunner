Restarting a workflow from an intermediate state in prior run is accomplished as follows:
1. Uncompress necessary file(s) from prior run
2. Create YAML file associated with a modified workflow; for instance, the TinDaisy workflow
   tindaisy2.6.1-postmerge_refilter.cwl starts from the output of the merge step and includes
   all subsequent filters
3. Run workflow

To help create YAML file, see steps in B_restart.

TODO: document based on /home/m.wyczalkowski/Projects/CromwellRunner/TinDaisy/27.DLBCL_105-refilter



