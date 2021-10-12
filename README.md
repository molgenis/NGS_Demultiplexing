# Demultiplexing pipeline

##1. Goal
Next Generation Sequencing data processing using the inhouse pipeline for Bcl To FastQ conversion, demultiplexing and standardized filename convertion.

##2. Scope of application
Demultiplexing pipeline for Illumina BaseCalls convertion to fastq files.  The members of the GCC-NGS team are responsible for the analyses. This pipeline is used in combination with NGS_automated. The general workflow consist of the following steps:

####Data flow:
```
   ⎛¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯⎞
   ⎜                    Illumina sequencers writes Bcl data to GATTACA {01,02}machines     ⎜
   ⎜                                                                                       ⎜
   ⎝______________________________________________________________________________________⎠
                                         v
                                         v  > > > > > > NGS_Automated Demultiplexing [automatically start Demultplexing Pipeline when new bcl files and samplesheet are available ]
                                         v
   ⎛¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯⎞
   ⎜                    NGS_Demultiplexing conversion of Bcls files to Fastq files,        ⎜
   ⎜                    and takes place on GATTACA {01,02}machines.                        ⎜
   ⎝______________________________________________________________________________________⎠
                                         v
                                         v  > > > > > > NGS_Automated CopyRawDataToPRM [stores .fq.gz and .fq.gz.md5 files on permanent storage system]
                                         v                                           
   ⎛¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯⎞
   ⎜                  Fastqs are available for futher pressing by NGS_DNA or NGS_RNA       ⎜
   ⎜                  pipelines.                                                           ⎜
   ⎝______________________________________________________________________________________⎠
```

## 3. Description of the different pipeline steps.
### Step 1: ProcessInterop
Stores and formats the clusterDensity, clustersPassingFilter, InterOp dir and Q30 QC values.

**Scriptname:** ProcessInterop <br/>
**Input:** InterOp dir <br/>
**Output:** Info/SequenceRun.csv file with clusterDensity, clustersPassingFilter and Q30. <br/>

### Step 2: BclToFastQ

The Bcl files produced by the Illumina sequencers (MiSeq,NextSeq etc), needs to be converted to a readable format in the form of a FastQ file.

**Scriptname:** BclToFastQ<br/>
**Input:** sequencer output (bcl files)<br/>
**Output:** Illumina FastQ files (lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz)<br/>

### Step 3: Illumina2GafFastQ 
The Illumina FastQ files have to be renamed to a format that can be used by the downstream pipeline

**Scriptname:** Illumina2GafFastQ<br/>
**Input:** Illumina FastQ files (lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz)<br/>
**Output:** (${filePrefix}_${lane}_${barcode}.fastq.gz)*<br/>

### Step 4: Demultiplex
In this step the reads with the known barcodes will be counted and will be written to a log file per lane.

**Scriptname:** Demultiplex<br/>
**Input:** (${filePrefix}_${lane}_${barcode}.fastq.gz)*<br/>
**Output:** ${filePrefix}_${lane}.log<br/>

  
### Step 5: UploadSampleSheet
Samplesheet will be copied to the track and trace server (molgenis server).

**Scriptname:**UploadSampleSheet<br/>

## 4. Preparing and running a !manually started NGS_Demultiplexing run.

To run a demultiplexing pipeline you need to have a samplesheet with the same name as the sequence run(e.g. STARTDATE_SEQ_RUNNR_FLOWCELLXX.csv)

```bash
SCR_ROOT_DIR=${root}/groups/${groupname}/${tmpDir}/
mkdir ${SCR_ROOT_DIRpDir}/generatedscripts/STARTDATE_SEQ_RUNNR_FLOWCELLXX
SCR_ROOT_DIR=${root}/groups/${groupname}/${tmpDir}/

scp –r STARTDATE_SEQ_RUNNR_FLOWCELLXX username@yourcluster:/groups/${groupname}/${tmpDir}/generatedscripts/

module load NGS_Demultiplexing

cd ${root}/groups/${groupname}/${tmpDir}/generatedscripts/STARTDATE_SEQ_RUNN_FLOWCELLXX
cp ${EBROOTNGS_Demultiplexing}/generate_template.sh .
bash generate_template.sh "${project}" "${SCR_ROOT_DIR}" "${group}"
```

Navigate to jobs folder (this will be outputted at the step before this one). And than submit the jobs.

```bash
bash submit.sh
```

