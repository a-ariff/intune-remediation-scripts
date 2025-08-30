# Microsoft Intune Remediation Scripts

[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://docs.microsoft.com/en-us/powershell/) [![Intune](https://img.shields.io/badge/Microsoft_Intune-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)](https://intune.microsoft.com/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT) [![GitHub stars](https://img.shields.io/github/stars/a-ariff/intune-remediation-scripts?style=for-the-badge&logo=github)](https://github.com/a-ariff/intune-remediation-scripts/stargazers) [![GitHub forks](https://img.shields.io/github/forks/a-ariff/intune-remediation-scripts?style=for-the-badge&logo=github)](https://github.com/a-ariff/intune-remediation-scripts/network) [![GitHub issues](https://img.shields.io/github/issues/a-ariff/intune-remediation-scripts?style=for-the-badge&logo=github)](https://github.com/a-ariff/intune-remediation-scripts/issues) [![GitHub last commit](https://img.shields.io/github/last-commit/a-ariff/intune-remediation-scripts?style=for-the-badge&logo=github)](https://github.com/a-ariff/intune-remediation-scripts/commits/main) [![Contributions welcome](https://img.shields.io/badge/Contributions-welcome-brightgreen.svg?style=for-the-badge)](https://github.com/a-ariff/intune-remediation-scripts/blob/main/CONTRIBUTING.md) [![Made with ❤️](https://img.shields.io/badge/Made%20with-❤️-red.svg?style=for-the-badge)](https://github.com/a-ariff)

## Build Status

[![PowerShell Lint](https://github.com/a-ariff/intune-remediation-scripts/actions/workflows/ps-lint.yml/badge.svg?branch=main)](https://github.com/a-ariff/intune-remediation-scripts/actions/workflows/ps-lint.yml) [![Link Check](https://github.com/a-ariff/intune-remediation-scripts/actions/workflows/link-check.yml/badge.svg?branch=main)](https://github.com/a-ariff/intune-remediation-scripts/actions/workflows/link-check.yml)

## Overview

A comprehensive collection of Microsoft Intune remediation scripts and configurations designed for enterprise endpoint management, device compliance enforcement, and automated system fixes. This repository provides production-ready PowerShell scripts that integrate seamlessly with Intune's remediation framework.

### Key Features

- **Device Compliance**: Automated scripts to detect and fix common compliance issues
- **Security Remediation**: Security-focused fixes for endpoint vulnerabilities  
- **Performance Optimization**: Scripts to optimize device performance and user experience
- **Modern PowerShell**: Supports -WhatIf and ShouldProcess for safe testing
- **Comprehensive Logging**: Standardized logging with Write-Information

## Quick Start

1. **Browse Examples**: Start with [`docs/examples/intune-import/`](docs/examples/intune-import/) for a complete detection/remediation pair
2. **Test Scripts**: Always run with `-WhatIf` parameter first to preview changes safely
3. **Deploy via Intune**: Follow the [deployment guide](docs/deployment-guide.md) for step-by-step Intune configuration

## Canonical Example

Here's a complete detection and remediation pair demonstrating proper structure:

### Detection Script (detect-example.ps1)
```powershell
[CmdletBinding()]
param()

try {
    $condition = Get-SomeCondition
    if ($condition) {
        Write-Information "Issue detected" -InformationAction Continue
        exit 1  # Issue found - remediation needed
    } else {
        Write-Information "No issues found" -InformationAction Continue
        exit 0  # Compliant - no remediation needed
    }
} catch {
    Write-Error "Detection failed: $_"
    exit 1
}
```

### Remediation Script (remediate-example.ps1)
```powershell
[CmdletBinding(SupportsShouldProcess=$true)]
param()

try {
    if ($PSCmdlet.ShouldProcess("System", "Apply Remediation")) {
        # Apply fix here
        Write-Information "Remediation applied successfully" -InformationAction Continue
        exit 0  # Success
    }
} catch {
    Write-Error "Remediation failed: $_"
    exit 1  # Failure
}
```

### Usage in Intune
1. Create new Remediation in Intune admin center
2. Upload detection script, set to run in system context
3. Upload remediation script, configure schedule
4. Assign to device groups and monitor results

## Directory Map

- **detection-scripts/**: Device and software compliance detection scripts
- **remediation-scripts/**: Corresponding remediation scripts for detected issues
- **security-management/**: Security baseline and vulnerability remediation tools
- **compliance-reporting/**: Compliance status reporting and analytics
- **browser-password-management/**: Browser security and password policy enforcement
- **device-lifecycle/**: Device provisioning, maintenance, and retirement scripts
- **graph-api-scripts/**: Microsoft Graph API integration and reporting tools
- **network-automation/**: Network connectivity and configuration management
- **performance-monitoring/**: System performance analysis and optimization
- **modern-automation/**: PowerShell 7 and cross-platform automation capabilities
- **docs/**: Comprehensive documentation and deployment guides
- **docs/examples/**: Sample implementations and import templates

## CI/Quality

Our continuous integration pipeline ensures code quality through:

- **PowerShell Script Analyzer**: Automated linting and best practice validation
- **Link Validation**: Automated checking of documentation links
- **Security Scanning**: CodeQL analysis for security vulnerabilities
- **Testing**: Automated validation of script syntax and functionality

All scripts follow PowerShell best practices:
- Support for `-WhatIf` and `ShouldProcess` where applicable
- Standardized error handling and logging
- Proper exit codes for Intune integration
- Security-conscious design (no Set-ExecutionPolicy usage)

## Contribution/Support

### Contributing
- 📖 Read our [Contributing Guidelines](CONTRIBUTING.md)
- 🐛 Report issues via [GitHub Issues](https://github.com/a-ariff/intune-remediation-scripts/issues)
- 💡 Submit feature requests and improvements
- 🔀 Create pull requests following our guidelines

### Support
- 📚 Browse our [comprehensive documentation](docs/)
- 🛠️ Check the [troubleshooting guide](docs/troubleshooting.md)
- 🔐 Review our [security policy](SECURITY.md)
- ⭐ Star this repo if you find it helpful!

### Community
- Follow [@a-ariff](https://github.com/a-ariff) for updates
- Join discussions in our [GitHub Discussions](https://github.com/a-ariff/intune-remediation-scripts/discussions)
- Share your use cases and improvements

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

**Made with ❤️ for the IT community**
