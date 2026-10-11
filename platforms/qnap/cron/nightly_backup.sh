#!/bin/bash
# ============================================================================
# QNAP Nightly Docker Backup
# ============================================================================
# Purpose: Nightly Docker container configuration backup to Restic
# Schedule: Daily at 4:00 AM
# CRON: 0 4 * * *
#
# This file is SHARED by every QNAP (qnap-home, qnap-office), so the backup
# script is resolved per host, never hardcoded to one device:
#   1. Device name: $QNAP_DEVICE if set, else mapped from `uname -n`.
#   2. Tracked script: docker-management/devices/<device>/.../backup-docker-containers.sh
#   3. Legacy fallback (only if 2 is absent): /share/Container/my-docker/backup/scripts/...
#      (on both QNAPs that path is a symlink to the tracked dir since 2026-08).
#   4. Nothing found: log to the backup log dir + syslog + stderr, exit 2.
# `--resolve-only` prints the resolved script and exits without running it.
# Portable: bash 3.2 (QNAP /bin/bash) and busybox tools only.
# ============================================================================

# Set HOME for root user (QNAP default)
HOME=/root

DM_ROOT="/share/Container/docker-management/devices"
SCRIPT_REL="my-docker/backup/scripts/backup-docker-containers.sh"
LEGACY_SCRIPT="/share/Container/my-docker/backup/scripts/backup-docker-containers.sh"
WRAPPER_LOG="/share/Container/my-docker/backup/logs/nightly_backup-wrapper.log"

# Description: Log one line to stderr, the wrapper log and syslog.
# Inputs: $1 level (INFO|ERROR), $2 message
# Outputs: none
log_line() {
    line="[$(date '+%Y-%m-%d %H:%M:%S')] [$1] nightly_backup: $2"
    echo "$line" >&2
    echo "$line" >> "$WRAPPER_LOG" 2>/dev/null
    logger -t nightly_backup "[$1] $2" 2>/dev/null
}

# Description: Map this host to its docker-management device name.
# Inputs: $QNAP_DEVICE (optional override), `uname -n`
# Outputs: device name on stdout; empty if unknown
resolve_device() {
    if [ -n "$QNAP_DEVICE" ]; then
        echo "$QNAP_DEVICE"
        return
    fi
    case "$(uname -n)" in
        QNP-1677X)    echo "qnap-home" ;;
        IMC-TSh973AX) echo "qnap-office" ;;
        *)            echo "" ;;
    esac
}

DEVICE="$(resolve_device)"
TRACKED_SCRIPT=""
[ -n "$DEVICE" ] && TRACKED_SCRIPT="$DM_ROOT/$DEVICE/$SCRIPT_REL"

if [ -n "$TRACKED_SCRIPT" ] && [ -x "$TRACKED_SCRIPT" ]; then
    BACKUP_SCRIPT="$TRACKED_SCRIPT"
elif [ -x "$LEGACY_SCRIPT" ]; then
    BACKUP_SCRIPT="$LEGACY_SCRIPT"
    log_line INFO "tracked script absent (device='$DEVICE' host='$(uname -n)' path='$TRACKED_SCRIPT'); using legacy $LEGACY_SCRIPT"
else
    log_line ERROR "NO BACKUP SCRIPT for host '$(uname -n)' device='$DEVICE': neither '$TRACKED_SCRIPT' nor '$LEGACY_SCRIPT' is executable. Backup NOT run."
    exit 2
fi

if [ "$1" = "--resolve-only" ]; then
    echo "device=$DEVICE script=$BACKUP_SCRIPT"
    exit 0
fi

# Run docker backup script (exec so cron sees its exit status)
exec "$BACKUP_SCRIPT"
