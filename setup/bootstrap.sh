#!/bin/bash

# Check for bash shell
if [[ -z $BASH ]] || [[ "$BASH" != "/bin/bash" ]] ;then
	echo
	echo "${LRED}Please run this script $0 with bash.${NOCOLOR}"
	echo
	exit 1
fi

# Set DOTFILESLOC before sourcing profile
export DOTFILESLOC="$HOME/.dotfiles"

# shellcheck source=../base/.profile
source "$HOME/.dotfiles/base/.profile"  
# shellcheck source=../base/shared/bash_colors.sh
source "$HOME/.dotfiles/base/shared/bash_colors.sh"
# shellcheck source=scripts/common/ui_helpers.sh
source "$HOME/.dotfiles/setup/scripts/common/ui_helpers.sh"
# shellcheck source=/menus/main_menu.sh
source "$HOME/.dotfiles/setup/menus/main_menu.sh"

# Check to make sure root is not running this script or sudo was used
if [ "$EUID" -eq 0 ]; then
	echo -e
	echo -e "${LRED}Do not run this script as root.${NOCOLOR}"
	echo -e
	exit 1
fi

checkPlatform(){
	case $OS in
		mac)
			return 0
			;;
		raspi)
			return 0
			;;
		qnap)
			return 0
			;;
		linux)
			return 0
			;;
		*)
			return 1
			;;
	esac
}

checkOhMyZsh(){
	if [ -d ~/.oh-my-zsh ]; then
		return 0
	else
		return 1
	fi
}

checkDotFiles(){
	if [[ -d ~/.dotfiles && -d ~/.dotfiles/base && -d ~/.dotfiles/platforms ]]; then
		return 0
	else
		return 1
	fi
}

checkSymLinks(){
	if ! { [[ -L "$HOME/.bash_profile" ]] && [[ $(readlink ~/.bash_profile) == "$HOME/.dotfiles/.bash_profile" ]]; } ; then
		return 1
	elif ! { [[ -L "$HOME/.bashrc" ]] && [[ $(readlink ~/.bashrc) == "$HOME/.dotfiles/.bashrc" ]]; } ; then
		return 1
	elif ! { [[ -L "$HOME/.zshrc" ]] && [[ $(readlink ~/.zshrc) == "$HOME/.dotfiles/.zshrc" ]]; } ; then
		return 1
	else
		return 0
	fi
}

checkSudoWithoutPassword(){
	if sudo -n true &> /dev/null; then 
		return 0
	else
		return 1
	fi
}


termwidth="80"
# Remove unused line variable

center() {	
	printf "%*s %s %*s\n" "$(((termwidth-2-${#1})/2))" "" "$1" "$(((termwidth-1-${#1})/2))" ""
}

showSetup(){
	clear
	
	# Modern header
	show_header "🔧 Dotfiles Setup & Configuration" "Interactive System Setup"
	
	# System information without box
	printf "%s💻 System Information:%s\n" "${BIWhite}" "${Color_Off}"
	printf "%s%s%s\n" "${BICyan}" "$(printf "%0.s─" {1..60})" "${Color_Off}"
	echo
	printf "  📅  %-14s %-s\n" "Date:" "$(date '+%Y-%m-%d %H:%M:%S')"
	printf "  🖥️  %-14s %-s\n" "Host:" "$(hostname)"
	printf "  💾  %-14s %-s\n" "Model:" "$MODEL"
	printf "  🔧  %-14s %-s\n" "OS Version:" "$OS_VERSION"
	printf "  ⚙️  %-14s %-s\n" "Architecture:" "$ARCH"
	printf "  🔩  %-14s %-s\n" "Kernel:" "$(uname -s -r)"
	printf "  👤  %-14s %-s\n" "User:" "$(whoami)"
	printf "  🐚  %-14s %-s\n" "Shell:" "$SHELL"
	printf "  📁  %-14s %-s\n" "Directory:" "$(pwd)"
	echo
	
	# Status checks in a clean list format
	printf "%s🔍 System Status Checks:%s\n" "${BIWhite}" "${Color_Off}"
	printf "%s%s%s\n\n" "${BICyan}" "$(printf "%0.s─" {1..40})" "${Color_Off}"
	
	# Platform detection
	if checkPlatform; then
		printf "  ${BIGreen}✓${Color_Off} %-25s ${BIGreen}%s${Color_Off}\n" "Platform Detection" "$OS"
	else
		printf "  ${BIRed}✗${Color_Off} %-25s ${BIRed}%s${Color_Off}\n" "Platform Detection" "Unknown"
	fi
	
	# Oh-My-Zsh detection  
	if checkOhMyZsh; then
		printf "  ${BIGreen}✓${Color_Off} %-25s ${BIGreen}%s${Color_Off}\n" "Oh-My-Zsh Framework" "Installed"
	else
		printf "  ${BIYellow}⚠${Color_Off} %-25s ${BIYellow}%s${Color_Off}\n" "Oh-My-Zsh Framework" "Not installed"
	fi
	
	# Dotfiles structure
	if checkDotFiles; then
		printf "  ${BIGreen}✓${Color_Off} %-25s ${BIGreen}%s${Color_Off}\n" "Dotfiles Structure" "Valid"
	else
		printf "  ${BIRed}✗${Color_Off} %-25s ${BIRed}%s${Color_Off}\n" "Dotfiles Structure" "Invalid"
	fi
	
	# Symbolic links
	if checkSymLinks; then
		printf "  ${BIGreen}✓${Color_Off} %-25s ${BIGreen}%s${Color_Off}\n" "Symbolic Links" "Configured"
	else
		printf "  ${BIYellow}⚠${Color_Off} %-25s ${BIYellow}%s${Color_Off}\n" "Symbolic Links" "Not linked"
	fi
	
	# Shell type
	if [[ $SHELL == *"/zsh" ]]; then
		printf "  ${BIGreen}✓${Color_Off} %-25s ${BIGreen}%s${Color_Off}\n" "Default Shell" "zsh"
	else
		printf "  ${BICyan}ℹ${Color_Off} %-25s ${BICyan}%s${Color_Off}\n" "Default Shell" "$(basename "$SHELL")"
	fi
	
	# Sudo configuration
	if checkSudoWithoutPassword; then
		printf "  ${BIGreen}✓${Color_Off} %-25s ${BIGreen}%s${Color_Off}\n" "Sudo Access" "Passwordless"
	else
		printf "  ${BICyan}ℹ${Color_Off} %-25s ${BICyan}%s${Color_Off}\n" "Sudo Access" "Password required"
	fi
	
	echo
	
	# Status message if provided
	if [[ -n "$1" ]]; then
		echo
		printf "${BIGreen}✨ %s${Color_Off}\n" "$1"
		echo
	fi
	
	# Separator
	local width
	read -r width _ <<< "$(get_terminal_size)"
	width=$((width > 80 ? 80 : width))
	printf "${BICyan}"
	for ((i=0; i<width; i++)); do printf "═"; done
	printf "${Color_Off}\n\n"
}

showSetup

if ! (checkPlatform); then
	echo -e
	echo -e "${LRED}Cannot determine the platform.${NOCOLOR}"
	echo -e
	exit 1
fi

mainmenu