# .profile - Login shell profile
# This file is read by login shells when no .bash_profile exists
# For local machine-specific settings, use ~/.profile.local

# Load local overrides if they exist
[[ -f ~/.profile.local ]] && source "$HOME/.profile.local"
