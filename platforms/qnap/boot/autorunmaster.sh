#!/bin/sh
# ============================================================================
# QNAP Autorunmaster - Executed on every boot from /dev/sdx6/autorun.sh
# ============================================================================
# Purpose:
#   - Fix system-level issues that don't survive QNAP reboots
#   - Configure terminal/screen compatibility
#   - Set up sudoers for passwordless sudo
#
# Note: User home directories (/share/homes/username) ARE persistent.
#       Only /root and system directories are reset on reboot.
# ============================================================================

# ============================================================================
# SYSTEM FIXES (run once per boot)
# ============================================================================
if [ ! -f /root/.autorun ]; then

    # ------------------------------------------------------------------------
    # Fix for 'screen' command - requires /var/run/utmp
    # ------------------------------------------------------------------------
    touch /var/run/utmp

    # ------------------------------------------------------------------------
    # Fix terminal compatibility - xterm-256color and xterm-color
    # QNAP's terminfo is missing these, causing display issues
    # ------------------------------------------------------------------------
    [ ! -e /usr/share/terminfo/x/xterm-256color ] && \
        ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-256color
    [ ! -e /usr/share/terminfo/x/xterm-color ] && \
        ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-color

    # ------------------------------------------------------------------------
    # Set BASH_ENV for non-interactive bash scripts
    # This ensures scripts get DOTFILESLOC and PATH from dotfiles
    # ------------------------------------------------------------------------
    if [ -f /etc/profile ]; then
        if ! grep -q "BASH_ENV" /etc/profile 2>/dev/null; then
            echo 'export BASH_ENV="$HOME/.bashenv"' >> /etc/profile
        fi
    fi

    # ========================================================================
    # ROOT USER DOTFILES INTEGRATION (COMMENTED - No longer needed)
    # ========================================================================
    # Previously, QNAP only allowed root login. Now users have their own
    # persistent home directories, so this is unnecessary for most setups.
    #
    # Uncomment the following block if you need root to have dotfiles:
    # ------------------------------------------------------------------------
    #
    # # Persistent storage location for root's dotfiles
    # # Change this path if your QNAP uses a different volume
    # PERSISTENT_ROOT="/share/CACHEDEV1_DATA/.root_dotfiles"
    #
    # # Create persistent directory if needed
    # mkdir -p "$PERSISTENT_ROOT"
    #
    # # Create history files in persistent location
    # touch "$PERSISTENT_ROOT/.bash_history"
    # touch "$PERSISTENT_ROOT/.zsh_history"
    #
    # # Remove transient root files
    # rm -f /root/.bashrc
    # rm -f /root/.bash_profile
    # rm -f /root/.bash_history
    # rm -f /root/.zsh_history
    #
    # # Link persistent files to root home
    # ln -svf "$PERSISTENT_ROOT"/.* /root/
    #
    # # Set up root's profile to load dotfiles
    # # Requires .dotfiles_location to exist in persistent storage
    # if [ -f "$PERSISTENT_ROOT/.dotfiles_location" ]; then
    #     echo "source $PERSISTENT_ROOT/.dotfiles_location" >> /root/.profile
    #     . "$PERSISTENT_ROOT/.dotfiles_location"
    #     echo "source \$DOTFILESLOC/base/.profile" >> /root/.profile
    # fi
    #
    # # NVIDIA GPU support (if applicable)
    # [ -f /root/.profile_nvidia ] && echo "source \$HOME/.profile_nvidia" >> /root/.profile
    #
    # # Convenience symlink to persistent storage
    # ln -s "$PERSISTENT_ROOT" /root/persistent
    #
    # ========================================================================

    # Mark that autorun has completed this boot
    touch /root/.autorun
fi

# ============================================================================
# SUDOERS CONFIGURATION
# ============================================================================
# Create passwordless sudo for current user if not already configured
# This survives reboots as /usr/etc/sudoers.d is on persistent storage
# ============================================================================
if [ ! -f "/usr/etc/sudoers.d/$(whoami)_grant_root" ]; then

    SUDO_CONFIG="# Passwordless sudo for $(whoami)
# Created by dotfiles autorunmaster.sh
$(whoami)   ALL=(ALL:ALL) NOPASSWD: ALL"

    printf "Creating sudoers file for %s\n" "$(whoami)"
    sudo mkdir -p /usr/etc/sudoers.d
    echo "$SUDO_CONFIG" | sudo tee "/usr/etc/sudoers.d/$(whoami)_grant_root" > /dev/null
    sudo chmod 440 "/usr/etc/sudoers.d/$(whoami)_grant_root"
fi
