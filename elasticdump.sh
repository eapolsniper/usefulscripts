#/bin/bash

#--------------    Basic settings  --------------

#How many lines to dump for each index. Large amounts will fill disk space and could cause performance issues. Default is 10.
maxlines=10

#Set protocol. Change to https if needed.
esprot="http"

#Port. Default is 9200
esport=9200

#------------------------------------------------


infile="$1"
	echo ""
	echo ""
	echo ""
	echo "Elasticsearch Dump"
	echo "Created by Tim Jensen @eapolsniper"
	echo "BSI CSIR - bsigroup.com"
	echo ""
	echo "To change protocol, port, or max lines of evidence (Default 10 lines) edit the script header."
	echo ""
	echo "-----------------------"

if [ -z "$infile" ]
then
	echo ""
	echo "ERROR! ERROR! ERROR!"
	echo ""
	echo ""
	echo "Script usage: ./elasticdump.sh iplist.txt"
	echo "No IP addresses provided. Put IP addresses in a file 1 IP per line and pass file name to this script."
	echo ""
	echo ""
	exit 1
fi

if [ ! -f "$infile" ]
then
	echo ""
	echo "ERROR! ERROR! ERROR!"
	echo ""
	echo ""
	echo "$infile can not be found. Make sure the path is correct."
	echo ""
	echo ""
	exit 1
fi

if ! which curl >/dev/null
then
	echo ""
	echo "Error. curl not installed! Install with apt-get install curl"
	echo ""
	echo ""
	exit 1
fi

projectprefix=`date +Results_%d%b%Y_%Hh%Mm%Ss`
mkdir $projectprefix


for i in `cat $infile`

do
	echo "Dumping $i"
	projdir="$projectprefix/$i"
	mkdir $projdir
	curl -s $esprot://$i:$esport/_cat/indices?v > $projdir/indices.dump

	for k in `cat $projdir/indices.dump | sed -e 's/  */ /g' | sed -n '1!p' | grep -v " close " | cut -d" " -f 3`
	do
		curl -s $esprot://$i:$esport/$k/_search?size=$maxlines >> $projdir/$k.index
		
	done
done



echo "Protocol: $esprot" >> $projectprefix/settings.log
echo "Port: $esport" >> $projectprefix/settings.log
echo "Max Lines: $maxlines" >> $projectprefix/settings.log

echo ""
echo "Script complete. Check the $projectprefix directory for output files!"
echo ""
echo "NOTE: Remember indices may start with a . and as such ls -alh should be used to see the .dump files for these indices!"
