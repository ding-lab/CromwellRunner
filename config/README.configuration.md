TinDaisy configuration system provides parameters to,
* configure YAML files based on case names, BamMap files, and workflow parameters
* Configure cromwell configuration files
* launch cromwell instances
* collect and process results

We divide parameters into four families, with examples of what parameters might be in each.
* Project parameters
  * parameters which are expected to change with every project, such as project name
* System parameters
  * expected to change between e.g. MGI and compute1
  * path to e.g. TinDaisy root directory
  * path to cromwell workflow storage location
* Collection parameters
  * Associated with collections such as CPTAC3 and MMRF
  * Reference dependencies here
  * External databases
    * VEP cache defined here
    * dbSnP-cosmic database defined here
* Workflow parameters
  * Will differ depending on e.g. whether this is tindaisy.cwl or tindaisy-postcall.cwl
  * Defines CWL 
  * Defines YAML template
  * Defines details related to finding BAMs in BamMap

We want parameter families inasmuch as possible to be independent of one another, so that parameters
in one group can be varied independently of those in another.  

In the case of paths to e.g. dbSnP DB, which will differ between system and reference, the system parameters
will include DBSNP_ROOT, which will yield reference specific path defined in collection as e.g., "DBSNP_ROOT/dbSnP-COSMIC.REF.vcf.gz"


