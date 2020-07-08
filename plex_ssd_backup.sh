#!/bin/bash

# variables
start_h=`date +%T`
SECONDS=0

echo "Script start: $start_h"

now=$(date +"%d_%m_%Y-%H_%M")
plex_library_dir="/mnt/disks/nvme/plex_appdata/plex"
backup_dir="/mnt/user/mount_mergerfs/saturn/backups/plex_appdata"
num_backups_to_keep=3

# Stop the container
docker stop plex
echo "Stopping plex"

# wait 30 seconds
sleep 30

# Get the state of the docker
plex_running=`docker inspect -f '{{.State.Running}}' plex`
echo "Plex running: $plex_running"

# If the container is still running retry 5 times
fail_counter=0
while [ "$plex_running" = "true" ];
do
    fail_counter=$((fail_counter+1))
    docker stop plex
    echo "Stopping Plex attempt #$fail_counter"
    sleep 30
    plex_running=`docker inspect -f '{{.State.Running}}' plex`
    # Exit with an error code if the container won't stop
    # Restart plex and report a warning to the Unraid GUI
    if (($fail_counter == 5));
    then
        echo "Plex failed to stop. Restarting container and exiting"
        docker start plex
        /usr/local/emhttp/webGui/scripts/notify -i warning -s "Plex Backup failed. Failed to stop container for backup."
        exit 1
    fi
done

# Once the container is stopped, backup the Application Support directory and restart the container
# The tar command shows progress
if [ "$plex_running" = "false" ]
then
    
	echo "Backing up Plex"
    
	rsync -a /mnt/disks/nvme/plex_appdata/plex /mnt/user/appdata
	
	echo "Starting Plex"
    docker start plex
	
	# wait 5 seconds
    sleep 5
	
	# Get the state of the docker
    plex_running=`docker inspect -f '{{.State.Running}}' plex`
    echo "Plex running: $plex_running"
	
	if [ "$plex_running" = "false" ]
	then
		echo "Plex failed to restart"
		/usr/local/emhttp/webGui/scripts/notify -i warning -s "Plex failed to restart."
	fi
	
	echo "Compressing Plex"
	cd $backup_dir
    tar -cpf plex_backup_$now.tar /mnt/user/appdata/plex

fi

# Get the number of files in the backup directory
num_files=`ls $backup_dir/plex_backup_*.tar | wc -l`
echo "Number of files in directory: $num_files"
# Get the full path of the oldest file in the directory
oldest_file=`ls -t $backup_dir/plex_backup_*.tar | tail -1`
echo $oldest_file

# After the backup, if the number of files is larger than the number of backups we want to keep
# remove the oldest backup file
if (($num_files > $num_backups_to_keep));
then
    echo "Removing file: $oldest_file"
    rm $oldest_file
fi

end_h=`date +%T`

echo "Script end at: $end_h"
duration=$SECONDS
echo "$(($duration / 60))m and $(($duration % 60))s elapsed."



# Push a notification to the Unraid GUI if the backup failed of passed
if [[ $? -eq 0 ]]; then
  /usr/local/emhttp/webGui/scripts/notify -i normal -s "Plex Backup completed in $(($duration / 60))m and $(($duration % 60))s"
else
  /usr/local/emhttp/webGui/scripts/notify -i warning -s "Plex Backup failed. See log for more details."
fi



