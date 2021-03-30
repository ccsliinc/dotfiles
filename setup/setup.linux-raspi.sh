#!/usr/bin/env bash

# Install my favourite tools using the apt package manager (currently tested only on Debian buster)

PROMPT='[apt-install]'

echo "$PROMPT I hope you're running this script as root!"


# Update apt
apt update -y

# Upgrade any preinstalled packages
apt upgrade -y

# ---------------------------------------------
# Tools I use often
# ---------------------------------------------

# Git, obviously
apt install git -y

# Vim B)
apt install vim -y

# Make requests with awesome response formatting
apt install httpie -y

# Show directory structure with excellent formatting
apt install tree -y

# tmux :'D
apt install tmux -y


# ---------------------------------------------
# Misc
# ---------------------------------------------

# Zsh
apt install zsh -y
echo "$PROMPT This script (intentionally) does not install the Oh-my-zsh framework. If you want it, install it manually!"


# ---------------------------------------------
# Terminal gimmicks xD
# ---------------------------------------------

# The computer fortune teller
apt install fortune -y

# The famous cowsay
apt install cowsay -y

# Multicolored text output -y
apt install lolcat -y


# Cleanup the cache (TODO: set up a cron to do this)
apt clean
