# 3) Preparing and running NGS_DNA pipeline

### 1) Make samplesheet (see also the samplesheets part)
```bash
scp –r SEQSTARTDATE_SEQ_RUNTEST_FLOWCELLXX username@yourcluster:${root}/groups/$groupname/${tmpDir}/rawdata/ngs/
```
### 2) Create a folder in the generatedscripts folder
```bash
mkdir ${root}/groups/$groupname/${tmpDir}/generatedscripts/198210_SEQ_RUNTEST_FLOWCELLXX
```
### 3) Copy generate_template.sh to to generatedscripts folder
**_Note: the name of the folder should be the same as samplesheet (.csv) file_**

### 4) Run the generate script and submit jobs to cluster
module load NGS_Demultiplexing
cd ${root}/groups/$groupname/${tmpDir}/generatedscripts/198210_SEQ_RUNTEST_FLOWCELLXX
cp $EBROOTNGS_Demultiplexing/generate_template.sh .
bash generate_template.sh

navigate to jobs folder (this will be outputted at the step before this one).
```bash
bash submit.sh
```

