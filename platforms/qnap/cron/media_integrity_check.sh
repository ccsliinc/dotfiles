#!/bin/bash
# ============================================================================
# QNAP Media Integrity (Bit-Rot) Check
# ============================================================================
# Purpose: Weekly BLAKE3 re-verify sweep over ~2% of the live media library
#          to detect silent disk corruption ("bit rot"). Picker is oldest-
#          first, so a full library pass completes in ~50 weeks while the
#          per-tick load stays cheap (~15 min for ~800 files).
# Schedule: Wednesday 04:30. The sweep now runs ALONGSIDE the encode wave by
#           design (no GPU use, read-only hashing, in-flight files excluded,
#           inventory.sqlite WAL + busy_timeout=30s, container nice'd via
#           --cpu-shares/--blkio-weight). The old `no_other_pipeline` gate was
#           removed — it made integrity never fire because encode runs
#           `0 */6 * * *` for 3-5h with no idle window. The 04:30 slot is just
#           a quiet-ish weekly cadence, not a collision dodge.
# CRON: 30 4 * * 3
# ============================================================================

# Set HOME for root user (QNAP default when invoked by crond)
HOME=/root

# Dispatch to the deployed runner on /share/Media/.media-tools (synced from
# the media repo). Runner owns gates, locking, logging.
/share/Media/.media-tools/integrity-cron.sh
