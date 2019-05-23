Production run of Y2.b2 WXS adjacent / blood normal analysis

Previous run like this is here:
    /gscuser/mwyczalk/projects/TinDaisy/TinDaisy/demo/task_call/cromwell.Y2b1.normals

Here, adjacent normal serves as the "tumor" case, blood normal serves as the "normal" case

1. get list of all Y2.b2 cases (exclude Y2.b2-noWXS):
```
grep Y2.b2 /gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/CPTAC3.cases.dat | grep -v Y2.b2-noWXS | cut -f 1 > dat/cases.Y2.b2.dat
```

However, note that not all of these have a tissue / adjacent normal sample:
$ grep -f dat/cases.Y2.b2.dat ~/projects/CPTAC3/CPTAC3.catalog/CPTAC3.file-summary.txt | cut -f 8 | sort | uniq -c
     47 WXS.hg38 T N
      9 WXS.hg38 T N A

To proceed, we extract just those cases which have the adjacent normal:
```
grep -f dat/cases.Y2.b2.dat ~/projects/CPTAC3/CPTAC3.catalog/CPTAC3.file-summary.txt | grep "WXS.hg38 T N A" | cut -f 1 > dat/cases.dat
```

-> we are processing 9 cases here
