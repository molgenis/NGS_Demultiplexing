### 1) Installing NGS_Demultiplexing

We first have to load EasyBuild, this can be done using the following command:
```bash
module load EasyBuild
```

The NGS_Demultiplexing has a some dependencies, these are handled by easybuild when the --robot command is executed (all the dependencies can be found [here](ngs-dependencies)). Since we have also our own repo we have to give the path to that also. There can be multiple paths to easybuild configs, just separate them by colon.

**_Note:_** The order in which you give the paths are important! The original easybuild path can be left empty (just a colon is enough)
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


### 2) Installing the necessary resources (Prepkit))

Logout and login again.
Run the script NGS_resources to install the required resources, you can download the scripts [here](attachments/scripts.tar.gz).

```bash
sh NGS_Demultiplexing-resources.sh
```


### 3) Creating workdir structure
```bash
sh makestructure.sh
```
