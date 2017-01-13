import sys
import csv

tel=0
reader = csv.DictReader(open(sys.argv[1], "rb"), delimiter=",")
barcode2Bool="false"
barcode2Value=""
barcode2file=sys.argv[2]+'/barcode2.is.there'
for row in reader:
        for (kolom,value) in row.items():
                v=value.strip()
                if tel == 0:
                        sys.stdout.write("barcode_combined\n")
                        tel=tel+1
                if "barcode2" in row:
                        if kolom == "barcode2":
                                if v.lower() != "none" and v != "":
                                        barcode2Bool="true"
                                        barcode2Value=v
                                        open(barcode2file, 'a').close()

                        if kolom == "barcode":
                                if "-" not in v:
                                        if v.lower() != "none" and v != "":
                                                if barcode2Bool == "true":
                                                        sys.stdout.write(v + "-" + barcode2Value + "\n")
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

