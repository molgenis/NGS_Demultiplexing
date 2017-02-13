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


barcode2IsThere="false"

for i in columns['barcode2']:
	if i == "none" and v == "":
		barcode2IsThere="false"
		break
	else:
		barcode2IsThere="true"
		my_list2.append(i)

for i in columns['barcode']:
	my_list.append(i)

listlength=len(my_list)
sys.stdout.write("barcode_combined\n")

if barcode2IsThere == "false":
	for i in range(0,listlength):
               sys.stdout.write(my_list[i]+ "\n")
else:
	for i in range(0,listlength):
		sys.stdout.write(my_list[i] + "-" + my_list2[i] + "\n")
		open(barcode2file, 'a').close()
