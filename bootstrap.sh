#!/bin/bash

PROMPT='[bootstrap]'
source .exports

# Initialize a few things
init () {
	echo "$PROMPT Making a Projects folder in $PATH_TO_PROJECTS if it doesn't already exist"
	mkdir -p "$PATH_TO_PROJECTS"
	echo "$PROMPT Making a Playground folder in $PATH_TO_PLAYGROUND if it doesn't already exist"
	mkdir -p "$PATH_TO_PLAYGROUND"
}

# TODO : Delete symlinks to deleted files
# Is this where rsync shines?
# TODO - add support for -f and --force

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
		ln -svf ~/.dotfiles/.aliases ~
		ln -svf ~/.dotfiles/.bash_profile ~
		ln -svf ~/.dotfiles/.bashrc ~
		ln -svf ~/.dotfiles/.exports ~
		ln -svf ~/.dotfiles/.functions ~
		ln -svf ~/.dotfiles/.profile ~
		ln -svf ~/.dotfiles/.zshrc ~
		echo "$PROMPT Symlinking complete"
	else
		echo "$PROMPT Symlinking cancelled by user"
		return 1
	fi
}

install_tools () {
	## MacOS
	if [[ "$OSTYPE" == *"darwin"* ]] ; then
		echo "$PROMPT Detected macOS"
		echo "$PROMPT This utility will install useful utilities using Homebrew"
		echo "$PROMPT Proceed? (y/n)"
		read -r resp

		if [[ $resp = [yY] ]] ; then
			echo "$PROMPT Installing useful stuff using brew. This may take a while..."
			sh setup/setup.darwin.sh
		else
			echo "$PROMPT Brew installation cancelled by user"
		fi
	else
		echo "$PROMPT Skipping installations using Homebrew because MacOS was not detected..."
	fi

	## GNU
	if [[ "$OSTYPE" == *"linux-gnu"* ]] && [[ "$MACHTYPE" == *"x86_64-pc-linux-gnu"* ]] ; then
		echo "$PROMPT Detected Linux"
		echo "$PROMPT This utility will install useful utilities using apt (this has been tested on Debian buster)"
		echo "$PROMPT Proceed? (y/n)"
		read -r resp

		if [[ $resp = [yY] ]] ; then
			echo "$PROMPT Installing useful stuff using apt. This may take a while..."
			sh setup/setup.linux-gnu.sh
		else
			echo "$PROMPT Apt installation cancelled by user"
		fi
	else
		echo "$PROMPT Skipping installations using apt because Debian/Linux was not detected..."
	fi

	## QNAP
	if [[ "$OSTYPE" == *"linux-gnu"* ]] && [[ "$MACHTYPE" == *"x86_64-QNAP-linux-gnu"* ]]; then
		echo "$PROMPT Detected QNAP"
		echo "$PROMPT This utility will install useful utilities"
		echo "$PROMPT Proceed? (y/n)"
		read -r resp

		if [[ $resp = [yY] ]] ; then
			echo "$PROMPT Installing useful stuff. This may take a while..."
			sh setup/setup.qnap.sh
		else
			echo "$PROMPT Installation cancelled by user"
		fi
	else
		echo "$PROMPT Skipping installation because QNAP was not detected..."
	fi

}

init
link
install_tools

#ln -s ~/.dotfiles/.zshrc .
