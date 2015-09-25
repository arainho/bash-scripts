#!/bin/bash

DST_FOLDER=""
MY_DATE=$(date +%Y-%m-%d)
ADMIN_MAIL="your-user@example.com"

echo "working on dir $PWD"
echo ""

echo "Enter users folder"
read -r DST_FOLDER

cd ${DST_FOLDER}/${MY_DATE}/
mkdir ${DST_FOLDER}/${MY_DATE}/tmp

MY_USERS=($(ls | grep -v tmp))
for myuser in ${MY_USERS[@]}; 
do 
	tar -cvf ${myuser}-sample-home.tar ${myuser}/
	if [ -d ${DST_FOLDER}/tmp ]
	then
		mv ${myuser} ${DST_FOLDER}/tmp/
	fi
done

echo "compress finish" | mail -s "users compression finish :-)" ${ADMIN_MAIL}

