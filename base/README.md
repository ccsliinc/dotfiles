# Base Configuration

This directory contains the core shell configuration that applies to all platforms and users. The base configuration establishes defaults that can be overridden by platform-specific configurations.

## Directory Structure

```
base/
├── README.md                    # This file
├── .aliases                     # Base aliases (cross-platform defaults)
├── .exports                     # Base environment variables and PATH
├── .functions                   # Function mapping documentation (functions are now scripts)
├── .profile                     # Base profile settings
├── .profile_interactive         # Main interactive shell loader
├── bin/                         # Cross-platform binaries
├── core/                        # Core system files
│   ├── .iterm2_shell_integration.zsh
│   ├── .profile_motd           # Message of the day
│   └── .profile_os             # OS detection logic
├── scripts/                     # All my- prefixed functions as executable scripts
│   ├── my-extract              # Archive extraction utility
│   ├── my-gen-cert             # Certificate generation
│   ├── my-backup-wordpress     # WordPress backup utility
│   └── ... (24 total scripts)
├── shared/                      # Shared utilities
│   └── bash_colors.sh          # Color definitions
└── vim/                         # Vim configuration
    └── .vimrc
```

## How It Works

### Loading Hierarchy

The base configuration loads first and establishes defaults:

1. **`.profile_interactive`** - Main entry point loaded by shell configs
2. **`.profile`** - Basic profile settings 
3. **`.exports`** - Environment variables and PATH setup
4. **`.aliases`** - Cross-platform alias definitions
5. **`.functions`** - Function mapping documentation (actual functions are now scripts)

### Platform Override System

Base provides sensible defaults that work across platforms. Platform-specific configurations in `platforms/{OS}/` can override these defaults:

- **Base alias**: `alias ls='ls -haF --color=auto'` (Linux format)
- **macOS override**: `alias ls='ls -haFG'` (macOS doesn't use --color)
- **Result**: macOS users get the macOS-compatible version

### Script System

All functions have been converted to individual `my-` prefixed scripts in `base/scripts/`:

- **Discoverable**: Type `my-` + TAB TAB to see all available functions
- **Self-contained**: Each script has proper headers, help, and error handling
- **Executable**: Available in PATH for all platforms

### Configuration Files

- **`.aliases`**: Cross-platform command shortcuts and function definitions
- **`.exports`**: Environment variables, PATH configuration, and system settings
- **`.functions`**: Documentation mapping old functions to new my- scripts
- **`.profile`**: Basic shell profile settings
- **`.profile_interactive`**: Main loader that sources all configurations

## Adding New Functionality

### New Aliases
Add to `base/.aliases` if cross-platform, or to `platforms/{OS}/.aliases` if OS-specific.

### New Scripts/Functions
Create new executable script in `base/scripts/` with `my-` prefix:

```bash
#!/bin/bash
# Function: my-new-tool
# Purpose: Description of what this does
# Usage: my-new-tool [options]
# Platform: All (or specify specific platforms)
# Dependencies: List required commands

my_new_tool() {
    # Implementation here
}

# Execute if called directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    my_new_tool "$@"
fi
```

### New Environment Variables
Add to `base/.exports` or platform-specific `.exports` file.

## File Loading Order

1. Shell config (`.zshrc`, `.bash_profile`, etc.) loads `base/.profile_interactive`
2. `base/.profile_interactive` loads:
   - `base/.profile`
   - `base/.exports` 
   - `base/.aliases`
   - Platform-specific overrides from `platforms/{OS}/`
   - Local overrides from `~/.{aliases,exports,profile}.local`

## Local Customization

Users can create local override files in their home directory:
- `~/.aliases.local` - Personal aliases
- `~/.exports.local` - Personal environment variables  
- `~/.profile.local` - Personal profile settings
- `~/.functions.local` - Personal functions

These files are sourced last and can override any base or platform settings.