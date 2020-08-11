# shellcheck shell=bash
# interactive shell ie. login

# do not overwrite files on > redirection
set -o noclobber

# update window size to fix wrapping
shopt -s checkwinsize

# shellcheck source=/dev/null
source "$HOME/.profile"

#############################
# color the working directory
if [[ $UID == 0 ]]; then
	export PS1="[${PS_LRED}\u${PS_NOCOLOR}@${PS_LYELLOW}\H${PS_LBLUE} \W${PS_NOCOLOR}]\$ "
else
	export PS1="[${PS_LGREEN}\u${PS_NOCOLOR}@${PS_LYELLOW}\H${PS_LBLUE} \W${PS_NOCOLOR}]\$ "
fi


