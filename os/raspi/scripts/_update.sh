#!/bin/bash

screen -d -m -S bash -c "Update sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y"