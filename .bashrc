# shellcheck shell=bash
# shellcheck disable=SC1091
# non interactive shell ie. scripts

if [[ -d "$HOME/.dotfiles" ]]; then
    DOTFILESLOC="$HOME/.dotfiles"
    export DOTFILESLOC
elif [[ -f "$HOME/.dotfiles_location" ]]; then
    source "$HOME/.dotfiles_location"
else
    echo "There is an error with your profile setup."
    echo "Please run bootstrap again."
    return 1
fi 

source "$DOTFILESLOC/base/.profile"

# This should be the last line of the file
# For local changes
# Don't make edits below this
[[ -f .bashrc.local ]] && source ".bashrc.local"
. "$HOME/.cargo/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/jsugamele/.cache/lm-studio/bin"
