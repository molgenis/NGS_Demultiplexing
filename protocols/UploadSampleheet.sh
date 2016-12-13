#MOLGENIS walltime=00:59:00 mem=2gb cores=1
#string sampleSheet
#string MCsampleSheet
#string workDir
#string runPrefix
#string runResultsDir

WHOAMI=$(whoami)
. /home/$WHOAMI/molgenis.cfg


echo "Importing Samplesheet into ${MOLGENISSERVER}"

cp ${sampleSheet} ${MCsampleSheet} 
cp ${sampleSheet} ${runResultsDir}${runPrefix}.csv
chmod u+rw,u-x,g+r,g-wx,o-rwx ${runResultsDir}/${runPrefix}*

group=""

if [ ${runResultsDir} == *"umcg-gaf"* ]
then
	group="umcg-gaf"
elif [ ${runResultsDir} == *"umcg-gd"* ]
then
	group="umcg-gd"
else
	group="other"
fi

mac2unix ${MCsampleSheet}

awk -v var="$group" 'BEGIN{FS=","}{if (NR==1){print $0",group"}else{print $0","var}}' ${MCsampleSheet} | perl -pe 'chomp if eof' > ${MCsampleSheet}.tmp

echo "updated ${MCsampleSheet} with group column"

mv ${MCsampleSheet}.tmp ${MCsampleSheet}


if [ ! -f ${workDir}/logs/${runPrefix}.is.uploaded ]
then
	CURLRESPONSE=$(curl -H "Content-Type: application/json" -X POST -d "{"username"="${USERNAME}", "password"="${PASSWORD}"}" https://${MOLGENISSERVER}/api/v1/login)
	TOKEN=${CURLRESPONSE:10:32}
	curl -H "x-molgenis-token:${TOKEN}" -X POST -F"file=@base_${MCsampleSheet}" -Faction=add -Fnotify=false https://${MOLGENISSERVER}/plugin/importwizard/importFile

	touch ${workDir}/logs/${runPrefix}.is.uploaded
else
	echo "samplesheet already uploaded to ${MOLGENISSERVER}"

fi
