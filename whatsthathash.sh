#!/usr/bin/bash

packman=0

#variables

#For Downloaded Hashcat Intallstions
#
#
#Hashcat installation location.
#hashcatloc="/opt/hashcat-6.2.6"
#BIN name is configurable incase your using OCLHashCat or some other future naming convention
#hashcatbin="hashcat.bin"

#If using Hashcat from a package manager: otherwise comment all of these out and uncomment the lines above.

packman=1
hashcatmodloc="/usr/share/hashcat"
hashcatbin="hashcat"

#RunMe

        echo ""
        echo ""
        echo ""
        echo "Whats That Hash"
        echo "Created by Tim Jensen @eapolsniper"
        echo "Version 0.1"
        echo "-----------------------"


#Command Line Options
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
        echo "<HELP>"
        echo "Whats That Hash"
        echo "Created by Tim Jensen @eapolsniper"
        echo ""
        echo "This script tests a known hash/password combo  against every hash type, and tells you if Hashcat can crack the hash."
        echo "You can then automatically start a hashcat job to crack your hashes"
        echo "---------------------"
        echo ""
        echo "-t   --  Your test hash (single hash in a file)"
        echo "-p   --  Your known password in a file"
        echo ""
        echo ""
        echo "</HELP>"
        echo ""
        exit
        shift # past argument
        shift # past value
        ;;
    -t|--testhashfile)
        testhashfile="$2"
        shift # past argument
        shift # past value
        ;;
    -p|--knownpassfile)
        knownpassfile="$2"
        shift # past argument
        shift # past value
        ;;
    *)    # unknown option
            echo "unknown option included. Try Harder."
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Build Module ID list
if test -f "hashtypes.tim"
then
        rm hashtypes.tim
fi

if [[ $packman -eq 1 ]]
then
        modloc="$hashcatmodloc"
else
        modloc="$hashcatloc"
fi

for i in `find $modloc/modules -type f -name "*.so" -follow`
do 
        echo $i | cut -d"_" -f 2 | cut -d "." -f 1 >> hashtypes.tim
done

cat hashtypes.tim | sed "s/^0*\([1-9]\)/\1/;s/^0*$/0/" | sort -n > hashtypes.tim2

mods=`cat hashtypes.tim2 | wc -l`
echo "$mods hash ID's have been found and will be tested"


#Run test and find correct hash type

testhash=`cat $testhashfile`

knownpass=`cat $knownpassfile`

echo "hash is: $testhash"
echo "Pass is: $knownpass"

if [[ $packman -eq 1 ]]
then
        runcmd="$hashcatbin"
else
        runcmd="$hashcatloc\/$hashcatbin"
fi

echo ""
success=0
for hashtype in `cat hashtypes.tim2`
do 
result=`$runcmd -m $hashtype -a 0 $testhashfile $knownpassfile --potfile-disable 2>&1`

        wantedresult="Cracked"

#echo "blob result:"
#echo "$result"
#echo ""
#echo ""
#
        if [[ "$result" =~ .*"$wantedresult".* ]]
        then
                echo "Hash cracked with hashtype $hashtype!"
                success=$((success+1))
        fi
done

echo ""

if [[ $success -gt 0 ]]
then
        echo "A total of $success hash ID's worked!"
else
        echo "I don't think Hashcat can crack this..."

fi
