# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/platforms/[platform]/.profile" ; fi

# =============================================================================
# [PLATFORM NAME]-SPECIFIC PROFILE SETTINGS
# =============================================================================

# Platform-specific profile initialization
# Add any platform-specific shell initialization here

# Example platform-specific settings:
# umask 022                                    # Default file permissions
# set +H                                       # Disable history expansion if needed

# Platform-specific system checks/initialization
# if [ ! -f /var/run/utmp ]; then
#     sudo touch /var/run/utmp
# fi

# Platform-specific environment setup
# if [ ! -d "/opt/[platform]" ]; then
#     echo "Warning: [Platform] installation not found"
# fi

# Auto-run platform-specific tools (uncomment if desired)
# my-[platform]-status                        # Show platform status on login
# my-[platform]-check                         # Run platform health check