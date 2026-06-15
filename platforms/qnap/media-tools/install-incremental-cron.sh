#!/bin/bash
# ============================================================================
# install-incremental-cron.sh
# ----------------------------------------------------------------------------
# Run-once setup: copies incremental-cron.sh to the QNAP and registers a
# 03:00 daily crontab entry.
#
# QNAP cron quirk: editing /var/spool/cron/crontabs/admin does NOT survive
# reboot. The persistent config lives at /etc/config/crontab. After
# modifying it you MUST run:
#   crontab /etc/config/crontab
#   /etc/init.d/crond.sh restart
#
# Usage (from this Mac):
#   bash scripts/qnap-ops/install-incremental-cron.sh [user@host]
#
# Default host: admin@10.0.1.200 (Home QNAP)
# ============================================================================

set -uo pipefail

QNAP_HOST=${1:-admin@10.0.1.200}
LOCAL_SCRIPT=$(cd "$(dirname "$0")" && pwd)/incremental-cron.sh
REMOTE_DIR=/share/Media/.media-tools
REMOTE_SCRIPT=$REMOTE_DIR/incremental-cron.sh
REMOTE_CRONTAB=/etc/config/crontab
CRON_LINE="0 3 * * * $REMOTE_SCRIPT"

if [ ! -f "$LOCAL_SCRIPT" ]; then
  echo "missing local script: $LOCAL_SCRIPT" >&2
  exit 1
fi

echo "==> copying $LOCAL_SCRIPT to $QNAP_HOST:$REMOTE_SCRIPT"
scp "$LOCAL_SCRIPT" "$QNAP_HOST:$REMOTE_SCRIPT"

echo "==> chmod +x on remote"
ssh "$QNAP_HOST" "chmod +x $REMOTE_SCRIPT"

echo "==> registering crontab entry"
ssh "$QNAP_HOST" bash <<EOSSH
set -uo pipefail
CRONTAB=$REMOTE_CRONTAB
LINE="$CRON_LINE"

# idempotent: skip if our exact line is already present
if grep -Fxq "\$LINE" "\$CRONTAB" 2>/dev/null; then
  echo "crontab entry already present, skipping append"
else
  # remove any prior entry pointing at the same script (path-based match)
  if grep -Fq "$REMOTE_SCRIPT" "\$CRONTAB" 2>/dev/null; then
    echo "removing prior entry for $REMOTE_SCRIPT"
    grep -Fv "$REMOTE_SCRIPT" "\$CRONTAB" > "\$CRONTAB.tmp" && \
      mv "\$CRONTAB.tmp" "\$CRONTAB"
  fi
  echo "\$LINE" >> "\$CRONTAB"
  echo "appended: \$LINE"
fi

echo "==> reloading cron (QNAP-specific)"
crontab "\$CRONTAB"
/etc/init.d/crond.sh restart
EOSSH

echo "==> done. verify with: ssh $QNAP_HOST 'crontab -l | grep incremental'"
