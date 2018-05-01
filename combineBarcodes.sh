set -e 
set -u

csvFile=$1
pathToScript=$2
echo "run makeCombinedBarcode.py and outputting it to barcode_combined.txt"
python ${pathToScript}/makeCombinedBarcode.py $csvFile $(pwd) > barcode_combined.txt

var=$(tail -1 barcode_combined.txt)

if [ "${var}" == "wrong" ]
then
	echo "barcode should be splitted into 2 columns first OR barcode_combined already exists in header (file = corrupt)"
	exit 1
else
	paste -d, ${csvFile} barcode_combined.txt > ${csvFile}.tmp
	cp ${csvFile} ${csvFile}.original
	mv ${csvFile}.tmp ${csvFile}
	echo "updated original ${csvFile} with an extra column barcode_combined"
fi
