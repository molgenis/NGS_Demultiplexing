set -e 
set -u

module load NGS_Demultiplexing

DATADIR="$HOME/apps/data/"

mkdir -p ${DATADIR}
printf "Copying Prepkits"
###Prepkits
printf "Get inSilico data \n ... creating dir ${DATADIR}/inSilico.."
cp $EBROOTNGS_DEDMULTIPLEXING/resources/Prepkits/ /apps/data/
printf " finished .. \n"
