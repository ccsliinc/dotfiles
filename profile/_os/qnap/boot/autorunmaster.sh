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
if [ ! -f /root/.autorun ]; then
    touch /var/run/utmp
    touch /share/CACHEDEV1_DATA/custom/.bash_history
    touch /share/CACHEDEV1_DATA/custom/.zsh_history

    ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-256color
    ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-color

    rm -f /root/.bashrc
    rm -f /root/.bash_profile
    rm -f /root/.bash_history
    rm -f /root/.zsh_history

    # link files back in root directory
    ln -svf /share/CACHEDEV1_DATA/custom/.* /root/
    ln -svf /share/CACHEDEV1_DATA/custom/dockers.local /root/dockers.local

    echo 'source /share/CACHEDEV1_DATA/custom/.dotfiles_location' >> /root/.profile
    echo "source $DOTFILESLOC/common/.profile" >> /root/.profile
    [ -f ~/.profile_nvidia ] && echo "source $HOME/.profile_nvidia" >> /root/.profile

    # symlink custom folder for ease of access
    ln -s /share/CACHEDEV1_DATA/custom /root/custom

    touch /root/.autorun
fi

if [ ! -f /share/CACHEDEV1_DATA/custom/dockers.local ]; then
    ln -svf /share/CACHEDEV1_DATA/custom/dockers.local /root/dockers.local
fi

if [[ ! -f "/usr/etc/sudoers.d/$(whoami)_grant_root" ]]; then

read -r -d '' SUDO << EOF
# Allow user $(whoami) execute any command without a
# password prompt
#$(whoami)   ALL=(ALL) NOPASSWD: ALL
$(whoami)   ALL=(ALL:ALL) NOPASSWD: ALL
EOF

    printf "Creating sudoers file\n"
    sudo mkdir -p /usr/etc/sudoers.d
    echo "$SUDO" | sudo tee -a "/usr/etc/sudoers.d/$(whoami)_grant_root"
fi