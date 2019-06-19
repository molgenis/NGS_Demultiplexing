#MOLGENIS walltime=00:59:00 mem=2gb cores=1
#string createPerSampleFinalReportPl
#string finalReportResultDir
#string run
#string arrayDir
#string sampleSheet
#string workDir
#string filePrefix
#string ngsUtilsVersion
#string ngsDir
#string intermediateDir
#string nextSeqRunDataDir
#string stage

${stage} "${ngsUtilsVersion}"

"${createPerSampleFinalReportPl}" \
-i "${arrayDir}" \
-o "${finalReportResultDir}" \
-r "${run}" \
-s "${sampleSheet}"

echo "final report created"

echo "creating ${ngsDir}/Info/"
mkdir -p "${ngsDir}/Info/"
rsync -rv "${nextSeqRunDataDir}/InterOp" "${ngsDir}/Info/"
rsync -v "${nextSeqRunDataDir}/RunInfo.xml" "${ngsDir}/Info/"
rsync -v "${nextSeqRunDataDir}/"*"unParameters.xml" "${ngsDir}/Info/"
