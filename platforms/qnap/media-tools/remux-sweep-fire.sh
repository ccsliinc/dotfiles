#!/bin/bash
# ============================================================================
# remux-sweep-fire.sh
# ----------------------------------------------------------------------------
# Autonomous container-swap remux sweep — the standing MKV-convergence
# backstop. Invoked by QNAP cron weekly (see dotfiles cron wrapper
# media_remux_sweep.sh). One-shot, gated, locked, logged.
#
# Operator directive 2026-05-29: "everything finishes at the MKV standard."
# New content lands via Sonarr/Radarr in whatever container the release
# shipped. This sweep normalizes any new non-MKV keeper-codec arrivals
# (h264 under-band, hevc, av1) into MKV via cheap stream-copy remux
# (-c:v copy — lossless, CPU-only, no GPU contention). Legacy codecs
# (mpeg4/xvid/wmv) are NOT remuxed — the selector excludes them; they route
# to the encode lane (HEVC re-encode) instead.
#
# Filter: container_swap (widened 2026-05-29 to h264+hevc+av1, commit 0b1febf).
#
# Sweep size is conservative (WAVE_LIMIT=40): steady-state ingress is small
# (most releases are already MKV), and a small wave keeps Sonarr's rescan
# queue calm. The selector + pipeline_state dedupe make it idempotent — rows
# already at-target (MKV) or already done are skipped.
#
# Gates (ALL must pass to fire):
#   A  — No batch row with status='running' in pipeline_state.sqlite
#   A2 — No live `media_pipeline ... encode execute` process (serializes
#        against the GPU encode wave so two batches never fight Sonarr's
#        rescan queue — remux is CPU but shares the *arr rescan path)
#   C  — > 0 container_swap candidates pending in inventory.sqlite
#   D  — /share/Expansion >= 50 GB free (staging-root for rollback backup)
#   D2 — /share/Media     >= 50 GB free
#
# Logs: /share/Media/.media-tools/encode/logs/remux-sweep-YYYYMMDD-HHMMSS.log
# Lock: /share/Media/.media-tools/encode/remux-sweep-fire.lock
# ============================================================================

set -uo pipefail

# ---- config ----------------------------------------------------------------
DATA_HOST=/share/Media/.media-tools
LOG_DIR=$DATA_HOST/encode/logs
LOCK_FILE=$DATA_HOST/encode/remux-sweep-fire.lock
IMAGE=10.0.10.71:5000/media-pipeline:latest
ENCODE_FILTER=container_swap
WAVE_LIMIT=40
MIN_PENDING=0
MIN_EXP_GB=50
MIN_MEDIA_GB=50

mkdir -p "$LOG_DIR"
TS=$(date +%Y%m%d-%H%M%S)
LOG=$LOG_DIR/remux-sweep-$TS.log

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

# ---- single-instance lock (PID-based; QNAP busybox lacks flock) ------------
if [ -f "$LOCK_FILE" ]; then
    OLD_PID=$(cat "$LOCK_FILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        log "SKIP: another remux-sweep-fire is running (pid=$OLD_PID)"
        exit 0
    fi
    log "WARN: stale lock file (pid=$OLD_PID not running) — clearing"
    rm -f "$LOCK_FILE"
fi
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

log "===== remux-sweep-fire start ====="

# ---- Gate A — running batch row -------------------------------------------
RUNNING=$(docker run --rm \
    -v "$DATA_HOST":/app/data \
    --entrypoint python3 "$IMAGE" -c "
import sqlite3
db = sqlite3.connect('/app/data/encode/pipeline_state.sqlite')
rows = db.execute(\"SELECT batch_id, started_at FROM batches WHERE status='running'\").fetchall()
print('|'.join(f'{b}@{s}' for b,s in rows) if rows else 'NONE')
" 2>/dev/null)

if [ "$RUNNING" != "NONE" ]; then
    log "HOLD: batch still running: $RUNNING"
    exit 0
fi

# ---- Gate A2 — live encode/remux process ----------------------------------
LIVE_PROC=$(ps -ef | grep -E 'media_pipeline.*encode execute' | grep -v grep | wc -l | tr -d ' ')
if [ "$LIVE_PROC" -gt 0 ]; then
    log "HOLD: live encode/remux proc detected ($LIVE_PROC) — serialize against *arr rescan queue"
    exit 0
fi

# ---- Gate C — pending container_swap work ----------------------------------
# Count must mirror media_pipeline.encode.selector._select_container_swap
# exactly. Keeper codecs (h264 under-band / hevc / av1) in non-MKV containers.
PENDING=$(docker run --rm \
    -v "$DATA_HOST":/app/data \
    --entrypoint python3 "$IMAGE" -c "
import sqlite3
from media_pipeline.encode.selector import select_rows
db = sqlite3.connect('/app/data/inventory/inventory.sqlite')
print(len(select_rows(db, filter_name='container_swap', limit=None)))
" 2>/dev/null)

if ! [ "$PENDING" -gt "$MIN_PENDING" ] 2>/dev/null; then
    log "HOLD: ${PENDING:-0} container_swap candidates pending (need > $MIN_PENDING) — library on-standard"
    exit 0
fi

# ---- Gate D / D2 — disk free ----------------------------------------------
EXP_FREE_GB=$(df -kP /share/Expansion | tail -1 | awk '{print int($4/1048576)}')
MEDIA_FREE_GB=$(df -kP /share/Media     | tail -1 | awk '{print int($4/1048576)}')

if [ "$EXP_FREE_GB" -lt "$MIN_EXP_GB" ]; then
    log "HOLD: Expansion only ${EXP_FREE_GB} GB free (need >= $MIN_EXP_GB)"
    exit 0
fi
if [ "$MEDIA_FREE_GB" -lt "$MIN_MEDIA_GB" ]; then
    log "HOLD: Media only ${MEDIA_FREE_GB} GB free (need >= $MIN_MEDIA_GB)"
    exit 0
fi

# ---- All gates passed — fire sweep ----------------------------------------
log "FIRE: gates passed (pending=$PENDING, exp=${EXP_FREE_GB}GB, media=${MEDIA_FREE_GB}GB)"
log "Launching remux sweep: limit=$WAVE_LIMIT, filter=$ENCODE_FILTER, encoder=remux"

# *arr creds for the post-remux rescan hook (extension change .mp4 -> .mkv
# triggers RescanSeries/RescanMovie to re-pair the renamed file).
ARR_ENV_HOST=$DATA_HOST/refetch/.env
ENV_FILE_ARG=""
if [ -f "$ARR_ENV_HOST" ]; then
    ENV_FILE_ARG="--env-file $ARR_ENV_HOST"
    log "arr-rescan: creds present, passing --env-file"
else
    log "arr-rescan: no env-file at $ARR_ENV_HOST — rescan hook will no-op"
fi

# CPU-only (no --gpus): stream copy needs no encoder. The /share/Expansion
# mount is MANDATORY — it is the staging-root for the displaced original's
# rollback backup. Without it the original moves into container ephemeral fs
# and is lost on --rm.
docker run --rm --memory=4g --entrypoint python3 \
    $ENV_FILE_ARG \
    -v /share/Media:/media \
    -v /share/Expansion:/expansion \
    -v "$DATA_HOST":/app/data \
    "$IMAGE" -m media_pipeline.cli encode execute \
        --db /app/data/inventory/inventory.sqlite \
        --filter "$ENCODE_FILTER" --encoder remux \
        --confirm --limit "$WAVE_LIMIT" >> "$LOG" 2>&1

RC=$?
if [ $RC -eq 0 ]; then
    log "===== remux-sweep-fire complete (rc=0) ====="
else
    log "===== remux-sweep-fire FAILED (rc=$RC) ====="
fi
exit $RC
