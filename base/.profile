# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/profile/.profile" ; fi

# shellcheck source=core/.profile_os
source "$DOTFILESLOC/base/core/.profile_os"

# shellcheck source=.functions
# load functions for all shells
source "$DOTFILESLOC/base/.functions"

# Load exports for all shells (including non-interactive)
# This ensures PATH is available for scripts, cron, SSH commands, etc.
# shellcheck source=.exports
source "$DOTFILESLOC/base/.exports"