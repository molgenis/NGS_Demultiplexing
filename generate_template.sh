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

rm -f barcode2.isthere

## Will return or nothing or in case there is a dualbarcode it will create a file
sh ${EBROOTNGS_DEMULTIPLEXING}/combineBarcodes.sh ${sampsheet} ${EBROOTNGS_DEMULTIPLEXING}
if [ $? == 0 ]
then
	dualBarcode="FALSE"
	
	if [ -f barcode2.is.there ]
	then	
		dualBarcode="TRUE"
	fi
	#
	#######
	#
	perl ${EBROOTNGS_DEMULTIPLEXING}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEXING}/parameters.csv > \
	${WORKDIR}/generatedscripts/${RAWDATANAME}/out.csv

	perl ${EBROOTNGS_DEMULTIPLEXING}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEXING}/${ENVIRONMENT_PARAMETERS} > \
	${WORKDIR}/generatedscripts/${RAWDATANAME}/environment_parameters.csv

	perl ${EBROOTNGS_DEMULTIPLEXING}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEXING}/parameters_${GROUP}.csv > \
	${WORKDIR}/generatedscripts/${RAWDATANAME}/parameters_group.csv

	sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
	-p ${WORKDIR}/generatedscripts/${RAWDATANAME}/out.csv \
	-p ${WORKDIR}/generatedscripts/${RAWDATANAME}/parameters_group.csv \
	-p ${WORKDIR}/generatedscripts/${RAWDATANAME}/environment_parameters.csv \
	-p ${WORKDIR}/generatedscripts/${RAWDATANAME}/${RAWDATANAME}.csv \
	-w ${WORKFLOW} \
	-rundir ${WORKDIR}/runs/${RAWDATANAME}/jobs \
	-o "dualBarcode=${dualBarcode}" \
	-b slurm \
	-weave \
	--generate

fi
