#!/bin/bash
# ============================================================================
# QNAP Nightly Docker Maintenance
# ============================================================================
# Purpose: Nightly Docker container restart for configured containers
# Schedule: Recommended to run at 2-3 AM daily via cron
# Usage: Add to crontab: 0 2 * * * /path/to/nightly_docker.sh
# ============================================================================

# Set HOME for root user (QNAP default)
HOME=/root

# Run docker restart for all configured containers
/share/CACHEDEV1_DATA/custom/custom/.dotfiles/platforms/qnap/scripts/my-docker-restart-all