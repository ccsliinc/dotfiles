# macOS Platform Configuration

This directory contains macOS-specific configuration overrides and tools for Apple macOS systems.

## Directory Structure

```
mac/
├── README.md           # This file
├── .aliases            # macOS-specific alias overrides
├── .exports            # macOS environment variables and PATH additions
├── .functions          # macOS-specific functions (primarily Finder integration)
├── .profile            # macOS-specific profile settings
├── scripts/            # macOS-specific my- prefixed scripts
│   ├── my-clean-php-logs        # Clean PHP-FPM logs
│   ├── my-destroy-valet-plus    # Remove Valet Plus development environment
│   └── my-update-mac            # Comprehensive macOS system update
└── streamdeck/         # Stream Deck automation scripts
    ├── _reference.sh
    ├── terminal_qnap_home.sh
    └── terminal_qnap_office.sh
```

## Platform-Specific Overrides

### Aliases (`.aliases`)

**File Listing Overrides:**
- `ls='ls -haFG'` - macOS uses `-G` instead of `--color=auto`
- `ll='ls -FGlAhp'` - macOS-specific detailed listing format
- `du1='du -d 1 -h'` - macOS uses `-d` instead of `--max-depth`

**System Command Overrides:**
- `which='type -a'` - macOS-specific executable finder
- `python='/usr/local/bin/python3'` - Use Homebrew Python

**macOS-Specific Aliases:**
- `f='open -a Finder ./'` - Open current directory in Finder
- `DT='tee ~/Desktop/terminalOut.txt'` - Pipe output to Desktop file
- `kill-barracuda` - Kill barracuda development processes

**macOS Functions:**
- `trash()` - Move files to Trash instead of permanent deletion
- `ql()` - Open files in QuickLook Preview

### Environment Variables (`.exports`)

- Adds `platforms/mac/scripts` to PATH for macOS-specific tools
- Adds Composer global binaries to PATH: `~/.composer/vendor/bin`
- Sets `BLOCKSIZE=1k` for consistent file size display

### Functions (`.functions`)

**Finder Integration:**
- `cdf()` - Change directory to frontmost Finder window location

### Scripts (`scripts/`)

**Development Environment:**
- `my-destroy-valet-plus` - Completely remove Laravel Valet Plus and dependencies
- `my-clean-php-logs` - Clean PHP-FPM logs (useful for cron)

**System Maintenance:**
- `my-update-mac` - Comprehensive system update including:
  - Homebrew packages and casks
  - npm global packages
  - Composer global packages
  - App Store applications (with mas)
  - Atom packages (if installed)
  - System backups to iCloud

## Usage Examples

### Development Environment Management
```bash
# Completely remove Valet Plus environment
my-destroy-valet-plus

# Clean PHP logs (good for daily cron)
my-clean-php-logs
```

### System Updates
```bash
# Force system update regardless of timing
my-update-mac --force

# Regular update (prompts if recent update exists)
my-update-mac
```

### Finder Integration
```bash
# Change to Finder's current directory
cdf

# Open current directory in Finder
f

# Move files to Trash instead of deleting
trash old-file.txt

# Preview file with QuickLook
ql document.pdf
```

### File Management
```bash
# Create test files (uses macOS mkfile)
make1mb    # Creates 1MB file
make5mb    # Creates 5MB file

# Pipe command output to Desktop
ls -la | DT
```

## Platform Requirements

- **OS**: macOS (tested on recent versions)
- **Package Manager**: Homebrew
- **Shell**: zsh (default) or bash
- **Optional Tools**: 
  - `mas` - Mac App Store CLI
  - `composer` - PHP dependency manager
  - `npm` - Node.js package manager
  - `apm` - Atom package manager

## Configuration Files

All configuration files follow the base → platform override pattern:

1. **Base loads first**: Establishes cross-platform defaults
2. **macOS overrides**: This platform's files override base where needed
3. **Local overrides**: `~/.{aliases,exports,profile}.local` can override everything

### File Purposes

- **`.aliases`**: macOS-specific command overrides and Finder integration
- **`.exports`**: macOS environment variables and PATH additions
- **`.functions`**: macOS-specific functions (primarily Finder integration)
- **`.profile`**: macOS-specific shell profile settings (auto-update disabled by default)

## macOS-Specific Features

### Finder Integration
- Seamless navigation between Terminal and Finder
- QuickLook preview integration
- Trash management instead of permanent deletion

### Development Tools
- Homebrew package management integration
- Laravel Valet Plus environment management
- PHP-FPM log management for local development

### System Integration
- iCloud backup integration for system settings
- App Store update management
- Comprehensive update workflow covering all package managers

## Adding macOS-Specific Tools

### New Scripts
Create executable scripts in `scripts/` with `my-` prefix:

```bash
#!/bin/bash
# Function: my-mac-tool
# Purpose: macOS-specific functionality
# Usage: my-mac-tool [options]
# Platform: macOS (requires Homebrew)
# Dependencies: List required tools/packages

my_mac_tool() {
    # Implementation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    my_mac_tool "$@"
fi
```

### New Aliases
Add to `.aliases` for macOS-specific command overrides or shortcuts.

### New Functions
Add to `.functions` for macOS-specific functions (especially Finder integration).

## Integration Notes

- Scripts are automatically available in PATH when macOS is detected
- Aliases override base definitions when running on macOS
- All tools follow the `my-` prefix convention for discoverability
- Use `my-` + TAB TAB to see all available macOS-specific tools
- Finder integration functions provide seamless Terminal/Finder workflow