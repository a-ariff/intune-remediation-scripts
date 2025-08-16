# Microsoft Intune Remediation Scripts

> **Demo Update**: This file has been edited as part of a GitHub automation demonstration.

[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://docs.microsoft.com/en-us/powershell/) [![Intune](https://img.shields.io/badge/Microsoft_Intune-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)](https://intune.microsoft.com/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

## Build Status

[![PowerShell Lint](https://github.com/a-ariff/intune-remediation-scripts/actions/workflows/ps-lint.yml/badge.svg?branch=main)](https://github.com/a-ariff/intune-remediation-scripts/actions/workflows/ps-lint.yml)

## Overview

A comprehensive collection of Microsoft Intune remediation scripts and configurations designed for enterprise endpoint management, device compliance enforcement, and automated system fixes. This repository provides production-ready PowerShell scripts that integrate seamlessly with Intune's remediation framework.

### Key Features

- **Device Compliance**: Automated scripts to detect and fix common compliance issues
- **Security Remediation**: Security-focused fixes for endpoint vulnerabilities
- **Performance Optimization**: Scripts to optimize device performance and user experience
- **Software Management**: Application installation, updates, and configuration management
- **Registry Fixes**: Safe registry modifications for common Windows issues
- **Network Troubleshooting**: Connectivity and network configuration remediation
- **User Experience**: Scripts to improve and standardize user environments

## Repository Structure

```
intune-remediation-scripts/
├── detection-scripts/
│   ├── compliance/
│   │   ├── bitlocker-detection.ps1
│   │   ├── defender-status-check.ps1
│   │   └── firewall-status-detection.ps1
│   ├── performance/
│   │   ├── disk-space-check.ps1
│   │   ├── memory-usage-detection.ps1
│   │   └── startup-programs-check.ps1
│   ├── software/
│   │   ├── outdated-software-detection.ps1
│   │   ├── required-apps-check.ps1
│   │   └── bloatware-detection.ps1
│   └── security/
│       ├── uac-status-check.ps1
│       ├── windows-update-detection.ps1
│       └── certificate-validation.ps1
├── remediation-scripts/
│   ├── compliance/
│   │   ├── enable-bitlocker.ps1
│   │   ├── configure-defender.ps1
│   │   └── enable-firewall.ps1
│   ├── performance/
│   │   ├── cleanup-temp-files.ps1
│   │   ├── optimize-startup.ps1
│   │   └── defragment-drives.ps1
│   ├── software/
│   │   ├── install-required-apps.ps1
│   │   ├── update-software.ps1
│   │   └── remove-bloatware.ps1
│   └── security/
│       ├── configure-uac.ps1
│       ├── install-windows-updates.ps1
│       └── update-certificates.ps1
├── configuration-profiles/
│   ├── device-compliance/
│   ├── app-protection/
│   ├── conditional-access/
│   └── security-baselines/
├── templates/
│   ├── detection-template.ps1
│   ├── remediation-template.ps1
│   └── configuration-template.json
├── tests/
│   ├── validation-scripts/
│   ├── unit-tests/
│   └── integration-tests/
├── docs/
│   ├── deployment-guide.md
│   ├── script-development.md
│   ├── testing-procedures.md
│   └── troubleshooting.md
├── examples/
│   ├── basic-scenarios/
│   ├── advanced-configurations/
│   └── custom-implementations/
├── utilities/
│   ├── logging/
│   ├── error-handling/
│   └── reporting/
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Quick Start

### Prerequisites

- Microsoft Intune subscription
- Windows 10/11 devices enrolled in Intune
- PowerShell 5.1 or later
- Administrative privileges for script deployment
- Understanding of Intune remediation framework

### Basic Usage

1. Clone the repository:

```powershell
git clone https://github.com/a-ariff/intune-remediation-scripts.git
cd intune-remediation-scripts
```

2. Select appropriate scripts:
   - Browse the `detection-scripts/` folder for detection logic
   - Find corresponding remediation in `remediation-scripts/`
   - Review script documentation and parameters

3. Test locally (optional but recommended):

```powershell
# Test detection script
.\detection-scripts\compliance\bitlocker-detection.ps1

# Test remediation script (with caution)
.\remediation-scripts\compliance\enable-bitlocker.ps1
```

4. Deploy via Intune:
   - Upload detection and remediation scripts to Intune
   - Configure assignment groups and settings
   - Monitor execution and results

## Script Categories

### 🔒 Compliance & Security

| Script | Detection | Remediation | Description |
|--------|-----------|-------------|--------------|
| **BitLocker** | `bitlocker-detection.ps1` | `enable-bitlocker.ps1` | Ensures BitLocker encryption is enabled |
| **Windows Defender** | `defender-status-check.ps1` | `configure-defender.ps1` | Configures and enables Windows Defender |
| **Windows Firewall** | `firewall-status-detection.ps1` | `enable-firewall.ps1` | Ensures Windows Firewall is properly configured |
| **UAC Settings** | `uac-status-check.ps1` | `configure-uac.ps1` | Configures User Account Control settings |
| **Windows Updates** | `windows-update-detection.ps1` | `install-windows-updates.ps1` | Manages Windows Update installation |
| **Certificate Validation** | `certificate-validation.ps1` | `update-certificates.ps1` | Validates and updates system certificates |

### ⚡ Performance Optimization

| Script | Detection | Remediation | Description |
|--------|-----------|-------------|--------------|
| **Disk Space** | `disk-space-check.ps1` | `cleanup-temp-files.ps1` | Monitors and cleans up disk space |
| **Memory Usage** | `memory-usage-detection.ps1` | `optimize-memory.ps1` | Detects and optimizes memory usage |
| **Startup Programs** | `startup-programs-check.ps1` | `optimize-startup.ps1` | Manages startup program configuration |
| **Disk Defragmentation** | `fragmentation-check.ps1` | `defragment-drives.ps1` | Schedules and performs disk defragmentation |

### 📦 Software Management

| Script | Detection | Remediation | Description |
|--------|-----------|-------------|--------------|
| **Required Applications** | `required-apps-check.ps1` | `install-required-apps.ps1` | Ensures critical applications are installed |
| **Software Updates** | `outdated-software-detection.ps1` | `update-software.ps1` | Detects and updates outdated software |
| **Bloatware Removal** | `bloatware-detection.ps1` | `remove-bloatware.ps1` | Identifies and removes unwanted software |

## Configuration

### Script Parameters

Most scripts support customizable parameters for different environments:

```powershell
# Example: BitLocker detection with custom parameters
.\detection-scripts\compliance\bitlocker-detection.ps1 -CheckAllDrives $true -RequireTPM $false

# Example: Disk cleanup with size threshold
.\remediation-scripts\performance\cleanup-temp-files.ps1 -ThresholdGB 10 -IncludeRecycleBin $true
```

### Environment Variables

Set common configuration through environment variables:

```powershell
# Set logging level
$env:INTUNE_SCRIPT_LOG_LEVEL = "Verbose"

# Set custom log path
$env:INTUNE_SCRIPT_LOG_PATH = "C:\Logs\IntuneRemediation"

# Enable detailed reporting
$env:INTUNE_SCRIPT_DETAILED_REPORTING = "true"
```

## Deployment Guide

### Intune Configuration

1. **Navigate to Intune Admin Center**
   - Go to Devices > Scripts and remediations > Remediations
   - Click "Create" to add a new remediation

2. **Upload Scripts**
   - Upload the detection PowerShell script
   - Upload the corresponding remediation script
   - Configure script settings and parameters

3. **Assignment Configuration**
   - Select target device groups
   - Set execution schedule (daily/weekly)
   - Configure retry and timeout settings

4. **Monitoring Setup**
   - Enable detailed logging
   - Configure success/failure notifications
   - Set up custom reporting if needed

### Best Practices

#### Script Development

- Follow PowerShell best practices and coding standards
- Implement comprehensive error handling and logging
- Use parameter validation and input sanitization
- Test thoroughly in isolated environments before deployment
- Document all parameters, return codes, and side effects

#### Security Considerations

- Run scripts with minimum required privileges
- Validate all user inputs and parameters
- Use secure coding practices
- Encrypt sensitive data in scripts
- Regular security reviews of all scripts

#### Monitoring & Reporting

- Implement comprehensive logging
- Use Intune reporting for success/failure tracking
- Set up alerts for critical remediation failures
- Regular review of remediation effectiveness

## Testing

### Local Testing

```powershell
# Run detection script locally
.\detection-scripts\compliance\bitlocker-detection.ps1

# Test remediation script (with appropriate permissions)
.\remediation-scripts\compliance\enable-bitlocker.ps1
```

### Validation Framework

```powershell
# Run validation tests
.\tests\validation-scripts\Invoke-ScriptValidation.ps1 -ScriptPath "detection-scripts\compliance"
```

## Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code standards and review process
- Testing requirements
- Documentation standards
- Security considerations

## Documentation

- [Deployment Guide](docs/deployment-guide.md) - Step-by-step deployment instructions
- [Script Development](docs/script-development.md) - Guidelines for creating new scripts
- [Testing Procedures](docs/testing-procedures.md) - Comprehensive testing methodology
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions

## Support

For questions, issues, or feature requests:

- Create an [issue](https://github.com/a-ariff/intune-remediation-scripts/issues)
- Check the [documentation](docs/)
- Review [Microsoft Intune documentation](https://docs.microsoft.com/en-us/mem/intune/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

⚠️**Important**: These scripts are provided as-is for educational and reference purposes. Always test thoroughly in a non-production environment before deploying to production systems. The authors are not responsible for any damage or issues that may arise from using these scripts.

## Tags

`intune` `powershell` `endpoint-management` `device-compliance` `remediation` `microsoft` `automation` `security` `windows` `mdm`
