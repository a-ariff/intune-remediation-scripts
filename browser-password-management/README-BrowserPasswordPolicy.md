# Browser Password Management Scripts

This folder contains Microsoft Intune remediation scripts for managing browser password policies on macOS devices.

## Overview

These scripts are designed to help IT administrators control and configure browser password management settings across macOS devices in an enterprise environment using Microsoft Intune's remediation framework.

## Files Description

### 1. Deploy-MacOSBrowserPasswordPolicy.ps1
- **Type**: PowerShell Script
- **Purpose**: Main deployment script for configuring browser password policies
- **Platform**: macOS (via PowerShell Core)
- **Function**: Orchestrates the deployment of browser password management configurations

### 2. disable-browser-passwords-macos.sh
- **Type**: Shell Script
- **Purpose**: Shell script to disable password saving in common browsers
- **Platform**: macOS
- **Browsers Supported**: 
  - Safari
  - Google Chrome
  - Mozilla Firefox
- **Function**: Directly configures browser settings to disable password storage

### 3. README-BrowserPasswordPolicy.md
- **Type**: Documentation
- **Purpose**: This documentation file explaining the script collection

## Usage Instructions

### Prerequisites
- Microsoft Intune subscription
- macOS devices enrolled in Intune
- PowerShell Core installed on target devices (for PowerShell script)
- Appropriate administrative permissions

### Deployment Steps

1. **Upload Scripts to Intune**:
   - Navigate to Microsoft Endpoint Manager admin center
   - Go to Devices > macOS > Scripts
   - Upload the PowerShell script: `Deploy-MacOSBrowserPasswordPolicy.ps1`
   - Upload the Shell script: `disable-browser-passwords-macos.sh`

2. **Configure Script Settings**:
   - Set appropriate execution policies
   - Configure target device groups
   - Set deployment schedule

3. **Monitor Deployment**:
   - Check script execution status in Intune portal
   - Review device compliance reports
   - Validate browser settings on target devices

## Security Considerations

- These scripts modify browser security settings
- Test thoroughly in a non-production environment first
- Ensure compliance with organizational security policies
- Document any exceptions or custom configurations

## Compatibility

- **Operating System**: macOS 10.15 (Catalina) and later
- **Browsers**: 
  - Safari (all versions)
  - Google Chrome (version 70+)
  - Mozilla Firefox (version 60+)
- **Intune**: Microsoft Intune (all current versions)
- **PowerShell**: PowerShell Core 7.0+

## Troubleshooting

### Common Issues
1. **Script Execution Fails**:
   - Check execution policy settings
   - Verify administrative permissions
   - Review device compatibility

2. **Browser Settings Not Applied**:
   - Ensure browsers are closed during deployment
   - Check for conflicting Group Policy settings
   - Verify script targeting is correct

### Log Files
- PowerShell script logs: Check Intune script execution logs
- Shell script logs: Review system logs via Console app
- Browser configuration: Verify settings in browser preferences

## Support

For technical support and questions:
- Review Microsoft Intune documentation
- Check browser-specific configuration guides
- Consult your organization's IT support team

## Version History

- **v1.0** (2025-08-31): Initial release with basic browser password management functionality

---

**Note**: These scripts are provided as-is for educational and administrative purposes. Always test in a controlled environment before production deployment.
