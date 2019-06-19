# Latest release Genetics diagnostics department UMCG 

## Is in use since 01-10-2018 (November 1st 2018)

download here: https://github.com/molgenis/NGS_Demultiplexing/releases/tag/2.2.12

## Release notes 2.2.12:

if discarded percentage for a certain lane is > 75 % the demultiplexing pipeline will stop immediately and a mail will go to helpdesk and diagnostics mailinglist

if a barcode has 0.0% reads there will be a file created next to the corresponding fq.gz file in the results folder
e.g. _1.fq.gz.rejected (this file will later on be picked up by the NGS pipeline that will exclude the sample from the analysis, for further actions/info go to the NGS_DNA pipeline)
