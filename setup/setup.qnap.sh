#!/usr/bin/env bash

# Mount boot partition
mount "$(/sbin/hal_app --get_boot_pd port_id=0)6" /tmp/config

# Add autorun into the boot partition

touch /tmp/config/autorun.sh

{
  echo #!/bin/sh
  # start a single script
  /share/CACHEDEV1_DATA/custom/autorunmaster.sh
  # finish
} > /tmp/config/autorun.sh

echo "Make sure you enable autorun in settings"
echo "Control Panel -> System -> Hardware -> 'Run user defined scripts...'"

# Unmount boot partition
umount /tmp/config

#cp autorun.sh /tmp/config/
#touch /tmp/config/autorun.sh
#chmod +x /tmp/config/autorun.sh
#$EDITOR /tmp/config/autorun.sh

# Link autorunmaster back to root of cusom folder
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/os/qnap/autorunmaster.sh /share/CACHEDEV1_DATA/custom/
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.profile /share/CACHEDEV1_DATA/custom/.profile_custom
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.aliases /share/CACHEDEV1_DATA/custom/.aliases
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.exports /share/CACHEDEV1_DATA/custom/.exports
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.functions /share/CACHEDEV1_DATA/custom/.functions

# Run autorun 
sh /share/CACHEDEV1_DATA/custom/.dotfiles/os/qnap/autorunmaster.sh