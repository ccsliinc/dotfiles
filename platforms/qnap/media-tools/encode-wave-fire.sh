#!/bin/bash
# ============================================================================
# encode-wave-fire.sh
# ----------------------------------------------------------------------------
# Autonomous encode-wave advance for the media compression pipeline.
# Invoked by QNAP cron hourly (see scripts/qnap-ops/cron/encode_wave.sh
# symlink that the dotfiles autorunmaster registers).
#
# Fires a 25-file NVENC HEVC encode wave when all gates pass.
# One-shot. Silent skip on gate failure — cron will run again in 1h.
#
# Filter: h264 (over-cap) — Phase 6 PRIMARY lever, the 24 TB h264 → HEVC grind.
#   Selector picks only SDR h264/avc whose bitrate_total exceeds the per-
#   resolution band cap (DEFAULT_H264_BAND_CEILINGS). Validated 72% savings,
#   0 fails, MKV-correct, *arr rescan hook live (commit d25b5cd).
#
# Wave size is 25 (small-frequent, retuned 2026-06-11): each wave runs ONE
#   --memory=4g container that processes all WAVE_LIMIT files back-to-back, so
#   memory accumulates across files inside that single container. A 75-file
#   wave OOM-killed mid-batch (file 12 of 75, 2026-06-02) and wedged the
#   pipeline 9 days. Smaller waves = fresh container per batch resets the
#   accumulation, smaller crash blast radius, ~3x smaller staging footprint.
#   Hourly cron keeps the single P2000 fed (a 25-file wave finishes well under
#   1h of GPU time on average); Gate A/A2 HOLD the next fire while a batch runs,
#   so a faster tick never doubles up — it just eliminates GPU idle gaps.
#
# Gates (ALL must pass to fire):
#   A  — No batch row with status='running' in pipeline_state.sqlite
#   A2 — No live `media_pipeline ... encode execute` process
#   C  — >= 1 h264 over-cap candidate pending in inventory.sqlite
#   D  — CACHEDEV3 (qBT SSD, holds .scratch/.staging) >= 400 GB free
#   D2 — /share/Media     >= 100 GB free
#
# Work-dir mount (.scratch/.staging) migrated 2026-06-15 from the Expansion
# external drive to the qBT SSD (CACHEDEV3) to free the external for reclaim.
# Container still writes /expansion/...; only the HOST side of the -v moved to
# /share/CACHEDEV3_DATA/.encode-work. The 24h staging retention (cleanup.py)
# keeps that dir ~330 GB so it coexists with qBT inside the 1.9 TB SSD — hence
# Gate D's 400 GB floor on CACHEDEV3 (protects qBT's ~300 GB working headroom).
#
# Logs: /share/Media/.media-tools/encode/logs/cron-YYYYMMDD-HHMMSS.log
# Lock: /share/Media/.media-tools/encode/encode-wave-fire.lock
# ============================================================================

set -uo pipefail

# ---- config ----------------------------------------------------------------
DATA_HOST=/share/Media/.media-tools
INV_DB=$DATA_HOST/inventory/inventory.sqlite
STATE_DB=$DATA_HOST/encode/pipeline_state.sqlite
LOG_DIR=$DATA_HOST/encode/logs
LOCK_FILE=$DATA_HOST/encode/encode-wave-fire.lock
# Fully-qualified registry tag. The bare `media-pipeline:latest` does NOT
# resolve once the local image is pruned (Watchtower / registry GC) — a bare
# `docker run` then errors, the error is swallowed, and the gates mis-read the
# empty output. Always use the registry path and pull-if-missing below.
IMAGE=10.0.10.71:5000/media-pipeline:latest
# Host path for the encode work dirs (.scratch / .staging). Migrated off the
# Expansion external onto the qBT SSD (CACHEDEV3) 2026-06-15. The container
# still sees these at /expansion (mount target unchanged) — only the host side
# moved, so no cli.py container-view path defaults needed to change.
WORK_HOST=/share/CACHEDEV3_DATA/.encode-work
ENCODE_FILTER=h264
WAVE_LIMIT=25
# MIN_PENDING gates the wave on backlog depth via `PENDING -gt MIN_PENDING`.
# It MUST be < WAVE_LIMIT or the tail of the backlog (the last MIN_PENDING
# files) never fires — tail starvation. 0 => fire whenever >=1 file is pending
# (full drain to empty); the wave's own --limit caps actual batch size at 25.
MIN_PENDING=0
# Floor on the CACHEDEV3 SSD that hosts .scratch/.staging. 400 GB leaves qBT
# its ~300 GB working headroom after a 24h-retention staging footprint (~330 GB
# of 791 GB free). A wave needs scratch room for the in-flight transcode plus
# the parked originals; below this we HOLD rather than risk filling the SSD and
# starving qBittorrent / breaching the IPT seed-ratio drive.
MIN_WORK_GB=400
MIN_MEDIA_GB=100

mkdir -p "$LOG_DIR"
# Ensure the migrated work roots exist on the SSD (container writes here via
# the /expansion mount). Idempotent — cheap to assert every tick.
mkdir -p "$WORK_HOST/.scratch" "$WORK_HOST/.staging"
TS=$(date +%Y%m%d-%H%M%S)
LOG=$LOG_DIR/cron-$TS.log

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

# ---- single-instance lock (PID-based, portable; QNAP busybox lacks flock) -
if [ -f "$LOCK_FILE" ]; then
    OLD_PID=$(cat "$LOCK_FILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        log "SKIP: another encode-wave-fire is running (pid=$OLD_PID)"
        exit 0
    fi
    log "WARN: stale lock file (pid=$OLD_PID not running) — clearing"
    rm -f "$LOCK_FILE"
fi
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

log "===== encode-wave-fire start ====="

# ---- Image presence guard --------------------------------------------------
# The runtime image is periodically pruned. If it's absent, every gate's
# `docker run` fails and (historically) produced an empty string the gates
# mis-read as "a batch is running" — a permanent silent HOLD. Pull it up front
# so the gates have a real image to query. Pull failure is fatal (skip cleanly).
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    log "INFO: image $IMAGE not local — pulling"
    if ! docker pull "$IMAGE" >>"$LOG" 2>&1; then
        log "SKIP: could not pull $IMAGE — gates cannot run; will retry next cron"
        exit 0
    fi
fi

# ---- Stale-batch reaper ----------------------------------------------------
# A crashed/OOM-killed encode container never runs execute_plan's finally, so
# its batches row stays status='running' forever — wedging BOTH Gate A and the
# staging reaper (which skips non-terminal batches). A live wave finishes well
# under 8h; any 'running' row older than STALE_BATCH_HOURS is dead. Auto-flip
# it to 'aborted' so the pipeline self-heals on the next cron tick.
STALE_BATCH_HOURS=24
docker run --rm \
    -v "$DATA_HOST":/app/data \
    --entrypoint python3 "$IMAGE" -c "
import sqlite3, datetime
cutoff = (datetime.datetime.now() - datetime.timedelta(hours=$STALE_BATCH_HOURS)).isoformat(timespec='seconds')
now = datetime.datetime.now().isoformat(timespec='seconds')
db = sqlite3.connect('/app/data/encode/pipeline_state.sqlite')
with db:
    cur = db.execute(
        \"UPDATE batches SET status='aborted', ended_at=? \"
        \"WHERE status='running' AND (started_at IS NULL OR started_at < ?)\",
        (now, cutoff))
    if cur.rowcount:
        print(f'stale-abort: flipped {cur.rowcount} dead running batch(es) to aborted')
" 2>>"$LOG" | while read -r line; do log "$line"; done

# ---- Gate A — running batch row -------------------------------------------
# Capture rc separately: an errored docker run must NOT be mistaken for a
# running batch. Treat empty / non-NONE-non-batch output as an explicit error
# skip, never as a fire.
RUNNING=$(docker run --rm \
    -v "$DATA_HOST":/app/data \
    --entrypoint python3 "$IMAGE" -c "
import sqlite3
db = sqlite3.connect('/app/data/encode/pipeline_state.sqlite')
rows = db.execute(\"SELECT batch_id, started_at FROM batches WHERE status='running'\").fetchall()
print('|'.join(f'{b}@{s}' for b,s in rows) if rows else 'NONE')
" 2>>"$LOG")
GATE_A_RC=$?

if [ $GATE_A_RC -ne 0 ] || [ -z "$RUNNING" ]; then
    log "SKIP: Gate A query failed (rc=$GATE_A_RC, out='${RUNNING}') — not firing on uncertainty"
    exit 0
fi
if [ "$RUNNING" != "NONE" ]; then
    log "HOLD: batch still running: $RUNNING"
    exit 0
fi

# ---- Gate A2 — live encode process ----------------------------------------
LIVE_PROC=$(ps -ef | grep -E 'media_pipeline.*encode execute' | grep -v grep | wc -l | tr -d ' ')
if [ "$LIVE_PROC" -gt 0 ]; then
    log "HOLD: live encode proc detected ($LIVE_PROC) — possible stale batches DB row"
    exit 0
fi

# ---- Gate C — pending h264 over-cap work -----------------------------------
# Count must mirror media_pipeline.encode.selector._select_h264 exactly, or the
# gate fires/holds on a count the actual wave selector won't honor. SDR-safe +
# per-resolution band ceiling, keyed off bitrate_total (99.3% populated).
PENDING=$(docker run --rm \
    -v "$DATA_HOST":/app/data \
    --entrypoint python3 "$IMAGE" -c "
import sqlite3
from media_pipeline.encode.selector import select_rows
db = sqlite3.connect('/app/data/inventory/inventory.sqlite')
print(len(select_rows(db, filter_name='h264', limit=None)))
" 2>>"$LOG")
GATE_C_RC=$?

# A non-integer / empty PENDING means the docker query errored — skip rather
# than mis-report a count. Only a clean integer drives the fire/hold decision.
if [ $GATE_C_RC -ne 0 ] || ! [ "$PENDING" -eq "$PENDING" ] 2>/dev/null; then
    log "SKIP: Gate C query failed (rc=$GATE_C_RC, out='${PENDING}') — not firing on uncertainty"
    exit 0
fi
if ! [ "$PENDING" -gt "$MIN_PENDING" ] 2>/dev/null; then
    log "HOLD: only ${PENDING:-?} h264 over-cap candidates pending (need > $MIN_PENDING)"
    exit 0
fi

# ---- Gate D / D2 — disk free ----------------------------------------------
# Gate D now guards the CACHEDEV3 SSD (home of .scratch/.staging post-migration),
# shared with qBittorrent — keep its floor high enough that a wave can't starve
# qBT and breach the IPT seed-ratio drive.
WORK_FREE_GB=$(df -kP "$WORK_HOST" | tail -1 | awk '{print int($4/1048576)}')
MEDIA_FREE_GB=$(df -kP /share/Media | tail -1 | awk '{print int($4/1048576)}')

if [ "$WORK_FREE_GB" -lt "$MIN_WORK_GB" ]; then
    log "HOLD: work SSD (CACHEDEV3) only ${WORK_FREE_GB} GB free (need >= $MIN_WORK_GB — protects qBT headroom)"
    exit 0
fi
if [ "$MEDIA_FREE_GB" -lt "$MIN_MEDIA_GB" ]; then
    log "HOLD: Media only ${MEDIA_FREE_GB} GB free (need >= $MIN_MEDIA_GB)"
    exit 0
fi

# ---- All gates passed — fire wave -----------------------------------------
log "FIRE: gates passed (pending=$PENDING, work_ssd=${WORK_FREE_GB}GB, media=${MEDIA_FREE_GB}GB)"
log "Launching encode wave: limit=$WAVE_LIMIT, filter=$ENCODE_FILTER, encoder=nvenc_hevc"

# *arr creds for the post-encode rescan hook. The refetch env-file (mounted
# at /app/data/refetch/.env via the DATA_HOST mount) holds SONARR/RADARR
# URL+key. Passed best-effort: if the file is missing, --env-file would
# error, so guard it. The rescan hook itself no-ops cleanly without creds.
ARR_ENV_HOST=$DATA_HOST/refetch/.env
ENV_FILE_ARG=""
if [ -f "$ARR_ENV_HOST" ]; then
    ENV_FILE_ARG="--env-file $ARR_ENV_HOST"
    log "arr-rescan: creds present, passing --env-file"
else
    log "arr-rescan: no env-file at $ARR_ENV_HOST — rescan hook will no-op"
fi

docker run --rm --gpus all --memory=4g --entrypoint python3 \
    $ENV_FILE_ARG \
    -v /share/Media:/media \
    -v "$WORK_HOST":/expansion \
    -v "$DATA_HOST":/app/data \
    "$IMAGE" -m media_pipeline.cli encode execute \
        --db /app/data/inventory/inventory.sqlite \
        --filter "$ENCODE_FILTER" --encoder nvenc_hevc \
        --confirm --limit "$WAVE_LIMIT" >> "$LOG" 2>&1

RC=$?
if [ $RC -eq 0 ]; then
    log "===== encode-wave-fire complete (rc=0) ====="
else
    log "===== encode-wave-fire FAILED (rc=$RC) ====="
fi
exit $RC
