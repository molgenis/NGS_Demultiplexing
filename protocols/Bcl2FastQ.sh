#MOLGENIS walltime=12:00:00 nodes=1 ppn=6 mem=12gb
#string bcl2fastqVersion
#string nextSeqRunDataDir
#string stage
#string checkStage
#string sampleSheet
#string run
#string intermediateDir
#string runJobsDir
#string prepKitsDir
#string ngsUtilsVersion
#string dualBarcode
#string runResultsDir
#string barcodeType
#string seqType

${stage} "${bcl2fastqVersion}"
${stage} "${ngsUtilsVersion}"

${checkStage}

#
# Initialize script specific vars.
#
if [ ! -d "${runResultsDir}" ]
then
	mkdir -p "${runResultsDir}"
	echo "mkdir ${runResultsDir}"
fi
#Make an intermediate and resultsDir 
if [ ! -d "${intermediateDir}" ]
then
	mkdir -p "${intermediateDir}"
fi

if [ -d "${intermediateDir}/Reports" ]
then
	rm -rf "${intermediateDir}/Reports"
fi

if [ -d "${intermediateDir}/Stats" ]
then
        rm -rf "${intermediateDir}/Stats"
fi

cp "${sampleSheet}" "${runJobsDir}"

echo "intermediateDir: ${intermediateDir}"

makeTmpDir "${intermediateDir}"
tmpIntermediateDir="${MC_tmpFile}"

echo "tmpIntermediateDir: ${tmpIntermediateDir}"

if [ "${dualBarcode}" == "TRUE" ]
then
	echo "dualBarcode modus on"
	CreateIlluminaSampleSheet_V2.pl \
	-i "${sampleSheet}" \
	-o "${tmpIntermediateDir}/Illumina_R${run}.csv" \
	-r "${run}" \
	-d TRUE \
	-s "${prepKitsDir}"
else
	echo "only one barcode detected"
	CreateIlluminaSampleSheet_V2.pl \
	-i "${sampleSheet}" \
	-o "${tmpIntermediateDir}/Illumina_R${run}.csv" \
	-r "${run}" \
	-s "${prepKitsDir}"

fi
mv "${tmpIntermediateDir}/Illumina_R${run}.csv" "${intermediateDir}/Illumina_R${run}.csv"

if  [[ "${seqType}" == "PE" && "${barcodeType}" == "UMI" ]]
then
	baseMask='y*,i8,y*,y*'
else
	baseMask='y*,i8'
fi

if [ "${barcodeType}" == "UMI" ]
then
	bcl2fastq \
	--runfolder-dir "${nextSeqRunDataDir}" \
	--output-dir "${tmpIntermediateDir}" \
	--mask-short-adapter-reads 5 \
	--use-bases-mask "${baseMask}" \
	--minimum-trimmed-read-length 0 \
	--create-fastq-for-index-reads \
	--sample-sheet "${intermediateDir}/Illumina_R${run}.csv"
else
	bcl2fastq \
	--runfolder-dir "${nextSeqRunDataDir}" \
	--output-dir "${tmpIntermediateDir}" \
	--mask-short-adapter-reads 10 \
	--sample-sheet "${intermediateDir}/Illumina_R${run}.csv"
fi


mv "${tmpIntermediateDir}/"* "${intermediateDir}"
echo "moved ${tmpIntermediateDir}/* ${intermediateDir}"
