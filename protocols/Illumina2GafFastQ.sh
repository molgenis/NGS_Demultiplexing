#MOLGENIS walltime=12:00:00 nodes=1 ppn=1 mem=5gb
#string runResultsDir
#string intermediateDir
#list externalSampleID
#string seqType
#list barcode_combined
#list barcodeType
#string lane
#string sequencingStartDate
#string sequencer
#string flowcell
#string run
#string filenamePrefix

OLDDIR=$(pwd)

n_elements=${externalSampleID[@]}
max_index=${#externalSampleID[@]}-1

for ((sampleNumber = 0; sampleNumber <= max_index; sampleNumber++))
do
	if [ "${seqType}" == "SR" ]
	then
		if [[ ${barcode_combined[sampleNumber]} == "None" || ${barcodeType[sampleNumber]} == "" ]]
		then
			# Process lane FastQ files for lane without barcodes or with GAF barcodes.
			cd "${intermediateDir}"

			md5sum lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz >  "${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}.fq.gz.md5"

			cp lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz "${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}.fq.gz"

			cd  "${runResultsDir}"
			VAR1="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}.fq.gz"
			perl -pi -e "s|lane${lane}_None_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5

			md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}.fq.gz"
		else
			if $(ls ${intermediateDir}/lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz 1> /dev/null 2>&1)
			then
				cd "${intermediateDir}"
				md5sum lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz > ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}.fq.gz.md5
				cp lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}.fq.gz

				cd "${runResultsDir}"
				VAR1="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}.fq.gz"
				perl -pi -e "s|lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
				md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}.fq.gz.md5"
			else
				echo "No reads detected with: lane${lane}_${barcode_combined[sampleNumber]}"
			fi
		fi

	elif [ "${seqType}" == "PE" ]
	then
		if [[ ${barcode_combined[sampleNumber]} == "None" || ${barcode_combined[sampleNumber]} == "" ]]
		then
			cd "${intermediateDir}"
			md5sum lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_1.fq.gz.md5
			md5sum lane${lane}_None_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_2.fq.gz.md5

			cp lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_1.fq.gz
			cp lane${lane}_None_S[0-9]*_L00${lane}_R2_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_2.fq.gz

			cd  "${runResultsDir}"

			VAR1="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_1.fq.gz"
			VAR2="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_2.fq.gz"

			perl -pi -e "s|lane${lane}_None_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
			perl -pi -e "s|lane${lane}_None_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR2|" $VAR2.md5

			md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_1.fq.gz.md5"
			md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_2.fq.gz.md5"

		###CORRECT BARCODES
		else
			if $(ls ${intermermediateDir}/lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R*_001.fastq.gz 1> /dev/null 2>&1)
			then
				cd "${intermediateDir}"
				##R1
				md5sum lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_1.fq.gz.md5
				cp lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_1.fq.gz

				cd  "${runResultsDir}"
				## R1
				VAR1="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_1.fq.gz"
				perl -pi -e "s|lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
				md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_1.fq.gz.md5"


				if [ "${barcodeType}" == "UMI" ]
				then
					### SWAPPING R2 with R3 (R2 is umi)
					cd "${intermediateDir}"
					## R3 --> R2
					md5sum lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R3_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_2.fq.gz.md5
					cp lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R3_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_2.fq.gz

					## R2(umi) --> R3(umi)
					cp lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_3.fq.gz
					md5sum lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_3.fq.gz.md5

					cd  "${runResultsDir}"
					##R3(umi)
					VAR3="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_3.fq.gz"
					perl -pi -e "s|lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]+_L00${lane}_R3_001.fastq.gz|$VAR3|" $VAR3.md5
					md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_3.fq.gz.md5"
				else
					cd "${intermediateDir}"
					##L2
					md5sum lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_2.fq.gz.md5
                                        cp lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_2.fq.gz
				fi
					cd  "${runResultsDir}"
					##L2
					VAR2="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_2.fq.gz"
					perl -pi -e "s|lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR2|" $VAR2.md5
					md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_2.fq.gz.md5"


			else
				echo "No reads detected with: lane${lane}_${barcode_combined[sampleNumber]}"
			fi
		fi
	fi
done

#discarded reads that could not be assigned to a sample.

if [ "${barcode_combined[0]}" != "None" ]
then
	if [ "${seqType}" == "SR" ]
	then
		cd "${intermediateDir}"
		md5sum Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED.fq.gz.md5

		cp Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED.fq.gz

		cd  "${runResultsDir}"

		VAR1="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED.fq.gz"

		perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5

		md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED.fq.gz.md5"

	else
		cd "${intermediateDir}"
		md5sum Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_1.fq.gz.md5
		cp Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_1.fq.gz

		cd  "${runResultsDir}"
		VAR1="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_1.fq.gz"
		perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
		md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_1.fq.gz.md5"


		if [ "${barcodeType}" == "UMI" ]
		then
                ##DISCARDED R2/R3 
			cd "${intermediateDir}"
			## R2(umi) --> R3(umi)
			md5sum Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_3.fq.gz.md5
			cp Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_3.fq.gz

			## R3 --> R2
			md5sum Undetermined_S[0-9]*_L00${lane}_R3_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz.md5
			cp Undetermined_S[0-9]*_L00${lane}_R3_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz

			##R3(umi)
			cd  "${runResultsDir}"
			VAR3="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_3.fq.gz"
			perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR3|" $VAR3.md5
			md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz.md5"

		else
			#R2
			cd "${intermediateDir}"
			md5sum Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz.md5
			cp Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz
		fi
		#R2
		cd  "${runResultsDir}"
		VAR2="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz"
		perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR2|" $VAR2.md5
		md5sum -c "${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz.md5"

	fi

else
	echo "There can't be discarded reads because the Barcode is set to None"
fi

cd "${OLDDIR}"
