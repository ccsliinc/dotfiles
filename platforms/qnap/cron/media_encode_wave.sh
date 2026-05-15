#!/bin/bash
# ============================================================================
# QNAP Media Encode Wave Advance
# ============================================================================
# Purpose: Autonomously advance the media compression pipeline by one wave
#          (100 files) when all gates pass — replaces the flaky Claude MCP
#          scheduled-task daemon. Source of truth is the media repo at
#          ~/Development/Assistants/Media; this wrapper just dispatches to
#          the deployed runner on /share/Media/.media-tools.
# Schedule: Every 6 hours
# CRON: 0 */6 * * *
# ============================================================================

# Set HOME for root user (QNAP default when invoked by crond)
HOME=/root

# Dispatch to the deployed runner. The runner owns gates, locking, logging.
/share/Media/.media-tools/encode-wave-fire.sh
