#!/bin/bash
# ============================================================================
# QNAP Media Missing-Sweep Wave Advance
# ============================================================================
# Purpose: Autonomously drain the missing-media backlog (Radarr movies +
#          Sonarr episodes) one disk-aware wave at a time. Fires a movies
#          wave first (operator priority), then an episodes wave if disk
#          headroom remains. Self-paces through the ~27 remaining waves as
#          SAB/qBT drain — the deployed Python runner owns all gates
#          (SAB slots/size, qBT active, CACHEDEV3 free-GB) and resumability
#          (per-id done markers). Source of truth is the media repo at
#          ~/Development/Assistants/Media; this wrapper just dispatches to
#          the deployed runner on /share/Media/.media-tools.
# Schedule: Every 3 hours
# CRON: 0 */3 * * *
# ============================================================================

# Set HOME for root user (QNAP default when invoked by crond)
HOME=/root

# Dispatch to the deployed runner. The runner owns gates, locking, logging.
/share/Media/.media-tools/missing-sweep/missing-sweep-fire.sh
