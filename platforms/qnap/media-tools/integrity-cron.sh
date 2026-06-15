#!/bin/bash
# ============================================================================
# integrity-cron.sh
# ----------------------------------------------------------------------------
# Weekly bit-rot detection sweep. Re-hashes ~2% of the live, baselined
# library (~800 files for a 40k-file library) and compares BLAKE3 against
# the stored baseline. Files currently being encoded are excluded.
#
# Invoked by QNAP cron via the dotfiles wrapper at
#   ~/.dotfiles/platforms/qnap/cron/media_integrity_check.sh
#
# Gates (ALL must pass to fire):
#   A — /share/Media >= 5 GB free (read-only sweep, but DB writes need room)
#
# The sweep runs ALONGSIDE the encode wave by design — there is no
# "encode-idle" window (encode runs 0/6/12/18h for 3-5h each over a 1900+
# file backlog), so a "no other pipeline" gate meant integrity never fired.
# It is now safe to overlap because:
#   * No GPU use — BLAKE3 is CPU-only; encode owns NVENC, no contention.
#   * Read-only on media files — only hashes, never mutates/deletes.
#   * The checker excludes paths the encoder is actively writing
#     (pipeline_state.sqlite state='encoding'), so it never hashes a file
#     mid-encode.
#   * inventory.sqlite is WAL + busy_timeout=30s, so the encode finalize
#     commit and the integrity verdict insert wait-and-retry instead of
#     erroring (the lock-cascade risk the old gate was masking is gone).
# The docker run is nice'd + ionice'd idle so the encode wave wins any CPU
# or disk contention; integrity just yields and finishes a little slower.
#
# Logs: /share/Media/.media-tools/inventory/logs/integrity-YYYYMMDD-HHMMSS.log
# Lock: /share/Media/.media-tools/inventory/integrity.lock
#
# Exit codes:
#   0  — sweep completed cleanly (zero mismatches), OR skipped on gate fail
#   1  — sweep completed but found >=1 mismatch (loud ALERT lines in log)
#   2  — pre-flight / lock / container error (sweep did not complete)
# ============================================================================

set -uo pipefail

# ---- config ----------------------------------------------------------------
DATA_HOST=/share/Media/.media-tools
INV_DB=$DATA_HOST/inventory/inventory.sqlite
LOG_DIR=$DATA_HOST/inventory/logs
LOCK_FILE=$DATA_HOST/inventory/integrity.lock
IMAGE=10.0.10.71:5000/media-pipeline:latest

BATCH_PCT="${INTEGRITY_BATCH_PCT:-2}"
MIN_AGE_DAYS="${INTEGRITY_MIN_AGE_DAYS:-30}"
MIN_MEDIA_GB=5

mkdir -p "$LOG_DIR"
TS=$(date +%Y%m%d-%H%M%S)
LOG=$LOG_DIR/integrity-$TS.log

iso_now() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }
log()         { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }
gate_log()    { echo "$(iso_now) $*" | tee -a "$LOG"; }
decision_log(){ echo "$(iso_now) decision=$*" | tee -a "$LOG"; }

# ---- single-instance lock (PID-based, busybox-safe; no flock on QNAP) ------
if [ -f "$LOCK_FILE" ]; then
    OLD_PID=$(cat "$LOCK_FILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        log "SKIP: another integrity-cron is running (pid=$OLD_PID)"
        decision_log "SKIP reason=lock_held pid=$OLD_PID"
        exit 0
    fi
    log "WARN: stale lock file (pid=$OLD_PID not running) — clearing"
    rm -f "$LOCK_FILE"
fi
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

log "===== integrity-cron start ====="

# ---- pre-flight ------------------------------------------------------------
if [ ! -f "$INV_DB" ]; then
    gate_log "gate=preflight pass=FALSE reason=inventory_db_missing path=$INV_DB"
    decision_log "ABORT failed_gate=preflight"
    exit 2
fi
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    gate_log "gate=preflight pass=FALSE reason=image_missing image=$IMAGE"
    decision_log "ABORT failed_gate=preflight"
    exit 2
fi
gate_log "gate=preflight pass=true inv_db=$INV_DB image=$IMAGE"

# NOTE: no "no_other_pipeline" gate — integrity runs alongside encode by
# design (see header). We log the observed encode-process count for context
# only; it never blocks the sweep.
LIVE_PROC=$(ps -ef | grep -E 'media_pipeline.*(encode execute|refetch execute)' \
    | grep -v grep | wc -l | tr -d ' ')
gate_log "info=concurrent_encode_procs count=$LIVE_PROC (non-blocking)"

# ---- Gate A — disk free for DB writes --------------------------------------
MEDIA_FREE_GB=$(df -kP /share/Media | tail -1 | awk '{print int($4/1048576)}')
if [ "$MEDIA_FREE_GB" -lt "$MIN_MEDIA_GB" ]; then
    gate_log "gate=disk pass=FALSE free_gb=$MEDIA_FREE_GB threshold=$MIN_MEDIA_GB"
    decision_log "SKIP failed_gate=disk"
    exit 0
fi
gate_log "gate=disk pass=true free_gb=$MEDIA_FREE_GB threshold=$MIN_MEDIA_GB"

# ---- All gates passed — fire sweep ----------------------------------------
decision_log "FIRE batch_pct=$BATCH_PCT min_age_days=$MIN_AGE_DAYS"
log "FIRE: batch_pct=$BATCH_PCT min_age_days=$MIN_AGE_DAYS"

# Low-priority CPU weight so a concurrent encode wave wins CPU contention.
# --cpu-shares 256 = 1/4 the default weight (1024); the sweep yields to encode
# under load and just runs a bit slower. (--blkio-weight is intentionally NOT
# used: this QNAP kernel's cgroup has no block-I/O weight support — Docker
# warns "Weight discarded" and ignores it. Integrity disk reads are sequential
# hashing and the encode wave already owns the GPU, so CPU-share yield is the
# meaningful lever here.)
docker run --rm --memory=2g --cpu-shares=256 \
    -v /share/Media:/media \
    -v "$DATA_HOST":/app/data \
    --entrypoint python3 "$IMAGE" \
    -m media_pipeline.cli integrity check \
        --db /app/data/inventory/inventory.sqlite \
        --batch-pct "$BATCH_PCT" \
        --min-age-days "$MIN_AGE_DAYS" \
        >> "$LOG" 2>&1

RC=$?
if [ $RC -eq 0 ]; then
    log "===== integrity-cron complete (rc=0, no mismatches) ====="
elif [ $RC -eq 1 ]; then
    MISMATCH_COUNT=$(grep -c '^ALERT type=bitrot' "$LOG" 2>/dev/null || echo 0)
    log "===== integrity-cron complete (rc=1, mismatches=$MISMATCH_COUNT) ====="
    decision_log "MISMATCHES_FOUND count=$MISMATCH_COUNT"
else
    log "===== integrity-cron FAILED (rc=$RC) ====="
    decision_log "FIRE_FAILED rc=$RC"
fi
exit $RC
