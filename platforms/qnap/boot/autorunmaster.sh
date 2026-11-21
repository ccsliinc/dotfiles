#!/bin/sh
# ============================================================================
# QNAP Autorunmaster - Boot Automation Script
# ============================================================================
# Purpose: Run on every QNAP boot to configure system and schedule tasks
# Location: Called from /dev/sdx6/autorun.sh
# Features:
#   - System fixes (utmp, terminfo, BASH_ENV)
#   - Sudoers configuration for primary user
#   - Fleet Console fleetdeploy sudo rule restore (fleet-sudoers-restore.sh)
#   - Cron job scheduling from platforms/qnap/cron/
#   - Logging with rotation
#   - Alert notifications (QNAP native + Pushover)
# ============================================================================

# ============================================================================
# CONFIGURATION
# ============================================================================

# Root runs this at boot (an @reboot line in /etc/config/crontab), so the user and
# every file it reads must be ones only that user or root can change. /share/homes is
# writable by every account, so the user is NOT found by scanning it (anyone could plant
# a home that sorts first, or rename a home and put their own in its place). Instead the
# user is the home this script itself lives in: <homes>/<user>/.dotfiles/platforms/qnap/boot/,
# and that home, the repo and the script must be owned by that same user.

SCRIPT_REL="platforms/qnap/boot/autorunmaster.sh"

# Description: True when a path is real (not a symlink), owned by the given uid or root,
#              and writable by neither group nor others.
# Inputs     : $1 path (string), $2 uid (integer)
# Outputs    : exit status 0 when trusted, 1 otherwise
# Example    : is_trusted_path "$USER_HOME/.exports.local" "$QNAP_UID" && . "$USER_HOME/.exports.local"
is_trusted_path() {
    [ -e "$1" ] && [ ! -L "$1" ] || return 1
    owner=$(stat -c %u "$1" 2>/dev/null) || return 1
    [ "$owner" = "$2" ] || [ "$owner" = 0 ] || return 1
    mode=$(stat -c %a "$1" 2>/dev/null) || return 1
    [ $(( 0$mode & 022 )) -eq 0 ]
}

# Description: Work out the user, home and repo from this script's own path, and check
#              that the whole chain from the home down to the script belongs to that user.
# Inputs     : $1 path this script was started by (string, normally "$0")
# Outputs    : sets SCRIPT_PATH, DOTFILESLOC, USER_HOME, QNAP_USER, QNAP_UID; on failure
#              sets RESOLVE_ERROR and returns 1
resolve_user() {
    RESOLVE_ERROR=""
    SCRIPT_PATH=$(readlink -f "$1" 2>/dev/null)
    DOTFILESLOC=${SCRIPT_PATH%/$SCRIPT_REL}
    USER_HOME=${DOTFILESLOC%/.dotfiles}
    if [ -z "$SCRIPT_PATH" ] || [ "$DOTFILESLOC" = "$SCRIPT_PATH" ] || [ "$USER_HOME" = "$DOTFILESLOC" ]; then
        RESOLVE_ERROR="not run from <home>/.dotfiles/$SCRIPT_REL (got: ${SCRIPT_PATH:-$1})"
        return 1
    fi
    QNAP_USER=$(basename "$USER_HOME")
    QNAP_UID=$(id -u "$QNAP_USER" 2>/dev/null)
    if [ -z "$QNAP_UID" ] || [ "$QNAP_UID" = 0 ]; then
        RESOLVE_ERROR="home folder $USER_HOME does not belong to a regular account"
        return 1
    fi
    # The home itself must be owned by the account it is named after, not merely by root.
    if [ "$(stat -c %u "$USER_HOME" 2>/dev/null)" != "$QNAP_UID" ]; then
        RESOLVE_ERROR="$USER_HOME is not owned by $QNAP_USER"
        return 1
    fi
    for path in "$USER_HOME" "$DOTFILESLOC" "$DOTFILESLOC/platforms" "$DOTFILESLOC/platforms/qnap" \
                "$DOTFILESLOC/platforms/qnap/boot" "$SCRIPT_PATH"; do
        if ! is_trusted_path "$path" "$QNAP_UID"; then
            RESOLVE_ERROR="$path is not owned by $QNAP_USER or root, or others can write it"
            return 1
        fi
    done
}

if ! resolve_user "$0"; then
    # Nothing under the home can be trusted yet, so report only to the QNAP system log.
    /sbin/log_tool --append "[autorunmaster] REFUSED to run: $RESOLVE_ERROR" --type=2 2>/dev/null
    echo "autorunmaster: refused to run: $RESOLVE_ERROR" >&2
    exit 1
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
    # Read Pushover credentials from user's exports.local (sourced as root, so it must be trusted)
    if [ -f "$USER_HOME/.exports.local" ]; then
        if is_trusted_path "$USER_HOME/.exports.local" "$QNAP_UID"; then
            . "$USER_HOME/.exports.local"
        else
            log "ERROR: not reading $USER_HOME/.exports.local: not owned by $QNAP_USER or root, or others can write it"
        fi
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
        log_error "No QNAP user resolved"
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
# FLEET CONSOLE SUDOERS RESTORE
# ============================================================================

# Fleet Console's install keeps the fleetdeploy rule here; QTS wipes the live copy
# in /usr/etc/sudoers.d at every boot (fleet-console deploy-host-wrapper.md section 6).
# The names must match fleet-sudoers-restore.sh, which owns the copy and its checks.
FLEET_ACCOUNT="fleetdeploy"
FLEET_VOLUME="/share/CACHEDEV1_DATA"
FLEET_ROOT="$FLEET_VOLUME/.fleet-console-deploy"
FLEET_MASTER="$FLEET_ROOT/sudoers/$FLEET_ACCOUNT"
FLEET_INCLUDE="/usr/etc/sudoers.d"
FLEET_RESTORE="$DOTFILESLOC/platforms/qnap/boot/fleet-sudoers-restore.sh"

# Description: Remove every fleetdeploy copy in sudo's include dir, so its sudo -n grants nothing.
# Inputs     : none (FLEET_INCLUDE, FLEET_ACCOUNT)
# Outputs    : none
clear_fleet_sudoers() {
    rm -f "$FLEET_INCLUDE/.$FLEET_ACCOUNT.new" "$FLEET_INCLUDE/$FLEET_ACCOUNT" \
          "$FLEET_INCLUDE/.$FLEET_ACCOUNT.err"
}

# Description: Fail closed: clear any fleetdeploy copy and log why.
# Inputs     : $1 reason (string)
# Outputs    : exit status 1, always
refuse_fleet_sudoers() {
    clear_fleet_sudoers
    log_error "sudoers-restore: $1; no copy left in $FLEET_INCLUDE"
    return 1
}

# Description: Put Fleet Console's fleetdeploy sudo rule back, only from a root-only tree.
# Inputs     : none (FLEET_* settings, QNAP_UID, QNAP_USER)
# Outputs    : exit 0 when installed or Fleet Console is not installed, 1 on a refusal
restore_fleet_sudoers() {
    # QNAP's /bin/sh is busybox ash, which has local.
    # shellcheck disable=SC3043
    local p out
    # An unmounted data volume would look like "not installed"; it must be a loud
    # refusal instead, or a boot-order problem silently drops fleetdeploy's rule.
    grep -q " $FLEET_VOLUME " /proc/mounts \
        || { refuse_fleet_sudoers "$FLEET_VOLUME is not mounted"; return; }
    # Before Fleet Console's install there is nothing to restore; that is not an error.
    # Still clear any copy, so an uninstall never leaves a rule nothing checks.
    if [ ! -e "$FLEET_ROOT" ] && [ ! -L "$FLEET_ROOT" ]; then
        clear_fleet_sudoers
        log "Fleet Console not installed ($FLEET_ROOT absent); no $FLEET_ACCOUNT rule to restore"
        return 0
    fi
    # The restore runs as root and installs a sudo rule, so every step of the tree
    # must be root's alone (uid 0 only), and the script must be one we trust.
    for p in "$FLEET_ROOT" "$FLEET_ROOT/sudoers" "$FLEET_MASTER" "$FLEET_MASTER.sha256"; do
        is_trusted_path "$p" 0 || { refuse_fleet_sudoers "$p is missing, a link, or not root-only"; return; }
    done
    is_trusted_path "$FLEET_RESTORE" "$QNAP_UID" || {
        refuse_fleet_sudoers "$FLEET_RESTORE is not owned by $QNAP_USER or root, or others can write it"
        return
    }
    if out=$(/bin/sh "$FLEET_RESTORE" 2>&1); then
        log_success "$out"
    else
        # The script cleans up on its own refusals; this also covers a death mid-way.
        clear_fleet_sudoers
        log_error "$out"
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
    if ! is_trusted_path "$CRON_DIR" "$QNAP_UID"; then
        log_error "Not installing cron jobs: $CRON_DIR is not owned by $QNAP_USER or root, or others can write it"
        return 1
    fi

    log "Installing cron jobs from $CRON_DIR"

    CRONTAB_FILE="/etc/config/crontab"
    jobs_added=0
    jobs_skipped=0

    # Ensure @reboot entry exists for autorunmaster.sh itself
    AUTORUN_ENTRY="@reboot $DOTFILESLOC/platforms/qnap/boot/autorunmaster.sh"
    if ! grep -qF "autorunmaster.sh" "$CRONTAB_FILE" 2>/dev/null; then
        echo "$AUTORUN_ENTRY" >> "$CRONTAB_FILE"
        log "  ADDED: autorunmaster.sh [@reboot]"
        jobs_added=$((jobs_added + 1))
    fi

    for script in "$CRON_DIR"/*.sh; do
        [ ! -f "$script" ] && continue

        script_name=$(basename "$script")

        # Root's crontab will run it, so only a script no other account can change gets in.
        if ! is_trusted_path "$script" "$QNAP_UID"; then
            log_error "  REFUSED: $script_name (not owned by $QNAP_USER or root, or others can write it)"
            jobs_skipped=$((jobs_skipped + 1))
            continue
        fi

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
    log "User: ${QNAP_USER:-NONE} (uid ${QNAP_UID:-?}, from the script's own path)"
    log "User home: $USER_HOME"
    log "Dotfiles: $DOTFILESLOC"

    errors=0

    # Apply system fixes (once per boot)
    apply_system_fixes || errors=$((errors + 1))

    # Configure sudoers
    configure_sudoers || errors=$((errors + 1))

    # Restore Fleet Console's fleetdeploy rule (after our own rule, so sudo's
    # listing check sees the whole policy as it will stand)
    restore_fleet_sudoers || errors=$((errors + 1))

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