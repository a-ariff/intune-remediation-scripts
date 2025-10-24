<div align="center">

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   ██╗███╗   ██╗████████╗██╗   ██╗███╗   ██╗███████╗                          ║
║   ██║████╗  ██║╚══██╔══╝██║   ██║████╗  ██║██╔════╝                          ║
║   ██║██╔██╗ ██║   ██║   ██║   ██║██╔██╗ ██║█████╗                            ║
║   ██║██║╚██╗██║   ██║   ██║   ██║██║╚██╗██║██╔══╝                            ║
║   ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚████║███████╗                          ║
║   ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚══════╝                          ║
║                                                                               ║
║              REMEDIATION SCRIPTS COLLECTION                                   ║
║           Enterprise-Grade Endpoint Management                                ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

# Microsoft Intune Remediation Scripts

### 🚀 Production-Ready PowerShell Scripts for Enterprise Endpoint Management

[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://docs.microsoft.com/en-us/powershell/) [![Intune](https://img.shields.io/badge/Microsoft_Intune-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)](https://intune.microsoft.com/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT) [![GitHub stars](https://img.shields.io/github/stars/a-ariff/intune-remediation-scripts?style=for-the-badge&logo=github)](https://github.com/a-ariff/intune-remediation-scripts/stargazers) [![GitHub forks](https://img.shields.io/github/forks/a-ariff/intune-remediation-scripts?style=for-the-badge&logo=github)](https://github.com/a-ariff/intune-remediation-scripts/network) [![GitHub issues](https://img.shields.io/github/issues/a-ariff/intune-remediation-scripts?style=for-the-badge&logo=github)](https://github.com/a-ariff/intune-remediation-scripts/issues) [![GitHub last commit](https://img.shields.io/github/last-commit/a-ariff/intune-remediation-scripts?style=for-the-badge&logo=github)](https://github.com/a-ariff/intune-remediation-scripts/commits/main) [![Contributions welcome](https://img.shields.io/badge/Contributions-welcome-brightgreen.svg?style=for-the-badge)](https://github.com/a-ariff/intune-remediation-scripts/blob/main/CONTRIBUTING.md) [![Made with ❤️](https://img.shields.io/badge/Made%20with-❤️-red.svg?style=for-the-badge)](https://github.com/a-ariff)

</div>

## Build Status

[![PowerShell Lint](https://github.com/a-ariff/intune-remediation-scripts/actions/workflows/ps-lint.yml/badge.svg?branch=main)](https://github.com/a-ariff/intune-remediation-scripts/actions/workflows/ps-lint.yml) [![Link Check](https://github.com/a-ariff/intune-remediation-scripts/actions/workflows/link-check.yml/badge.svg?branch=main)](https://github.com/a-ariff/intune-remediation-scripts/actions/workflows/link-check.yml)

## 📋 Table of Contents

- [Overview](#overview)
- [Why Use This Repository?](#why-use-this-repository)
- [Popular Scripts](#popular-scripts)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Canonical Example](#canonical-example)
- [Directory Map](#directory-map)
- [CI/Quality](#ciquality)
- [FAQ](#faq)
- [Contribution/Support](#contributionsupport)

## Overview

A comprehensive collection of Microsoft Intune remediation scripts and configurations designed for enterprise endpoint management, device compliance enforcement, and automated system fixes. This repository provides production-ready PowerShell scripts that integrate seamlessly with Intune's remediation framework.

### Key Features

- **Device Compliance**: Automated scripts to detect and fix common compliance issues
- **Security Remediation**: Security-focused fixes for endpoint vulnerabilities
- **Performance Optimization**: Scripts to optimize device performance and user experience
- **Modern PowerShell**: Supports -WhatIf and ShouldProcess for safe testing
- **Comprehensive Logging**: Standardized logging with Write-Information
- **CI/CD Ready**: Pre-configured GitHub Actions for linting and validation
- **Enterprise-Tested**: Battle-tested scripts used in production environments

## Why Use This Repository?

### 🎯 Save Time and Effort
Stop reinventing the wheel! This repository provides **ready-to-deploy** remediation scripts that you can use immediately in your Intune environment. Each script follows Microsoft best practices and has been designed with real-world scenarios in mind.

### 🛡️ Production-Ready and Tested
All scripts include:
- ✅ Proper error handling and logging
- ✅ Support for `-WhatIf` mode for safe testing
- ✅ Comprehensive documentation
- ✅ PowerShell Script Analyzer validation
- ✅ Real-world testing in enterprise environments

### 🚀 Accelerate Your Intune Deployment
Whether you're new to Intune remediation scripts or a seasoned pro, this repository provides:
- **Complete Examples**: Full detection/remediation pairs you can learn from
- **Best Practices**: Follow proven patterns for script development
- **Quick Deployment**: Copy, customize, and deploy in minutes
- **Active Maintenance**: Regular updates and community contributions

### 💡 Learn and Contribute
- **Educational Resource**: Learn PowerShell and Intune best practices
- **Community-Driven**: Share your scripts and learn from others
- **Open Source**: Free to use, modify, and contribute

## Popular Scripts

### 🔥 Most Used Scripts

| Script | Category | Description | Use Case |
|--------|----------|-------------|----------|
| **[BitLocker Detection](detection-scripts/compliance/bitlocker-detection.ps1)** | Compliance | Detects if BitLocker is enabled | Ensure drive encryption compliance |
| **[Disk Space Cleanup](remediation-scripts/performance/cleanup-temp-files.ps1)** | Performance | Cleans temporary files and caches | Free up disk space on endpoints |
| **[Windows Update Check](detection-scripts/security/windows-update-detection.ps1)** | Security | Detects pending Windows updates | Maintain security patch compliance |
| **[Memory Usage Monitor](detection-scripts/performance/memory-usage-detection.ps1)** | Performance | Monitors high memory usage | Identify performance issues |
| **[Security Baseline](security-management/Deploy-SecurityBaseline.ps1)** | Security | Deploys security hardening | Apply security configurations |

### 💼 Enterprise Scenarios

**Compliance Management**: Use our compliance scripts to ensure devices meet organizational security standards (BitLocker, Windows Updates, Security Baselines).

**Performance Optimization**: Deploy performance monitoring and cleanup scripts to maintain optimal device performance and user experience.

**Security Hardening**: Leverage security-focused scripts to detect and remediate vulnerabilities across your endpoint fleet.

**Device Lifecycle**: Automate device provisioning, maintenance, and retirement tasks to streamline IT operations.

## Quick Start

### 🎬 Get Started in 3 Steps

```powershell
# 1. Clone the repository
git clone https://github.com/a-ariff/intune-remediation-scripts.git
cd intune-remediation-scripts

# 2. Test a script locally (always use -WhatIf first!)
.\remediation-scripts\performance\cleanup-temp-files.ps1 -WhatIf

# 3. Review the deployment guide
# See docs/deployment-guide.md for Intune integration steps
```

### 📚 Learning Path

1. **Browse Examples**: Start with [`docs/examples/intune-import/`](docs/examples/intune-import/) for a complete detection/remediation pair
2. **Test Scripts**: Always run with `-WhatIf` parameter first to preview changes safely
3. **Deploy via Intune**: Follow the [deployment guide](docs/deployment-guide.md) for step-by-step Intune configuration
4. **Monitor Results**: Use Intune's reporting dashboard to track remediation success rates

### 🎓 New to Intune Remediation Scripts?

Check out our [Intune Remediation Blueprint](docs/intune-remediation-blueprint.md) for a comprehensive guide on creating your own remediation packages.

## Architecture

### 🏗️ How Intune Remediation Scripts Work

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Intune Admin Center                         │
│                     (Create Remediation Package)                    │
└────────────────────────────────┬────────────────────────────────────┘
                                 │ Deploy to Device Groups
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         Managed Endpoints                           │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Step 1: Detection Script Runs (Scheduled or On-Demand)      │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │  Exit Code 0 = Compliant (No Action Needed)           │  │   │
│  │  │  Exit Code 1 = Non-Compliant (Remediation Required)   │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────┬───────────────────────────────────┘   │
│                             │ If Exit Code = 1                      │
│                             ▼                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Step 2: Remediation Script Runs Automatically              │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │  Apply fixes, configurations, or updates              │  │   │
│  │  │  Exit Code 0 = Success | Exit Code 1 = Failure        │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────┬───────────────────────────────────┘   │
│                             │                                       │
│                             ▼                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Step 3: Results Reported Back to Intune                    │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│              Intune Reporting Dashboard (Monitor Results)           │
│  • Device Compliance Status  • Remediation Success Rates            │
│  • Script Execution Logs     • Failure Analysis                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 🔄 Workflow Example: Disk Space Management

1. **Detection**: Script checks if C: drive has < 10GB free space
2. **Trigger**: If true (exit 1), remediation script is automatically invoked
3. **Remediation**: Script cleans temp files, clears caches, removes old logs
4. **Verification**: Detection script runs again to confirm issue is resolved
5. **Reporting**: Results are logged and visible in Intune admin center

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

## FAQ

<details>
<summary><b>❓ Do I need an Intune license to use these scripts?</b></summary>

Yes, Microsoft Intune remediation scripts require an Intune license. These scripts are designed to integrate with Intune's Proactive Remediations feature (formerly known as "Endpoint Analytics - Proactive Remediations"). However, you can still test the scripts locally on Windows endpoints without Intune.
</details>

<details>
<summary><b>❓ Can I run these scripts outside of Intune?</b></summary>

Absolutely! All scripts can be executed locally on Windows machines for testing purposes. Use the `-WhatIf` parameter to preview changes before applying them. However, for automated deployment and monitoring at scale, Intune is recommended.
</details>

<details>
<summary><b>❓ Are these scripts safe for production use?</b></summary>

Yes, all scripts follow PowerShell best practices and include proper error handling. However:
- Always test in a non-production environment first
- Use the `-WhatIf` parameter to preview changes
- Review and customize scripts for your specific environment
- Start with a pilot group before broad deployment
</details>

<details>
<summary><b>❓ How often should remediation scripts run?</b></summary>

This depends on your use case:
- **Security updates**: Daily or hourly for critical security checks
- **Performance optimization**: Weekly or monthly
- **Compliance checks**: Daily for regulatory requirements
- **General maintenance**: Weekly

Configure the schedule in Intune's Remediation policy settings based on your organizational needs.
</details>

<details>
<summary><b>❓ What PowerShell version is required?</b></summary>

Most scripts are compatible with:
- **Windows PowerShell 5.1** (default on Windows 10/11)
- **PowerShell 7.x** (for modern-automation/ scripts)

Scripts automatically detect the PowerShell version and adjust accordingly.
</details>

<details>
<summary><b>❓ Can I customize these scripts?</b></summary>

Yes! All scripts are MIT licensed and can be freely modified. We encourage customization to fit your environment. When modifying:
- Maintain the same exit code structure (0 = success, 1 = failure)
- Keep error handling and logging
- Test thoroughly before deployment
- Consider contributing your improvements back to the community
</details>

<details>
<summary><b>❓ Do scripts require administrator privileges?</b></summary>

Most remediation scripts require administrator privileges because they modify system settings. Intune can run scripts in system context, which provides the necessary permissions. Detection scripts may or may not require admin rights depending on what they're checking.
</details>

<details>
<summary><b>❓ How do I troubleshoot failed remediations?</b></summary>

1. Check Intune's device diagnostics for script output logs
2. Review the script's error messages (logged via `Write-Error`)
3. Test the script locally on an affected device
4. Check our [troubleshooting guide](docs/troubleshooting.md)
5. [Open an issue](https://github.com/a-ariff/intune-remediation-scripts/issues) if you need help
</details>

<details>
<summary><b>❓ Can I use these scripts with Configuration Manager (SCCM)?</b></summary>

Yes! While designed for Intune, these PowerShell scripts can be adapted for use with Configuration Manager compliance settings or configuration items. You may need to adjust logging and exit code handling to match SCCM's requirements.
</details>

<details>
<summary><b>❓ Are there any prerequisites?</b></summary>

For Intune deployment:
- Microsoft Intune subscription
- Windows 10/11 devices enrolled in Intune
- Appropriate admin permissions in Intune

For local testing:
- Windows PowerShell 5.1 or higher
- Administrator privileges (for most remediation scripts)
</details>

<details>
<summary><b>❓ How can I contribute my own scripts?</b></summary>

We welcome contributions! Please:
1. Read our [Contributing Guidelines](CONTRIBUTING.md)
2. Follow the script structure in our [blueprint](docs/intune-remediation-blueprint.md)
3. Ensure scripts pass PowerShell Script Analyzer
4. Include comprehensive documentation
5. Submit a pull request

See our [script development guide](docs/script-development.md) for detailed requirements.
</details>

<details>
<summary><b>❓ What's the difference between detection and remediation scripts?</b></summary>

- **Detection Script**: Checks if a problem exists. Returns exit code 1 if remediation is needed, 0 if compliant.
- **Remediation Script**: Fixes the problem detected by the detection script. Returns exit code 0 on success, 1 on failure.

Detection scripts run first. If they return exit code 1, Intune automatically triggers the remediation script.
</details>

---

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

## 📊 Repository Stats

![GitHub repo size](https://img.shields.io/github/repo-size/a-ariff/intune-remediation-scripts)
![Lines of code](https://img.shields.io/tokei/lines/github/a-ariff/intune-remediation-scripts)
![GitHub contributors](https://img.shields.io/github/contributors/a-ariff/intune-remediation-scripts)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/a-ariff/intune-remediation-scripts)

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

**Made with ❤️ for the IT community**
