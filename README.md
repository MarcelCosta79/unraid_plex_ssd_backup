# Overview
This is a script that is meant to backup(Rsync+tar) a dedicated Plex SSD on Unraid. The script creates a tar file out of the PLEX directory in the plex_library_dir variable. It places the tar file in the backup_dir variable defined at the top of the file. The filename format for the backup file is plex_backup_{date-time}.tar.

# How To Use
This script was written for use with the User Scripts plugin. There are two main options for running it.
1. Copy and paste the script contents into a new user script (method I use)
2. Clone/download this repository and write a user script to call this one

For either option you will want to edit the following variables at the beginning of the script to suit your needs.
1. plex_library_dir
2. backup_dir
3. num_backups_to_keep


# What is the script doing?
The following is the steps the script goes through to backup Plex.
1. Plex docker is stopped
2. Wait for 30 seconds then check if the docker is stopped
3. If the container is stopped, starts rsync. It'll clone the plex folder into appdata original folder for an instant recovery in case of drive failure.
   If not, attempt to stop the constainer up to 5 times  
   If that fails, the script exits with status 1 and pushes a warning to the Unraid GUI
4. Once the rsync has finished, start the Plex docker again.
5. Check if plex has really restarted.
5. After 5 seconds, starts a backup of the cloned folder.
5. Check if the number of Plex backup files exceeds the specified maximum
6. If it does, delete the oldest backup file in the backup directory
7. Push a notification to the Unraid GUI if the script passed or failed

Original Script
Credits:https://github.com/ColonelRyzen/unraid_plex_ssd_backup
