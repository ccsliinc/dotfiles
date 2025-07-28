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
  gawk \
  gcc \
  git \
  htop \
  jq \
  mas \
  node \
  nvm \
  rclone \
  shellcheck \
  sslyze \
  wp-cli \
  yarn \
  yt-dlp \
  zsh
