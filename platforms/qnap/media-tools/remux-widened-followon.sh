#!/bin/bash
# ============================================================================
# remux-widened-followon.sh
# ----------------------------------------------------------------------------
# ONE-SHOT follow-on for the widened container_swap remux pass (commit 0b1febf,
# h264+hevc+av1). Waits for an in-flight remux batch to exit, then fires the
# widened pass against the remaining non-MKV keeper-codec backlog (the ~552
# hevc files the h264-only filter never covered).
#
# WHY a follow-on instead of firing now:
#   Two concurrent remux batches would both drive Sonarr RescanSeries on
#   every extension change (.mp4 -> .mkv), flooding the *arr rescan queue and
#   risking mis-pairs. We serialize: wait for the running batch (its PID) to
#   exit, then fire once.
#
# Usage:
#   bash remux-widened-followon.sh <wait_pid> [limit]
#     wait_pid : the in-flight remux container-station PID to wait on
#                (e.g. the `docker run ... --filter container_swap` PID).
#     limit    : files for the widened fire (default 700 — covers the full
#                hevc non-MKV backlog with headroom; idempotent, skips done).
#
# Idempotent: the widened pass uses the same container_swap filter + pipeline
# state dedupe, so it skips every h264 file the prior batch already converted
# and picks up only the still-non-MKV keeper codecs.
#
# Logs: /share/Media/.media-tools/encode/logs/remux-followon-YYYYMMDD-HHMMSS.log
# ============================================================================
set -uo pipefail

WAIT_PID="${1:?usage: remux-widened-followon.sh <wait_pid> [limit]}"
LIMIT="${2:-700}"
DATA_HOST=/share/Media/.media-tools
LOG_DIR=$DATA_HOST/encode/logs
mkdir -p "$LOG_DIR"
TS=$(date +%Y%m%d-%H%M%S)
LOG=$LOG_DIR/remux-followon-$TS.log
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

log "===== remux-widened-followon start: waiting on pid=$WAIT_PID, then fire limit=$LIMIT ====="

# ---- Wait for the in-flight remux batch to exit ----------------------------
while kill -0 "$WAIT_PID" 2>/dev/null; do
    sleep 60
done
log "in-flight remux pid=$WAIT_PID has exited — proceeding"

# Belt-and-suspenders: also wait out any other live encode-execute proc so we
# never run two batches against Sonarr's rescan queue at once.
while [ "$(ps -ef | grep -E 'media_pipeline.*encode execute' | grep -v grep | wc -l | tr -d ' ')" -gt 0 ]; do
    log "another encode-execute proc still live — waiting 60s"
    sleep 60
done

# ---- Fire the widened remux pass -------------------------------------------
log "FIRE: widened container_swap remux pass, limit=$LIMIT"
/share/Media/.media-tools/remux-fire.sh "$LIMIT" >> "$LOG" 2>&1
RC=$?
log "===== remux-widened-followon done rc=$RC ====="
exit $RC
