#!/bin/bash


# Check for bash shell
if [[ -z $BASH ]] || [[ "$BASH" != "/bin/bash" ]] ;then
	echo 
	echo "${LRED}Please run this script $0 with bash.${NOCOLOR}"
	echo 
	exit 1
fi

source ../profile/profile/.profile_os &> /dev/null
source ../profile/shared/bash_colors.sh &> /dev/null
source menus/main_menu.sh &> /dev/null

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
		gnu)
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
	if [ -d ~/.dotfiles ]; then
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
line="$(printf "%0.1s" "_"{1..80})"

center() {	
	printf "%*s %s %*s\n" "$(((termwidth-2-${#1})/2))" "" "$1" "$(((termwidth-1-${#1})/2))" ""
}

showSetup(){
	clear
	printf "${LBLUE}%s\n" "$line"
	printf "${LRED}%s" ""
	center "Profile Setup & Configure"
	printf "${LBLUE}%s\n" "$line"
	printf "\n"
	printf "${LCYAN}%-40s%40s\n" "$(date)" "Host : $(hostname)"
	printf "\n"
	printf "${LYELLOW}%14s : %-18s | %14s : %-35s\n" "Model" "$MODEL" "OS Version" "$OS_VERSION"
	printf "${LYELLOW}%14s : %-18s | %14s : %-35s\n" "Architecture" "$ARCH" "Uname" "$(uname -s -r -m -p)"
	printf "${LYELLOW}%14s : %-18s | %14s : %-35s\n" "User" "$(whoami)" "Shell" "$SHELL"
	printf "\n"
	printf "${LGRAY}%-18s : %-40s\n" "Current Directory" "$(pwd)"
	printf "${LBLUE}%s\n" "$line"
	printf "\n"

# ROW1
	if checkPlatform; then
	printf "${LGREEN}%-22s : %-15s${NOCOLOR}" "Detected OS" "✔ $OS"
	else
	printf "${LRED}%-22s : %-15s${NOCOLOR}" "Detected OS" "⍻ No"
	fi

	printf " %s " "|"

	if checkOhMyZsh; then 
	printf "${LGREEN}%-22s : %-15s${NOCOLOR}" "Detected OhMyZsh" "✔ Yes"
	else
	printf "${LRED}%-22s : %-15s${NOCOLOR}" "Detected OhMyZsh" "⍻ No"
	fi
	
	printf "\n"
# END ROW1

# ROW2
	if checkOhMyZsh; then
	printf "${LGREEN}%-22s : %-15s${NOCOLOR}" "Dotfiles Location " "✔ Yes"
	else
	printf "${LRED}%-22s : %-15s${NOCOLOR}" "Dotfiles Location " "⍻ No"
	fi

	printf " %s " "|"

	if checkSymLinks; then 
	printf "${LGREEN}%-22s : %-15s${NOCOLOR}" "Symlinks" "✔ Yes"
	else
	printf "${LRED}%-22s : %-15s${NOCOLOR}" "Symlinks" "⍻ No"
	fi
	
	printf "\n"
# END ROW2

# ROW3
	if [[ $SHELL == "/bin/zsh" ]]; then 
	printf "${LGREEN}%-22s : %-15s${NOCOLOR}" "Shell" "✔ Yes"
	else
	printf "${LRED}%-22s : %-15s${NOCOLOR}" "Shell" "⍻ No"
	fi

	printf " %s " "|"

	if checkSudoWithoutPassword; then 
	printf "${LGREEN}%-22s : %-15s${NOCOLOR}" "Sudo Without Password" "✔ Yes"
	else
	printf "${LRED}%-22s : %-15s${NOCOLOR}" "Sudo Without Password" "⍻ No"
	fi
	
	printf "\n"
# END ROW3

	printf "${LBLUE}%s\n" "$line"
	if [[ $1 != "" ]] ; then
		printf "${LPURPLE}%s\n"
		center "$1"
		printf "${NOCOLOR}%s\n"
	fi
}

showSetup

if ! (checkPlatform); then
	echo -e
	echo -e "${LRED}Cannot determine the platform.${NOCOLOR}"
	echo -e
	exit 1
fi

mainmenu