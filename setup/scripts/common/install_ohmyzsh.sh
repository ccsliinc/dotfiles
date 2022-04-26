#!/bin/bash

if ! [ -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [[ -f ~/.zshrc.pre-oh-my-zsh ]]; then
        rm -rf ~/.zshrc
        mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
    fi
fi