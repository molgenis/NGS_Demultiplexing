import sys
import csv
from collections import defaultdict

tel=0
reader = csv.DictReader(open(sys.argv[1], "rb"), delimiter=",")

columns = defaultdict(list)
barcode2file=sys.argv[2]+'/barcode2.is.there'

my_list = list()
my_list2 = list()
for row in reader:
        for (kolom,value) in row.items():
                v=value.strip()
                columns[kolom].append(v)
		if "barcode_combined" in kolom:
			print "barcode_combined already exists.. file is corrupt"
			print "wrong"
			sys.exit()

barcode2IsThere="false"

for i in columns['barcode2']:
        if i == "none" or i == "":
                barcode2IsThere="false"
                break
        else:
             	barcode2IsThere="true"
                my_list2.append(i)

for i in columns['barcode']:
        if "-" not in i:
                my_list.append(i)
        else:
             	print "barcode already contains a dash, quitting"
		print "wrong"

                sys.exit()

listlength=len(my_list)
sys.stdout.write("barcode_combined\n")

if barcode2IsThere == "false":
        for i in range(0,listlength):
               sys.stdout.write(my_list[i]+ "\n")
else:
     	for i in range(0,listlength):
                sys.stdout.write(my_list[i] + "-" + my_list2[i] + "\n")
                open(barcode2file, 'a').close()

