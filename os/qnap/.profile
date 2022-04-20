# shellcheck shell=bash
umask 022

if [ ! -f /var/run/utmp ]; then
    sudo touch /var/run/utmp
fi

if [ ! -f /usr/share/terminfo/x/xterm-256color ]; then
    sudo ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-256color
fi

if [ ! -f /usr/share/terminfo/x/xterm-color ]; then
    sudo ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-color
fi
