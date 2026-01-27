#!/bin/bash

# Install Xcode command line tools if needed
if ! xcode-select -p &> /dev/null; then
    xcode-select --install
fi

# Install Homebrew if not already installed
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install \
  fortune \
  fzf \
  gawk \
  gcc \
  gum \
  git \
  htop \
  jq \
  mas \
  node \
  nvm \
  ollama \
  rclone \
  shellcheck \
  sslyze \
  tmux \
  wp-cli \
  yarn \
  yt-dlp \
  zsh

# Casks (GUI apps and fonts)
brew install --cask \
  font-meslo-lg-nerd-font

# tmux plugin manager setup (run once on new machine)
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Then open tmux and press prefix + I to install plugins
