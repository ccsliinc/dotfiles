#!/bin/bash
# ============================================================================
# QNAP Media Refetch Wave Advance
# ============================================================================
# Purpose: Autonomously advance the refetch (re-download corrupt media)
#          pipeline by one wave when all gates pass — replaces the silently
#          no-op'ing Claude MCP scheduled-task daemon. Source of truth is the
#          media repo at ~/Development/Assistants/Media; this wrapper just
#          dispatches to the deployed runner on /share/Media/.media-tools.
#          Runner self-gates on cadence (>=6h since last wave), qBT disk,
#          wave_cap, remaining work, sonarr_queue.
# Schedule: Every 3 hours
# CRON: 0 */3 * * *
# ============================================================================

# Set HOME for root user (QNAP default when invoked by crond)
HOME=/root

# Dispatch to the deployed runner. The runner owns gates, locking, logging.
/share/Media/.media-tools/refetch/refetch-wave-fire.sh
