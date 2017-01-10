import sys
import csv

tel=0
reader = csv.DictReader(open(sys.argv[1], "rb"), delimiter=",")

barcode2file=sys.argv[2]+'/barcode2.is.there'
for row in reader:
        for (k,v) in row.items():
                if tel == 0:
                        sys.stdout.write("barcode_combined\n")
                        tel=tel+1
                if "barcode2" in row:
			open(barcode2file, 'a').close()
                        if k == "barcode":
                                if "-" not in v:
                                        if v != "None" or v != "none" or v == "":
                                                sys.stdout.write(v + "-")
                                else:
                                     	print "wrong"
                                        sys.exit()
                        if k == "barcode2":
                                if v != "None" or v != "none" or v == "":
                                        sys.stdout.write(v + "\n")
                else:
                     	if k == "barcode":
                                if "-" not in v:
                                        if v != "None" or v != "none" or v == "":
                                                sys.stdout.write(v + "\n")
                                else:
                                     	print "wrong"
                                        sys.exit()

