#!/bin/bash
# ============================================================================
# QNAP Media Encode Wave Advance
# ============================================================================
# Purpose: Autonomously advance the media compression pipeline by one wave
#          (25 files) when all gates pass — replaces the flaky Claude MCP
#          scheduled-task daemon. Source of truth is the media repo at
#          ~/Development/Assistants/Media; this wrapper just dispatches to
#          the deployed runner on /share/Media/.media-tools.
# Schedule: Hourly (retuned 2026-06-11 from 6h — small-frequent waves keep the
#          P2000 fed without GPU idle gaps; gates HOLD overlap on the single GPU)
# CRON: 0 * * * *
# ============================================================================

# Set HOME for root user (QNAP default when invoked by crond)
HOME=/root

# Dispatch to the deployed runner. The runner owns gates, locking, logging.
/share/Media/.media-tools/encode-wave-fire.sh
