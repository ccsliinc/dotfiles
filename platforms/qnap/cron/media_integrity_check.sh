#!/bin/bash
# ============================================================================
# QNAP Media Integrity (Bit-Rot) Check
# ============================================================================
# Purpose: Weekly BLAKE3 re-verify sweep over ~2% of the live media library
#          to detect silent disk corruption ("bit rot"). Picker is oldest-
#          first, so a full library pass completes in ~50 weeks while the
#          per-tick load stays cheap (~15 min for ~800 files).
# Schedule: Wednesday 04:00 — spread away from encode-cron (0 */6 * * *)
#           and refetch-cron, and well clear of the nightly backup window.
# CRON: 0 4 * * 3
# ============================================================================

# Set HOME for root user (QNAP default when invoked by crond)
HOME=/root

# Dispatch to the deployed runner on /share/Media/.media-tools (synced from
# the media repo). Runner owns gates, locking, logging.
/share/Media/.media-tools/integrity-cron.sh
