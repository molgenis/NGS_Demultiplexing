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


sampsheet=${runResultsDir}/${runPrefix}.csv
HEADER=$(head -1 ${sampsheet})
OLDIFS=$IFS
IFS=','
array=($HEADER)
IFS=$OLDIFS
count=0
barcode=""
barcode2=""
for i in "${array[@]}"
do

        if [ "${i}" == "barcode" ]
        then
            	barcode=$((count+1))
        elif [ "${i}" == "barcode2" ]
        then
            	barcode2=$((count+1))
        fi
	count=$((count + 1))
done

if [ ! -z $barcode2 ]
then

	perl -p -e 's|barcode,|barcode_old,|g' $sampsheet > ${intermediateDir}/changedDollar1.csv	
	cut -d"," -f$barcode2 ${intermediateDir}/changedDollar1.csv >> ${intermediateDir}/barcode2.txt
	barcode2bool="true"
	
	while read line
	do
		if [[ $line == "none" || $line == "" || $line == "None" ]]
		then
			echo "barcode2 is: none, None or empty"
			barcode2bool="false"
			break
		fi
	done<${intermediateDir}barcode2.txt
	
	if [ "${barcode2bool}" =="true" ]
	then
		cut -d"," -f$barcode,$barcode2 --output-delimiter=$'-' ${intermediateDir}/changedDollar1.csv > ${intermediateDir}/changedDollar2.csv
		
		paste -d "," ${intermediateDir}/changedDollar1.csv ${intermediateDir}/changedDollar2.csv > ${intermediateDir}/changedDollar3.csv
		
		perl -p -e 's|,barcode_old-barcode2|,barcode|g' ${intermediateDir}/changedDollar3.csv > ${intermediateDir}/changedDollar4.csv
		mv ${intermediateDir}/changedDollar4.csv ${runResultsDir}/${runPrefix}.csv
		echo "replaced column barcode in ${runResultsDir}/${runPrefix}.csv"
		echo "finished"
	fi
else
    	echo "barcode2 is not in the file"
fi

### Pipeline is finished, write a finished file
touch ${workDir}/logs/${runPrefix}_Demultiplexing.finished
