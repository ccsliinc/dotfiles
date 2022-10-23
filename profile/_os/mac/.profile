# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/profile/_os/mac/.profile" ; fi

bash "$DOTFILESLOC/profile/_os/mac/scripts/_update_mac.sh"