#!/bin/bash

# shellcheck source=../../../base/core/.profile_os
source ~/.dotfiles/base/core/.profile_os

read -r -d '' SUDO << EOF
# Allow user $(whoami) execute any command without a
# password prompt
#$(whoami)   ALL=(ALL) NOPASSWD: ALL
$(whoami)   ALL=(ALL:ALL) NOPASSWD: ALL
EOF

if [[ "$OS" == "mac" ]]; then
    echo "$SUDO" | sudo tee -a "/private/etc/sudoers.d/$(whoami)_grant_root"
elif [[ "$OS" == "gnu" ]] || [[ "$OS" == "raspi" ]]; then
    echo "$SUDO" | sudo tee -a "/etc/sudoers.d/$(whoami)_grant_root"
    sudo chmod 0440 "/etc/sudoers.d/$(whoami)_grant_root"
elif [[ "$OS" == "qnap" ]]; then
    sudo mkdir -p /usr/etc/sudoers.d
    echo "$SUDO" | sudo tee -a "/usr/etc/sudoers.d/$(whoami)_grant_root"
fi
