#!/bin/bash

MEMBERS_FILE=""
DST_FOLDER="/opt/OLD-Users/Missing-Backup"
MY_DATE=$(date +%Y-%m-%d)
RSYNC_OPTIONS="-raxvH --links --numeric-ids"

## ASK remote user, server, mount point

        echo "enter members file"
        read -r MEMBERS_FILE
        USERS_ARRAY=($(cat ${MEMBERS_FILE}))

	echo "enter remote user"
	read -r REMOTE_USER
	
	echo "enter remote server"
	read -r REMOTE_SERVER
	
	echo "enter remote mount point"
	read -r REMOTE_MOUNT_POINT

## MOVE users home to /opt/OLD-Users/...

	mkdir -p $DST_FOLDER/$MY_DATE
	for myuser in ${USERS_ARRAY[@]}
	do
		echo "moving $myuser to $DST_FOLDER"
		mv /home/$myuser	$DST_FOLDER/$MY_DATE/
		echo "..."
	done

## COMPRESS users homes

	cd $DST_FOLDER/$MY_DATE/
	mkdir $DST_FOLDER/$MY_DATE/tmp
	MY_USERS=($(ls | grep -v tmp))
	for myuser in ${MY_USERS[@]}; do 
		tar -cvf ${myuser}-sample-home.tar ${myuser}/
		if [ -d $DST_FOLDER/$MY_DATE/tmp ]
		then
			mv ${myuser} $PWD/tmp/
		fi
	done

## SYNC stuff to remote server

	echo "let's sync stuff to remote server ..."
	echo "rsync $RSYNC_OPTIONS ${DST_FOLDER}/${MY_DATE}/ ${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_MOUNT_POINT}/"

## CHECK stuff

	echo "just checking"
	ssh ${REMOTE_USER}@${REMOTE_SERVER} ls ${REMOTE_MOUNT_POINT}

