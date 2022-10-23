# Custom Cross Platform Profile

Installation instructions for all platforms.

## Linux & Raspberry Pi

### Linux Profile Install

```bash
ssh user@ipadress

sudo apt update -y && sudo apt upgrade -y
sudo apt install git -y
git clone https://github.com/ccsliinc/dotfiles.git ~/.dotfiles
~/.dotfiles/setup/bootstrap.sh
```

## Qnap

### Prerequisits

1. Create a user other than admin (admin acount should be disabled).
2. Enable home folder for all users.
3. Install Entware package via the web interface
   - <https://github.com/Entware/entware/wiki/Install-on-QNAP-NAS>

### QNAP Profile Install

```bash
sudo /opt/bin/opkg update                #update opkg package list
sudo /opt/bin/opkg install git git-http  #install git
sudo /opt/bin/opkg upgrade               #upgrade all packages
```

```bash
/opt/bin/git clone https://github.com/ccsliinc/dotfiles.git ~/.dotfiles
~/.dotfiles/setup/bootstrap.sh
```

### Opkg

>These are packages I use regularly.

- bash
- git
- grep
- htop
- nload - Realtime Network Load
- jq
- zsh

### Dockers

>Create a docker network for our containers to run in. The ethernet interface is one less than the interface name which the ethernet cable is connected to.  Interface 4 = eth3

 ```bash
#docker network create --driver=qnet --ipam-driver=qnet --ipam-opt=iface=eth0 --subnet 10.0.17.0/24 --gateway 10.0.17.1 qnet-static-eth0
sudo docker network create -d qnet --ipam-driver=qnet --ipam-opt=iface=eth1 --subnet 10.0.1.0/24 --gateway 10.0.1.1 qnet-static-eth1 --opt=iface=eth1
 ```

### Cron

>Editing cron jobs is a 3 step process.  You must follow the steps provided or the schedule will not persist across reboots.

- Edit your crontab file eg: sudo vi /etc/config/crontab
- Make crontab see the changes: sudo crontab /etc/config/crontab
- Restart the crontab service: sudo /etc/init.d/crond.sh restart
