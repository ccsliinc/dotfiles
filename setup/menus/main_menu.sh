#!/bin/bash

# shellcheck source=../../base/core/.profile_os
source "$HOME/.dotfiles/base/core/.profile_os" &> /dev/null

mainmenu() {
    echo -ne "
${DGREEN}MAIN MENU${NOCOLOR}

1) Link Files
2) Sudo Without Password
3) Install Tools
4) Install OhMyZSH
5) Change Shell
6) Run All
7) Fix OhMyZsh
${LRED}0) Exit${NOCOLOR}

Choose an option:  "

    read -r ans
    case $ans in
        1) # Link Files
            bash "$HOME/.dotfiles/setup/scripts/common/link_home_dir.sh"
            showSetup "Files have been linked!"
            mainmenu
            ;;
        2) # Sudo Without Password
            bash "$HOME/.dotfiles/setup/scripts/common/sudo_no_password.sh"
            showSetup "Sudo without password set!"
            mainmenu
            ;;
        3) # Install Tools
            sudo bash "$HOME/.dotfiles/setup/scripts/setup/setup.$OS.sh"
            showSetup "Tools installed!"
            mainmenu
            ;;
        4) # Install OhMyZsh
            bash "$HOME/.dotfiles/setup/scripts/common/install_ohmyzsh.sh"
            showSetup "OhMyZsh installed!"
            mainmenu
            ;;
        5) # Change Shell
            bash "$HOME/.dotfiles/setup/scripts/common/change_default_shell.sh"
            showSetup "Shell Changed"
            mainmenu
            ;;
        6) # Run All Scripts
            bash "$HOME/.dotfiles/setup/scripts/common/link_home_dir.sh"
            bash "$HOME/.dotfiles/setup/scripts/common/sudo_no_password.sh"
            bash "$HOME/.dotfiles/setup/scripts/setup/setup.$OS.sh"
            bash "$HOME/.dotfiles/setup/scripts/common/install_ohmyzsh.sh"
            bash "$HOME/.dotfiles/setup/scripts/common/change_default_shell.sh"
            showSetup "All scripts completed."
            mainmenu
            ;;
        7) # Fix OhMyZsh after git update
            bash "$HOME/.dotfiles/setup/scripts/common/fix_ohmyzsh.sh"
            showSetup "Fixed OhMyZsh."
            mainmenu
            ;;
        0 | q) # Exit
            #echo "Bye bye."
            exit 0
            ;;
        *)
            echo "Invalid Option."
            exit 1
            ;;
    esac
}