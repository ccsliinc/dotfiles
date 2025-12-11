# Cross-Platform Dotfiles

A modern, comprehensive dotfiles system supporting macOS, Linux, Raspberry Pi, and QNAP NAS platforms with automated setup, script discovery, and hierarchical configuration management.

## Philosophy

This dotfiles system is designed around one core principle: **a familiar, consistent terminal experience across all your machines** - from your MacBook to your Linux servers to your QNAP NAS.

The architecture supports:
- **Hierarchical Configuration**: Base → Platform → Machine-level overrides
- **Deliberate Sourcing Order**: Every source statement is intentional, allowing you to define defaults at higher levels and override them at lower levels
- **Non-Interactive Shell Support**: Scripts, cron jobs, and SSH commands all get the same environment as interactive shells
- **Flexible Installation**: Install anywhere, not just `~/.dotfiles`

## Features

- 🚀 **Modern Interactive Setup** - Professional UI with progress tracking and system detection
- 🔧 **40+ Utility Scripts** - Organized tools for system management, development, and maintenance
- 🌐 **Cross-Platform Support** - Seamless operation across multiple operating systems
- 📋 **Script Discovery** - Built-in commands to explore available aliases and functions
- 🎨 **Modern Terminal UI** - Professional colors, formatting, and user experience
- 📚 **Comprehensive Documentation** - Detailed README files for all platforms and components

## Quick Start

### macOS
```bash
git clone https://github.com/ccsliinc/dotfiles.git ~/.dotfiles
~/.dotfiles/setup/bootstrap.sh
```

### Linux & Raspberry Pi
```bash
sudo apt update -y && sudo apt upgrade -y
sudo apt install git -y
git clone https://github.com/ccsliinc/dotfiles.git ~/.dotfiles
~/.dotfiles/setup/bootstrap.sh
```

### QNAP NAS
```bash
# Prerequisites: Install Entware via web interface
sudo /opt/bin/opkg update
sudo /opt/bin/opkg install git git-http
/opt/bin/git clone https://github.com/ccsliinc/dotfiles.git ~/.dotfiles
~/.dotfiles/setup/bootstrap.sh
```

## Script Discovery

Explore available tools with built-in discovery commands:

```bash
# List all aliases with examples and descriptions
my-list-aliases

# List all functions with usage information  
my-list-functions
```

## Architecture

The system uses a hierarchical configuration approach:

**Base** → **Platform** → **Local** overrides

```
Shell Startup Flow:
┌─────────────────────────────────────────────────────────────────────┐
│  .zshenv / .bashenv                                                 │
│  └── base/.env_common          # Sets DOTFILESLOC, loads exports    │
├─────────────────────────────────────────────────────────────────────┤
│  .zshrc / .bash_profile        # Interactive shells                 │
│  └── base/.profile_interactive                                      │
│      ├── base/.profile         # Core profile                       │
│      │   ├── base/core/.profile_os    # OS detection ($OS variable) │
│      │   ├── base/.functions          # Shell functions             │
│      │   └── base/.exports            # PATH, environment vars      │
│      │       └── platforms/$OS/.exports   # Platform additions      │
│      ├── base/.aliases                # Common aliases              │
│      │   └── platforms/$OS/.aliases       # Platform additions      │
│      └── platforms/$OS/.profile       # Platform-specific profile   │
└─────────────────────────────────────────────────────────────────────┘
```

### Directory Structure

- `base/` - Core cross-platform configuration and 20+ universal scripts
- `platforms/[os]/` - Platform-specific configurations and tools
- `setup/` - Modern interactive installation and setup system
- Root shell files (`.zshrc`, `.bashrc`, etc.) - Symlinked from home directory

### Environment Files

For non-interactive shells (scripts, cron, SSH commands):

| File | Shell | Purpose |
|------|-------|---------|
| `.zshenv` | zsh | Automatically sourced for ALL zsh invocations |
| `.bashenv` | bash | Sourced via `BASH_ENV` variable |
| `base/.env_common` | both | Shared logic for setting up environment |

### Custom Install Location

By default, dotfiles are expected at `~/.dotfiles`. To install elsewhere:

```bash
# Create ~/.dotfiles_location with your custom path
echo 'export DOTFILESLOC="/your/custom/path"' > ~/.dotfiles_location
```

## Platform-Specific Scripts

### Base Scripts (Universal)
- `my-backup-wordpress` - WordPress backup with versioning
- `my-gen-cert` - SSL certificate generation utility
- `my-compose-update` - Docker Compose service updates
- `my-extract` - Universal archive extraction
- `my-hosts-edit` - Hosts file management
- And 15+ more utilities...

### Linux Server Tools
- `my-setup-server-stack` - Complete LEMP stack installation
- `my-fix-permissions-magento` - Magento permission fixes
- `my-restart-nginx-varnish` - Service restart utilities
- `my-install-webmin` - Webmin administration panel setup

### macOS Development Tools  
- `my-update-mac` - System and Homebrew updates
- `my-destroy-valet-plus` - Laravel Valet cleanup
- `my-clean-php-logs` - PHP log management

### QNAP NAS Management
- `my-docker-update` - Container update automation
- `my-qnap-system-report` - System health reporting
- `my-qnap-optimize-performance` - Performance tuning
- `my-qnap-clean-share` - Storage cleanup utilities

### Raspberry Pi IoT Tools
- `my-setup-kiosk` - Kiosk mode configuration
- `my-setup-unifi` - UniFi controller installation
- `my-system-update` - Automated system maintenance

## Setup System Features

The modern bootstrap system provides:

- 📊 **System Information Display** - Hardware, OS, and environment details
- ✅ **Interactive Status Checks** - Verification of all components
- 🎯 **Guided Installation** - Step-by-step setup with progress tracking
- 🔧 **Automated Configuration** - Shell setup, symlinks, and permissions
- 🎨 **Professional UI** - Modern colors, icons, and formatting

## Development

### Adding New Scripts

1. Use the `my-` prefix for all new scripts
2. Include standard headers:
   ```bash
   #!/bin/bash
   # Purpose: Brief description of what the script does
   # Usage: my-script-name [options] <arguments>
   # Example: my-script-name --verbose /path/to/file
   ```
3. Ensure shellcheck compliance: `shellcheck your-script`
4. Test across platforms where applicable

### Contributing

1. Fork the repository
2. Create a feature branch
3. Follow existing code patterns and naming conventions
4. Update documentation as needed
5. Submit a pull request

### Platform Support

For detailed platform-specific information, see:
- `platforms/mac/README.md` - macOS development setup
- `platforms/linux/README.md` - Linux server configuration
- `platforms/qnap/README.md` - QNAP NAS management
- `platforms/raspi/README.md` - Raspberry Pi IoT setup

## Project Structure

```
~/.dotfiles/
├── base/                       # Core cross-platform configuration
│   ├── .env_common            # Shared environment setup (non-interactive)
│   ├── .profile               # Core profile (loads OS, functions, exports)
│   ├── .profile_interactive   # Interactive shell additions
│   ├── .aliases               # Common aliases
│   ├── .exports               # PATH, environment variables
│   ├── .functions             # Shell functions
│   ├── core/                  # Core modules
│   │   ├── .profile_os        # OS detection ($OS, $MODEL, $ARCH)
│   │   ├── .profile_motd      # Message of the day
│   │   └── .iterm2_shell_integration.zsh
│   ├── scripts/               # Universal utility scripts (20+)
│   ├── bin/                   # Binary tools (gdrive, docker-cli)
│   ├── shared/                # Shared resources
│   │   └── bash_colors.sh     # Color definitions and UI elements
│   └── vim/                   # Vim configuration
├── platforms/                  # Platform-specific overrides
│   ├── mac/                   # macOS (Homebrew, dev tools)
│   ├── linux/                 # Linux servers
│   ├── qnap/                  # QNAP NAS (Entware, Docker)
│   │   └── boot/              # Boot scripts (autorunmaster.sh)
│   ├── raspi/                 # Raspberry Pi (IoT, kiosk)
│   └── _skeleton/             # Template for new platforms
├── setup/                      # Installation system
│   ├── bootstrap.sh           # Main interactive setup
│   ├── menus/                 # Setup menu system
│   └── scripts/               # Setup utilities
│       ├── common/            # Cross-platform setup scripts
│       └── setup/             # Platform-specific setup
├── .zshrc                      # Zsh interactive config (symlinked)
├── .zshenv                     # Zsh environment (all shells)
├── .bash_profile               # Bash login config (symlinked)
├── .bashrc                     # Bash interactive config (symlinked)
└── .bashenv                    # Bash environment (via BASH_ENV)
```

---

**License**: MIT  
**Maintainer**: [@ccsliinc](https://github.com/ccsliinc)  
**Issues**: [GitHub Issues](https://github.com/ccsliinc/dotfiles/issues)