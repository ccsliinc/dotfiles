# Platform-Specific Configurations

This directory contains platform-specific configuration overrides that extend the base configuration for different operating systems and environments.

## Available Platforms

- **[linux/](linux/)** - Linux (Debian/Ubuntu) systems with server tools and Magento development
- **[mac/](mac/)** - macOS systems with Homebrew, Finder integration, and development tools  
- **[qnap/](qnap/)** - QNAP NAS systems with Docker management and system optimization
- **[raspi/](raspi/)** - Raspberry Pi systems with ARM-specific tools and hardware integration
- **[_skeleton/](_skeleton/)** - Template for creating new platform configurations

## How Platform Override System Works

### Loading Hierarchy

1. **Base Configuration** (`../base/`) loads first with cross-platform defaults
2. **Platform Override** (`platforms/{OS}/`) overrides base settings for OS-specific behavior
3. **Local Override** (`~/.{aliases,exports,profile}.local`) allows personal customizations

### Example: `ls` Command Override

- **Base**: `alias ls='ls -haF --color=auto'` (Linux-style flags)
- **macOS Override**: `alias ls='ls -haFG'` (macOS uses `-G` instead of `--color=auto`)
- **Result**: Linux users get `--color=auto`, macOS users get `-G`

## Platform Structure

Each platform directory contains:

```
[platform]/
├── README.md           # Platform-specific documentation
├── .aliases            # Command overrides and platform-specific aliases
├── .exports            # Environment variables and PATH additions
├── .functions          # Function documentation (functions are now scripts)
├── .profile            # Platform-specific shell profile settings
└── scripts/            # Platform-specific my- prefixed executable scripts
```

## Creating a New Platform

### 1. Copy Skeleton Template
```bash
cp -r platforms/_skeleton platforms/new-platform
cd platforms/new-platform
```

### 2. Customize Configuration Files
```bash
# Edit each file to replace placeholders:
# - [PLATFORM NAME] -> Actual platform name
# - [platform] -> lowercase platform identifier
# - Add platform-specific overrides and tools
```

### 3. Add Platform Detection
Add the new platform to OS detection in `../base/core/.profile_os`:

```bash
# Add detection logic for new platform
if [[ "$OSTYPE" == "new-platform"* ]]; then
    export OS="new-platform"
fi
```

### 4. Create Platform Scripts
Add platform-specific tools in `scripts/` with `my-` prefix:

```bash
#!/bin/bash
# Function: my-platform-tool
# Purpose: Platform-specific functionality
# Usage: my-platform-tool [options]
# Platform: New Platform
# Dependencies: List requirements

my_platform_tool() {
    # Implementation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    my_platform_tool "$@"
fi
```

### 5. Test Integration
- Verify configuration loads correctly on target platform
- Test that overrides work as expected
- Ensure scripts are discoverable with `my-` + TAB TAB

## Common Override Patterns

### File Listing Commands
Different platforms use different flags:
```bash
# Base (Linux)
alias ls='ls -haF --color=auto'

# macOS override
alias ls='ls -haFG'

# Minimal system override
alias ls='ls -haF'
```

### File Creation Commands
Not all platforms have `mkfile`:
```bash
# Base (macOS)
alias make1mb='mkfile 1m ./1MB.dat'

# Linux override
alias make1mb='fallocate -l 1M ./1MB.dat || dd if=/dev/zero of=./1MB.dat bs=1M count=1'

# ARM/embedded override  
alias make1mb='dd if=/dev/zero of=./1MB.dat bs=1M count=1'
```

### System Commands
Platform-specific versions:
```bash
# Base
alias which='type -all'

# Some platforms override
alias which='which'
```

## Platform-Specific Features

### Linux (`linux/`)
- Server setup and management tools
- Magento development environment
- LEMP stack installation
- System service management

### macOS (`mac/`)
- Homebrew integration
- Finder integration with `cdf()`, `f`, `trash()`
- QuickLook preview with `ql()`
- Development environment management (Valet Plus)

### QNAP (`qnap/`)
- Docker container management
- NAS-specific system optimization
- Architecture-aware binary selection
- NVIDIA GPU driver management

### Raspberry Pi (`raspi/`)
- ARM architecture support
- Hardware configuration with `raspi-config`
- UniFi Controller installation
- Memory-optimized operations

## Script Naming Conventions

All platform-specific scripts use the `my-` prefix for discoverability:

- **Generic tools**: `my-extract`, `my-backup-wordpress`
- **Platform-specific**: `my-qnap-system-report`, `my-setup-unifi`
- **Platform prefix**: Use platform name for platform-specific tools

## Integration Notes

- Platform directories are automatically detected and loaded
- Scripts in `scripts/` are automatically added to PATH
- All configuration follows the base → platform → local override pattern
- Use `my-` + TAB TAB to discover available platform-specific tools
- Each platform README contains detailed usage and setup instructions

## Maintenance

- Keep platform overrides minimal - only override what's necessary
- Document all platform-specific behavior in README files
- Test changes on actual target platforms when possible
- Follow established patterns from existing platforms for consistency