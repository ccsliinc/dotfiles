#!/usr/bin/env bash

if [[ -x /opt/bin/opkg ]]; then
    echo "Installing Entware Packages"
    # install entware packages
    /opt/bin/opkg update
    /opt/bin/opkg install bash
    /opt/bin/opkg install git
    /opt/bin/opkg install grep
    /opt/bin/opkg install htop
    /opt/bin/opkg install jq
    /opt/bin/opkg install zsh
    /opt/bin/opkg install nload
    /opt/bin/opkg install node
    /opt/bin/opkg install node-npm
    /opt/bin/opkg install tmux
else
    echo "Please install Entware"
fi

if [[ -x /opt/bin/zsh ]]; then
    sudo usermod -s /opt/bin/zsh "$(whoami)"
    echo 'Default shell changed to ZSH'
else
    echo 'edit /etc/passwd and change shell'
fi

echo "Make sure you add the line jsugamele ALL=(ALL) ALL to /usr/etc/sudoers"