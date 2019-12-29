# Testing on compute1

* docker server startup and paths to project dirs will differ.
* Initial runs are manta
* Constructing docker image to run cromwell and CromwellRunner in ./docker
* moving cq-type code to ./src.  Motivation is to start separating out cq-code from
  TinDaisy to make it more general

## Preliminaries

Need to have conda installed so that can enable environment with jq, parallel, etc.
Currently running the image registry.gsc.wustl.edu/apipe-builder/genome_perl_environment:22
- this needs to have conda installed along with 
    * `jq`
    * `parallel`
    * `tmux`

# Ongoing development

* Isolate cq functionality to this project, remove from TinDaisy (varscan branch currently)
* Move MutectDemo on compute1 functionality to TinDaisy
  * it does not belong in CromwellRunner
* Simplify organization of following tasks
  * run on different system (MGI vs. compute1)
  * TinDaisy entire workflow vs. restart (tindaisy-postcall.cwl)
  * Run on different collections (e.g., MMRF hg19 vs. CPTAC3 hg38)

