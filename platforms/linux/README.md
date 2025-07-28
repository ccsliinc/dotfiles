# Linux Platform Configuration

This directory contains Linux-specific configuration overrides and tools for Debian/Ubuntu-based systems.

## Directory Structure

```
linux/
├── README.md           # This file
├── .aliases            # Linux-specific alias overrides
├── .exports            # Linux environment variables and PATH additions
├── .functions          # Function documentation (functions are now scripts)
├── .profile            # Linux-specific profile settings
└── scripts/            # Linux-specific my- prefixed scripts
    ├── my-fix-permissions-magento    # Fix Magento file permissions
    ├── my-install-webmin            # Install Webmin admin interface
    ├── my-restart-nginx-varnish     # Restart web services
    ├── my-setup-mysql-secure        # Secure MySQL installation
    ├── my-setup-server-advanced     # Advanced server setup
    ├── my-setup-server-stack        # LEMP stack installation
    ├── my-update-clean              # System update and cleanup
    └── my-update-magento            # Magento update process
```

## Platform-Specific Overrides

### Aliases (`.aliases`)

**System Command Overrides:**
- `chkconfig='sudo sysv-rc-conf'` - Use modern service configuration
- `which='which'` - Use standard which command
- `flushDNS` - Linux-specific DNS restart commands

**File Creation Commands:**
- `make1mb/5mb/10mb` - Use `fallocate` or `dd` instead of macOS `mkfile`

**Linux-Specific Aliases:**
- `netstatt='netstat -tulpen'` - Enhanced network status with process info
- `gdrive='gdrive_linux_x86'` - Linux x86 Google Drive binary

### Environment Variables (`.exports`)

- Adds `platforms/linux/scripts` to PATH for Linux-specific tools

### Scripts (`scripts/`)

**Server Management:**
- `my-install-webmin` - Install Webmin web-based system administration
- `my-setup-server-stack` - Complete LEMP (Linux, Nginx, MySQL, PHP) stack setup
- `my-setup-server-advanced` - Advanced server configuration with Java/Elasticsearch
- `my-setup-mysql-secure` - Interactive MySQL security configuration

**Magento Development:**
- `my-fix-permissions-magento` - Fix file/directory permissions for Magento
- `my-restart-nginx-varnish` - Restart web services and clear Magento cache
- `my-update-magento` - Complete Magento update process with cache clearing

**System Maintenance:**
- `my-update-clean` - Update packages and remove unused dependencies

## Usage Examples

### Server Setup
```bash
# Install complete LEMP stack
my-setup-server-stack

# Configure MySQL security
my-setup-mysql-secure

# Install web admin interface
my-install-webmin
```

### Magento Development
```bash
# Fix file permissions for www-data user
my-fix-permissions-magento www-data

# Update Magento installation
my-update-magento

# Restart web services
my-restart-nginx-varnish
```

### System Maintenance
```bash
# Update system and clean up
my-update-clean

# Enhanced network monitoring
netstatt
```

## Platform Requirements

- **OS**: Debian/Ubuntu-based Linux distributions
- **Package Manager**: apt/apt-get
- **Init System**: systemd (for service management)
- **Shell**: bash or zsh

## Configuration Files

All configuration files follow the base → platform override pattern:

1. **Base loads first**: Establishes cross-platform defaults
2. **Linux overrides**: This platform's files override base where needed
3. **Local overrides**: `~/.{aliases,exports,profile}.local` can override everything

### File Purposes

- **`.aliases`**: Linux-specific command overrides and shortcuts
- **`.exports`**: Linux environment variables and PATH additions
- **`.functions`**: Documentation mapping old functions to new scripts
- **`.profile`**: Linux-specific shell profile settings

## Adding Linux-Specific Tools

### New Scripts
Create executable scripts in `scripts/` with `my-` prefix:

```bash
#!/bin/bash
# Function: my-linux-tool
# Purpose: Linux-specific functionality
# Usage: my-linux-tool [options]
# Platform: Linux (Debian/Ubuntu)
# Dependencies: List required packages

my_linux_tool() {
    # Implementation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    my_linux_tool "$@"
fi
```

### New Aliases
Add to `.aliases` for Linux-specific command overrides or shortcuts.

### New Environment Variables
Add to `.exports` for Linux-specific environment configuration.

## Integration Notes

- Scripts are automatically available in PATH when Linux is detected
- Aliases override base definitions when running on Linux
- All tools follow the `my-` prefix convention for discoverability
- Use `my-` + TAB TAB to see all available Linux-specific tools