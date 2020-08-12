#/bin/bash

infile="$1"
	echo ""
	echo ""
	echo ""
	echo "Redis Dump"
	echo "Created by Tim Jensen @eapolsniper"
	echo "BSI CSIR - bsigroup.com"
	echo ""
	echo "-----------------------"

if [ -z "$infile" ]
then
	echo ""
	echo "ERROR! ERROR! ERROR!"
	echo ""
	echo ""
	echo "Script usage: ./redisdump.sh iplist.txt"
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

if ! which redis-cli >/dev/null
then
	echo ""
	echo "Error. Redis-cli not installed! Install with apt-get install redis-tools"
	echo ""
	echo ""
	exit 1
fi

projectprefix=`date +Results_%d%b%Y_%Hh%Mm%Ss`
mkdir $projectprefix

for i in `cat $infile`

do

redis-cli -h $i --scan > $projectprefix/$i.keys

	for a in `cat $projectprefix/$i.keys`

	do
	redis-cli -h $i info >> $projectprefix/$i.info
	redis-cli -h $i get $a >> $projectprefix/$i.getout
	redis-cli -h $i hgetall $a >> $projectprefix/$i.hgetout
	redis-cli -h $i lrange $a 1 100 >> $projectprefix/$i.lrange
	done
done

echo ""
echo "Script complete. Check the $projectprefix directory for output files!"
