# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/platforms/mac/.profile" ; fi

# Source mac-specific functions
# shellcheck source=.functions
source "$DOTFILESLOC/platforms/mac/.functions"

# Source iTerm2 functions (only loads if in iTerm2)
# shellcheck source=iterm2_functions.sh
source "$DOTFILESLOC/platforms/mac/iterm2_functions.sh"

# Source iTerm2 TUI quick-access functions (tt* commands)
# shellcheck source=iterm2_tui.sh
source "$DOTFILESLOC/platforms/mac/iterm2_tui.sh"

# Check if Claude config needs syncing
my-claude-sync-check

# Check for system updates on shell load (prompts if > 4 days since last update).
# DISABLED 2026-05-21: the updater ran on EVERY shell launch with no concurrency
# guard, so parallel tabs prompted, hung, and clobbered the shared
# ~/.update_mac_output.log — which broke new terminal tabs.
# RE-ARMED 2026-06-12: my-update-mac now claims a 1-day timestamp reservation
# BEFORE prompting, so the first tab locks and any other tabs opened while it runs
# see a fresh stamp and skip silently. The thundering-herd that broke tabs is gone.
my-update-mac
# Push both dotfiles repos (main + _reference.local)
dotpush() {
    echo "Pushing main dotfiles repo..."
    (cd ~/.dotfiles && git push)
    echo "Pushing _reference.local repo..."
    (cd ~/.dotfiles/_reference.local && git push)
    echo "All repos pushed."
}
