#!/bin/bash
# link_home_dir.sh - Create symlinks from home directory to dotfiles
# ============================================================================
# This script creates symbolic links for shell configuration files.
# Run this after cloning dotfiles to enable the configuration.
# ============================================================================

# Shell configuration files
ln -sf ~/.dotfiles/.bash_profile ~
ln -sf ~/.dotfiles/.bashrc ~
ln -sf ~/.dotfiles/.zshrc ~

# Environment files for non-interactive shells
ln -sf ~/.dotfiles/.zshenv ~
ln -sf ~/.dotfiles/.bashenv ~

# tmux configuration
ln -sf ~/.dotfiles/base/.tmux.conf ~/.tmux.conf
