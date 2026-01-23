# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/platforms/mac/.profile" ; fi

# Source mac-specific functions
# shellcheck source=.functions
source "$DOTFILESLOC/platforms/mac/.functions"

# Source iTerm2 functions (only loads if in iTerm2)
# shellcheck source=iterm2_functions.sh
source "$DOTFILESLOC/platforms/mac/iterm2_functions.sh"

# Check if Claude config needs syncing
my-claude-sync-check

# Uncomment to run auto-update on shell load (not recommended for regular use)
# my-update-mac