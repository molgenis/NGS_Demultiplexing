#MOLGENIS walltime=00:59:00 mem=2gb cores=1
#string sampleSheet
#string MCsampleSheet
#string workDir
#string ngsDir
#string filePrefix
#string runResultsDir
#string dualBarcode
#string intermediateDir
#string generatedScriptsDir
#string nextSeqRunDataDir

WHOAMI=$(whoami)
# shellcheck source=/home/${WHOAMI}/molgenis.cfg
. "/home/${WHOAMI}/molgenis.cfg"

echo "Importing Samplesheet into ${MOLGENISSERVER}"

SCRIPT_NAME="UploadSampleSheet"
group=""

if [[ "${runResultsDir}" == *"umcg-gaf"* ]]
then
	group="umcg-gaf"
elif [[ "${runResultsDir}" == *"umcg-gd"* ]]
then
	group="umcg-gd"
elif [[ "${runResultsDir}" == *"umcg-atd"* ]]
then
	group="umcg-atd"
else
	group="other"
fi

echo "creating ${ngsDir}/Info/"
mkdir -p "${ngsDir}/Info/"
rsync -rv "${nextSeqRunDataDir}/InterOp" "${ngsDir}/Info/"
rsync -v "${nextSeqRunDataDir}/RunInfo.xml" "${ngsDir}/Info/"
rsync -v "${nextSeqRunDataDir}/RunCompletionStatus.xml" "${ngsDir}/Info/"
rsync -v "${nextSeqRunDataDir}/"*"unParameters.xml" "${ngsDir}/Info/"

cp "${sampleSheet}" "${MCsampleSheet}"
cp "${sampleSheet}" "${ngsDir}/${filePrefix}.csv"
chmod u+rw,u-x,g+r,g-wx,o-rwx "${ngsDir}/${filePrefix}"*

if [ ! -d "${workDir}/logs/${filePrefix}/" ]
then
	mkdir -p "${workDir}/logs/${filePrefix}/"
fi

HEADER=$(head -1 "${MCsampleSheet}")
IFS=',' array=("${HEADER}")

groupNameBool='false'
for i in "${array[@]}"
do
	if [ "${i}" == 'groupName' ]
        then
		groupNameBool='true'
        fi
done
if [ "${groupNameBool}" == 'false' ]
then
	externalSampleID=$(head -1 "${MCsampleSheet}"  | awk 'BEGIN {FS=","}{for (i==1 ; i <=NF; i++){ if ($i=="externalSampleID"){printf i}}}')
        project=$(head -1 "${MCsampleSheet}"  | awk 'BEGIN {FS=","}{for (i==1 ; i <=NF; i++){ if ($i=="project"){printf i}}}')
        lane=$(head -1 "${MCsampleSheet}"  | awk 'BEGIN {FS=","}{for (i==1 ; i <=NF; i++){ if($i=="lane"){printf i}}}')

	awk -v ext="${externalSampleID}" 'BEGIN{FS=","}{print $ext}' "${MCsampleSheet}" | awk 'BEGIN{FS="_"}{if (NR==1){print "famnr,umcgnr,dnanr,onderzoeknr,archiveLocation"} else {print $1","$2","$3","$4",prm03"}}' > "${MCsampleSheet}.splittedExtID"
	awk -v var="${group}" -v ext="${externalSampleID}" -v pro="$project" -v la="$lane" 'BEGIN{FS=","}{if (NR==1){print $0",groupName,uniqueID"}else{print $0","var","$ext"_"$pro"_"$la}}' "${MCsampleSheet}" > "${MCsampleSheet}.add"
	paste -d',' "${MCsampleSheet}.splittedExtID" "${MCsampleSheet}.add" > "${MCsampleSheet}.tmp"
	perl -pi -e 'chomp if eof' "${MCsampleSheet}.tmp"
	echo "updated ${MCsampleSheet} with group column"
	mv "${MCsampleSheet}.tmp" "${MCsampleSheet}"
fi


if [ ! -f "${workDir}/logs/${filePrefix}/run01.${SCRIPT_NAME}.finished" ]
then
	if curl -s -f -H "Content-Type: application/json" -X POST -d "{"username"="${USERNAME}", "password"="${PASSWORD}"}" https://${MOLGENISSERVER}/api/v1/login
	then
		CURLRESPONSE=$(curl -H "Content-Type: application/json" -X POST -d "{"username"="${USERNAME}", "password"="${PASSWORD}"}" https://${MOLGENISSERVER}/api/v1/login)
		TOKEN=${CURLRESPONSE:10:32}
		curl -H "x-molgenis-token:${TOKEN}" -X POST -F"file=@${MCsampleSheet}" -FentityTypeId='status_samples' -Faction=add -Fnotify=false -FmetadataAction=ignore https://${MOLGENISSERVER}/plugin/importwizard/importFile
	else
		echo "curl couldn't connect to host, skipped the uploading of the samplesheet to ${MOLGENISSERVER}"
		echo "curl couldn't connect to host, skipped the uploading of the samplesheet to ${MOLGENISSERVER}" > "${ngsDir}/${filePrefix}.csv.uploadingFailed"

	fi
	touch "${workDir}/logs/${filePrefix}/run01.${SCRIPT_NAME}.finished"
else
	echo "samplesheet already uploaded to ${MOLGENISSERVER}"

fi

fieldIndex=$(for i in  "${ngsDir}/"*".rejected" ; do [[ -e "${i}" ]] || break ;  echo "${i}" | awk '{n=split($0, array, "_")} END{ print n-1 }';done)
for i in "${ngsDir}/"*".rejected"; do [[ -e "${i}" ]] || break ; echo "${i}" | awk -v field="${fieldIndex}" 'BEGIN{FS="_"}{print $field}' ;done | uniq > "${ngsDir}/rejectedBarcodes.txt"

if [ ! -s "${ngsDir}/rejectedBarcodes.txt" ]
then
	rm "${ngsDir}/rejectedBarcodes.txt"
fi

if [ -f "${workDir}/logs/${filePrefix}/run01.demultiplexing.started" ]
then
	mv "${workDir}/logs/${filePrefix}/run01.demultiplexing."{started,finished}
else
	touch "${workDir}/logs/${filePrefix}/run01.demultiplexing.finished"
fi
cd "${runResultsDir}" || exit

while IFS='\n' read -r line; do resultsArray+=("$line"); done < <(find "${ngsDir}/"*.*)
for i in "${resultsArray[@]}"
do
	ln -s "${i}" 
done

cd - || exit

echo "made symlinks from the rawdata/ngs folder to the results folder: ${runResultsDir}"
echo "finished: $(date +%FT%T%z)" >> "${workDir}/logs/${filePrefix}//run01.demultiplexing.totalRuntime"
