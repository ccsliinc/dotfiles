# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/profile/.profile" ; fi

# shellcheck source=profile/.profile_os
source "$DOTFILESLOC/profile/profile/.profile_os"

# shellcheck source=.functions
# load functions for all shells
source "$DOTFILESLOC/profile/.functions"