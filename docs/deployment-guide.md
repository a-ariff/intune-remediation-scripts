# Deployment Guide

## Overview

This comprehensive guide provides step-by-step instructions for deploying Intune remediation scripts to managed devices, including creating remediations, configuring assignments, testing, monitoring, and rollback procedures.

## Prerequisites

- [ ] Microsoft Intune admin access with appropriate permissions
- [ ] Script testing completed in development environment
- [ ] Device groups configured for pilot and production deployments
- [ ] Azure AD Premium P1 or P2 license for advanced features
- [ ] PowerShell scripts validated with `-WhatIf` parameter
- [ ] Remediation scripts follow exit code conventions (0=success, 1=failure)

## Creating an Intune Remediation

### Step 1: Access Intune Admin Center

1. Navigate to [Microsoft Intune admin center](https://intune.microsoft.com)
2. Sign in with your administrator credentials
3. Go to **Reports** > **Endpoint analytics** > **Remediations**

*[Screenshot placeholder: Intune admin center navigation to Remediations]*

### Step 2: Create New Remediation

1. Click **+ Create script package**
2. Configure basic information:
   - **Name**: Descriptive name (e.g., "Fix Chrome Update Issue")
   - **Description**: Detailed description of the remediation purpose
   - **Publisher**: Your organization name

*[Screenshot placeholder: Create script package basic information]*

### Step 3: Upload Detection Script

1. Click **Next** to go to **Settings**
2. Upload your **detection script** (.ps1 file)
3. Configure detection script settings:
   - **Run this script using the logged-on credentials**: No (recommended)
   - **Enforce script signature check**: Yes (for production)
   - **Run script in 64-bit PowerShell**: Yes (if required)

*[Screenshot placeholder: Detection script upload and configuration]*

### Step 4: Upload Remediation Script

1. Upload your **remediation script** (.ps1 file)
2. Configure remediation script settings:
   - **Run this script using the logged-on credentials**: No (recommended)
   - **Enforce script signature check**: Yes (for production)
   - **Run script in 64-bit PowerShell**: Yes (if required)

*[Screenshot placeholder: Remediation script upload and configuration]*

### Step 5: Configure Assignments

#### Device Group Assignment

1. Click **Next** to go to **Assignments**
2. Click **+ Add group**
3. Select assignment type:
   - **Include**: Assign to specific groups
   - **Exclude**: Exclude specific groups from assignment

*[Screenshot placeholder: Assignment configuration screen]*

#### Assignment Options

- **Assign to**: 
  - All devices
  - Selected groups
  - All users
  - Selected user groups

#### Scope Tags Configuration

1. Navigate to **Scope tags** tab
2. Add appropriate scope tags for:
   - **Department-specific**: IT, HR, Finance
   - **Location-specific**: US, EU, APAC
   - **Environment-specific**: Production, Staging

*[Screenshot placeholder: Scope tags configuration]*

### Step 6: Configure Schedule

#### Detection Schedule

1. Set **Run frequency**: 
   - Every 4 hours (aggressive)
   - Daily (recommended)
   - Weekly (maintenance scenarios)

#### Remediation Schedule

1. Configure **Remediation settings**:
   - **Reboot device if required by script**: Yes/No
   - **Re-run remediation if initial remediation fails**: Yes (recommended)
   - **Number of retries if remediation fails**: 3 (recommended)

*[Screenshot placeholder: Schedule configuration options]*

### Step 7: Review and Create

1. Review all configurations on **Review + Create** tab
2. Verify:
   - Script names and descriptions
   - Assignment groups
   - Schedule settings
   - Scope tags
3. Click **Create** to deploy

*[Screenshot placeholder: Review and create summary]*

## Testing with -WhatIf Parameter

### Pre-Deployment Testing

Before deploying to production, always test scripts with the `-WhatIf` parameter:

```powershell
# Test detection script
.\detect-script.ps1 -WhatIf

# Test remediation script with ShouldProcess support
.\remediate-script.ps1 -WhatIf
```

### Pilot Group Testing

1. **Create pilot device group** (5-10 devices)
2. **Deploy to pilot group first**
3. **Monitor results for 24-48 hours**
4. **Validate remediation effectiveness**
5. **Check for any adverse effects**

*[Screenshot placeholder: Pilot group creation and assignment]*

### Validation Steps

1. **Manual verification**: Check remediation results on pilot devices
2. **Log analysis**: Review PowerShell execution logs
3. **Performance impact**: Monitor device performance metrics
4. **User impact**: Gather feedback from pilot users

## Monitoring and Reporting

### Built-in Monitoring

1. Navigate to **Reports** > **Endpoint analytics** > **Remediations**
2. Select your remediation package
3. Review key metrics:
   - **Device compliance status**
   - **Detection results**
   - **Remediation success rate**
   - **Error rates and trends**

*[Screenshot placeholder: Remediation monitoring dashboard]*

### Device Status Monitoring

#### Individual Device Status

1. Click on specific remediation
2. Go to **Device status** tab
3. Review per-device results:
   - **Compliant**: No issues detected
   - **Not compliant**: Issues detected, remediation needed
   - **Remediated**: Issues fixed successfully
   - **Error**: Detection or remediation failed

*[Screenshot placeholder: Device status detailed view]*

#### Error Analysis

1. Filter by **Error** status
2. Export error logs for analysis
3. Common error patterns:
   - Permission issues
   - Network connectivity
   - Script execution policy
   - Resource availability

### Advanced Monitoring

#### Log Analytics Integration

1. Configure **Log Analytics workspace**
2. Enable **Intune data collection**
3. Create custom **KQL queries** for advanced analysis
4. Set up **automated alerts** for failure thresholds

*[Screenshot placeholder: Log Analytics configuration]*

#### Custom Reporting

```powershell
# Example: Export remediation results to CSV
$Results = Get-IntuneRemediationResults -RemediationId "your-id"
$Results | Export-Csv -Path "C:\Reports\RemediationResults.csv" -NoTypeInformation
```

## Rollback Procedures

### Emergency Rollback

#### Immediate Actions

1. **Stop remediation deployment**:
   - Navigate to remediation package
   - Click **Assignments** > **Edit**
   - Remove all assignments
   - Click **Save**

*[Screenshot placeholder: Emergency assignment removal]*

2. **Notify affected users** if user impact is expected
3. **Document rollback reasons** for post-incident review

### Planned Rollback

#### Rollback Script Development

1. **Create rollback detection script**:
   - Detect if remediation was applied
   - Check for adverse effects

2. **Create rollback remediation script**:
   - Undo changes made by original remediation
   - Restore previous configuration
   - Log rollback actions

```powershell
# Example rollback remediation script structure
[CmdletBinding(SupportsShouldProcess=$true)]
param()

try {
    if ($PSCmdlet.ShouldProcess("System", "Rollback Previous Remediation")) {
        # Rollback logic here
        Write-Information "Rollback completed successfully" -InformationAction Continue
        exit 0
    }
} catch {
    Write-Error "Rollback failed: $_"
    exit 1
}
```

#### Rollback Testing

1. **Test rollback scripts** in isolated environment
2. **Verify complete restoration** of previous state
3. **Document rollback procedures** for operations team

### Rollback Deployment

1. **Create new remediation package** with rollback scripts
2. **Assign to affected devices** only
3. **Monitor rollback progress** closely
4. **Validate successful rollback** on sample devices

*[Screenshot placeholder: Rollback remediation deployment]*

## Post-Deployment Activities

### Success Metrics

- **Compliance improvement**: % of devices moved to compliant state
- **Error rate**: < 5% failure rate target
- **Performance impact**: No significant device slowdown
- **User satisfaction**: Minimal user disruption

### Documentation Updates

1. **Update deployment records** with actual results
2. **Document lessons learned** for future deployments
3. **Update runbooks** with new procedures discovered
4. **Share knowledge** with team members

### Continuous Improvement

1. **Review error patterns** for script improvements
2. **Optimize detection frequency** based on business needs
3. **Update assignment groups** as organization evolves
4. **Refine monitoring thresholds** based on operational experience

## Troubleshooting Common Issues

### Script Execution Failures

| Error Type | Cause | Solution |
|------------|-------|----------|
| Access Denied | Insufficient permissions | Review script context and permissions |
| Execution Policy | PowerShell policy restriction | Configure via Intune policy, not Set-ExecutionPolicy |
| Script Timeout | Long-running operations | Optimize script performance, add progress indicators |
| Network Issues | Connectivity problems | Add network checks, implement retries |

### Assignment Issues

- **Devices not receiving remediation**: Check group membership and assignment filters
- **Scope tag conflicts**: Verify scope tag assignments match user permissions
- **Timing issues**: Allow 8+ hours for initial deployment propagation

### Monitoring Gaps

- **Missing device status**: Check device enrollment and compliance
- **Delayed reporting**: Allow up to 24 hours for full reporting sync
- **Incomplete data**: Verify Log Analytics workspace configuration

## Advanced Deployment Scenarios

### Multi-Tenant Deployments

1. **Configure tenant-specific scope tags**
2. **Customize scripts per tenant requirements**
3. **Implement centralized monitoring** across tenants
4. **Coordinate deployment timing** across organizations

### Conditional Deployments

1. **Use assignment filters** for advanced targeting:
   - Device properties (OS version, manufacturer)
   - User properties (department, location)
   - Custom device attributes

2. **Dynamic group assignments** for automatic targeting

*[Screenshot placeholder: Advanced assignment filter configuration]*

### Integration with Other Systems

1. **ServiceNow integration** for change management
2. **Teams notifications** for deployment status
3. **PowerBI dashboards** for executive reporting
4. **Azure Automation** for complex orchestration

## Security Considerations

### Script Security

- **Code signing**: Always sign production scripts
- **Access control**: Limit script modification permissions
- **Sensitive data**: Never hardcode credentials or secrets
- **Audit trail**: Maintain deployment and modification logs

### Compliance Requirements

- **Change approval**: Follow organizational change management
- **Documentation**: Maintain comprehensive deployment records
- **Testing evidence**: Document all testing phases and results
- **Rollback readiness**: Always have tested rollback procedures

---

## References

- [Microsoft Intune Remediations Documentation](https://docs.microsoft.com/en-us/mem/analytics/remediations)
- [PowerShell Best Practices for Intune](https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/00-introduction)
- [Troubleshooting Guide](troubleshooting.md)
- [Script Development Guide](script-development.md)

*Last Updated: August 2025 | Version 2.0*
