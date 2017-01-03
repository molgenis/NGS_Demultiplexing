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
module load ${ngsUtilsVersion}

${createPerSampleFinalReportPl} \
-i ${arrayDir} \
-o ${finalReportResultDir} \
-r ${run} \
-s ${sampleSheet}

perl -p -e 's|,barcode,|,barcode_old,|' ${sampleSheet} > ${sampleSheet}.tmp1

perl -pi -e 's|,barcode_combined,|,barcode,|' ${sampleSheet}.tmp1 > ${sampleSheet}.tmp2

echo "mv ${sampleSheet}.tmp2 ${sampleSheet}"
