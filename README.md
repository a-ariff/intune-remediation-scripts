# Microsoft Intune Remediation Scripts

[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://docs.microsoft.com/en-us/powershell/)
[![Intune](https://img.shields.io/badge/Microsoft_Intune-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)](https://intune.microsoft.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

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
│   ├── script-templates/
│   ├── json-configurations/
│   └── powershell-modules/
├── docs/
│   ├── deployment-guide.md
│   ├── script-development.md
│   ├── testing-procedures.md
│   └── troubleshooting.md
├── tests/
│   ├── unit-tests/
│   ├── integration-tests/
│   └── validation-scripts/
└── README.md
```

## Quick Start

### Prerequisites

- Microsoft Intune subscription with appropriate licensing
- Azure AD tenant with device management permissions
- PowerShell 5.1 or later (PowerShell 7.x recommended)
- Intune Administrator or Global Administrator role
- Windows 10/11 devices enrolled in Intune

### Deployment Steps

1. **Download Scripts**
   ```powershell
   git clone https://github.com/a-ariff/intune-remediation-scripts.git
   cd intune-remediation-scripts
   ```

2. **Review and Customize**
   ```powershell
   # Review detection script
   Get-Content detection-scripts/compliance/bitlocker-detection.ps1
   
   # Review remediation script
   Get-Content remediation-scripts/compliance/enable-bitlocker.ps1
   ```

3. **Deploy via Intune**
   - Navigate to Microsoft Endpoint Manager admin center
   - Go to **Devices** > **Scripts and remediations** > **Remediation**
   - Create new remediation package with detection and remediation scripts
   - Assign to appropriate device groups

## Script Categories

### Compliance & Security
- **BitLocker Encryption**: Detect and enable BitLocker on corporate devices
- **Windows Defender**: Ensure antivirus is enabled and updated
- **Firewall Configuration**: Validate and configure Windows Firewall
- **UAC Settings**: Maintain appropriate User Account Control levels
- **Certificate Management**: Validate and update expired certificates

### Performance & Maintenance
- **Disk Cleanup**: Remove temporary files and system cache
- **Startup Optimization**: Manage startup programs for better boot times
- **Memory Management**: Detect and resolve memory leaks
- **Registry Cleanup**: Safe registry maintenance and optimization
- **Service Management**: Ensure critical services are running properly

### Software Management
- **Application Installation**: Deploy required business applications
- **Update Management**: Automate software updates and patches
- **Bloatware Removal**: Remove unwanted pre-installed software
- **License Compliance**: Track and manage software licensing

### Network & Connectivity
- **DNS Configuration**: Validate and fix DNS settings
- **Proxy Settings**: Configure corporate proxy settings
- **VPN Connectivity**: Troubleshoot VPN connection issues
- **Network Adapter**: Reset and reconfigure network adapters

## Best Practices

### Script Development
- Always include proper error handling and logging
- Test scripts in a lab environment before production deployment
- Use PowerShell best practices and approved verbs
- Include detailed comments and documentation
- Implement rollback mechanisms where applicable

### Security Considerations
- Follow principle of least privilege
- Validate all user inputs and parameters
- Use secure coding practices
- Encrypt sensitive data in scripts
- Regular security reviews of all scripts

### Monitoring & Reporting
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

⚠️ **Important**: These scripts are provided as-is for educational and reference purposes. Always test thoroughly in a non-production environment before deploying to production systems. The authors are not responsible for any damage or issues that may arise from using these scripts.

## Tags

`intune` `powershell` `endpoint-management` `device-compliance` `remediation` `microsoft` `automation` `security` `windows` `mdm`
