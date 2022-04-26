#!/bin/bash

rm -rf ~/.dotfiles/.oh-my-zsh
rm -rf ~/.dotfiles/.dotfiles_location
rm -rf ~/.dotfiles_location
rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
rm -rf ~/.zshrc
mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
exec zsh