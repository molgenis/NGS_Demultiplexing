import sys
import csv

tel=0
reader = csv.DictReader(open(sys.argv[1], "rb"), delimiter=",")

barcode2file=sys.argv[2]+'/barcode2.is.there'
for row in reader:
        for (kolom,value) in row.items():
		v=value.strip()
                if tel == 0:
                        sys.stdout.write("barcode_combined\n")
                        tel=tel+1
                if "barcode2" in row:
                        if kolom == "barcode":
                                if "-" not in v:
                                        if v.lower() != "none" and v != "":
                                                sys.stdout.write(v + "-")
                                else:
                                     	print "wrong"
                                        sys.exit()
                        if kolom == "barcode2":
                                if v.lower() != "none" and v != "":
                                        sys.stdout.write(v + "\n")
					open(barcode2file, 'a').close()
                else:
                     	if kolom == "barcode":
                                if "-" not in v:
                                        if v.lower() != "none" and v != "":
                                                sys.stdout.write(v + "\n")
                                else:
                                     	print "wrong"
                                        sys.exit()
