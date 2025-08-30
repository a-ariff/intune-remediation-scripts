# Intune Import Example

This example demonstrates how to import and deploy detection and remediation scripts to Microsoft Intune. It includes sample scripts that follow proper exit code conventions and logging practices.

## Overview

This folder contains:
- `detection.ps1` - Sample detection script demonstrating proper structure and exit codes
- `remediation.ps1` - Sample remediation script with ShouldProcess support and logging
- Step-by-step import guide for deploying to Microsoft Intune

## Files in this Example

### detection.ps1
Detection script that checks for a common system condition and returns proper exit codes:
- Exit 0: System is compliant (no remediation needed)
- Exit 1: Issue detected (remediation required)

### remediation.ps1
Remediation script that fixes the detected issue with:
- ShouldProcess support for safe testing with -WhatIf
- Proper error handling and logging
- Standardized exit codes for Intune integration

## Step-by-Step Import Guide

### Prerequisites

- [ ] Microsoft Intune admin access
- [ ] Appropriate permissions for creating remediations
- [ ] PowerShell scripts tested locally
- [ ] Device groups configured for assignment

### Step 1: Prepare Scripts

1. **Download sample scripts** from this folder:
   - `detection.ps1`
   - `remediation.ps1`

2. **Customize scripts** for your environment:
   - Update detection logic for your specific use case
   - Modify remediation actions as needed
   - Test scripts locally with `-WhatIf` parameter

3. **Validate script structure**:
   ```powershell
   # Test detection script
   .\detection.ps1
   
   # Test remediation script (safe mode)
   .\remediation.ps1 -WhatIf
   ```

### Step 2: Access Intune Admin Center

1. Navigate to [Microsoft Intune admin center](https://intune.microsoft.com)
2. Sign in with administrator credentials
3. Go to **Reports** > **Endpoint analytics** > **Remediations**

### Step 3: Create Remediation Package

1. **Click "+ Create script package"**
2. **Configure basic settings**:
   - **Name**: `Sample System Check Remediation`
   - **Description**: `Detects and remediates common system configuration issues`
   - **Publisher**: Your organization name
3. **Click "Next"**

### Step 4: Upload Detection Script

1. **In the Settings page**:
   - Click **"Browse"** under Detection script
   - Select your `detection.ps1` file
   - Upload the script

2. **Configure detection settings**:
   - **Run this script using the logged-on credentials**: `No` (recommended)
   - **Enforce script signature check**: `Yes` (for production)
   - **Run script in 64-bit PowerShell**: `Yes`

### Step 5: Upload Remediation Script

1. **Upload remediation script**:
   - Click **"Browse"** under Remediation script
   - Select your `remediation.ps1` file
   - Upload the script

2. **Configure remediation settings**:
   - **Run this script using the logged-on credentials**: `No` (recommended)
   - **Enforce script signature check**: `Yes` (for production)
   - **Run script in 64-bit PowerShell**: `Yes`

3. **Click "Next"**

### Step 6: Configure Assignments

1. **Select target groups**:
   - Click **"+ Add group"**
   - Choose **"Include"** assignment type
   - Select appropriate device groups (start with pilot group)

2. **Configure assignment settings**:
   - **Run frequency**: `Daily` (recommended for initial testing)
   - **Reboot device if required**: Configure based on your remediation needs

3. **Click "Next"**

### Step 7: Configure Scope Tags (if required)

1. **Add scope tags** if your organization uses them:
   - Select appropriate scope tags for your deployment
   - Ensure tags match your permissions and organizational structure

2. **Click "Next"**

### Step 8: Review and Create

1. **Review configuration**:
   - Verify script names and settings
   - Confirm assignment groups
   - Check schedule configuration

2. **Click "Create"** to deploy the remediation

### Step 9: Monitor Deployment

1. **Check deployment status**:
   - Return to **Reports** > **Endpoint analytics** > **Remediations**
   - Select your new remediation package
   - Monitor device compliance and remediation results

2. **Review device-level results**:
   - Click on the remediation name
   - Go to **Device status** tab
   - Check individual device results and any errors

3. **Analyze results**:
   - **Compliant**: Devices where no issues were detected
   - **Not compliant**: Devices where issues were found but not yet remediated
   - **Remediated**: Devices where issues were successfully fixed
   - **Error**: Devices where scripts failed to execute properly

## Testing and Validation

### Pre-deployment Testing

```powershell
# Test detection script
.\detection.ps1
Write-Host "Exit code: $LASTEXITCODE"

# Test remediation script safely
.\remediation.ps1 -WhatIf
```

### Pilot Deployment

1. **Start with small pilot group** (5-10 devices)
2. **Monitor results for 24-48 hours**
3. **Validate remediation effectiveness**
4. **Check for any adverse effects**
5. **Expand to larger groups** once validated

### Troubleshooting Common Issues

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| Script not running | Execution policy | Configure via Intune policy, not Set-ExecutionPolicy |
| Permission errors | Insufficient rights | Review script context and required permissions |
| Detection false positives | Logic errors | Review detection script conditions |
| Remediation failures | Resource conflicts | Add error handling and retry logic |
| Slow deployment | Assignment propagation | Allow 8+ hours for full deployment |

## Best Practices

### Script Development
- **Always include proper error handling**
- **Use Write-Information instead of Write-Host**
- **Support -WhatIf parameter for testing**
- **Follow consistent exit code conventions**
- **Include detailed logging for troubleshooting**

### Deployment Strategy
- **Test scripts thoroughly before deployment**
- **Start with pilot groups**
- **Monitor results closely**
- **Have rollback procedures ready**
- **Document all changes and results**

### Security Considerations
- **Never hardcode credentials or secrets**
- **Use appropriate execution contexts**
- **Sign scripts in production environments**
- **Limit script modification permissions**
- **Maintain audit trail of all changes**

## Next Steps

1. **Customize the sample scripts** for your specific requirements
2. **Test in your environment** using the provided samples
3. **Follow the import guide** to deploy your first remediation
4. **Review results** and iterate on your approach
5. **Scale to additional use cases** using lessons learned

## Additional Resources

- [Microsoft Intune Remediations Documentation](https://docs.microsoft.com/en-us/mem/analytics/remediations)
- [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/00-introduction)
- [Deployment Guide](../deployment-guide.md)
- [Troubleshooting Guide](../troubleshooting.md)

---

*This example provides a foundation for implementing Intune remediations in your environment. Customize the scripts and processes according to your specific requirements and organizational policies.*
