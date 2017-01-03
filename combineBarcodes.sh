set -e 
set -u

csvFile=$1
pathToScript=$2
echo "run makeCombinedBarcode.py and outputting it to barcode_combined.txt"
python ${pathToScript}/makeCombinedBarcode.py $csvFile > barcode_combined.txt

var=$(tail -1 barcode_combined.txt)

if [ "${var}" == "wrong" ]
then
	echo "barcode should be splitted into 2 columns first"
	exit
elif [ "${var}" == "skipped" ]
then
	echo "No barcode2 found, skipped"
else
	echo "barcode2 found, pasting original with updated combined barcode column together"
	paste -d, $csvFile barcode_combined.txt > $csvFile.tmp
	touch barcode2.isthere
	mv $csvFile.tmp $csvFile
	echo "updated original $csvFile with an extra column barcode_combined"
fi
