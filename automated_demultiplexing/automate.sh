#!/bin/bash
set -e
set -u

##Demultiplexing module will be loaded via cronjob
module list

MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )

##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
if [[ "${myhost}" == *"gattaca"* ]]
then
	echo "${myhost}"
	. "${MYINSTALLATIONDIR}/gattaca.cfg"
else
	echo "${myhost}"
	. "${MYINSTALLATIONDIR}/${myhost}.cfg"
fi
WHOAMI=$(whoami)
. "/home/${WHOAMI}/molgenis.cfg"

GROUP=$1
### Sequencer is writing to this location: $NEXTSEQDIR
### Looping through to see if all files
echo "ls -1 -d ${NEXTSEQDIR}/*/"
for i in $(ls -1 -d "${NEXTSEQDIR}/"*/)
do

	## PROJECTNAME is sequencingStartDate_sequencer_run_flowcell
	PROJECTNAME=$(basename "${i}")
	echo "working on ${PROJECTNAME}"
	sequencer=$(echo "${PROJECTNAME}" | awk 'BEGIN {FS="_"} {print $2}')
	miSeqCompleted="no"

        ## Check if there the run is already completed
        if [[ -f "${NEXTSEQDIR}/${PROJECTNAME}/RTAComplete.txt" ]] && [[ "${sequencer}" == "M01785" || "${sequencer}" == "M01997" ]]
        then
		miSeqCompleted="yes"
        fi
	## Check if there the run is already completed
	if [[ -f "${NEXTSEQDIR}/${PROJECTNAME}/RunCompletionStatus.xml" || "${miSeqCompleted}" == "yes" ]]
	then

		##Check if it is a GAF or GD run
		if [ ! -f "${ROOTDIR}/umcg-${GROUP}/${SCRATCHDIR}/Samplesheets/${PROJECTNAME}.csv" ]
		then
			continue
		fi

		### SETTING PATHS
		WORKDIR="${ROOTDIR}/${GROUP}/${SCRATCHDIR}"
		LOGSDIR="${WORKDIR}/logs"
		SAMPLESHEETSDIR="${WORKDIR}/Samplesheets"
		DEBUGGER="${LOGSDIR}/${PROJECTNAME}_logger.txt"
		### Check if the demultiplexing is already started
		if [ ! -f "${LOGSDIR}/${PROJECTNAME}_Demultiplexing.started" ]
		then
			rm -f "${DEBUGGER}.error"
			python "${EBROOTNGS_DEMULTIPLEXING}/automated_demultiplexing/checkSampleSheet.py" --input "${SAMPLESHEETSDIR}/${PROJECTNAME}.csv" --logfile "${DEBUGGER}.error"
			if [ -s "${DEBUGGER}.error" ]
			then
				echo "${PROJECTNAME} skipped"
				cat  "${DEBUGGER}.error" | mail -s "Samplesheet error ${PROJECTNAME}" "${ONTVANGER}"
				rm "${DEBUGGER}.error"
				break
			else
				echo  "Samplesheet is OK" >> "${DEBUGGER}"
				#####
				## RUN PIPELINE PART ##
				#####
				RUNFOLDER="${PROJECTNAME}"
				LOGGERPIPELINE="${WORKDIR}/generatedscripts/${RUNFOLDER}/logger.txt"
				echo "All checks are done. Logging from now on can be found: ${LOGGERPIPELINE}" >> "${DEBUGGER}"

				## Check if Check file (if samplesheet is already there) is existing
				if [ -f "${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.txt" ]
				then
					## Remove tmp Check file
                                        rm "${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.txt"
					echo "rm ${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.txt" >> "${LOGGERPIPELINE}"
				fi

					### Check if runfolder already exists
				if [ ! -d "${WORKDIR}/generatedscripts/${RUNFOLDER}" ]
				then
					mkdir -p "${WORKDIR}/generatedscripts/${RUNFOLDER}/"
					echo "mkdir -p ${WORKDIR}/generatedscripts/${RUNFOLDER}/" >> "${LOGGERPIPELINE}"
				fi

				## Direct to generatedscripts folder
				cd "${WORKDIR}/generatedscripts/${RUNFOLDER}/"

				## Copy generate script and samplesheet
				cp "${SAMPLESHEETSDIR}/${PROJECTNAME}.csv" "${PROJECTNAME}.csv"
				echo "copied ${SAMPLESHEETSDIR}/${PROJECTNAME}.csv to ${PROJECTNAME}.csv" >> "${LOGGERPIPELINE}"

				cp "${EBROOTNGS_DEMULTIPLEXING}/generate_template.sh" ./
				echo "Copied ${EBROOTNGS_DEMULTIPLEXING}/generate_template.sh to ." >> "${LOGGERPIPELINE}"
				echo "" >> "${LOGGERPIPELINE}"


				### Generating scripts
                                echo "Generated scripts" >> "${LOGGERPIPELINE}"
                                sh generate_template.sh "${PROJECTNAME}" "${WORKDIR}" "${GROUP}" 2>&1 >> "${LOGGERPIPELINE}"

				check=$(tail -1 "${LOGGERPIPELINE}")
				if [[ "${check}" == *"WRONG"* ]]
				then
					echo "there is something wrong, EXIT"
					echo "###"
					echo "### Here comes the last three lines of the logger:"
					tail -3 "${LOGGERPIPELINE}"
					echo "###"
					echo "###"
					exit 1 
				fi
                                echo "cd ${WORKDIR}/runs/${RUNFOLDER}/jobs" >> "${LOGGERPIPELINE}"
                                cd "${WORKDIR}/runs/${RUNFOLDER}/jobs"

				sh submit.sh
                                echo "jobs submitted, pipeline is running" >> "${LOGGERPIPELINE}"
                                touch "${LOGSDIR}/${PROJECTNAME}_Demultiplexing.started"

				printf "run_id,group,demultiplexing,copy_raw_prm,projects,date\n" > "${LOGSDIR}/${PROJECTNAME}_uploading.csv"
				printf "${PROJECTNAME},${GROUP},started,,," >> "${LOGSDIR}/${PROJECTNAME}_uploading.csv"

				CURLRESPONSE=$(curl -H "Content-Type: application/json" -X POST -d "{"username"="${USERNAME}", "password"="${PASSWORD}"}" https://${MOLGENISSERVER}/api/v1/login)
				TOKEN=${CURLRESPONSE:10:32}

				curl -H "x-molgenis-token:${TOKEN}" -X POST -F"file=@${LOGSDIR}/${PROJECTNAME}_uploading.csv" -FentityTypeId='status_overview' -Faction=add -Fnotify=false https://${MOLGENISSERVER}/plugin/importwizard/importFile

				echo "De demultiplexing pipeline is gestart, over een aantal uren zal dit klaar zijn \
                                en word de data automatisch naar zinc-finger gestuurd, hierna  word de pipeline gestart" | mail -s "Het demultiplexen van ${PROJECTNAME} is gestart op (`date +%d/%m/%Y` `date +%H:%M`)" ${ONTVANGER}


			fi
                fi
	fi
done
