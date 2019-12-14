# Testing on compute1
o
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


