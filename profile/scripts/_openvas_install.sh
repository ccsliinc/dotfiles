#!/bin/bash

sudo apt install libwacom-common

sudo apt -y install openvas

sudo gvm-setup

sudo gvm-check-setup

#gvmd --user=admin --new-password=passwd;