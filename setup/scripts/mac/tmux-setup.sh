#!/bin/bash
# tmux-setup.sh - Install tmux plugin manager and plugins
# ============================================================================
# Run this once on a new machine after brew.sh installs tmux
# ============================================================================

set -euo pipefail

TPM_DIR="$HOME/.tmux/plugins/tpm"

echo "Setting up tmux plugin manager..."

# Clone TPM if not already present
if [[ -d "$TPM_DIR" ]]; then
    echo "TPM already installed at $TPM_DIR"
else
    echo "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "TPM installed!"
fi

echo ""
echo "Next steps:"
echo "  1. Start tmux: tmux"
echo "  2. Press: Ctrl+b then I (capital i) to install plugins"
echo "  3. Restart tmux or press: Ctrl+b then r to reload config"
echo ""
echo "Done!"
