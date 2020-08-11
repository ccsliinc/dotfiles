# QNAP Custom Boot Files

## Setup

### QNAP

```bash
mkdir /share/CACHEDEV1_DATA/custom
cd /share/CACHEDEV1_DATA/custom
git clone git@bitbucket.org:joepersonal/mac-home.git .dotfiles
cd .dotfiles
./bootstrap.sh
```

## Dockers

```bash
cd docker
sh dockercommand.sh
```

### RClone Config
*This is used for SYNCing folders with RCLone, the crontab can be edited manually or use the script below to insert the line.  Make sure you restart the cron daemon once completed.*

`vi /etc/config/crontab`


`
echo '0 */4 * * * /share/CACHEDEV1_DATA/custom/rclone.sh' >> /etc/config/crontab
crontab /etc/config/crontab && /etc/init.d/crond.sh restart
`

### RClone Reference

rclone
rclone copy dropbox_joe:apps/"apps/wpmu dev snapshot" gdrive_webteam:snapshot_backups
rclone lsd dropbox_joe:"apps/wpmu dev snapshot"
rclone lsd gdrive_webteam:snapshot_backups

#### Notes
https://natelandau.com/bash-scripting-utilities/
https://natelandau.com/my-mac-osx-bash_profile/
