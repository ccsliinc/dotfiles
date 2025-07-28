# Raspberry Pi Platform Configuration

This directory contains Raspberry Pi-specific configuration overrides and tools for Raspberry Pi OS (Debian-based ARM systems).

## Directory Structure

```
raspi/
├── README.md           # This file
├── .aliases            # Raspberry Pi-specific alias overrides
├── .exports            # Raspberry Pi environment variables and PATH additions
├── .functions          # Raspberry Pi-specific function documentation
├── .profile            # Raspberry Pi-specific profile settings
└── scripts/            # Raspberry Pi-specific my- prefixed scripts
    ├── my-setup-kiosk      # Configure Raspberry Pi kiosk mode
    ├── my-setup-unifi      # Install UniFi Controller
    └── my-system-update    # Comprehensive Raspberry Pi system update
```

## Platform-Specific Overrides

### Aliases (`.aliases`)

**File Creation Commands:**
- `make1mb/5mb/10mb` - Use `dd` command (ARM systems don't have mkfile)

**DNS Management:**
- `flushDNS` - Raspberry Pi-specific network service restart

**Raspberry Pi-Specific Aliases:**
- `raspi-setup='sudo raspi-config'` - Open Raspberry Pi configuration tool
- `raspi-update` - Comprehensive system update in screen session

### Environment Variables (`.exports`)

- Adds `platforms/raspi/scripts` to PATH for Raspberry Pi-specific tools
- ARM-specific environment configuration

### Scripts (`scripts/`)

**System Setup:**
- `my-setup-kiosk` - Configure Raspberry Pi for kiosk/display mode
- `my-setup-unifi` - Install Ubiquiti UniFi Controller
- `my-system-update` - Comprehensive system update with health checks

## Usage Examples

### System Configuration
```bash
# Open Raspberry Pi configuration tool
raspi-setup

# Configure as kiosk system
my-setup-kiosk
```

### Network Services
```bash
# Install UniFi Controller
my-setup-unifi

# Check UniFi service status
sudo systemctl status unifi
```

### System Maintenance
```bash
# Comprehensive system update
my-system-update

# Quick update in screen session
raspi-update
```

### File Management
```bash
# Create test files using dd
make1mb    # Creates 1MB file with dd
make5mb    # Creates 5MB file with dd
```

## Platform Requirements

- **OS**: Raspberry Pi OS (Debian-based)
- **Architecture**: ARM (armv7l, arm64)
- **Hardware**: Raspberry Pi (all models)
- **Dependencies**:
  - `raspi-config` - Raspberry Pi configuration tool
  - `systemctl` - System service management
  - `java8` - For UniFi Controller installation

## Configuration Files

All configuration files follow the base → platform override pattern:

1. **Base loads first**: Establishes cross-platform defaults
2. **Raspberry Pi overrides**: This platform's files override base where needed
3. **Local overrides**: `~/.{aliases,exports,profile}.local` can override everything

### File Purposes

- **`.aliases`**: Raspberry Pi-specific command overrides and shortcuts
- **`.exports`**: Raspberry Pi environment variables and PATH additions
- **`.functions`**: Raspberry Pi-specific function documentation
- **`.profile`**: Raspberry Pi-specific shell profile settings

## Raspberry Pi-Specific Features

### Hardware Configuration
- Easy access to `raspi-config` for hardware setup
- Kiosk mode configuration for display applications
- ARM-specific optimizations

### Network Services
- UniFi Controller installation and management
- Network service integration with Raspberry Pi networking

### System Optimization
- ARM-specific file operations using `dd`
- Memory and performance considerations for limited hardware
- Comprehensive update process including distribution upgrades

## UniFi Controller Setup

The `my-setup-unifi` script provides complete UniFi Controller installation:

1. Installs Java 8 runtime
2. Adds Ubiquiti repository
3. Installs UniFi Controller
4. Configures system services
5. Provides access information

Access controller at: `https://YOUR_PI_IP:8443`

## Adding Raspberry Pi-Specific Tools

### New Scripts
Create executable scripts in `scripts/` with `my-` prefix:

```bash
#!/bin/bash
# Function: my-raspi-tool
# Purpose: Raspberry Pi-specific functionality
# Usage: my-raspi-tool [options]
# Platform: Raspberry Pi (ARM-based)
# Dependencies: List required packages

my_raspi_tool() {
    # Implementation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    my_raspi_tool "$@"
fi
```

### New Aliases
Add to `.aliases` for Raspberry Pi-specific command overrides or shortcuts.

### Hardware Integration
Consider ARM architecture limitations and memory constraints when developing tools.

## Performance Considerations

### Memory Management
- Raspberry Pi has limited RAM - scripts should be memory-efficient
- Use `screen` for long-running operations to prevent SSH disconnection
- Consider swap configuration for memory-intensive operations

### Storage
- SD card wear leveling - minimize unnecessary writes
- Use appropriate file creation methods (`dd` vs `fallocate`)
- Regular system cleanup to preserve storage space

### Network
- Consider bandwidth limitations for update operations
- Optimize for intermittent connectivity scenarios

## Integration Notes

- Scripts are automatically available in PATH when Raspberry Pi is detected
- Architecture detection handles ARM-specific requirements
- All tools follow the `my-` prefix convention for discoverability
- Use `my-` + TAB TAB to see all available Raspberry Pi-specific tools
- System updates run in screen sessions to handle network interruptions
- Hardware configuration tools integrate with `raspi-config` system