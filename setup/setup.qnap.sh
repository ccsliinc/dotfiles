#!/usr/bin/env bash

#edit /etc/passwd and change shell

# Mount boot partition
mount "$(/sbin/hal_app --get_boot_pd port_id=0)6" /tmp/config

# Add autorun into the boot partition
touch /tmp/config/autorun.sh

echo '#!/bin/sh' > "/tmp/config/autorun.sh"
echo "# start a single script" >> "/tmp/config/autorun.sh"
echo "$PWD/os/qnap/autorunmaster.sh" >> "/tmp/config/autorun.sh"
echo "# finish" >> "/tmp/config/autorun.sh"

echo "Make sure you enable autorun in settings"
echo "Control Panel -> System -> Hardware -> 'Run user defined scripts...'"

# Unmount boot partition
umount /tmp/config

# install entware packages
/opt/bin/opkg update
/opt/bin/opkg install bash
/opt/bin/opkg install git
/opt/bin/opkg install grep
/opt/bin/opkg install htop
/opt/bin/opkg install jq
/opt/bin/opkg install zsh


# Link autorunmaster back to root of cusom folder
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/os/qnap/autorunmaster.sh /share/CACHEDEV1_DATA/custom/
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.profile /share/CACHEDEV1_DATA/custom/.profile
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.aliases /share/CACHEDEV1_DATA/custom/.aliases
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.exports /share/CACHEDEV1_DATA/custom/.exports
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.functions /share/CACHEDEV1_DATA/custom/.functions
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.bashrc /share/CACHEDEV1_DATA/custom/.bashrc
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.bash_profile /share/CACHEDEV1_DATA/custom/.bash_profile
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.zshrc /share/CACHEDEV1_DATA/custom/.zshrc
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.oh-my-zsh /share/CACHEDEV1_DATA/custom/.oh-my-zsh

# Create empty files for persistence
touch /share/CACHEDEV1_DATA/custom/.bash_history
touch /share/CACHEDEV1_DATA/custom/.zsh_history
touch /share/CACHEDEV1_DATA/custom/.viminfo

# Run autorun 
sh /share/CACHEDEV1_DATA/custom/.dotfiles/os/qnap/autorunmaster.sh