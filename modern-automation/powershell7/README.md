# PowerShell 7 Support

This directory contains modern PowerShell 7+ compatible scripts and modules for cross-platform automation.

## Overview

The PowerShell 7 section provides enhanced automation capabilities using the latest PowerShell features, cross-platform compatibility, and improved performance for modern endpoint management.

## Directory Structure

```
powershell7/
├── core-modules/
│   ├── remediation-core/
│   ├── detection-core/
│   └── utilities/
├── cross-platform/
│   ├── windows/
│   ├── linux/
│   └── macos/
└── modern-syntax/
    ├── classes/
    ├── pipelines/
    └── advanced-functions/
```

## Features

### Core Modules
- Reusable PowerShell modules for common operations
- Standardized error handling and logging
- Modular architecture for easy maintenance
- Built-in parameter validation

### Cross-Platform Support
- Windows PowerShell compatibility layer
- Native Linux support through PowerShell Core
- macOS automation capabilities
- Platform-specific adaptations

### Modern Syntax
- PowerShell classes for object-oriented design
- Pipeline optimization techniques
- Advanced function patterns
- Modern error handling with try-catch-finally

## Key Improvements Over Windows PowerShell

### Performance
- Faster execution times
- Improved memory management
- Parallel processing capabilities
- Better resource utilization

### Language Features
- Enhanced cmdlet support
- Improved JSON handling
- Better REST API integration
- Enhanced string manipulation

### Compatibility
- Cross-platform execution
- Container support
- Cloud-native integration
- Modern authentication methods

## Prerequisites

- PowerShell 7.2 or later
- .NET 6.0 or later
- Platform-specific requirements (Windows/Linux/macOS)
- Appropriate execution policies configured

## Installation

### Windows
```powershell
winget install Microsoft.PowerShell
```

### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install -y powershell
```

### macOS
```bash
brew install --cask powershell
```

## Getting Started

1. Verify PowerShell 7 installation:
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. Import core modules:
   ```powershell
   Import-Module ./core-modules/remediation-core
   ```

3. Run compatibility checks:
   ```powershell
   Test-PlatformCompatibility
   ```

4. Execute cross-platform scripts:
   ```powershell
   ./cross-platform/universal-detection.ps1
   ```

## Migration Guide

For scripts migrating from Windows PowerShell 5.1 to PowerShell 7:

### Common Changes
- Update `#Requires` statements
- Replace deprecated cmdlets
- Update module imports
- Test cross-platform compatibility

### Best Practices
- Use explicit module version specifications
- Implement proper error handling
- Follow PowerShell approved verbs
- Use parameter sets for flexibility

## Configuration

See individual subdirectories for specific configuration requirements and platform-specific setup instructions.
