# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a cross-platform dotfiles repository that provides shell configuration and system setup scripts for multiple platforms: macOS, Linux (GNU), Raspberry Pi, and QNAP NAS systems.

## Architecture

- **Bootstrap**: Main entry point via `setup/bootstrap.sh` - detects platform and launches interactive setup
- **Base Profile System**: Core shell configuration in `base/` directory
  - `base/.profile_interactive` - main interactive shell configuration
  - `base/core/.profile_os` - OS detection and platform-specific settings
  - `base/shared/bash_colors.sh` - color definitions for terminal output
- **Platform-Specific**: OS-specific configurations and scripts in `platforms/[platform]/`
  - `mac/` - macOS-specific scripts and configurations
  - `linux/` - Linux server configurations (formerly `gnu`)
  - `qnap/` - QNAP NAS-specific scripts and cron jobs
  - `raspi/` - Raspberry Pi configurations
- **Shell Files**: Root-level shell configuration files that get symlinked:
  - `.zshrc` - Uses Oh My Zsh with "maran" theme
  - `.bash_profile` - Bash login shell configuration
  - `.bashrc` - Bash interactive shell configuration

## Common Development Tasks

### Setup and Installation
```bash
# Run the main setup script
~/.dotfiles/setup/bootstrap.sh
```

### Platform Detection
The system uses OS detection through `base/core/.profile_os` with these supported platforms:
- `mac` - macOS systems
- `linux` - GNU/Linux systems
- `raspi` - Raspberry Pi systems
- `qnap` - QNAP NAS systems

### Shell Configuration
- All shells source from `$DOTFILESLOC/base/.profile_interactive`
- Color definitions are centralized in `base/shared/bash_colors.sh`
- Platform-specific customizations are loaded automatically based on OS detection

## Key Components

### Setup System
- Interactive setup with status checking for: platform detection, Oh My Zsh, dotfiles location, symlinks, shell type, and sudo configuration
- Platform-specific setup scripts in `setup/scripts/setup/setup.[platform].sh`

### Binary Tools
- Platform-specific binaries in `base/bin/` including gdrive clients and Docker CLI tools
- QNAP-specific binaries in `platforms/qnap/bin/`

### Scripts and Utilities
- System maintenance scripts in `platforms/[platform]/scripts/`
- Docker management utilities for QNAP in `platforms/qnap/scripts/`
- Backup and maintenance utilities in `base/scripts/`

## Working with This Repository

- Use `builtin cd` instead of `cd` when navigating directories
- The system expects symlinks from home directory to dotfiles for shell configuration
- All shell configurations ultimately source from the modular profile system
- Platform detection is automatic and configurations adjust accordingly