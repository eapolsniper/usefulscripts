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


for i in `cat $infile`

do

redis-cli -h $i --scan > $i.keys

	for a in `cat $i.keys`

	do

	redis-cli -h $i get $a >> $i.getout
	redis-cli -h $i hgetall $a >> $i.hgetout
	done
done
