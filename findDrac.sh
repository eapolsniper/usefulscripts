#!/usr/bin/bash

uname="root"
passw="calvin"
timeout=1
unset fileloc

#Command Line Options
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
	echo "<HELP>"
    echo "iDRAC Login Finder"
	echo "Created by Tim Jensen @eapolsniper"
	echo "BSI CSIR - bsigroup.com"
	echo ""
	echo "---------------------"
	echo ""
	echo "-t   --  Host timeout in seconds, default is 1 second"
	echo "-u   --  Username, default is 'root'"
	echo "-p   --  Password, default is 'calvin"
	echo "-f   --  File containing individual IPs to scan"
	echo ""
	echo "</HELP>"
	echo ""
	exit
	shift # past argument
    	shift # past value
    	;;
    -t|--timeout)
    	timeout=$2
    	echo "Timeout set to $timeout"
    	shift # past argument
    	shift # past value
    	;;
    -u|--user)
    	uname="$2"
    	echo "Username set to $uname"
		shift # past argument
    	shift # past value
    	;;
    -p|--password)
	passw=$2
	echo "Password set to $passw"
	shift
	shift
	;;
 	-f|--file)
	fileloc="$2"
	echo "IP file set to $fileloc"
	shift
	shift
	;;	
    *)    # unknown option
	    echo "unknown option included. Check the help file with -h"
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ ! -f $fileloc ]
then
echo ""
echo ""
echo -e "\e[1;41m  !!! IP file can not be found. !!!  \e[0m"
exit
fi


for i in `cat $fileloc`
do
echo "trying $i" >> run.log
curlcmd="timeout $timeout curl -L -i -s -k -X 'POST' -H 'Host: $i' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:78.0) Gecko/20100101 Firefox/78.0' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate' -H 'user: \"$uname\"' -H 'password: \"$passw\"' -H 'Origin: https://$i' -H 'Connection: close' -H 'Referer: https://$i/restgui/start.html' -H 'Content-Length: 0' 'https://$i/sysmgmt/2015/bmc/session'"

a=`eval $curlcmd | grep -i "set-cookie"`
#a=`eval $curlcmd`

if [[ $a == *"Set-Cookie: -http-session-="* ]];
then
echo -e "\e[1;92m Successful Login to iDrac on $i userpass: $uname/$passw Evidence: $a \e[0m" | tee idrac.loot
echo -e "$i\t443/TCP\t$uname\t$passw" >> success.txt
fi

done
