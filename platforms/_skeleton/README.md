# [PLATFORM NAME] Platform Configuration

This directory contains [PLATFORM NAME]-specific configuration overrides and tools.

## Directory Structure

```
[platform]/
├── README.md           # This file
├── .aliases            # Platform-specific alias overrides
├── .exports            # Platform environment variables and PATH additions
├── .functions          # Platform-specific function documentation
├── .profile            # Platform-specific profile settings
└── scripts/            # Platform-specific my- prefixed scripts
    └── my-[platform]-example    # Example platform-specific script
```

## Platform-Specific Overrides

### Aliases (`.aliases`)

**System Command Overrides:**
- Override base commands that have different flags/behavior on this platform
- Example: `ls`, `du`, `which`, `make*` commands

**Platform-Specific Aliases:**
- Add shortcuts and tools specific to this platform
- Use descriptive names that indicate the platform when relevant

### Environment Variables (`.exports`)

- Add `platforms/[platform]/scripts` to PATH for platform-specific tools
- Set platform-specific environment variables
- Configure paths for platform-specific binaries or libraries

### Scripts (`scripts/`)

**Platform Management:**
- System configuration and setup scripts
- Platform-specific maintenance tools
- Service management utilities

## Usage Examples

### Platform Setup
```bash
# Example platform-specific commands
my-[platform]-setup
my-[platform]-configure
```

### Platform Maintenance
```bash
# Platform updates and maintenance
my-[platform]-update
my-[platform]-cleanup
```

## Platform Requirements

- **OS**: [Operating System Requirements]
- **Architecture**: [Architecture Requirements]
- **Package Manager**: [Package Manager Used]
- **Dependencies**: 
  - List required tools/packages
  - Version requirements if any

## Configuration Files

All configuration files follow the base → platform override pattern:

1. **Base loads first**: Establishes cross-platform defaults
2. **Platform overrides**: This platform's files override base where needed
3. **Local overrides**: `~/.{aliases,exports,profile}.local` can override everything

### File Purposes

- **`.aliases`**: Platform-specific command overrides and shortcuts
- **`.exports`**: Platform environment variables and PATH additions
- **`.functions`**: Platform-specific function documentation
- **`.profile`**: Platform-specific shell profile settings

## Platform-Specific Features

### Key Capabilities
- List the main platform-specific features
- Explain unique aspects of this platform
- Document integration points with system services

### Hardware/Software Integration
- Platform-specific hardware considerations
- Software stack integration notes
- Performance characteristics

## Adding Platform-Specific Tools

### New Scripts
Create executable scripts in `scripts/` with `my-` prefix:

```bash
#!/bin/bash
# Function: my-[platform]-tool
# Purpose: Platform-specific functionality
# Usage: my-[platform]-tool [options]
# Platform: [Platform Name] ([requirements])
# Dependencies: List required tools/packages

my_[platform]_tool() {
    # Implementation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    my_[platform]_tool "$@"
fi
```

### New Aliases
Add to `.aliases` for platform-specific command overrides or shortcuts.

### New Environment Variables
Add to `.exports` for platform-specific environment configuration.

## Setup Instructions

### 1. Copy Skeleton
```bash
cp -r platforms/_skeleton platforms/[new-platform]
cd platforms/[new-platform]
```

### 2. Customize README
- Replace `[PLATFORM NAME]` with actual platform name
- Replace `[platform]` with lowercase platform identifier
- Update requirements and features sections

### 3. Create Configuration Files
```bash
# Create the four required configuration files
touch .aliases .exports .functions .profile
```

### 4. Add Platform Detection
Add the new platform to the OS detection logic in `base/core/.profile_os`.

### 5. Test Integration
- Verify files load correctly on the target platform
- Test that platform-specific overrides work as expected
- Ensure scripts are available in PATH

## Integration Notes

- Scripts are automatically available in PATH when platform is detected
- Aliases override base definitions when running on this platform
- All tools follow the `my-` prefix convention for discoverability
- Use `my-` + TAB TAB to see all available platform-specific tools
- Follow established patterns from existing platforms for consistency

## Template Checklist

When setting up a new platform:

- [ ] Copy skeleton directory
- [ ] Customize README.md with platform details
- [ ] Create `.aliases` with platform-specific overrides
- [ ] Create `.exports` with PATH and environment variables
- [ ] Create `.functions` with function documentation
- [ ] Create `.profile` with platform-specific profile settings
- [ ] Add platform detection to `base/core/.profile_os`
- [ ] Create initial `my-[platform]-*` scripts in `scripts/`
- [ ] Test loading and functionality on target platform
- [ ] Document platform-specific requirements and features