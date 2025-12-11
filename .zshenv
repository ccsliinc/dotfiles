# shellcheck shell=zsh
# .zshenv - Executed for ALL zsh invocations (interactive and non-interactive)
# ============================================================================
# This is the first file zsh reads, before .zshrc
#
# Purpose:
#   - Set up DOTFILESLOC for non-interactive shells
#   - Load PATH and exports for scripts, cron, SSH commands
#   - Ensure consistent environment across all zsh invocations
#
# Note: Keep this file minimal - heavy initialization belongs in .zshrc
# ============================================================================

# Source shared environment setup
# Uses $HOME since DOTFILESLOC isn't set yet
if [[ -f "$HOME/.dotfiles/base/.env_common" ]]; then
    source "$HOME/.dotfiles/base/.env_common"
elif [[ -f "$HOME/.dotfiles_location" ]]; then
    source "$HOME/.dotfiles_location"
    [[ -f "$DOTFILESLOC/base/.env_common" ]] && source "$DOTFILESLOC/base/.env_common"
fi
