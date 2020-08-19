# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo ".profile" ; fi

# shellcheck source=.profile_os
source "$DOTFILESLOC/common/.profile_os"

# shellcheck source=.functions
# load functions for all shells
source "$DOTFILESLOC/common/.functions"