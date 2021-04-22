# Linux
Log into ssh

```bash
sudo apt update -y
sudo apt upgrade -y
sudo apt install git -y
git clone --recursive https://github.com/ccsliinc/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
chsh
# change to /bin/zsh

#git submodule update --init
```

# QNAP Custom Boot Files

## Setup

### QNAP

#### Intel

Log into Web Interface and open the Control Panel App.  Click on Hardware or on the left menu select System -> Hardware.  On the general tab check the checkbox to select "Run user defined processes during startup" and click apply. This will allow the autorun.sh to be processed during system startup.

Optional install https://www.qnapclub.eu/en/qpkg/556 Entware to the QNAP for command line utilities.  This will allow installation and usage of git and other command line utilities. If you would like to use git to install this repo, log into ssh and install git.  It will be located at /opt/bin/git.

Make sure valid ssh keys are generated and added to github to allow pull.

```bash
opkg update       #update opkg package list
opkg install git git-http  #install git
opkg upgrade      #upgrade all packages
```

Once this is complete log into the QNAP via ssh from a command prompt and complete the following.

```bash
mkdir -p /share/CACHEDEV1_DATA/custom
cd /share/CACHEDEV1_DATA/custom
git clone --recursive https://github.com/ccsliinc/dotfiles.git .dotfiles
cd .dotfiles
./bootstrap.sh
```

#### Opkg

- bash
- git
- grep
- htop
- jq
- zsh

#### Dockers

 Create a docker network for our containers to run in. The ethernet interface is one less than the interface name which the ethernet cable is connected to.  Interface 4 = eth3
 
 ```bash
docker network create --driver=qnet --ipam-driver=qnet --ipam-opt=iface=eth3 --subnet 172.16.1.0/24 --gateway 172.16.1.1 qnet-static-eth3
 ```



### To Be Deleted
## Dockers

```bash
cd docker
sh dockercommand.sh
```

### RClone Config

*This is used for SYNCing folders with RCLone, the crontab can be edited manually or use the script below to insert the line.  Make sure you restart the cron daemon once completed.*

`vi /etc/config/crontab`

`echo '0 */4 * * * /share/CACHEDEV1_DATA/custom/rclone.sh' >> /etc/config/crontab
crontab /etc/config/crontab && /etc/init.d/crond.sh restart`

### RClone Reference

rclone
rclone copy dropbox_joe:apps/"apps/wpmu dev snapshot" gdrive_webteam:snapshot_backups
rclone lsd dropbox_joe:"apps/wpmu dev snapshot"
rclone lsd gdrive_webteam:snapshot_backups

#### Notes

<https://natelandau.com/bash-scripting-utilities/>
<https://natelandau.com/my-mac-osx-bash_profile/>
