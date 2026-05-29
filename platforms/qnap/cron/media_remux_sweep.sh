#!/bin/bash
# ============================================================================
# QNAP Media Remux Sweep (MKV-convergence backstop)
# ============================================================================
# Purpose: Keep the library on the MKV standard. Normalizes any new non-MKV
#          keeper-codec arrivals (h264 under-band / hevc / av1) into MKV via
#          cheap stream-copy remux. Legacy codecs route to the encode lane,
#          not here. Source of truth is the media repo at
#          ~/Development/Assistants/Media; this wrapper dispatches to the
#          deployed gated runner on /share/Media/.media-tools.
# Schedule: Weekly, Sunday 05:00 (off-peak; encode wave runs every 6h, refetch
#           every 3h — Sunday 05:00 keeps the remux sweep clear of the 04:30
#           Wed integrity check and the nightly 03:00 incremental).
# CRON: 0 5 * * 0
# ============================================================================

# Set HOME for root user (QNAP default when invoked by crond)
HOME=/root

# Dispatch to the deployed runner. The runner owns gates, locking, logging,
# and self-skips if a batch is already running or there's no pending work.
/share/Media/.media-tools/remux-sweep-fire.sh
