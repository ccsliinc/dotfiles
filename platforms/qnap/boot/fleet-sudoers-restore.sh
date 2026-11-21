#!/bin/sh
# ============================================================================
# fleet-sudoers-restore.sh - put Fleet Console's fleetdeploy sudo rule back at boot
# ============================================================================
# Purpose: QTS rebuilds /usr/etc/sudoers.d from firmware at every boot, so the rule
#          Fleet Console's install writes for its fleetdeploy account is gone after a
#          reboot. This copies Fleet Console's root-owned master back, checked against
#          its sha256 sidecar, and proves sudo read it cleanly.
# Contract: fleet-console docs/architecture/deploy-host-wrapper.md section 6,
#          "Boot restore contract (for Dotfiles)". Output lines and exit codes match
#          its reference script (python3 -m fleet_deploy.host_install sudoers-restore),
#          and fleet-console tests/deploy/test_host_sudoers_boot_real.py covers both.
# Usage:   run as root, ONLY after the caller checked that the install root, its
#          sudoers/ folder, the master and the sidecar are root-only
#          (autorunmaster.sh restore_fleet_sudoers does that walk).
# Example: /bin/sh fleet-sudoers-restore.sh
# Exit 0:  prints "sudoers-restore: installed /usr/etc/sudoers.d/fleetdeploy".
# Exit 1:  one "sudoers-restore: <reason>; no copy left in ..." line on stderr, and
#          neither the target nor the staged copy is left, so fleetdeploy's sudo -n
#          grants nothing.
# ============================================================================

set -u
# The staged copy must never be readable or writable by anyone but root, even for
# the instant before chmod.
umask 0227
PATH=/bin:/usr/bin:/sbin:/usr/sbin

ACCOUNT=fleetdeploy
INCLUDE_DIR=/usr/etc/sudoers.d
M=/share/CACHEDEV1_DATA/.fleet-console-deploy/sudoers/$ACCOUNT
S=$M.sha256
T=$INCLUDE_DIR/$ACCOUNT
# Dotted names: sudo's @includedir skips any name containing a dot, so neither the
# staged copy nor the saved stderr is ever read as policy.
N=$INCLUDE_DIR/.$ACCOUNT.new
E=$INCLUDE_DIR/.$ACCOUNT.err
MODE=0440
SHA256_HEX_LENGTH=64
# The sidecar is exactly "<64 hex>  <master path>\n".
DIGEST_BYTES=$((SHA256_HEX_LENGTH + 2 + ${#M} + 1))

# Description: Remove every copy this script could have left, report why, and exit 1.
# Inputs     : $* reason (string)
# Outputs    : never returns; one line on stderr
refuse() {
    /bin/rm -f "$N" "$T" "$E"
    echo "sudoers-restore: $*; no copy left in $INCLUDE_DIR" >&2
    exit 1
}

[ "$(id -u)" = 0 ] || { echo "sudoers-restore: run as root" >&2; exit 1; }

# 1. Both files are real regular files (the caller already checked ownership).
[ -f "$M" ] && [ ! -L "$M" ] || refuse "$M is missing or not a regular file"
[ -f "$S" ] && [ ! -L "$S" ] || refuse "$S is missing or not a regular file"

# 2. The sidecar is exactly one line naming exactly the master.
IFS= read -r LINE < "$S" || refuse "$S has no complete line"
D=${LINE%%  *}
[ "$LINE" = "$D  $M" ] || refuse "$S does not name $M"
[ ${#D} = "$SHA256_HEX_LENGTH" ] || refuse "$S holds no sha256"
case $D in *[!0-9a-f]*) refuse "$S holds no sha256" ;; esac
[ $(( $(wc -c < "$S") )) = "$DIGEST_BYTES" ] || refuse "$S has more than one line"

# 3. The master matches its digest.
/bin/sha256sum -c "$S" > /dev/null 2>&1 || refuse "$M does not match $S"

# 4. Stage a root-only copy and check it is byte for byte the master.
/bin/rm -f "$N"
# A failure at any of the three steps must refuse, which is what && ... || means here.
# shellcheck disable=SC2015
/bin/cp "$M" "$N" && /bin/chown 0:0 "$N" && /bin/chmod "$MODE" "$N" || refuse "staging $N failed"
echo "$D  $N" | /bin/sha256sum -c > /dev/null 2>&1 || refuse "$N does not match $S"

# 5. One atomic rename onto the target.
[ ! -d "$T" ] || refuse "$T is a directory"
/bin/mv -f "$N" "$T" || refuse "renaming $N to $T failed"

# 6. sudo must read the policy without a word on stderr and list every rule. Since
#    sudo 1.9.3 (error_recovery) a syntax error is only a warning and sudo still
#    exits 0, so the exit status alone proves nothing.
/bin/rm -f "$E"
L=$(/usr/bin/sudo -n -l -U "$ACCOUNT" 2> "$E") || refuse "sudo does not accept $T"
[ ! -s "$E" ] || refuse "sudo wrote to stderr while listing $ACCOUNT's rules"
/bin/rm -f "$E"
R=$(sed -n "s/^$ACCOUNT ALL=\\(([^)]*) NOPASSWD: \\).*/\\1/p" "$T")
[ -n "$R" ] || refuse "$T holds no $ACCOUNT rule"
# Every account line must be one the listing check can read, or an unchecked rule
# could ride along.
[ $(( $(grep -c "^$ACCOUNT " "$T") )) = $(( $(printf '%s\n' "$R" | wc -l) )) ] \
    || refuse "$T has a $ACCOUNT rule this check cannot read"
X=$(printf '%s\n' "$R" | while IFS= read -r P; do
    printf '%s\n' "$L" | W="    $P" awk 'index($0, ENVIRON["W"]) == 1 { f = 1 } END { exit !f }' \
        || printf '%s; ' "$P"
done)
[ -z "$X" ] || refuse "sudo -l does not list the rule $X"

echo "sudoers-restore: installed $T"
