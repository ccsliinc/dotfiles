#!/bin/bash
# ============================================================================
# QNAP Nightly Docker Backup
# ============================================================================
# Purpose: Nightly Docker container configuration backup to Restic
# Schedule: Daily at 4:00 AM
# CRON: 0 4 * * *
# ============================================================================

# Set HOME for root user (QNAP default)
HOME=/root

# Run docker backup script
/share/Container/my-docker/backup/scripts/backup-docker-containers.sh