Test run of MutectDemo dataset.  We are currently relying on test data distributed
with TinDaisy.  TinDaisy installation directory is defined as TD_ROOT in 


Goal of this work is to,
1) implement running of simple (lobotomized) workflow
2) test running on compute1
3) demonstrate updated workflow organizational structure (./workflow.XXX)


# How to run

Trying idea of having base scripts in .., passing arguments to scripts to be workflow-specific

```
bash 1_make_yaml.sh workflow.MutectDemo/project_config.MutectDemo.compute1.sh

```
