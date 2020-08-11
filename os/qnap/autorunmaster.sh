#!/bin/sh
# This is the autorunmaster file which is executed from
# mounted device /dev/sdx6/ with file autorun.sh
# Enter below your scripts and comments
#
# Fix broken screen command which has missing file
# /var/run/utmp and may have missing environment
# variables for TERM, as such pointing to a non-existing
# xterm file like xterm-color.

#fix for screen on QNAP
touch /var/run/utmp
touch /share/CACHEDEV1_DATA/custom/.bash_history

ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-256color
ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-color

## ORDER OF EVENTS
## when admin logs in, system sources ~/.profile
## we insert -> source '.bash_profile' <- which is the existing original .bash_profile
## we insert -> source '.bashrc_custom' <- which is our custom additions
## the original/existing .bash_profile sources the original .bashrc

# every system boot the system copies the files back
# move files to custom location
# mv -f /root/.bashrc /share/CACHEDEV1_DATA/custom/
# mv -f /root/.bash_profile /share/CACHEDEV1_DATA/custom/
# mv -f /root/.profile /share/CACHEDEV1_DATA/custom/

rm -f /root/.bashrc
rm -f /root/.bash_profile
rm -f /root/.bash_history

# link files back in root directory
ln -svf /share/CACHEDEV1_DATA/custom/.* /root/
ln -svf /share/CACHEDEV1_DATA/custom/.dotfiles/os/qnap/docker/ /root/docker
#ln -s /share/CACHEDEV1_DATA/custom/.bashrc /root/.bashrc
#ln -s /share/CACHEDEV1_DATA/custom/.profile /root/.profile
#ln -s /share/CACHEDEV1_DATA/custom/.bash_profile /root/.bash_profile
#ln -s /share/CACHEDEV1_DATA/custom/.bash_history /root/.bash_history

echo 'source /share/CACHEDEV1_DATA/custom/.profile' >> /root/.profile
#echo 'source /share/CACHEDEV1_DATA/custom/.profile_custom' >> /share/CACHEDEV1_DATA/custom/.profile

# symlink custom folder for ease of access
ln -s /share/CACHEDEV1_DATA/custom /root/custom