#!/bin/bash
# ============================================================================
# inventory-watchdog.sh
# ----------------------------------------------------------------------------
# Self-healing watchdog for the media inventory scan. Runs the python scanner
# in a docker container against the QNAP media roots, retries on failure, and
# spits out a heartbeat file every 30s so an external monitor can spot hangs.
#
# Usage (detached):
#   nohup bash inventory-watchdog.sh > /dev/null 2>&1 &
#
# Heartbeat semantics (for the external monitor):
#   - $HEARTBEAT          -> updated every ${HEARTBEAT_INTERVAL}s while scan runs.
#                            File age > 2 * HEARTBEAT_INTERVAL = scan is wedged.
#   - $HEARTBEAT.done     -> written on clean exit (timestamp + attempts).
#   - $HEARTBEAT.failed   -> written when retries are exhausted.
#
# Idempotency: the python scanner skips files whose mtime+size already match
# the DB row, so retrying a partial run is safe — no double work, no dupes.
#
# Note: chmod +x this file yourself. We don't do that here.
# ============================================================================

set -uo pipefail

# ---- config ----------------------------------------------------------------
DB_HOST=/share/Media/.media-tools/inventory/inventory.sqlite
LOG_DIR=/share/Media/.media-tools/inventory/logs
HEARTBEAT=/share/Media/.media-tools/inventory/watchdog.heartbeat
ROOTS_HOST="/share/Media/Movies /share/Media/TV"
ROOTS_CONTAINER="/media/Movies /media/TV"
IMAGE=10.0.10.71:5000/media-pipeline:latest
MAX_ATTEMPTS=10
RETRY_SLEEP=60
HEARTBEAT_INTERVAL=30

# ---- setup -----------------------------------------------------------------
mkdir -p "$LOG_DIR"
mkdir -p "$(dirname "$DB_HOST")"

LOG="$LOG_DIR/watchdog-$(date +%Y%m%d-%H%M%S).log"
echo "$LOG" > "$LOG_DIR/latest.log"

# nuke stale terminal markers from a previous run — fresh slate
rm -f "${HEARTBEAT}.done" "${HEARTBEAT}.failed"

# ---- heartbeat -------------------------------------------------------------
# Background ticker. Writes ISO-8601 to $HEARTBEAT every HEARTBEAT_INTERVAL
# seconds. External monitor stat()s the file — old mtime = wedged scan.
heartbeat_loop() {
  while true; do
    date -Iseconds > "$HEARTBEAT"
    sleep "$HEARTBEAT_INTERVAL"
  done
}

heartbeat_loop &
HEARTBEAT_PID=$!
trap 'kill $HEARTBEAT_PID 2>/dev/null' EXIT

# ---- retry loop ------------------------------------------------------------
attempt=0
while [ $attempt -lt $MAX_ATTEMPTS ]; do
  attempt=$((attempt+1))
  echo "[$(date -Iseconds)] attempt $attempt/$MAX_ATTEMPTS starting" | tee -a "$LOG"

  docker run --rm \
    -v /share/Media:/media:ro \
    -v /share/Media/.media-tools:/app/data \
    --entrypoint python3 "$IMAGE" \
    -m media_pipeline -v inventory scan $ROOTS_CONTAINER \
    --db /app/data/inventory/inventory.sqlite 2>&1 | tee -a "$LOG"
  rc=${PIPESTATUS[0]}

  if [ $rc -eq 0 ]; then
    echo "[$(date -Iseconds)] scan completed cleanly after $attempt attempts" | tee -a "$LOG"
    date -Iseconds > "${HEARTBEAT}.done"
    echo "attempts=$attempt" >> "${HEARTBEAT}.done"
    exit 0
  fi

  echo "[$(date -Iseconds)] scan failed rc=$rc, sleeping ${RETRY_SLEEP}s before retry" | tee -a "$LOG"
  sleep $RETRY_SLEEP
done

echo "[$(date -Iseconds)] exhausted $MAX_ATTEMPTS attempts, giving up" | tee -a "$LOG"
date -Iseconds > "${HEARTBEAT}.failed"
echo "last_rc=$rc" >> "${HEARTBEAT}.failed"
exit 1
