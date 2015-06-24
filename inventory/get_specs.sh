#!/bin/bash
# collect machine specs (hostname,cpu,ram,disk) and build a csv file

FILE_INPUT="hostnames.txt"
FILE_OUTPUT="machines_specs.csv"
MY_HOSTNAMES=($(cat $FILE_INPUT))
NEXENTA_OS="my-nexenta"
SERVER_WITH_LONG_LV_NAME="my-server-lvlong"

echo -n "HOSTNAME|CPU|RAM|DISK" > $FILE_OUTPUT
echo "" >>  $FILE_OUTPUT

for h in ${MY_HOSTNAMES[@]}; do 

	ping -c 1 -w 5 $h &> /dev/null
	if [ $? -eq 0 ]; then
		
		if [ $h == "$NEXENTA_OS" ]; then
			echo -n $h;
			echo -n "|";
			
			ssh $h prtdiag | grep -i GHz | xargs echo -n ""
			echo -n "|"; 
			
			ssh $h prtconf | head -3 | awk '( $1 == "Memory" ) { printf "%.f", $3/1024}'
			echo -n "G|";
	
			ssh $h "df -h | grep /$" | awk '{print $2}'
		else
			echo -n $h;
			echo -n "|";

			ssh $h "cat /proc/cpuinfo | grep 'model name' | uniq | cut -d ':' -f2 | awk '{print $1 " " $2 " " $3 " " $4 " " $5 " " $6}'" | xargs echo -n
			echo -n "|"; 
				
			ssh $h "cat /proc/meminfo" | awk '( $1 == "MemTotal:" ) { printf "%.2f", $2/1024/1024}'
			echo -n "G|";
			
			if [ $h != "$SERVER_WITH_LONG_LV_NAME" ]; then	
				ssh $h "df -hl | grep ^/dev | grep /$" | awk '{print $2}'
			else
				ssh $h "df -hl | grep /$" | awk '{print $1}'
			fi
		fi
	else
		echo -n $h;
		echo -n "|";
		echo -n " ";	
		echo -n "|";
		echo -n " ";
		echo -n "|";
		echo -n " ";		
		echo "";
	fi

done >> $FILE_OUTPUT

