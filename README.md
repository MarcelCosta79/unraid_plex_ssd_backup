Overview
This is a script that is meant to backup a dedicated Plex SSD on Unraid. The script creates a tar file out of the "Application Support" directory in the Plex data directory in the plex_library_dir variable. It places the tar file in the backup_dir variable defined at the top of the file. The filename format for the backup file is plex_backup_{date-time}.tar.gz.

How To Use
This script was written for use with the User Scripts plugin. There are two main options for running it.

Copy and paste the script contents into a new user script (method I use)
Clone/download this repository and write a user script to call this one
For either option you will want to edit the following variables at the beginning of the script to suit your needs.

plex_library_dir
backup_dir
num_backups_to_keep
What is the script doing?
The following is teh steps the script goes through to backup Plex.

Plex docker is stopped
Wait for 30 seconds then check if the docker is stopped
If the container is stopped, start the backup
If not, attempt to stop the constainer up to 5 times
If that fails, the script exits with status 1 and pushes a warning to the Unraid GUI
Once the backup has finished, start the Plex docker again.
Check if the number of Plex backup files exceeds the specified maximum
If it does, delete the oldest backup file in the backup directory
Push a notification to the Unraid GUI if the script passed or failed


Original Script
Credits:https://github.com/ColonelRyzen/unraid_plex_ssd_backup
