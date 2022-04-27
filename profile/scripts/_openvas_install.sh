#!/bin/bash

sudo apt install libwacom-common

sudo apt -y install openvas

sudo gvm-setup

sudo gvm-check-setup

#sudo runuser -u _gvm -- gvmd --get-users
#gvmd --user=admin --new-password=passwd;