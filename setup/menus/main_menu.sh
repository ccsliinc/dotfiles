#!/bin/bash

# shellcheck source=../../base/.profile
source "$HOME/.dotfiles/base/.profile"
# shellcheck source=../scripts/common/ui_helpers.sh
source "$HOME/.dotfiles/setup/scripts/common/ui_helpers.sh" &> /dev/null

mainmenu() {
    printf "${BIWhite}🚀 Setup Options:${Color_Off}\n\n"
    
    printf "  ${BICyan}1)${Color_Off} ${BIWhite}🔗 Link Configuration Files${Color_Off}\n"
    printf "     ${LGRAY}Create symbolic links for shell configurations${Color_Off}\n\n"
    
    printf "  ${BICyan}2)${Color_Off} ${BIWhite}🔐 Configure Sudo Access${Color_Off}\n" 
    printf "     ${LGRAY}Enable passwordless sudo for easier installation${Color_Off}\n\n"
    
    printf "  ${BICyan}3)${Color_Off} ${BIWhite}📦 Install Development Tools${Color_Off}\n"
    printf "     ${LGRAY}Install platform-specific packages and utilities${Color_Off}\n\n"
    
    printf "  ${BICyan}4)${Color_Off} ${BIWhite}🐚 Install Oh-My-Zsh Framework${Color_Off}\n"
    printf "     ${LGRAY}Enhanced shell experience with themes and plugins${Color_Off}\n\n"
    
    printf "  ${BICyan}5)${Color_Off} ${BIWhite}⚡ Change Default Shell${Color_Off}\n"
    printf "     ${LGRAY}Switch to zsh for better terminal experience${Color_Off}\n\n"
    
    printf "  ${BICyan}6)${Color_Off} ${BIWhite}🎯 Run Complete Setup${Color_Off}\n"
    printf "     ${LGRAY}Execute all setup steps automatically${Color_Off}\n\n"
    
    printf "  ${BIRed}0)${Color_Off} ${BIRed}❌ Exit Setup${Color_Off}\n\n"
    
    printf "${BIYellow}${ARROW}${Color_Off} ${BIWhite}Choose an option (or press Enter to exit): ${Color_Off}"

    read -r ans
    echo
    
    # Default to exit if nothing entered
    [[ -z "$ans" ]] && ans="0"
    
    case $ans in
        1) # Link Files
            printf "${BIYellow}🔗 Linking configuration files...${Color_Off}\n"
            if bash "$HOME/.dotfiles/setup/scripts/common/link_home_dir.sh"; then
                showSetup "✅ Configuration files linked successfully!"
            else
                showSetup "❌ Failed to link configuration files"
            fi
            mainmenu
            ;;
        2) # Sudo Without Password
            printf "${BIYellow}🔐 Configuring sudo access...${Color_Off}\n"
            if bash "$HOME/.dotfiles/setup/scripts/common/sudo_no_password.sh"; then
                showSetup "✅ Sudo access configured successfully!"
            else
                showSetup "❌ Failed to configure sudo access"
            fi
            mainmenu
            ;;
        3) # Install Tools
            printf "${BIYellow}📦 Installing development tools for $OS...${Color_Off}\n"
            if sudo bash "$HOME/.dotfiles/setup/scripts/setup/setup.$OS.sh"; then
                showSetup "✅ Development tools installed successfully!"
            else
                showSetup "❌ Some tools may have failed to install"
            fi
            mainmenu
            ;;
        4) # Install OhMyZsh
            printf "${BIYellow}🐚 Installing Oh-My-Zsh framework...${Color_Off}\n"
            if bash "$HOME/.dotfiles/setup/scripts/common/install_ohmyzsh.sh"; then
                showSetup "✅ Oh-My-Zsh installed successfully!"
            else
                showSetup "❌ Failed to install Oh-My-Zsh"
            fi
            mainmenu
            ;;
        5) # Change Shell
            printf "${BIYellow}⚡ Changing default shell...${Color_Off}\n"
            if bash "$HOME/.dotfiles/setup/scripts/common/change_default_shell.sh"; then
                showSetup "✅ Default shell changed successfully!"
            else
                showSetup "❌ Failed to change default shell"
            fi
            mainmenu
            ;;
        6) # Run All Scripts
            printf "${BIYellow}🎯 Running complete setup...${Color_Off}\n\n"
            
            local steps=("Linking files" "Configuring sudo" "Installing tools" "Installing Oh-My-Zsh" "Changing shell")
            local current=0
            local total=${#steps[@]}
            
            # Step 1: Link files
            printf "${BICyan}Step $((++current))/$total: ${steps[0]}${Color_Off}\n"
            bash "$HOME/.dotfiles/setup/scripts/common/link_home_dir.sh"
            
            # Step 2: Sudo setup  
            printf "${BICyan}Step $((++current))/$total: ${steps[1]}${Color_Off}\n"
            bash "$HOME/.dotfiles/setup/scripts/common/sudo_no_password.sh"
            
            # Step 3: Install tools
            printf "${BICyan}Step $((++current))/$total: ${steps[2]}${Color_Off}\n"
            sudo bash "$HOME/.dotfiles/setup/scripts/setup/setup.$OS.sh"
            
            # Step 4: Oh-My-Zsh
            printf "${BICyan}Step $((++current))/$total: ${steps[3]}${Color_Off}\n"
            bash "$HOME/.dotfiles/setup/scripts/common/install_ohmyzsh.sh"
            
            # Step 5: Change shell
            printf "${BICyan}Step $((++current))/$total: ${steps[4]}${Color_Off}\n"
            bash "$HOME/.dotfiles/setup/scripts/common/change_default_shell.sh"
            
            showSetup "🎉 Complete setup finished successfully!"
            mainmenu
            ;;
        0 | q) # Exit
            printf "${BIGreen}👋 Thanks for using dotfiles setup!${Color_Off}\n"
            cleanup_exit
            ;;
        *)
            printf "${BIRed}❌ Invalid option: '$ans'${Color_Off}\n"
            printf "${BIYellow}Please choose a number from 0-6${Color_Off}\n\n"
            sleep 2
            showSetup
            mainmenu
            ;;
    esac
}