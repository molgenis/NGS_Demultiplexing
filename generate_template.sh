#!/bin/bash
set -eu

##external call with 3 arguments (rawdataName, group and workDir)

module list
host=$(hostname -s)

ENVIRONMENT_PARAMETERS="parameters_${host}.csv"
RAWDATANAME="${1}"
WORKDIR="${2}"
GROUP="${3}"
WORKFLOW="${EBROOTNGS_DEMULTIPLEXING}/workflow.csv"
echo "$WORKDIR AND $RAWDATANAME"
echo "GROUPIE: $GROUP"

mkdir -p "${WORKDIR}/generatedscripts/NGS_Demultiplexing/${RAWDATANAME}/"
mkdir -p "${WORKDIR}/rawdata/ngs/${RAWDATANAME}/"
mkdir -p "${WORKDIR}/logs/${RAWDATANAME}/"

rm -rf "${WORKDIR}/generatedscripts/NGS_Demultiplexing/${RAWDATANAME}/out.csv"

#
###### Dual barcode checker
#
sampsheet="${WORKDIR}/generatedscripts/NGS_Demultiplexing/${RAWDATANAME}/${RAWDATANAME}.csv"
SAMPLESHEET_SEP=","
cp "${sampsheet}"{,.converted} 
sed -i 's/\r/\n/g' "${sampsheet}.converted" 
sed -i "/^[\s${SAMPLESHEET_SEP}]*$/d" "${sampsheet}.converted"
mv "${sampsheet}.converted" "${sampsheet}"

declare -a _sampleSheetColumnNames=()
declare -A _sampleSheetColumnOffsets=()

IFS="," read -r -a _sampleSheetColumnNames <<< "$(head -1 "${sampsheet}")"
	for (( _offset = 0 ; _offset < ${#_sampleSheetColumnNames[@]:-0} ; _offset++ ))
	do
		_sampleSheetColumnOffsets["${_sampleSheetColumnNames[${_offset}]}"]="${_offset}"
	done
dualBarcode="unknown"
if [[ -n "${_sampleSheetColumnOffsets["barcode"]+isset}" ]]; then
	barcodeFieldIndex=$((_sampleSheetColumnOffsets["barcode"] + 1))
	readarray -t barcodes< <(tail -n +2 "${sampsheet}" | cut -d "," -f "${barcodeFieldIndex}" | sort | uniq )
	for barcode in "${barcodes[@]}"
	do
		if [[ "${barcode}" == *"-"* ]]
		then
			dualBarcode="TRUE"
		else
			dualBarcode="FALSE"
		fi
	done
fi

## Will return or nothing or in case there is a dualbarcode it will create a file
perl "${EBROOTNGS_DEMULTIPLEXING}/scripts/convertParametersGitToMolgenis.pl" "${EBROOTNGS_DEMULTIPLEXING}/parameters.csv" > \
"${WORKDIR}/generatedscripts/NGS_Demultiplexing/${RAWDATANAME}/out.csv"

perl "${EBROOTNGS_DEMULTIPLEXING}/scripts/convertParametersGitToMolgenis.pl" "${EBROOTNGS_DEMULTIPLEXING}/${ENVIRONMENT_PARAMETERS}" > \
"${WORKDIR}/generatedscripts/NGS_Demultiplexing/${RAWDATANAME}/environment_parameters.csv"

perl "${EBROOTNGS_DEMULTIPLEXING}/scripts/convertParametersGitToMolgenis.pl" "${EBROOTNGS_DEMULTIPLEXING}/parameters_${GROUP}.csv" > \
"${WORKDIR}/generatedscripts/NGS_Demultiplexing/${RAWDATANAME}/parameters_group.csv"

bash "${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh" \
-p "${WORKDIR}/generatedscripts/NGS_Demultiplexing/${RAWDATANAME}/out.csv" \
-p "${WORKDIR}/generatedscripts/NGS_Demultiplexing/${RAWDATANAME}/parameters_group.csv" \
-p "${WORKDIR}/generatedscripts/NGS_Demultiplexing/${RAWDATANAME}/environment_parameters.csv" \
-p "${WORKDIR}/generatedscripts/NGS_Demultiplexing/${RAWDATANAME}/${RAWDATANAME}.csv" \
-w "${WORKFLOW}" \
-rundir "${WORKDIR}/runs/NGS_Demultiplexing/${RAWDATANAME}/jobs" \
--header "${EBROOTNGS_DEMULTIPLEXING}/templates/slurm/header_tnt.ftl" \
--footer "${EBROOTNGS_DEMULTIPLEXING}/templates/slurm/footer_tnt.ftl" \
-o "dualBarcode=${dualBarcode};\
demultiplexingversion=$(module list | grep -o -P 'NGS_Demultiplexing(.+)')" \
-b slurm \
-weave \
--generate
