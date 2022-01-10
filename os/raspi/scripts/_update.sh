#!/bin/bash

screen -d -m -S Update bash -c "Update sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y"