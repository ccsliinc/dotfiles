#!/bin/bash
# ============================================================================
# incremental-cron.sh
# ----------------------------------------------------------------------------
# Nightly incremental inventory scan, invoked by QNAP cron at 03:00.
#
# One-shot. Does NOT loop or retry — the daily cadence IS the retry.
# Single-instance lock prevents overlapping runs if a previous run is wedged.
#
# Logs to /share/Media/.media-tools/inventory/logs/incremental-YYYYMMDD.log.
# Heartbeat at /share/Media/.media-tools/inventory/incremental.heartbeat.
# ============================================================================

set -uo pipefail

# ---- config ----------------------------------------------------------------
DATA_HOST=/share/Media/.media-tools
DB_HOST=$DATA_HOST/inventory/inventory.sqlite
LOG_DIR=$DATA_HOST/inventory/logs
LOCK_FILE=$DATA_HOST/inventory/incremental.lock
HEARTBEAT_HOST=$DATA_HOST/inventory/incremental.heartbeat
ROOTS_CONTAINER="/media/Movies /media/TV"
IMAGE=10.0.10.71:5000/media-pipeline:latest
MAX_FPS=10

# ---- setup -----------------------------------------------------------------
mkdir -p "$LOG_DIR"
mkdir -p "$(dirname "$DB_HOST")"

LOG="$LOG_DIR/incremental-$(date +%Y%m%d).log"

log() {
  echo "[$(date -Iseconds)] $*" | tee -a "$LOG"
}

# ---- single-instance lock --------------------------------------------------
acquire_lock_flock() {
  exec 9>"$LOCK_FILE"
  flock -n 9 || return 1
  echo $$ >&9
  return 0
}

acquire_lock_pidfile() {
  if [ -f "$LOCK_FILE" ]; then
    local old_pid
    old_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
      return 1
    fi
    log "stale lock from pid=$old_pid, removing"
    rm -f "$LOCK_FILE"
  fi
  echo $$ > "$LOCK_FILE"
  return 0
}

if command -v flock >/dev/null 2>&1; then
  if ! acquire_lock_flock; then
    log "another incremental run holds the lock, exiting"
    exit 0
  fi
  trap 'rm -f "$LOCK_FILE"' EXIT
else
  if ! acquire_lock_pidfile; then
    log "another incremental run holds the lock, exiting"
    exit 0
  fi
  trap 'rm -f "$LOCK_FILE"' EXIT
fi

# ---- run -------------------------------------------------------------------
START=$(date +%s)
log "incremental scan starting (image=$IMAGE roots=$ROOTS_CONTAINER fps=$MAX_FPS)"

docker run --rm \
  -v /share/Media:/media:ro \
  -v "$DATA_HOST":/app/data \
  --entrypoint python3 "$IMAGE" \
  -m media_pipeline -v inventory incremental $ROOTS_CONTAINER \
  --db /app/data/inventory/inventory.sqlite \
  --max-fps $MAX_FPS \
  --heartbeat /app/data/inventory/incremental.heartbeat 2>&1 | tee -a "$LOG"
rc=${PIPESTATUS[0]}

END=$(date +%s)
ELAPSED=$((END - START))

log "incremental scan finished rc=$rc elapsed=${ELAPSED}s"
exit $rc
