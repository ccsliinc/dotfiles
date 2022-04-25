#!/bin/bash

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
            bash "scripts/common/link_home_dir.sh"
            showSetup "Files have been linked!"
            mainmenu
            ;;
        2) # Sudo Without Password
            bash "scripts/common/sudo_no_password.sh"
            showSetup "Sudo without password set!"
            mainmenu
            ;;
        3) # Install Tools
            bash "scripts/setup/setup.$OS.sh"
            showSetup "Tools installed!"
            mainmenu
            ;;
        4) # Install OhMyZsh
            bash "scripts/common/install_ohmyzsh.sh"
            showSetup "OhMyZsh installed!"
            mainmenu
            ;;
        5) # Change Shell
            bash "scripts/common/change_default_shell.sh"
            showSetup "Shell Changed"
            mainmenu
            ;;
        6) # Run All Scripts
            bash "scripts/common/link_home_dir.sh"
            bash "scripts/common/sudo_no_password.sh"
            bash "scripts/setup/setup.$OS.sh"
            bash "scripts/common/install_ohmyzsh.sh"
            bash "scripts/common/change_default_shell.sh"
            showSetup "All scripts completed."
            mainmenu
            ;;
        7) # Fix OhMyZsh after git update
            rm -f ~/.oh-my-zsh
            bash "scripts/common/install_ohmyzsh.sh"
            rm -f ~/.zshrc
            showSetup "Fixed OhMyZsh."
            mainmenu
            ;;
        0) # Exit
            #echo "Bye bye."
            exit 0
            ;;
        *)
            echo "Invalid Option."
            exit 1
            ;;
    esac
}