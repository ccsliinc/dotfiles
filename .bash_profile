# shellcheck shell=bash
# interactive shell ie. login

# shellcheck source=/dev/null
source ".dotfiles_location"
source "$DOTFILESLOC/common/.profile_interactive"

# do not overwrite files on > redirection
set -o noclobber

# update window size to fix wrapping
shopt -s checkwinsize

#############################
# color the working directory
if [[ $UID == 0 ]]; then
	export PS1="[${PS_LRED}\u${PS_NOCOLOR}@${PS_LYELLOW}\H${PS_LBLUE} \W${PS_NOCOLOR}]\$ "
else
	export PS1="[${PS_LGREEN}\u${PS_NOCOLOR}@${PS_LYELLOW}\H${PS_LBLUE} \W${PS_NOCOLOR}]\$ "
fi

# This should be the last line of the file
# For local changes
# Don't make edits below this
[[ -f ~/.bash_profile.local ]] && source "$HOME/.bash_profile.local"