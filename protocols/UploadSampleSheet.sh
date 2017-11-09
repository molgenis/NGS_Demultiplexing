#MOLGENIS walltime=00:59:00 mem=2gb cores=1
#string sampleSheet
#string MCsampleSheet
#string workDir
#string runPrefix
#string runResultsDir
#string dualBarcode
#string intermediateDir
#string generatedScriptsDir

WHOAMI=$(whoami)
. "/home/${WHOAMI}/molgenis.cfg"

echo "Importing Samplesheet into ${MOLGENISSERVER}"

group=""

if [[ "${runResultsDir}" == *"umcg-gaf"* ]]
then
	group="umcg-gaf"
elif [[ "${runResultsDir}" == *"umcg-gd"* ]]
then
	group="umcg-gd"
else
	group="other"
fi
if [ "${dualBarcode}" == "TRUE" ]
then
	echo "dual barcode MODE: copied samplesheet to ${workDir}/Samplesheets/${runPrefix}.csv.original"
	cp "${workDir}/Samplesheets/${runPrefix}.csv" "${workDir}/Samplesheets/${runPrefix}.csv.original"
fi
if [ ! -f "${generatedScriptsDir}/${runPrefix}.samplesheetConverted" ]
then
	perl -pi -e 's|,barcode,|,barcode1,|' "${sampleSheet}"
	perl -pi -e 's|,barcode_combined|,barcode|' "${sampleSheet}"
	touch "${generatedScriptsDir}/${runPrefix}.samplesheetConverted"
fi

if [ "${dualBarcode}" == "TRUE" ]
then
	cp -f "${sampleSheet}" "${workDir}/Samplesheets/${runPrefix}.csv"
fi

cp "${sampleSheet}" "${MCsampleSheet}"
cp "${sampleSheet}" "${runResultsDir}/${runPrefix}.csv"
chmod u+rw,u-x,g+r,g-wx,o-rwx "${runResultsDir}/${runPrefix}"*

HEADER=$(head -1 "${MCsampleSheet}")
OLDIFS=$IFS
IFS=','
array=($HEADER)
IFS=$OLDIFS
count=0
groupNameBool="false"
for i in "${array[@]}"
do
	if [ "${i}" == "groupName" ]
        then
		groupNameBool="true"
        fi
done
if [ "${groupNameBool}" == "false" ]
then
	awk -v var="${group}" 'BEGIN{FS=","}{if (NR==1){print $0",groupName"}else{print $0","var}}' "${MCsampleSheet}" > "${MCsampleSheet}.tmp"
	perl -pi -e 'chomp if eof' "${MCsampleSheet}.tmp"
	echo "updated ${MCsampleSheet} with group column"
	mv "${MCsampleSheet}.tmp" "${MCsampleSheet}"
fi


if [ ! -f "${workDir}/logs/${runPrefix}.is.uploaded" ]
then
	CURLRESPONSE=$(curl -H "Content-Type: application/json" -X POST -d "{"username"="${USERNAME}", "password"="${PASSWORD}"}" https://${MOLGENISSERVER}/api/v1/login)
	TOKEN=${CURLRESPONSE:10:32}
	curl -H "x-molgenis-token:${TOKEN}" -X POST -F"file=@${MCsampleSheet}" -FentityTypeId='status_samples' -Faction=add -Fnotify=false https://${MOLGENISSERVER}/plugin/importwizard/importFile

	touch "${workDir}/logs/${runPrefix}.is.uploaded"
else
	echo "samplesheet already uploaded to ${MOLGENISSERVER}"

fi

touch "${workDir}/logs/${runPrefix}_Demultiplexing.finished"

printf "run_id,group,demultiplexing,copy_raw_prm,projects,date\n" > "${intermediateDir}/${runPrefix}_uploading.csv"
printf "${runPrefix},${group},finished,,," >> "${intermediateDir}/${runPrefix}_uploading.csv"

CURLRESPONSE=$(curl -H "Content-Type: application/json" -X POST -d "{"username"="${USERNAME}", "password"="${PASSWORD}"}" https://${MOLGENISSERVER}/api/v1/login)
TOKEN=${CURLRESPONSE:10:32}

curl -H "x-molgenis-token:${TOKEN}" -X POST -F"file=@${intermediateDir}/${runPrefix}_uploading.csv" -FentityTypeId='status_overview' -Faction=update -Fnotify=false https://${MOLGENISSERVER}/plugin/importwizard/importFile
