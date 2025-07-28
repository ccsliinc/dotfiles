# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/profile/.profile" ; fi

# shellcheck source=core/.profile_os
source "$DOTFILESLOC/base/core/.profile_os"

# shellcheck source=.functions
# load functions for all shells
source "$DOTFILESLOC/base/.functions"