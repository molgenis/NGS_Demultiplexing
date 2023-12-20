#MOLGENIS walltime=12:00:00 nodes=1 ppn=1 mem=5gb
#string ngsDir
#string intermediateDir
#string ngsDir
#list externalSampleID
#string seqType
#list barcode
#list barcodeType
#string lane
#string filePrefix
#string	logsDir

OLDDIR=$(pwd)

max_index=${#externalSampleID[@]}-1

for ((sampleNumber = 0; sampleNumber <= max_index; sampleNumber++))
do
	if [ "${seqType}" == "SR" ]
	then
		if [[ "${barcode[sampleNumber]}" == "None" || "${barcodeType[sampleNumber]}" == "" ]]
		then
			# Process lane FastQ files for lane without barcodes or with GAF barcodes.
			cd "${intermediateDir}" || exit

			md5sum lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz >  "${ngsDir}/${filePrefix}_L${lane}.fq.gz.md5"

			cp lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz "${ngsDir}/${filePrefix}_L${lane}.fq.gz"

			cd  "${ngsDir}" || exit
			VAR1="${filePrefix}_L${lane}.fq.gz"
			perl -pi -e "s|lane${lane}_None_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5

			md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}.fq.gz"
		else
			if $(ls ${intermediateDir}/lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz 1> /dev/null 2>&1)
			then
				cd "${intermediateDir}" || exit
				md5sum lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz > ${ngsDir}/${filePrefix}_L${lane}_${barcode[sampleNumber]}.fq.gz.md5
				cp lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz ${ngsDir}/${filePrefix}_L${lane}_${barcode[sampleNumber]}.fq.gz

				cd "${ngsDir}" || exit
				VAR1="${filePrefix}_L${lane}_${barcode[sampleNumber]}.fq.gz"
				perl -pi -e "s|lane${lane}_${barcode[sampleNumber]}_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
				md5sum -c "${filePrefix}_L${lane}_${barcode[sampleNumber]}.fq.gz.md5"
			else
				echo "No reads detected with: lane${lane}_${barcode[sampleNumber]}"
			fi
		fi

	elif [ "${seqType}" == "PE" ]
	then
		if [[ "${barcode[sampleNumber]}" == "None" || "${barcode[sampleNumber]}" == "" ]]
		then
			cd "${intermediateDir}" || exit
			md5sum lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_1.fq.gz.md5
			md5sum lane${lane}_None_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_2.fq.gz.md5

			cp lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz ${ngsDir}/${filePrefix}_L${lane}_1.fq.gz
			cp lane${lane}_None_S[0-9]*_L00${lane}_R2_001.fastq.gz ${ngsDir}/${filePrefix}_L${lane}_2.fq.gz

			cd  "${ngsDir}" || exit

			VAR1="${filePrefix}_L${lane}_1.fq.gz"
			VAR2="${filePrefix}_L${lane}_2.fq.gz"

			perl -pi -e "s|lane${lane}_None_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
			perl -pi -e "s|lane${lane}_None_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR2|" $VAR2.md5

			md5sum -c "${filePrefix}_L${lane}_1.fq.gz.md5"
			md5sum -c "${filePrefix}_L${lane}_2.fq.gz.md5"

		###CORRECT BARCODES
		else
			if $(ls ${intermediateDir}/lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R*_001.fastq.gz 1> /dev/null 2>&1)
			then
				cd "${intermediateDir}" || exit
				##R1
				md5sum lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_${barcode[sampleNumber]}_1.fq.gz.md5
				cp lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz  ${ngsDir}/${filePrefix}_L${lane}_${barcode[sampleNumber]}_1.fq.gz

				cd "${ngsDir}" || exit 
				## R1
				VAR1="${filePrefix}_L${lane}_${barcode[sampleNumber]}_1.fq.gz"
				perl -pi -e "s|lane${lane}_${barcode[sampleNumber]}_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
				md5sum -c "${filePrefix}_L${lane}_${barcode[sampleNumber]}_1.fq.gz.md5"


				if [ "${barcodeType}" == "UMIR3" ]
				then
					### SWAPPING R2 with R3 (R2 is umi)
					cd "${intermediateDir}" || exit 
					## R3 --> R2
					md5sum lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R3_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_${barcode[sampleNumber]}_2.fq.gz.md5
					cp lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R3_001.fastq.gz  ${ngsDir}/${filePrefix}_L${lane}_${barcode[sampleNumber]}_2.fq.gz

					## R2(umi) --> R3(umi)
					cp lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${ngsDir}/${filePrefix}_L${lane}_${barcode[sampleNumber]}_3.fq.gz
					md5sum lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_${barcode[sampleNumber]}_3.fq.gz.md5

					cd  "${ngsDir}" || exit
					##R3(umi)
					VAR3="${filePrefix}_L${lane}_${barcode[sampleNumber]}_3.fq.gz"
					perl -pi -e "s|lane${lane}_${barcode[sampleNumber]}_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR3|" $VAR3.md5
					md5sum -c "${filePrefix}_L${lane}_${barcode[sampleNumber]}_3.fq.gz.md5"

					##L2
					VAR2="${filePrefix}_L${lane}_${barcode[sampleNumber]}_2.fq.gz"
					perl -pi -e "s|lane${lane}_${barcode[sampleNumber]}_S[0-9]+_L00${lane}_R3_001.fastq.gz|$VAR2|" $VAR2.md5
					md5sum -c "${filePrefix}_L${lane}_${barcode[sampleNumber]}_2.fq.gz.md5"
				else
					cd "${intermediateDir}" || exit
					##L2
					md5sum lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_${barcode[sampleNumber]}_2.fq.gz.md5
					cp lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${ngsDir}/${filePrefix}_L${lane}_${barcode[sampleNumber]}_2.fq.gz
					cd  "${ngsDir}" || exit
					##L2
					VAR2="${filePrefix}_L${lane}_${barcode[sampleNumber]}_2.fq.gz"
					perl -pi -e "s|lane${lane}_${barcode[sampleNumber]}_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR2|" $VAR2.md5
					md5sum -c "${filePrefix}_L${lane}_${barcode[sampleNumber]}_2.fq.gz.md5"
				fi

			else
				echo "No reads detected with: lane${lane}_${barcode[sampleNumber]}"
			fi
		fi
	fi
done

#discarded reads that could not be assigned to a sample.

if [ "${barcode[0]}" != "None" ]
then
	if [ "${seqType}" == "SR" ]
	then
		cd "${intermediateDir}" || exit 
		md5sum Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_DISCARDED.fq.gz.md5

		cp Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz ${ngsDir}/${filePrefix}_L${lane}_DISCARDED.fq.gz

		cd "${ngsDir}" || exit

		VAR1="${filePrefix}_L${lane}_DISCARDED.fq.gz"

		perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5

		md5sum -c "${filePrefix}_L${lane}_DISCARDED.fq.gz.md5"

	else
		cd "${intermediateDir}" || exit
		md5sum Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_DISCARDED_1.fq.gz.md5
		cp Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz  ${ngsDir}/${filePrefix}_L${lane}_DISCARDED_1.fq.gz

		cd  "${ngsDir}" || exit
		VAR1="${filePrefix}_L${lane}_DISCARDED_1.fq.gz"
		perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
		md5sum -c "${filePrefix}_L${lane}_DISCARDED_1.fq.gz.md5"


		if [ "${barcodeType}" == "UMIR3" ]
		then
			##DISCARDED R2/R3
			cd "${intermediateDir}" || exit
			## R2(umi) --> R3(umi)
			md5sum Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_DISCARDED_3.fq.gz.md5
			cp Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${ngsDir}/${filePrefix}_L${lane}_DISCARDED_3.fq.gz

			## R3 --> R2
			md5sum Undetermined_S[0-9]*_L00${lane}_R3_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_DISCARDED_2.fq.gz.md5
			cp Undetermined_S[0-9]*_L00${lane}_R3_001.fastq.gz  ${ngsDir}/${filePrefix}_L${lane}_DISCARDED_2.fq.gz

			##R3(umi)
			cd  "${ngsDir}" || exit
			VAR3="${filePrefix}_L${lane}_DISCARDED_3.fq.gz"
			perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR3|" $VAR3.md5
			md5sum -c "${filePrefix}_L${lane}_DISCARDED_3.fq.gz.md5"
			#R2
			VAR2="${filePrefix}_L${lane}_DISCARDED_2.fq.gz"
			perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R3_001.fastq.gz|$VAR2|" $VAR2.md5
			md5sum -c "${filePrefix}_L${lane}_DISCARDED_2.fq.gz.md5"

		else
			cd "${intermediateDir}" || exit
			md5sum Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${ngsDir}/${filePrefix}_L${lane}_DISCARDED_2.fq.gz.md5
			cp Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${ngsDir}/${filePrefix}_L${lane}_DISCARDED_2.fq.gz

			cd  "${ngsDir}" || exit
			VAR2="${filePrefix}_L${lane}_DISCARDED_2.fq.gz"
			perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR2|" $VAR2.md5
			md5sum -c "${filePrefix}_L${lane}_DISCARDED_2.fq.gz.md5"

		fi

	fi

else
	echo "There can't be discarded reads because the Barcode is set to None"
fi

cd "${OLDDIR}"
