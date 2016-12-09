#MOLGENIS walltime=12:00:00 nodes=1 ppn=6 mem=12gb
#string bcl2fastqVersion
#string NGSDir
#string nextSeqRunDataDir
#string runResultsDir
#string stage
#string checkStage
#string sampleSheet
#string run
#string intermediateDir
#string runJobsDir
#string prepKitsDir
#string ngsUtilsVersion

${stage} ${bcl2fastqVersion}
${stage} ${ngsUtilsVersion}

${checkStage}

#
# Initialize script specific vars.
#

#Make an intermediate and resultsDir 
if [ ! -d ${runResultsDir} ]
then
	mkdir -p ${runResultsDir}
	echo "mkdir ${runResultsDir}"
fi

if [ ! -d ${intermediateDir} ]
then
    	mkdir -p ${intermediateDir}
fi

if [ -d ${intermediateDir}/Reports ]
then
	rm -rf ${intermediateDir}/Reports
fi

if [ -d ${intermediateDir}/Stats ]
then
        rm -rf ${intermediateDir}/Stats
fi

cp ${sampleSheet} ${runJobsDir}

echo "intermediateDir: ${intermediateDir}"

makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

HEADER=$(head -1 ${sampleSheet})
OLDIFS=$IFS
IFS=','
array=($HEADER)
IFS=$OLDIFS
count=0
barcode=""
barcode2=""

dualBarcode="false"

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

    	perl -p -e 's|barcode,|barcode_old,|g' $sampleSheet > ${intermediateDir}/changedDollar1.csv
        cut -d"," -f$barcode2 ${intermediateDir}/changedDollar1.csv >> ${intermediateDir}/barcode2.txt
        

        while read line
        do
          	if [[ $line == "none" || $line == "" || $line == "None" ]]
                then
                    	echo "barcode2 is: none, None or empty"
                        dualBarcode="false"
                        break
		else
			dualBarcode="true"
			break
                fi
        done<${intermediateDir}barcode2.txt
fi

echo "tmpIntermediateDir: ${tmpIntermediateDir}"

if [ "${dualBarcode}" == "true" ]
then
	CreateIlluminaSampleSheet_V2.pl \
	-i ${sampleSheet} \
	-o ${tmpIntermediateDir}/Illumina_R${run}.csv \
	-r ${run} \
	-d TRUE \
	-s ${prepKitsDir}
else
	CreateIlluminaSampleSheet_V2.pl \
	-i ${sampleSheet} \
	-o ${tmpIntermediateDir}/Illumina_R${run}.csv \
	-r ${run} \
	-s ${prepKitsDir}

fi
mv ${tmpIntermediateDir}/Illumina_R${run}.csv ${intermediateDir}/Illumina_R${run}.csv

bcl2fastq \
--runfolder-dir ${nextSeqRunDataDir} \
--output-dir ${tmpIntermediateDir} \
--mask-short-adapter-reads 10 \
--sample-sheet ${intermediateDir}/Illumina_R${run}.csv 

mv ${tmpIntermediateDir}/* ${intermediateDir}
echo "moved ${tmpIntermediateDir}/* ${intermediateDir}"

echo "fixing dual barcode (if exists)"

if [ "${dualBarcode}" == "true" ]
then

	perl -p -e 's|barcode,|barcode_old,|g' $sampleSheet > ${intermediateDir}/changedDollar1.csv	
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
	
	if [ "${barcode2bool}" == "true" ]
	then
		cut -d"," -f$barcode,$barcode2 --output-delimiter=$'-' ${intermediateDir}/changedDollar1.csv > ${intermediateDir}/changedDollar2.csv
		
		paste -d "," ${intermediateDir}/changedDollar1.csv ${intermediateDir}/changedDollar2.csv > ${intermediateDir}/changedDollar3.csv
		
		perl -p -e 's|,barcode_old-barcode2|,barcode|g' ${intermediateDir}/changedDollar3.csv > ${intermediateDir}/changedDollar4.csv
		mv ${intermediateDir}/changedDollar4.csv ${sampleSheet}
		echo "replaced column barcode in ${sampleSheet}"
		echo "finished"
	fi
else
    	echo "barcode2 is not in the file"
fi
