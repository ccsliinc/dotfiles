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

# Pre-trust known third-party taps (Homebrew 6.0+ "tap trust").
# Seeds ~/.homebrew/trust.json from the dotfiles snapshot so trusted taps load
# once enforcement is on (HOMEBREW_REQUIRE_TAP_TRUST / future default), and the
# non-interactive updater never trips a trust gate. Non-destructive: only seeds
# when no live trust file exists yet -- after that, brew owns/updates the file.
# To re-snapshot after trusting new taps:
#   cp ~/.homebrew/trust.json ~/.dotfiles/platforms/mac/homebrew/trust.json
if [ ! -f "$HOME/.homebrew/trust.json" ] && [ -f "$HOME/.dotfiles/platforms/mac/homebrew/trust.json" ]; then
    mkdir -p "$HOME/.homebrew"
    cp "$HOME/.dotfiles/platforms/mac/homebrew/trust.json" "$HOME/.homebrew/trust.json"
    echo "Seeded Homebrew tap trust from dotfiles."
fi

# tmux plugin manager setup (run once on new machine)
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Then open tmux and press prefix + I to install plugins
