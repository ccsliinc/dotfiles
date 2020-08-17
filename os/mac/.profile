# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo ".mac.profile" ; fi

_update_brew

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
    # This loads nvm
    [[ -s "/usr/local/opt/nvm/nvm.sh" ]] && . "/usr/local/opt/nvm/nvm.sh"
    # This loads nvm bash_completion
    [[ -s "/usr/local/opt/nvm/etc/bash_completion" ]] && . "/usr/local/opt/nvm/etc/bash_completion"
#eval $(docker-machine env default)
