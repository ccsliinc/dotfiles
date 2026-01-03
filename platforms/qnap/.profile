# shellcheck shell=bash
# ============================================================================
# QNAP Platform Profile
# ============================================================================
# Purpose: QNAP-specific profile settings loaded on user login
# Note: System fixes are handled by autorunmaster.sh on boot
# ============================================================================

if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/platforms/qnap/.profile" ; fi

umask 022

# ============================================================================
# AUTORUNMASTER VERIFICATION
# ============================================================================
# Check if autorunmaster ran on boot. If not, trigger it as fallback.
# This provides a safety net in case the boot script didn't execute.
# ============================================================================

if [ ! -f /root/.autorun ]; then
    echo "WARNING: autorunmaster did not run on boot!"
    echo "Attempting to run autorunmaster as fallback..."

    if [ -f "$DOTFILESLOC/platforms/qnap/boot/autorunmaster.sh" ]; then
        sudo "$DOTFILESLOC/platforms/qnap/boot/autorunmaster.sh"
    else
        echo "ERROR: autorunmaster.sh not found at $DOTFILESLOC/platforms/qnap/boot/"

        # Apply critical fixes manually if autorunmaster is missing
        [ ! -f /var/run/utmp ] && sudo touch /var/run/utmp
        [ ! -e /usr/share/terminfo/x/xterm-256color ] && \
            sudo ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-256color 2>/dev/null
        [ ! -e /usr/share/terminfo/x/xterm-color ] && \
            sudo ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-color 2>/dev/null
    fi
fi

# ============================================================================
# SUDOERS FALLBACK
# ============================================================================
# If sudoers wasn't configured by autorunmaster (e.g., first login before
# reboot), attempt to create it now. This works because we're running as
# the actual user, so $(whoami) returns the correct username.
# ============================================================================

if [ ! -f "/usr/etc/sudoers.d/$(whoami)_grant_root" ]; then
    echo "Sudoers not configured. Attempting to create..."

    SUDO_CONFIG="# Passwordless sudo for $(whoami)
# Created by dotfiles .profile fallback on $(date '+%Y-%m-%d')
$(whoami)   ALL=(ALL:ALL) NOPASSWD: ALL"

    sudo mkdir -p /usr/etc/sudoers.d
    echo "$SUDO_CONFIG" | sudo tee "/usr/etc/sudoers.d/$(whoami)_grant_root" > /dev/null
    sudo chmod 440 "/usr/etc/sudoers.d/$(whoami)_grant_root"

    if [ -f "/usr/etc/sudoers.d/$(whoami)_grant_root" ]; then
        echo "Sudoers configured successfully."
    else
        echo "ERROR: Failed to configure sudoers."
    fi
fi