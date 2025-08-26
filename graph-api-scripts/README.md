# Graph API Scripts for Intune Remediation

## Overview

This directory contains Microsoft Graph API scripts designed to enhance Intune remediation capabilities for the 2025 enhancement project. These scripts leverage the Microsoft Graph API to perform advanced device management tasks, retrieve compliance data, and automate administrative operations that extend beyond traditional PowerShell remediation scripts.

## Purpose

The Graph API Scripts directory is specifically designed to:

- **Advanced Device Management**: Perform complex device operations using Microsoft Graph API
- **Data Analytics**: Retrieve and analyze device compliance, security, and performance data
- **Automation Enhancement**: Automate administrative tasks that require Graph API access
- **Integration Support**: Provide seamless integration between Intune and other Microsoft 365 services
- **Reporting Capabilities**: Generate comprehensive reports using Graph API data sources

## Key Features

### 🔗 Graph API Integration
- Native Microsoft Graph API connectivity
- Secure authentication using managed identities
- Comprehensive error handling and retry logic
- Rate limiting and throttling management

### 📊 Advanced Analytics
- Device compliance trend analysis
- Security posture assessment
- Application deployment statistics
- User behavior insights

### 🔄 Automation Workflows
- Automated device grouping based on criteria
- Dynamic policy assignment
- Bulk device operations
- Cross-tenant management capabilities

### 📈 Reporting & Monitoring
- Custom dashboard data generation
- Real-time monitoring capabilities
- Historical trend analysis
- Executive summary reports

## Directory Structure

```
graph-api-scripts/
├── authentication/
│   ├── managed-identity-auth.ps1
│   ├── app-registration-auth.ps1
│   └── certificate-auth.ps1
├── device-management/
│   ├── bulk-device-operations.ps1
│   ├── device-compliance-analysis.ps1
│   ├── device-inventory-sync.ps1
│   └── autopilot-management.ps1
├── policy-management/
│   ├── dynamic-group-assignment.ps1
│   ├── policy-deployment-automation.ps1
│   ├── compliance-policy-analysis.ps1
│   └── conditional-access-integration.ps1
├── reporting/
│   ├── compliance-dashboard-data.ps1
│   ├── security-posture-report.ps1
│   ├── application-deployment-stats.ps1
│   └── executive-summary-generator.ps1
├── utilities/
│   ├── graph-api-helper-functions.ps1
│   ├── rate-limit-handler.ps1
│   ├── error-handling-framework.ps1
│   └── logging-utilities.ps1
└── examples/
    ├── basic-graph-queries.ps1
    ├── advanced-filtering-examples.ps1
    └── batch-operations-samples.ps1
```

## Prerequisites

### Technical Requirements
- PowerShell 7.0 or later (recommended for cross-platform support)
- Microsoft Graph PowerShell SDK
- Azure AD application registration (for app-based authentication)
- Appropriate Graph API permissions

### Required Permissions

Minimum Graph API permissions required:
- `DeviceManagementManagedDevices.ReadWrite.All`
- `DeviceManagementConfiguration.ReadWrite.All`
- `DeviceManagementApps.ReadWrite.All`
- `Directory.Read.All`
- `Reports.Read.All`

### Authentication Methods
- **Managed Identity** (recommended for Azure environments)
- **Application Registration** (for on-premises or hybrid scenarios)
- **Certificate-based Authentication** (for high-security environments)

## Quick Start

### 1. Setup Authentication

```powershell
# Install required modules
Install-Module Microsoft.Graph -Scope AllUsers
Install-Module Microsoft.Graph.Authentication

# Import authentication script
.\authentication\managed-identity-auth.ps1

# Test connection
Test-GraphConnection
```

### 2. Basic Device Query

```powershell
# Import utility functions
.\utilities\graph-api-helper-functions.ps1

# Get all managed devices
$devices = Get-IntuneDevices -Filter "managementState eq 'managed'"

# Display summary
Write-Output "Total managed devices: $($devices.Count)"
```

### 3. Generate Compliance Report

```powershell
# Run compliance analysis
.\reporting\compliance-dashboard-data.ps1 -OutputPath "C:\Reports\ComplianceData.json"

# Generate executive summary
.\reporting\executive-summary-generator.ps1 -InputData "C:\Reports\ComplianceData.json"
```

## Authentication Configuration

### Managed Identity Setup

```powershell
# Configure managed identity for Azure VM or Azure Function
$identity = @{
    Type = "SystemAssigned"
    ResourceGroup = "YourResourceGroup"
    SubscriptionId = "your-subscription-id"
}

# Grant required permissions
New-AzRoleAssignment -ObjectId $identity.PrincipalId -RoleDefinitionName "Intune Administrator"
```

### Application Registration Setup

```powershell
# Create app registration
$app = @{
    DisplayName = "Intune Graph API Scripts"
    RequiredResourceAccess = @(
        @{
            ResourceAppId = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
            ResourceAccess = @(
                @{ Id = "dc377aa6-52d8-4e23-b271-2a7ae04cedf3"; Type = "Role" } # DeviceManagementManagedDevices.ReadWrite.All
                @{ Id = "9241abd9-d0e6-425a-bd4f-47ba86e767a4"; Type = "Role" } # DeviceManagementConfiguration.ReadWrite.All
            )
        }
    )
}

New-AzADApplication @app
```

## Usage Examples

### Device Management

```powershell
# Bulk device operations
.\device-management\bulk-device-operations.ps1 -Operation "Retire" -DeviceIds @("device1", "device2")

# Sync device inventory
.\device-management\device-inventory-sync.ps1 -OutputFormat "CSV" -IncludeApps

# Autopilot device management
.\device-management\autopilot-management.ps1 -ImportCsv "devices.csv" -AssignProfile "Corporate"
```

### Policy Management

```powershell
# Dynamic group assignment
.\policy-management\dynamic-group-assignment.ps1 -Criteria "deviceOSType" -Value "Windows"

# Automated policy deployment
.\policy-management\policy-deployment-automation.ps1 -PolicyType "Compliance" -TargetGroup "IT-Devices"
```

### Reporting

```powershell
# Generate compliance dashboard data
.\reporting\compliance-dashboard-data.ps1 -TimeRange "Last30Days" -ExportFormat "JSON"

# Security posture report
.\reporting\security-posture-report.ps1 -IncludeRecommendations -OutputPath "SecurityReport.html"
```

## Error Handling

All scripts include comprehensive error handling:

```powershell
try {
    # Graph API operation
    $result = Invoke-MgGraphRequest -Uri $uri -Method GET
    
    # Process result
    Write-Output "Operation successful: $($result.Count) items processed"
}
catch [Microsoft.Graph.PowerShell.RuntimeException] {
    Write-Error "Graph API error: $($_.Exception.Message)"
    
    # Implement retry logic
    if ($_.Exception.Response.StatusCode -eq 429) {
        Start-Sleep -Seconds (Get-RetryDelay $_.Exception.Response.Headers)
        # Retry operation
    }
}
catch {
    Write-Error "Unexpected error: $($_.Exception.Message)"
    # Log for debugging
    Write-LogEntry -Level "Error" -Message $_.Exception.ToString()
}
```

## Best Practices

### Security
- Use managed identities when possible
- Implement least privilege access
- Rotate certificates regularly
- Monitor API usage for anomalies

### Performance
- Implement proper rate limiting
- Use batch operations for bulk updates
- Cache frequently accessed data
- Optimize query filters

### Reliability
- Implement retry logic with exponential backoff
- Handle transient errors gracefully
- Validate input parameters
- Log all operations for debugging

## Integration with Intune Remediation

These Graph API scripts can be integrated with traditional Intune remediation scripts:

```powershell
# Detection script integration
if (Test-ComplianceCondition) {
    # Use Graph API for detailed analysis
    $detailedData = .\graph-api-scripts\device-management\device-compliance-analysis.ps1
    
    # Make remediation decision based on Graph data
    if ($detailedData.RequiresRemediation) {
        exit 1 # Trigger remediation
    }
}

exit 0 # Compliant
```

## Monitoring and Logging

All scripts include comprehensive logging:

```powershell
# Configure logging
$LogConfig = @{
    LogPath = "C:\Logs\GraphAPIScripts"
    LogLevel = "Information"
    RetentionDays = 30
    IncludeGraphMetrics = $true
}

# Initialize logging
Initialize-ScriptLogging @LogConfig

# Log Graph API calls
Write-GraphAPILog -Operation "GET" -Uri $uri -ResponseTime $responseTime -StatusCode $statusCode
```

## Troubleshooting

### Common Issues

1. **Authentication Failures**
   - Verify app registration permissions
   - Check certificate expiration
   - Validate managed identity configuration

2. **Rate Limiting**
   - Implement exponential backoff
   - Use batch operations
   - Monitor throttling headers

3. **Permission Errors**
   - Review required Graph permissions
   - Ensure admin consent is granted
   - Check role assignments

### Debug Mode

Enable debug mode for troubleshooting:

```powershell
$DebugPreference = "Continue"
$VerbosePreference = "Continue"

# Run script with debug output
.\graph-api-scripts\device-management\device-inventory-sync.ps1 -Debug -Verbose
```

## Support and Maintenance

### Version Compatibility
- Microsoft Graph API v1.0 (stable)
- Microsoft Graph PowerShell SDK v2.x
- PowerShell 7.0+ recommended

### Update Schedule
- Monthly security updates
- Quarterly feature enhancements
- Annual major version releases

### Community Support
- GitHub Issues for bug reports
- Discussion forums for questions
- Documentation wiki for guides

## Contributing

Contributions are welcome! Please refer to the main repository's CONTRIBUTING.md for guidelines on:
- Code standards and review process
- Testing requirements for Graph API scripts
- Documentation standards
- Security considerations for API access

## License

This project is licensed under the MIT License - see the main repository LICENSE file for details.

## Related Documentation

- [Microsoft Graph API Documentation](https://docs.microsoft.com/en-us/graph/)
- [Microsoft Graph PowerShell SDK](https://docs.microsoft.com/en-us/powershell/microsoftgraph/)
- [Intune Graph API Reference](https://docs.microsoft.com/en-us/graph/api/resources/intune-graph-overview)
- [Azure AD App Registration Guide](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)

## Changelog

### Version 1.0.0 (2025-08-26)
- Initial release for 2025 enhancement project
- Basic Graph API authentication methods
- Core device management scripts
- Reporting and analytics capabilities
- Comprehensive documentation and examples

---

*This directory is part of the 2025 Intune Remediation Scripts enhancement project, focusing on advanced Graph API integration and enterprise-scale automation capabilities.*
