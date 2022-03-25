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
#string interopVersion

WHOAMI=$(whoami)
# shellcheck source=/home/${WHOAMI}/molgenis.cfg
. "/home/${WHOAMI}/molgenis.cfg"


ml "${interopVersion}"

echo "creating ${ngsDir}/Info/"
mkdir -p "${ngsDir}/Info/"

Q30=$(summary "${nextSeqRunDataDir}" | grep Total | awk 'BEGIN{FS=","}{print $7}')
echo "Q30:${Q30}"
if [[ -f "${nextSeqRunDataDir}/RunCompletionStatus.xml" ]]
then
	ClusterDensity=$(grep ClusterDensity "${nextSeqRunDataDir}/RunCompletionStatus.xml" | grep -Eo '[0-9]{1,9}[.][0-9]{1,9}')
	echo "ClusterDensity:${ClusterDensity}"
	ClustersPassingfilter=$(grep ClustersPassingFilter "${nextSeqRunDataDir}/RunCompletionStatus.xml" | grep -Eo '[0-9]{1,9}[.][0-9]{1,9}')
	echo "ClustersPassingfilter:${ClustersPassingfilter}"
	rsync -v "${nextSeqRunDataDir}/RunCompletionStatus.xml" "${ngsDir}/Info/"
else
	ClusterDensity=""
	ClustersPassingfilter=""
fi
year=$(summary "${nextSeqRunDataDir}" | head -9 | sed 's/ //g' | grep -Eo '[1-4]{1}[0-9]{5}'| cut -b 1,2)
month=$(summary "${nextSeqRunDataDir}" | head -9 | sed 's/ //g' | grep -Eo '[1-4]{1}[0-9]{5}' | cut -b 3,4)
day=$(summary "${nextSeqRunDataDir}" | head -9 | sed 's/ //g' | grep -Eo '[1-4]{1}[0-9]{5}' | cut -b 5,6)

echo "date:${day}/${month}/${year}"

sequencingDate="${day}/${month}/20${year}"
echo "sequencingDate:${sequencingDate}"

echo -e "Sample,Run,Date\n${filePrefix},run01,${sequencingDate}" > "${ngsDir}/Info/SequenceRun_run_date_info.csv"
echo -e "Sample\tClusterDensity(K/mm2)\tClustersPassingFilter(%)\tPercentage>=Q30\n${filePrefix}\t${ClusterDensity}\t${ClustersPassingfilter}\t${Q30}" > "${ngsDir}/Info/SequenceRun.csv"


#deze zouden waarschijnlijk niet eens mee hoeven.
rsync -rv "${nextSeqRunDataDir}/InterOp" "${ngsDir}/Info/"
rsync -v "${nextSeqRunDataDir}/RunInfo.xml" "${ngsDir}/Info/"
rsync -v "${nextSeqRunDataDir}/"*"unParameters.xml" "${ngsDir}/Info/"

if [ ! -d "${workDir}/logs/${filePrefix}/" ]
then
	mkdir -p "${workDir}/logs/${filePrefix}/"
fi


touch "${workDir}/logs/${filePrefix}/run01.demultiplexing.started"


#################Dit stuk later aanpassen, naar hoe de diagnostiek het wil. Dit werkt ook nog niet, kan niet met komma getallen overweg.##################
#if [ "${Q30}" -lt 100 ]
#then
#	echo -e "Sequence run: ${nextSeqRunDataDir}, has a Q30 of ${Q30}, this is below the threshold of 70%." > "${workDir}/logs/${filePrefix}/run01.demultiplexing.failed"
#
#elif [ "${ClusterDensity}" -lt 170 ] || [ "${ClusterDensity}" -gt 230 ]
#then
#	echo -e "Sequence run: ${nextSeqRunDataDir}, has a Cluster density of ${ClusterDensity}, this is not whithin the specifications of 180-220 k/mm2." > "${workDir}/logs/${filePrefix}/run01.demultiplexing.failed"
#
#elif [ "${ClustersPassingfilter}" -lt 100]
#then
#	echo -e "Sequence run: ${nextSeqRunDataDir}, has a Cluster passing filter of ${ClustersPassingfilter}%, this is below the threshold of 70%." > "${workDir}/logs/${filePrefix}/run01.demultiplexing.failed"
#else
#	touch "${workDir}/logs/${filePrefix}/run01.demultiplexing.started"
#fi
##################
