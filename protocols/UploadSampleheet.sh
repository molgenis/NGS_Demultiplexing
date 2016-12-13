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

if [[ ${runResultsDir} == *"umcg-gaf"* ]]
then
	group="umcg-gaf"
elif [[ ${runResultsDir} == *"umcg-gd"* ]]
then
	group="umcg-gd"
else
	group="other"
fi

mac2unix ${MCsampleSheet}


HEADER=$(head -1 ${MCsampleSheet})
OLDIFS=$IFS
IFS=','
array=($HEADER)
IFS=$OLDIFS
count=0
groupNameBool="false"
for i in "${array[@]}"
do
  	if [ "${i}" == "group" ]
        then
            	groupNameBool="true"
        fi
done
if [ ${groupNameBool} == "false" ]
then
	awk -v var="$group" 'BEGIN{FS=","}{if (NR==1){print $0",groupName"}else{print $0","var}}' ${MCsampleSheet} > ${MCsampleSheet}.tmp
	perl -pi -e 'chomp if eof' ${MCsampleSheet}.tmp
	echo "updated ${MCsampleSheet} with group column"
	mv ${MCsampleSheet}.tmp ${MCsampleSheet}
fi


if [ ! -f ${workDir}/logs/${runPrefix}.is.uploaded ]
then
	CURLRESPONSE=$(curl -H "Content-Type: application/json" -X POST -d "{"username"="${USERNAME}", "password"="${PASSWORD}"}" https://${MOLGENISSERVER}/api/v1/login)
	TOKEN=${CURLRESPONSE:10:32}
	curl -H "x-molgenis-token:${TOKEN}" -X POST -F"file=@${MCsampleSheet}" -Faction=add -Fnotify=false https://${MOLGENISSERVER}/plugin/importwizard/importFile

	touch ${workDir}/logs/${runPrefix}.is.uploaded
else
	echo "samplesheet already uploaded to ${MOLGENISSERVER}"

fi
