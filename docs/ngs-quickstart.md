#  Installing NGS_DNA pipeline

This is the Quickstart tutorial. When there are any problems, please first go to the detailed [install page](ngs-install), or when there are problems [running the pipeline](ngs-run)

We first have to load EasyBuild, this can be done using the following command:
```bash
module load EasyBuild
```

The NGS_Demultiplexing has some dependencies, that are handled by EasyBuild when the --robot command is executed (all the dependencies can be found [here](ngs-dependencies)). Since we also have our own repo we have to give the path to that also. There can be multiple paths to easybuild configs, just separate them by colon.

**_Note:_** The order in which you give the paths is important! The original easybuild path can be left empty (just a colon is enough)
```bash
eb NGS_Automated/2.0.13-NGS_Demultiplexing-2.0.12 --robot --robot-paths=${pathToMYeasybuild}/easybuild-easyconfigs/easybuild/easyconfigs/:
```
**_Note:_** Some software cannot be downloaded automagically due to for example licensing or technical issues and the build will fail initially.
In these cases you will have to manually download and copy the sources to
${HPC_ENV_PREFIX}/sources/[a-z]/NameOfTheSoftwarePackage/
This is the case for example for Java. Therefore:
```bash
scp jdk-7u80-linux-x64.tar.gz your_account@yourcluster.nl:${root}/apps/sources/j/Java/
scp jdk-8u45-linux-x64.tar.gz your_account@yourcluster.nl:${root}/apps/sources/j/Java/
```


#  Preparing and running NGS_Demultiplexing pipeline

To run a demultiplexing pipeline you need to have a samplesheet with the same name as the sequence run(e.g. 198210_SEQ_RUNTEST_FLOWCELLXX.csv)
```bash


mkdir ${root}/groups/$groupname/${tmpDir}/generatedscripts/198210_SEQ_RUNTEST_FLOWCELLXX

scp –r 198210_SEQ_RUNTEST_FLOWCELLXX.csv username@yourcluster:/groups/$groupname/${tmpDir}/generatedscripts/

module load NGS_Demultiplexing
cd ${root}/groups/$groupname/${tmpDir}/generatedscripts/198210_SEQ_RUNTEST_FLOWCELLXX
cp $EBROOTNGS_Demultiplexing/generate_template.sh .
bash generate_template.sh

navigate to jobs folder (this will be outputted at the step before this one).
```bash
bash submit.sh
```
