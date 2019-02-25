#MOLGENIS walltime=00:59:00 mem=2gb cores=1
#string createPerSampleFinalReportPl
#string finalReportResultDir
#string run
#string arrayDir
#string sampleSheet
#string workDir
#string runPrefix
#string ngsUtilsVersion
#string runResultsDir
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

echo "creating ${runResultsDir}/Info/"
mkdir ${runResultsDir}/Info/
rsync -rv ${nextSeqRunDataDir}/InterOp ${runResultsDir}/Info/
rsync -v ${nextSeqRunDataDir}/RunInfo.xml ${runResultsDir}/Info/
rsync -v ${nextSeqRunDataDir}/*unParameters.xml ${runResultsDir}/Info/
