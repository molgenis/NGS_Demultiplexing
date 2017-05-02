#MOLGENIS walltime=12:00:00 nodes=1 ppn=1 mem=5gb
#string runResultsDir
#string intermediateDir
#list internalSampleID
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

n_elements=${internalSampleID[@]}
max_index=${#internalSampleID[@]}-1

function savecopy {(
        set -e
	set -o pipefail
	if [ ! -f "$1" ] ;then
                >&2 echo "ERROR file '$1' does not exist or isn't a file!"
                exit 1
        fi
	if [ -f "$2" ]; then
                >&2 echo "WARN file '$2' already  exists!"
        fi
	if [ ! -d "$(dirname -- "$2")" ]; then
                >&2 echo "ERROR output dir '"$(dirname  -- "$2")"' does not exist or isn't a dir!"
                exit 1
        fi

	in=$(readlink -f -- "$1")
	out=$(readlink -f -- "$2")
	>&2 echo "INFO copy '$in' to '$out' with md5sums and so on."

        (
                cd -- "$(dirname -- "$in")"
                md5sum  -- "$(basename "$in")" > "${out}".md5
                cp "$in" "$out"
        )
	(
                cd -- "$(dirname -- "$out")"
                perl -pi -e "s|$(basename "$in")|$(basename "$out")|" "$out".md5
                md5sum -c -- "$out".md5
        )

)}


for ((sampleNumber = 0; sampleNumber <= max_index; sampleNumber++))
do
	if [ "${seqType}" == "SR" ]
	then
  		if [[ ${barcode_combined[sampleNumber]} == "None" || ${barcodeType[sampleNumber]} == "GAF" ]]
		then
                        # Process lane FastQ files for lane without barcodes or with GAF barcodes.
                        gafFqGzBase=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}

			savecopy lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${gafFqGzBase}.fq.gz

		else
			gafFqGzBase=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}
			
			savecopy lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${gafFqGzBase}.fq.gz
			
			if  [ ${barcodeType[sampleNumber]} == "NG" ]; then

	                        savecopy lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz \
	                         ${runResultsDir}/${gafFqGzBase}_UMI.fq.gz

                                savecopy lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz \
                                 ${runResultsDir}/${gafFqGzBase}_INDEX.fq.gz

			fi
			
	        fi

	elif [ "${seqType}" == "PE" ]
	then
		if [[ ${barcode_combined[sampleNumber]} == "None" ]]
    		then
	
			savecopy lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_1.fq.gz
			savecopy lane${lane}_None_S[0-9]*_L00${lane}_R2_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_2.fq.gz
	
	
		###CORRECT BARCODES
		elif [[ ${barcodeType[sampleNumber]} == "RPI" || ${barcodeType[sampleNumber]} == "BIO" || ${barcodeType[sampleNumber]} == "MON" || ${barcodeType[sampleNumber]} == "AGI" || ${barcodeType[sampleNumber]} == "LEX" || ${barcodeType[sampleNumber]} == "NEX" || ${barcodeType[sampleNumber]} == "AG8" || ${barcodeType[sampleNumber]} == "sRP" ]]
		then
			cd ${intermediateDir}

			savecopy lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz  \
				${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_1.fq.gz
                        savecopy lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz  \
				${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}_2.fq.gz
    		elif [ ${barcodeType[sampleNumber]} == "NG" ]; then
                                gafFqGzBase=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode_combined[sampleNumber]}

				cd ${intermediateDir}

                                savecopy lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz \
                                 ${runResultsDir}/${gafFqGzBase}_1.fq.gz
				savecopy lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R3_001.fastq.gz \
                                 ${runResultsDir}/${gafFqGzBase}_2.fq.gz
				savecopy lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz \
                                 ${runResultsDir}/${gafFqGzBase}_UMI.fq.gz
				savecopy lane${lane}_${barcode_combined[sampleNumber]}_S[0-9]*_L00${lane}_I1_001.fastq.gz \
                                 ${runResultsDir}/${gafFqGzBase}_INDEX.fq.gz

		fi
	fi
done

#discarded reads that could not be assigned to a sample.

if [ "${barcode_combined[0]}" != "None" ]
then
	if [ "${seqType}" == "SR" ]
	then
		cd ${intermediateDir}

                savecopy Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED.fq.gz
		if [ ${barcodeType[sampleNumber]} == "NG" ]; then
			#SingleRead NuGene
			savecopy Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_UMI.fq.gz
			savecopy Undetermined_S[0-9]*_L00${lane}_I1_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_INDEX.fq.gz
		fi
	elif [ ${barcodeType[sampleNumber]} == "NG" ]; then
		#PairedRead NuGene
		savecopy Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_1.fq.gz
                savecopy Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_UMI.fq.gz
		savecopy Undetermined_S[0-9]*_L00${lane}_R3_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz
		savecopy Undetermined_S[0-9]*_L00${lane}_I1_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_INDEX.fq.gz
	
	else
        #DISCARDED READS
		cd ${intermediateDir}

	  	savecopy Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_1.fq.gz
                savecopy Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz

	fi
else
		echo "There can't be discarded reads because the Barcode is set to None"
fi

cd $OLDDIR

