#!/bin/bash

# Update OS
sudo apt update -y

# Upgrade OS
sudo apt upgrade -y

# Upgrade Dist
sudo apt dist-upgrade -y

# Change the listening IP for GVM
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /lib/systemd/system/greenbone-security-assistant.service
sudo sed -i 's/--port 9392/--port 9392 --no-redirect/g' /lib/systemd/system/greenbone-security-assistant.service

sudo sed -i 's/127.0.0.1/0.0.0.0/g' /lib/systemd/system/gsad.service
sudo sed -i 's/--port 9392/--port 9392 --no-redirect/g' /lib/systemd/system/gsad.service


# Check GVM Setup
sudo gvm-feed-update
sudo gvm-check-setup

#Change 127.0.0.1 to 0.0.0.0
#sudo vi /lib/systemd/system/greenbone-security-assistant.service



# Start GVM
# sudo gvm-start


############
####OLD#####
############


#database upgrade

#/usr/lib/postgresql/13/bin/pg_ctl -D /var/lib/postgresql/13/main stop
#/usr/lib/postgresql/14/bin/pg_ctl -D /var/lib/postgresql/14/main stop

#/usr/lib/postgresql/14/bin/pg_upgrade   --old-datadir=/var/lib/postgresql/13/main   --new-datadir=/var/lib/postgresql/14/main   --old-bindir=/usr/lib/postgresql/13/bin   --new-bindir=/usr/lib/postgresql/14/bin   --old-options '-c config_file=/etc/postgresql/13/main/postgresql.conf'   --new-options '-c config_file=/etc/postgresql/14/main/postgresql.conf'
#/usr/lib/postgresql/14/bin/pg_upgrade   --old-datadir=/var/lib/postgresql/13/main   --new-datadir=/var/lib/postgresql/14/main   --old-bindir=/usr/lib/postgresql/13/bin   --new-bindir=/usr/lib/postgresql/14/bin   --old-options '-c config_file=/etc/postgresql/13/main/postgresql.conf'   --new-options '-c config_file=/etc/postgresql/14/main/postgresql.conf'

#sudo vim /etc/postgresql/14/main/postgresql.conf
# ...and change "port = 5433" to "port = 5432"

#sudo vim /etc/postgresql/13/main/postgresql.conf
# ...and change "port = 5432" to "port = 5433"

#./delete_old_cluster.sh
#

#sudo systemctl start postgresql.service
#sudo su - postgres
#psql -c "SELECT version();"
#/usr/lib/postgresql/14/bin/vacuumdb --all --analyze-in-stages
#apt list --installed | grep postgresql
#sudo apt-get remove postgresql-13 postgresql-server-dev-13