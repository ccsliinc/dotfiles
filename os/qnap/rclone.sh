#!/bin/sh
#this will need to be in the profile.
RCLONE_CONFIG=/share/CACHEDEV1_DATA/custom/.config/rclone/rclone.conf
export RCLONE_CONFIG

cd /share/CACHEDEV1_DATA/custom/ || exit

mkdir -p /share/CACHEDEV1_DATA/custom/log/

echo "Time: $(date). Script Starting." >> /share/CACHEDEV1_DATA/custom/log/rclone.log

RCLONE_CONFIG=/share/CACHEDEV1_DATA/custom/.config/rclone/rclone.conf
export RCLONE_CONFIG

rclone -v copy dropbox_joe:"apps/wpmu dev snapshot" gdrive_webteam:snapshot_backups >> /share/CACHEDEV1_DATA/custom/log/rclone.log 2>&1

echo "Time: $(date). Script Ending." >> /share/CACHEDEV1_DATA/custom/log/rclone.log
