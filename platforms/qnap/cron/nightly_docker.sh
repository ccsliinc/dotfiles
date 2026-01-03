#!/bin/bash
# ============================================================================
# QNAP Nightly Docker Maintenance (REFERENCE ONLY)
# ============================================================================
# Purpose: Nightly Docker container restart for configured containers
# Schedule: Disabled - kept for reference
# CRON: DISABLED
# ============================================================================
# Note: This script is no longer used but kept for reference.
# It was previously used to restart all Docker containers nightly.
# ============================================================================

# Set HOME for root user (QNAP default)
HOME=/root

# Run docker restart for all configured containers
# Uses DOTFILESLOC from environment or falls back to standard location
DOTFILESLOC="${DOTFILESLOC:-$HOME/.dotfiles}"
"$DOTFILESLOC/platforms/qnap/scripts/my-docker-restart-all"