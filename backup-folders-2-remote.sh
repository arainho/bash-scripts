#!/bin/bash
# script to copy local directories to remote host

REMOTE_HOST="remote-host.example.com"
REMOTE_USER="remote-username"
REMOTE_MOUNT_POINT="/your/remote/mount-point"
REMOTE_FOLDER="remote-folder"
ADMIN_MAIL="your-mail@example.com"

LOCAL_DIR[0]="your-local-dir-you-want-2-copy"
LOCAL_DIR[1]="your-second-local-dir-you-want-2-copy"
LOCAL_PATH="your-local-path"


LOCAL_DATE=$(date +'%F-%I%p')
TOTAL_DISK_SPACE=""

declare -A LOCAL_DISK_SPACE
for local_dir in "${LOCAL_DIR[@]}"; do
    "${LOCAL_DISK_SPACE[$local_dir]}"="$(du -sh $LOCAL_PATH/$local_dir)"
done

LOG_DIR="/tmp"
LOG_NAME="rsync-$LOCAL_DATE.log"
LOG_FILE="$LOG_DIR/$LOG_NAME"

MY_COMMAND="rsync"
MY_ARGS=" -raxvH --links --numeric-ids --stats --log-file $LOG_FILE"

# Create log file
> "$LOG_FILE"

# Install sendmail
dpkg -l sendmail > /dev/null 2>&1
if [[ $? -eq 1 ]]; then
    apt-get install -y sendmail
fi

for dir in "${LOCAL_DIR[@]}"; do
    exec "$MY_COMMAND" "$MY_ARGS" "$LOCAL_PATH"/"$dir"/ "$REMOTE_USER"@"$REMOTE_HOST":"$REMOTE_MOUNT_POINT"/"$REMOTE_FOLDER"/"$dir"/
done

# Find if scp succeed or not
[ $? -eq 0 ] && my_status="backup succeed :D" || my_status="backup failed :-/ ..."

for disk_space in "${LOCAL_DISK_SPACE[@]}"; do
    TOTAL_DISK_SPACE="$TOTAL_DISK_SPACE -- $disk_space "
done

# Write mail to admin
mail -a "$LOG_FILE" -s "Backup $my_status" $ADMIN_MAIL << END_OF_MAIL

The backup of "${LOCAL_DIR[@]}" job finished

End date: $(date)
Hostname: $(hostname)
Status: $my_status

Disk space: $TOTAL_DISK_SPACE

END_OF_MAIL
