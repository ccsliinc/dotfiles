#!/bin/bash

PROMPT='[bootstrap]'
source common/.profile_os

# Initialize a few things
# init () {
# 	echo "$PROMPT Making a Projects folder in $PATH_TO_PROJECTS if it doesn't already exist"
# 	mkdir -p "$PATH_TO_PROJECTS"
# 	echo "$PROMPT Making a Playground folder in $PATH_TO_PLAYGROUND if it doesn't already exist"
# 	mkdir -p "$PATH_TO_PLAYGROUND"
# }

# TODO : Delete symlinks to deleted files
# Is this where rsync shines?
# TODO - add support for -f and --force
create_dotfilesloc () {
	# Create file which holds exported variable of the location of this folder
	echo "DOTFILESLOC=\"$PWD\"" > ".dotfiles_location"
	echo "export DOTFILESLOC" >> ".dotfiles_location"
	echo "export DEBUG=false" >> ".dotfiles_location"
	echo "if [ \"\$DEBUG\" = \"true\" ]; then echo \".dotfiles_location\" ; fi" >> ".dotfiles_location"
}

link () {
	echo "$PROMPT This utility will symlink the files in this repo to the home directory"
	echo "$PROMPT Proceed? (y/n)"
	read -r resp
	# TODO - regex here?
	if [[ $resp = [yY] ]] ; then
		#for file in $( ls -A | grep -vE '\.exclude*|\.git$|\.gitignore|.*.md' ) ; do
		#	ln -sv "$PWD/$file" "$HOME"
		#done
		# TODO: source files here?
		if [[ "$OS" == "mac" ]] || [[ "$OS" == "gnu" ]] || [[ "$OS" == "raspi" ]]; then
			#ln -svf ~/.dotfiles/common/.aliases ~
			ln -svf ~/.dotfiles/.bash_profile ~
			ln -svf ~/.dotfiles/.bashrc ~
			#ln -svf ~/.dotfiles/common/.exports ~
			#ln -svf ~/.dotfiles/common/.functions ~
			#ln -svf ~/.dotfiles/common/.profile ~
			ln -svf ~/.dotfiles/.zshrc ~
			ln -svf ~/.dotfiles/.oh-my-zsh ~
			ln -svf ~/.dotfiles/.dotfiles_location ~
		fi
		echo "$PROMPT Symlinking complete"
	else
		echo "$PROMPT Symlinking cancelled by user"
		return 1
	fi
}

install_tools () {
	## MacOS
	if [[ "$OS" == "mac" ]]; then
		echo "$PROMPT Detected macOS"
		echo "$PROMPT This utility will install useful utilities using Homebrew"
		echo "$PROMPT Proceed? (y/n)"
		read -r resp

		if [[ $resp = [yY] ]] ; then
			echo "$PROMPT Installing useful stuff using brew. This may take a while..."
			sudo bash setup/setup.darwin.sh
		else
			echo "$PROMPT Brew installation cancelled by user"
		fi
	else
		echo "$PROMPT Skipping installations using Homebrew because MacOS was not detected..."
	fi

	## GNU
	if [[ "$OS" == "gnu" ]]; then
		echo "$PROMPT Detected Linux"
		echo "$PROMPT This utility will install useful utilities using apt (this has been tested on Debian buster)"
		echo "$PROMPT Proceed? (y/n)"
		read -r resp

		if [[ $resp = [yY] ]] ; then
			echo "$PROMPT Installing useful stuff using apt. This may take a while..."
			sudo bash setup/setup.linux-gnu.sh
		else
			echo "$PROMPT Apt installation cancelled by user"
		fi
	else
		echo "$PROMPT Skipping installations using apt because Debian/Linux was not detected..."
	fi

	## QNAP
	if [[ "$OS" == "qnap" ]] || [[ "$OS" == "qnap-arm" ]]; then
		echo "$PROMPT Detected QNAP"
		echo "$PROMPT This utility will install useful utilities"
		echo "$PROMPT Proceed? (y/n)"
		read -r resp

		if [[ $resp = [yY] ]] ; then
			echo "$PROMPT Installing useful stuff. This may take a while..."
			sudo bash setup/setup.qnap.sh
		else
			echo "$PROMPT Installation cancelled by user"
		fi
	else
		echo "$PROMPT Skipping installation because QNAP was not detected..."
	fi

	## RASPBERRY PI
	if [[ "$OS" == "raspi" ]]; then
		echo "$PROMPT Detected Raspberry Pi"
		echo "$PROMPT This utility will install useful utilities"
		echo "$PROMPT Proceed? (y/n)"
		read -r resp

		if [[ $resp = [yY] ]] ; then
			echo "$PROMPT Installing useful stuff. This may take a while..."
			sudo bash setup/setup.linux-raspi.sh
		else
			echo "$PROMPT Installation cancelled by user"
		fi
	else
		echo "$PROMPT Skipping installation because Raspberry Pi was not detected..."
	fi
}

# Checklist
echo "#####################################"
echo "Detected System : $OS"
echo "User : $(whoami)"
echo "Current Directory : $(pwd)"
echo "#####################################"
echo ""
echo "You should be running this without sudo from your .dotfiles directory"
echo ""
echo "$PROMPT Proceed? (y/n)"
read -r resp

if [[ $resp = [yY] ]] ; then
	# init
	create_dotfilesloc
	link
	install_tools
fi

#ln -s ~/.dotfiles/.zshrc .
