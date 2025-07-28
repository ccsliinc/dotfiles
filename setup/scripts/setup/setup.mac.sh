#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Install homebrew if it is not installed
if ! command -v brew >/dev/null 2>&1; then
	echo "Homebrew not installed. Attempting to install Homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	if ! command -v brew >/dev/null 2>&1; then
		echo "Something went wrong. Exiting..." && exit 1
	fi
fi

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Core Utils
brew install coreutils


# ---------------------------------------------
# Programming Languages and Frameworks
# ---------------------------------------------

# NodeJS
brew install node

# Python 3
brew install python

# Golang
brew install go


# ---------------------------------------------
# Tools I use often
# ---------------------------------------------

# Yarn - an alternative to npm
brew install yarn

# Docker for containerization
brew install docker

# ---------------------------------------------
# Useful tools
# ---------------------------------------------

# Make requests with awesome response formatting
brew install httpie

# Show directory structure with excellent formatting
brew install tree

# tmux :'D
brew install tmux

# gdb
brew install gdb

# OpenSSL
brew install openssl

# ---------------------------------------------
# Misc
# ---------------------------------------------

# Zsh
brew install zsh

# The Fire Code font
# https://github.com/tonsky/FiraCode
# This method of installation is
# not officially supported, might install outdated version
# Change font in terminal preferences
# brew tap caskroom/fonts
# brew install font-fira-code

# My favorite text editors
brew install --cask visual-studio-code

# ---------------------------------------------
# Terminal gimmicks xD
# ---------------------------------------------

# The computer fortune teller
brew install fortune

# The famous cowsay
brew install cowsay

# Multicolored text output
brew install lolcat


# Remove outdated versions from the cellar
brew cleanup

# Atom editor discontinued - remove this section if not needed
