# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a cross-platform dotfiles repository that provides shell configuration and system setup scripts for multiple platforms: macOS, Linux (GNU), Raspberry Pi, and QNAP NAS systems.

## Architecture

- **Bootstrap**: Modern interactive setup via `setup/bootstrap.sh` with professional UI
- **Base System**: Core cross-platform configuration in `base/` directory
  - `base/.profile_interactive` - main interactive shell configuration
  - `base/core/.profile_os` - OS detection and platform-specific settings
  - `base/shared/bash_colors.sh` - modern color definitions and UI elements
  - `base/scripts/` - 20+ universal utility scripts with `my-` prefix
- **Platform-Specific**: OS-specific configurations and scripts in `platforms/[platform]/`
  - `mac/` - macOS-specific scripts and configurations
  - `linux/` - Linux server configurations
  - `qnap/` - QNAP NAS-specific scripts and cron jobs
  - `raspi/` - Raspberry Pi configurations
  - `_skeleton/` - Template system for adding new platforms
- **Shell Files**: Root-level shell configuration files that get symlinked:
  - `.zshrc` - Uses Oh My Zsh with "maran" theme
  - `.bash_profile` - Bash login shell configuration
  - `.bashrc` - Bash interactive shell configuration

## Common Development Tasks

### Setup and Installation
```bash
# Run the modern interactive setup script
~/.dotfiles/setup/bootstrap.sh
```

### Script Discovery
```bash
# List all available aliases with descriptions and examples
my-list-aliases

# List all available functions with usage information
my-list-functions
```

### Platform Detection
The system uses automatic OS detection with hierarchical configuration loading:
- **Base** → **Platform** → **Local** override pattern
- `mac` - macOS systems with Homebrew and development tools
- `linux` - GNU/Linux systems with server utilities
- `raspi` - Raspberry Pi with IoT and embedded tools
- `qnap` - QNAP NAS with Entware package management

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
- **Base Scripts**: 20+ universal utilities in `base/scripts/` (my-backup-wordpress, my-gen-cert, etc.)
- **Platform Scripts**: Platform-specific tools in `platforms/[platform]/scripts/`
  - Linux: Server management, MySQL, Nginx utilities
  - Mac: Homebrew management, Valet cleanup, system updates
  - QNAP: Docker management, system optimization, cleanup tools
  - Raspberry Pi: Kiosk setup, UniFi controller, system updates
- **Discovery System**: Use `my-list-aliases` and `my-list-functions` to explore available tools

## Working with This Repository

### Development Guidelines
- Use `builtin cd` instead of `cd` when navigating directories
- All scripts follow `my-` prefix naming convention for discoverability
- Include Purpose, Usage, and Example headers in all new scripts
- Follow hierarchical configuration: base → platform → local overrides

### Script Standards
- All scripts pass shellcheck validation
- Use proper quoting and error handling
- Include help text accessible via `--help` or `-h`
- Cross-platform compatibility when possible

### Configuration Loading
- Platform detection is automatic via OS detection
- Shell configurations source from modular profile system
- Symlinks from home directory enable dotfiles functionality
- Local overrides supported via `.local` files

### Adding New Platforms
1. Copy `platforms/_skeleton/` to `platforms/[newplatform]/`
2. Update platform detection in `base/core/.profile_os`
3. Create platform-specific setup script in `setup/scripts/setup/`
4. Add platform documentation to README files