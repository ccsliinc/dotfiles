#!/bin/bash

rm -rf ~/.dotfiles/.oh-my-zsh
rm -rf ~/.dotfiles/.dotfiles_location
rm -rf ~/.dotfiles_location ~/.dotfiles_location .oh-my-zsh
bash ~/.dotfiles/setup/scripts/common/install_ohmyzsh.sh
rm -rf ~/.zshrc
mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
exec /opt/bin/zsh