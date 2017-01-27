import sys
import csv

tel=0
reader = csv.DictReader(open(sys.argv[1], "rb"), delimiter=",")
barcode2Bool="unset"
barcodeBool="unset"

barcode2Value=""
barcodeValue=""
barcode2file=sys.argv[2]+'/barcode2.is.there'
for row in reader:
        for (kolom,value) in row.items():
                v=value.strip()
                if tel == 0:
                        sys.stdout.write("barcode_combined\n")
                        tel=tel+1
                else:
                     	if "barcode2" in row:
                                if kolom == "barcode2":
                                        if v.lower() != "none" and v != "":
                                                if barcodeBool == "true":
                                                        sys.stdout.write(barcodeValue + "-" + v + "\n")
                                                        open(barcode2file, 'a').close()

                                                else:
                                                     	barcode2Bool="true"
                                                        barcode2Value=v
                                                        open(barcode2file, 'a').close()

                                if kolom == "barcode":
                                        if "-" not in v:
                                                if v.lower() != "none" and v != "":
                                                        if barcode2Bool == "true":
                                                                sys.stdout.write(v + "-" + barcode2Value + "\n")
                                                        elif barcode2Bool == "unset":
                                                                barcodeValue=v
                                                                barcodeBool="true"
                                                        else:
                                                             	sys.stdout.write(v + "\n")
                                        else:
                                             	print "wrong"
                                                sys.exit()

                        else:
                             	if kolom == "barcode":
                                        if "-" not in v:
                                                if v.lower() != "none" and v != "":
                                                        sys.stdout.write(v + "\n")
                                        else:
                                             	print "wrong"
                                                sys.exit()

