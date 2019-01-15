### Step 1: BclToFastQ

The Bcl files produced by the Illumina sequencers (HiSeq,NextSeq etc), needs to be converted to a readable format in the form of a FastQ file.

**Scriptname:** BclToFastQ<br/>
**Input:** sequencer output (bcl files)<br/>
**Output:** Illumina FastQ files (lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz)<br/>

### Step 2: Illumina2GafFastQ 
The Illumina FastQ files have to be renamed to a format that can be used by the downstream pipeline
.fastq.gz
**Scriptname:**Illumina2GafFastQ<br/>
**Input:** Illumina FastQ files (lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz)<br/>
**Output:** (${filePrefix}_${lane}_${barcode}.fastq.gz)*<br/>

### Step 3: Demultiplex
In this step the reads with the known barcodes will be counted and will be written to a log file per lane.

**Scriptname:**Demultiplex<br/>
**Input:** (${filePrefix}_${lane}_${barcode}.fastq.gz)*<br/>
**Output:** ${filePrefix}_${lane}.log<br/>

### Step 4: CreateFinalReport
Copying Info from the sequencer to the results folder to preserve the important sequence data. <br />
This step was used to create a final report, this is only working when there is an arrayfile present. 

**Scriptname:**CreateFinalReport<br/>
**Input:** (${filePrefix}_${lane}_${barcode}.fastq.gz)*<br/>
**Output:** RunInfo.xml, RunParameters.xml and folder InterOp containing some .bin files <br/>
  
### Step 5: UploadSampleSheet
Samplesheet will be copied to the track and trace server (molgenis server).

**Scriptname:**UploadSampleSheet<br/>
