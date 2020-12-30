#!/bin/bash

xcode-select --install
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

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
  youtube-dl \
  zsh
