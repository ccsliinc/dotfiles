# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo ".profile" ; fi

# OS Version
if [[ "$OSTYPE" == *"darwin"* ]] ; then
    export OS="mac"
elif [[ "$OSTYPE" == *"linux-gnu"* ]] && [[ "$MACHTYPE" == *"x86_64-pc-linux-gnu"* ]] ; then
    export OS="gnu"
elif [[ "$OSTYPE" == *"linux-gnu"* ]] && [[ "$(uname -r)" == *"qnap"* ]]; then
    export OS="qnap"
fi

# shellcheck source=.functions
# load functions for all shells
source "$DOTFILESLOC/common/.functions"