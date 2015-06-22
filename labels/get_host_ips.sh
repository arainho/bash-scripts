#!/bin/bash

CHECK_VALUE=""
FILE_INPUT="hostnames.txt"
FILE_OUTPUT="machines_labels.csv"
MY_HOSTNAMES=($(cat $FILE_INPUT))

DOMAIN_ONE="example.biz"
DOMAIN_TWO="myexample.net"
MY_LIST_DOMAIN_ONE=(host1 host2 host3 host4 host5 host6 host7)

check_it_host(){
    for my_it_host in "${MY_LIST_DOMAIN_ONE[@]}"; do        
    
        if [ "$1" == "$my_it_host" ]; then
            CHECK_VALUE="true"
            break
        elif [ "$1" != "$my_it_host" ]; then
            CHECK_VALUE="false"
        fi

    done
}

rm "$FILE_OUTPUT"
touch "$FILE_OUTPUT"
echo -n "HOSTNAME|DNS|IPv4|" > "$FILE_OUTPUT"
echo "" >>  "$FILE_OUTPUT"

for h in "${MY_HOSTNAMES[@]}"; do 

		echo -n "$h"  >> "$FILE_OUTPUT";
		echo -n "|" >> "$FILE_OUTPUT";

                check_it_host "$h"

                echo "$h" " : " "$CHECK_VALUE"

                if [ "$CHECK_VALUE" == "true" ]; then
                        echo -n "$h"."$DOMAIN_ONE" >> "$FILE_OUTPUT"
                        echo -n "|" >> "$FILE_OUTPUT"
                        echo -n "$(dig -4 +short "$h"."$DOMAIN_ONE" | grep 1)" >> "$FILE_OUTPUT"
                elif [ "$CHECK_VALUE" == "false" ]; then
                        if [ "$h" == "fluffy" ]; then
                            h="$h"-ipv4
                        fi 
                        echo -n "$h"."$DOMAIN_TWO" >> "$FILE_OUTPUT"
		        echo -n "|" >> "$FILE_OUTPUT"
                        echo -n "$(dig -4 +short "$h"."$DOMAIN_TWO" | grep 1)" >> "$FILE_OUTPUT"
                fi

                echo -n "|" >> $FILE_OUTPUT;
		echo "" >> $FILE_OUTPUT;
done

