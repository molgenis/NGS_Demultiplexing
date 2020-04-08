#!/bin/bash
set -e 
set -u

##external call with 3 arguments (rawdataName, group and workDir)

module list

ENVIRONMENT_PARAMETERS=parameters_gattaca.csv
RAWDATANAME=${1}
WORKDIR=$2
GROUP=$3
WORKFLOW=${EBROOTNGS_DEMULTIPLEXING}/workflow.csv
echo "$WORKDIR AND $RAWDATANAME"
echo "GROUPIE: $GROUP"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

mkdir -p ${WORKDIR}/generatedscripts/${RAWDATANAME}/
mkdir -p ${WORKDIR}/rawdata/ngs/${RAWDATANAME}/

if [ -f ${WORKDIR}/generatedscripts/${RAWDATANAME}/out.csv  ];
then
	rm -rf ${WORKDIR}/generatedscripts/${RAWDATANAME}/out.csv
fi

#
###### Dual barcode checker
#
sampsheet=${WORKDIR}/generatedscripts/${RAWDATANAME}/${RAWDATANAME}.csv

mac2unix ${sampsheet}

declare -a _sampleSheetColumnNames=()
declare -A _sampleSheetColumnOffsets=()

IFS="," read -r -a _sampleSheetColumnNames <<< "$(head -1 "${sampsheet}")"
	for (( _offset = 0 ; _offset < ${#_sampleSheetColumnNames[@]:-0} ; _offset++ ))
	do
		_sampleSheetColumnOffsets["${_sampleSheetColumnNames[${_offset}]}"]="${_offset}"
	done
dualBarcode="unknown"
if [[ -n "${_sampleSheetColumnOffsets["barcode"]+isset}" ]]; then
	barcodeFieldIndex=$((${_sampleSheetColumnOffsets["barcode"]} + 1))
	readarray -t barcodes< <(tail -n +2 "${sampsheet}" | cut -d "," -f "${barcodeFieldIndex}" | sort | uniq )
	for barcode in "${barcodes[@]}"
	do
		if [[ "${barcode}" == *"-"* ]]
		then
			echo "TRUE"
			dualBarcode="TRUE"
		else
			echo "false"
			dualBarcode="FALSE"
		fi
	done
fi

## Will return or nothing or in case there is a dualbarcode it will create a file
perl ${EBROOTNGS_DEMULTIPLEXING}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEXING}/parameters.csv > \
${WORKDIR}/generatedscripts/${RAWDATANAME}/out.csv

perl ${EBROOTNGS_DEMULTIPLEXING}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEXING}/${ENVIRONMENT_PARAMETERS} > \
${WORKDIR}/generatedscripts/${RAWDATANAME}/environment_parameters.csv

perl ${EBROOTNGS_DEMULTIPLEXING}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEXING}/parameters_${GROUP}.csv > \
${WORKDIR}/generatedscripts/${RAWDATANAME}/parameters_group.csv

bash $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/${RAWDATANAME}/out.csv \
-p ${WORKDIR}/generatedscripts/${RAWDATANAME}/parameters_group.csv \
-p ${WORKDIR}/generatedscripts/${RAWDATANAME}/environment_parameters.csv \
-p ${WORKDIR}/generatedscripts/${RAWDATANAME}/${RAWDATANAME}.csv \
-w ${WORKFLOW} \
-rundir ${WORKDIR}/runs/${RAWDATANAME}/jobs \
-o "dualBarcode=${dualBarcode};\
demultiplexingversion=$(module list | grep -o -P 'NGS_Demultiplexing(.+)')" \
-b slurm \
-weave \
--generate

fi
