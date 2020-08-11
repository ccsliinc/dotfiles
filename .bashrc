# shellcheck shell=bash
# shellcheck disable=SC1091
# non interactive shell ie. scripts

source ".bash_profile"

# This should be the last line of the file
# For local changes
# Don't make edits below this
[[ -f .bashrc.local ]] && source ".bashrc.local"