# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/profile/_os/qnap/.profile" ; fi

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



if [[ ! -f "/usr/etc/sudoers.d/$(whoami)_grant_root" ]]; then

read -r -d '' SUDO << EOF
# Allow user $(whoami) execute any command without a
# password prompt
#$(whoami)   ALL=(ALL) NOPASSWD: ALL
$(whoami)   ALL=(ALL:ALL) NOPASSWD: ALL
EOF

    printf "Creating sudoers file"
    sudo mkdir -p /usr/etc/sudoers.d
    echo "$SUDO" | sudo tee -a "/usr/etc/sudoers.d/$(whoami)_grant_root"
fi