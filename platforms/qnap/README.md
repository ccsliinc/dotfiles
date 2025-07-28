# QNAP NAS Platform Configuration

This directory contains QNAP NAS-specific configuration overrides and tools for QNAP systems running Linux.

## Directory Structure

```
qnap/
├── README.md           # This file
├── .aliases            # QNAP-specific alias overrides
├── .exports            # QNAP environment variables and PATH additions
├── .functions          # QNAP-specific function documentation
├── .profile            # QNAP-specific profile settings
├── bin/                # QNAP-specific binaries
│   └── gdrive          # Google Drive CLI tool
├── boot/               # Boot scripts
│   └── autorunmaster.sh
├── cron/               # Cron job scripts
│   └── nightly_docker.sh
└── scripts/            # QNAP-specific my- prefixed scripts
    ├── my-docker-check-image-latest    # Check for Docker image updates
    ├── my-docker-restart-all           # Restart Docker containers
    ├── my-docker-update                # Update Docker containers
    ├── my-qnap-clean-share             # Clean QNAP share directories
    ├── my-qnap-optimize-performance    # Optimize QNAP performance
    ├── my-qnap-remove-builtin          # Remove builtin QNAP packages
    └── my-qnap-system-report           # Generate system reports
```

## Platform-Specific Overrides

### Aliases (`.aliases`)

**System Command Overrides:**
- `grep='grep'` - Use standard grep (QNAP override)
- `which='which'` - Use standard which (QNAP version)
- `flushDNS` - QNAP-specific message (no standard DNS flush)

**File Creation Commands:**
- `make1mb/5mb/10mb` - Use `dd` command (QNAP doesn't have mkfile)

**Docker Integration:**
- `docker-cli` - Architecture-specific Docker CLI (ARM64 vs x64)

**QNAP-Specific Aliases:**
- `rclone-webgui` - Start rclone web interface with admin credentials
- `fix-nvidia-drivers` - Restart NVIDIA GPU drivers for Container Station

### Environment Variables (`.exports`)

- Comprehensive PATH setup including QNAP-specific directories
- Adds Container Station Docker CLI to PATH
- Sets up QNAP system paths: `/opt/bin`, `/opt/sbin`
- Architecture detection for proper binary selection

### Scripts (`scripts/`)

**Docker Management:**
- `my-docker-check-image-latest` - Check if Docker images have updates available
- `my-docker-restart-all` - Restart containers based on configuration file
- `my-docker-update` - Update individual Docker containers

**QNAP System Management:**
- `my-qnap-clean-share` - Clean system files from QNAP shares
- `my-qnap-optimize-performance` - Optimize QNAP performance settings
- `my-qnap-remove-builtin` - Remove unnecessary builtin QNAP packages
- `my-qnap-system-report` - Generate comprehensive system reports

## Usage Examples

### Docker Management
```bash
# Check for image updates
my-docker-check-image-latest pihole/pihole

# Restart all configured containers
my-docker-restart-all

# Update specific container
my-docker-update container-name
```

### QNAP System Management
```bash
# Clean share directories
my-qnap-clean-share

# Optimize system performance
my-qnap-optimize-performance

# Generate system report
my-qnap-system-report --output /share/reports/
```

### Docker CLI Usage
```bash
# Use architecture-appropriate Docker CLI
docker-cli ps
docker-cli images
```

### Services
```bash
# Start rclone web interface
rclone-webgui

# Fix NVIDIA drivers if needed
fix-nvidia-drivers
```

## Platform Requirements

- **OS**: QNAP QTS (Linux-based)
- **Architecture**: ARM64 or x64 (auto-detected)
- **Container Station**: For Docker functionality
- **Dependencies**: 
  - `jq` - For JSON processing in Docker scripts
  - `curl` - For API interactions
  - `rclone` - For cloud storage management

## Configuration Files

All configuration files follow the base → platform override pattern:

1. **Base loads first**: Establishes cross-platform defaults
2. **QNAP overrides**: This platform's files override base where needed
3. **Local overrides**: `~/.{aliases,exports,profile}.local` can override everything

### File Purposes

- **`.aliases`**: QNAP-specific command overrides and NAS shortcuts
- **`.exports`**: QNAP environment variables, PATH, and system integration
- **`.functions`**: QNAP-specific function documentation
- **`.profile`**: QNAP-specific shell profile settings and system setup

## QNAP-Specific Features

### Docker Integration
- Architecture-aware Docker CLI selection
- Container management and monitoring
- Automated update checking and container restart workflows

### System Optimization
- Performance tuning for NAS workloads
- Builtin package cleanup for more storage
- Share directory maintenance

### Hardware Integration
- NVIDIA GPU driver management for AI workloads
- System reporting with hardware details

## Docker Configuration

Scripts use `~/dockers.local` JSON configuration file:

```json
{
  "dockers": {
    "container1": {
      "name": "pihole",
      "update": true
    },
    "container2": {
      "name": "nextcloud", 
      "update": false
    }
  }
}
```

## Adding QNAP-Specific Tools

### New Scripts
Create executable scripts in `scripts/` with `my-qnap-` prefix:

```bash
#!/bin/bash
# Function: my-qnap-tool
# Purpose: QNAP-specific functionality
# Usage: my-qnap-tool [options]
# Platform: QNAP NAS (requires QTS)
# Dependencies: List required QNAP packages

my_qnap_tool() {
    # Implementation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    my_qnap_tool "$@"
fi
```

### New Aliases
Add to `.aliases` for QNAP-specific command overrides or shortcuts.

### Environment Variables
Add to `.exports` for QNAP-specific paths or system integration.

## Integration Notes

- Scripts are automatically available in PATH when QNAP is detected
- Architecture detection handles ARM64 vs x64 binaries automatically
- All tools follow the `my-` prefix convention for discoverability
- Use `my-` + TAB TAB to see all available QNAP-specific tools
- Docker tools integrate with Container Station and external Docker APIs
- System tools are designed for NAS-specific optimization and maintenance