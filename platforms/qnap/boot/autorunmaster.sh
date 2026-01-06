#!/bin/sh
# ============================================================================
# QNAP Autorunmaster - Boot Automation Script
# ============================================================================
# Purpose: Run on every QNAP boot to configure system and schedule tasks
# Location: Called from /dev/sdx6/autorun.sh
# Features:
#   - System fixes (utmp, terminfo, BASH_ENV)
#   - Sudoers configuration for primary user
#   - Cron job scheduling from platforms/qnap/cron/
#   - Logging with rotation
#   - Alert notifications (QNAP native + Pushover)
# ============================================================================

# ============================================================================
# CONFIGURATION
# ============================================================================

# Detect primary QNAP user (user with .dotfiles installed, not just first alphabetically)
QNAP_USER=""
for user in $(ls /share/homes 2>/dev/null | grep -v "^@" | grep -v "^lost+found"); do
    if [ -d "/share/homes/$user/.dotfiles" ]; then
        QNAP_USER="$user"
        break
    fi
done
# Fallback to first user if no dotfiles found
if [ -z "$QNAP_USER" ]; then
    QNAP_USER=$(ls /share/homes 2>/dev/null | grep -v "^@" | grep -v "^lost+found" | head -n 1)
fi
USER_HOME="/share/homes/$QNAP_USER"

# Get DOTFILESLOC from user's config or use standard location
if [ -f "$USER_HOME/.dotfiles_location" ]; then
    . "$USER_HOME/.dotfiles_location"
else
    DOTFILESLOC="$USER_HOME/.dotfiles"
fi

CRON_DIR="$DOTFILESLOC/platforms/qnap/cron"

# Logging configuration
LOG_DIR="$USER_HOME/.logs"
LOG_FILE="$LOG_DIR/autorunmaster.log"
MAX_LOG_SIZE=102400  # 100KB rotation threshold

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

rotate_log() {
    if [ -f "$LOG_FILE" ]; then
        log_size=$(wc -c < "$LOG_FILE" 2>/dev/null || echo 0)
        if [ "$log_size" -gt "$MAX_LOG_SIZE" ]; then
            mv "$LOG_FILE" "$LOG_FILE.old"
        fi
    fi
}

log() {
    mkdir -p "$LOG_DIR"
    rotate_log
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_error() {
    log "ERROR: $1"
    # Also log to QNAP system log
    /sbin/log_tool --append "[autorunmaster] ERROR: $1" --type=2 2>/dev/null
}

log_success() {
    log "SUCCESS: $1"
}

# ============================================================================
# ALERT FUNCTIONS
# ============================================================================

send_pushover() {
    # Read Pushover credentials from user's exports.local
    if [ -f "$USER_HOME/.exports.local" ]; then
        . "$USER_HOME/.exports.local"
    fi

    # Skip if not configured
    [ -z "$PUSHOVER_USER" ] || [ -z "$PUSHOVER_TOKEN" ] && return 0

    message="$1"
    priority="${2:-0}"  # -2=lowest, -1=low, 0=normal, 1=high, 2=emergency

    curl -s -X POST https://api.pushover.net/1/messages.json \
        -d "token=$PUSHOVER_TOKEN" \
        -d "user=$PUSHOVER_USER" \
        -d "message=$message" \
        -d "title=QNAP Autorunmaster" \
        -d "priority=$priority" \
        > /dev/null 2>&1
}

alert() {
    message="$1"
    severity="${2:-0}"  # 0=info, 1=warning, 2=error

    # Log to QNAP notification center
    /sbin/log_tool --append "[autorunmaster] $message" --type="$severity" 2>/dev/null

    # Send Pushover notification for warnings and errors
    if [ "$severity" -ge 1 ]; then
        pushover_priority=$((severity - 1))  # Convert: 1->0, 2->1
        send_pushover "$message" "$pushover_priority"
    fi
}

# ============================================================================
# SYSTEM FIXES (run once per boot)
# ============================================================================

apply_system_fixes() {
    if [ -f /root/.autorun ]; then
        log "System fixes already applied this boot"
        return 0
    fi

    log "Applying system fixes..."

    # Fix for 'screen' command - requires /var/run/utmp
    if [ ! -f /var/run/utmp ]; then
        touch /var/run/utmp
        log "  Created /var/run/utmp"
    fi

    # Fix terminal compatibility - xterm-256color and xterm-color
    if [ ! -e /usr/share/terminfo/x/xterm-256color ]; then
        ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-256color 2>/dev/null
        log "  Linked xterm-256color"
    fi
    if [ ! -e /usr/share/terminfo/x/xterm-color ]; then
        ln -s /usr/share/terminfo/x/xterm-xfree86 /usr/share/terminfo/x/xterm-color 2>/dev/null
        log "  Linked xterm-color"
    fi

    # Set BASH_ENV for non-interactive bash scripts
    if [ -f /etc/profile ]; then
        if ! grep -q "BASH_ENV" /etc/profile 2>/dev/null; then
            echo 'export BASH_ENV="$HOME/.bashenv"' >> /etc/profile
            log "  Added BASH_ENV to /etc/profile"
        fi
    fi

    # Mark that system fixes have been applied this boot
    touch /root/.autorun
    log_success "System fixes applied"
}

# ============================================================================
# SUDOERS CONFIGURATION
# ============================================================================

configure_sudoers() {
    if [ -z "$QNAP_USER" ]; then
        log_error "No QNAP user detected in /share/homes"
        return 1
    fi

    SUDOERS_FILE="/usr/etc/sudoers.d/${QNAP_USER}_grant_root"

    if [ -f "$SUDOERS_FILE" ]; then
        log "Sudoers already configured for user"
        return 0
    fi

    log "Configuring sudoers for detected user..."

    mkdir -p /usr/etc/sudoers.d

    cat > "$SUDOERS_FILE" << EOF
# Passwordless sudo for QNAP primary user
# Created by dotfiles autorunmaster.sh on $(date '+%Y-%m-%d')
$QNAP_USER   ALL=(ALL:ALL) NOPASSWD: ALL
EOF

    chmod 440 "$SUDOERS_FILE"

    if [ -f "$SUDOERS_FILE" ]; then
        log_success "Sudoers configured"
    else
        log_error "Failed to create sudoers file"
        return 1
    fi
}

# ============================================================================
# CRON SCHEDULING
# ============================================================================

install_cron_jobs() {
    if [ ! -d "$CRON_DIR" ]; then
        log "Cron directory not found: $CRON_DIR"
        return 1
    fi

    log "Installing cron jobs from $CRON_DIR"

    CRONTAB_FILE="/etc/config/crontab"
    jobs_added=0
    jobs_skipped=0

    for script in "$CRON_DIR"/*.sh; do
        [ ! -f "$script" ] && continue

        script_name=$(basename "$script")

        # Extract CRON schedule from script header
        schedule=$(grep "^# CRON:" "$script" 2>/dev/null | sed 's/^# CRON: *//')

        # Skip if disabled or no schedule
        if [ -z "$schedule" ] || [ "$schedule" = "DISABLED" ]; then
            log "  SKIP: $script_name (disabled or no schedule)"
            jobs_skipped=$((jobs_skipped + 1))
            continue
        fi

        # Check if already in crontab (avoid duplicates)
        if grep -q "$script" "$CRONTAB_FILE" 2>/dev/null; then
            log "  EXISTS: $script_name"
            continue
        fi

        # Add to crontab
        echo "$schedule $script" >> "$CRONTAB_FILE"
        log "  ADDED: $script_name [$schedule]"
        jobs_added=$((jobs_added + 1))
    done

    # Reload cron daemon if we added jobs
    if [ "$jobs_added" -gt 0 ]; then
        crontab "$CRONTAB_FILE" && /etc/init.d/crond.sh restart > /dev/null 2>&1
        log_success "Cron daemon restarted ($jobs_added jobs added, $jobs_skipped skipped)"
    else
        log "No new cron jobs to add ($jobs_skipped skipped)"
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log "========================================"
    log "AUTORUNMASTER STARTING"
    log "========================================"
    log "Detected user: ${QNAP_USER:-NONE}"
    log "User home: $USER_HOME"
    log "Dotfiles: $DOTFILESLOC"

    errors=0

    # Apply system fixes (once per boot)
    apply_system_fixes || errors=$((errors + 1))

    # Configure sudoers
    configure_sudoers || errors=$((errors + 1))

    # Install cron jobs
    install_cron_jobs || errors=$((errors + 1))

    # Final status
    log "========================================"
    if [ "$errors" -gt 0 ]; then
        log_error "Completed with $errors error(s)"
        alert "Autorunmaster completed with $errors error(s)" 2
        return 1
    else
        log_success "Autorunmaster completed successfully"
        alert "QNAP boot completed successfully" 0
        return 0
    fi
}

# Run main function
main