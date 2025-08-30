# Get-AdvancedComplianceReport.ps1
# PowerShell script for generating advanced compliance reports for Intune devices

function Get-AdvancedComplianceReport {
    <#
    .SYNOPSIS
        Generates an advanced compliance report for Intune-managed devices
    
    .DESCRIPTION
        This script generates a comprehensive compliance report that includes device compliance status,
        policy assignments, and detailed compliance information for Microsoft Intune managed devices.
    
    .PARAMETER OutputPath
        Specifies the path where the report will be saved
    
    .PARAMETER Format
        Specifies the output format (CSV, JSON, HTML)
    
    .EXAMPLE
        Get-AdvancedComplianceReport -OutputPath "C:\Reports\ComplianceReport.csv" -Format CSV
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$OutputPath = "ComplianceReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv",
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("CSV", "JSON", "HTML")]
        [string]$Format = "CSV"
    )
    
    try {
        Write-Information "Starting Advanced Compliance Report generation..." -InformationAction Continue
        
        # Connect to Microsoft Graph
        Write-Information "Connecting to Microsoft Graph..." -InformationAction Continue
        
        # Check if Microsoft.Graph module is installed
        if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
            Write-Information "Microsoft.Graph module not found. Installing..." -InformationAction Continue
            Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
        }
        
        # Import required modules
        Import-Module Microsoft.Graph.Authentication
        Import-Module Microsoft.Graph.DeviceManagement
        
        # Connect with required scopes
        $RequiredScopes = @(
            "DeviceManagementManagedDevices.Read.All",
            "DeviceManagementConfiguration.Read.All",
            "Directory.Read.All"
        )
        
        Connect-MgGraph -Scopes $RequiredScopes -NoWelcome
        
        Write-Information "Successfully connected to Microsoft Graph" -InformationAction Continue
        
        # Get all managed devices
        Write-Information "Retrieving managed devices..." -InformationAction Continue
        $ManagedDevices = Get-MgDeviceManagementManagedDevice -All
        
        Write-Information "Found $($ManagedDevices.Count) managed devices" -InformationAction Continue
        
        # Get compliance policies
        Write-Information "Retrieving compliance policies..." -InformationAction Continue
        $CompliancePolicies = Get-MgDeviceManagementDeviceCompliancePolicy
        
        # Initialize results array
        $ComplianceResults = @()
        
        # Process each device
        $DeviceCount = 0
        foreach ($Device in $ManagedDevices) {
            $DeviceCount++
            Write-Information "Processing device $DeviceCount of $($ManagedDevices.Count): $($Device.DeviceName)" -InformationAction Continue
            
            # Get device compliance status
            $ComplianceStatus = Get-MgDeviceManagementManagedDeviceDeviceCompliancePolicyState -ManagedDeviceId $Device.Id
            
            # Get device configuration status
            $ConfigurationStatus = Get-MgDeviceManagementManagedDeviceDeviceConfigurationState -ManagedDeviceId $Device.Id
            
            # Create device report object
            $DeviceReport = [PSCustomObject]@{
                DeviceName = $Device.DeviceName
                DeviceId = $Device.Id
                UserPrincipalName = $Device.UserPrincipalName
                Platform = $Device.OperatingSystem
                OSVersion = $Device.OsVersion
                ComplianceState = $Device.ComplianceState
                LastSyncDateTime = $Device.LastSyncDateTime
                EnrollmentDateTime = $Device.EnrolledDateTime
                ManagementAgent = $Device.ManagementAgent
                DeviceType = $Device.DeviceType
                Manufacturer = $Device.Manufacturer
                Model = $Device.Model
                SerialNumber = $Device.SerialNumber
                TotalStorageSpaceInBytes = $Device.TotalStorageSpaceInBytes
                FreeStorageSpaceInBytes = $Device.FreeStorageSpaceInBytes
                CompliancePoliciesCount = $ComplianceStatus.Count
                ConfigurationPoliciesCount = $ConfigurationStatus.Count
                IsEncrypted = $Device.IsEncrypted
                IsSupervised = $Device.IsSupervised
                ExchangeAccessState = $Device.ExchangeAccessState
                ExchangeAccessStateReason = $Device.ExchangeAccessStateReason
            }
            
            $ComplianceResults += $DeviceReport
        }
        
        Write-Information "Device processing completed. Generating report..." -InformationAction Continue
        
        # Generate output based on format
        switch ($Format) {
            "CSV" {
                $ComplianceResults | Export-Csv -Path $OutputPath -NoTypeInformation
                Write-Information "CSV report saved to: $OutputPath" -InformationAction Continue
            }
            "JSON" {
                $ComplianceResults | ConvertTo-Json -Depth 3 | Out-File -FilePath $OutputPath -Encoding UTF8
                Write-Information "JSON report saved to: $OutputPath" -InformationAction Continue
            }
            "HTML" {
                $HtmlReport = $ComplianceResults | ConvertTo-Html -Title "Advanced Compliance Report" -Head "<style>table{border-collapse:collapse;width:100%;}th,td{border:1px solid #ddd;padding:8px;text-align:left;}th{background-color:#f2f2f2;}</style>"
                $HtmlReport | Out-File -FilePath $OutputPath -Encoding UTF8
                Write-Information "HTML report saved to: $OutputPath" -InformationAction Continue
            }
        }
        
        # Generate summary
        $TotalDevices = $ComplianceResults.Count
        $CompliantDevices = ($ComplianceResults | Where-Object { $_.ComplianceState -eq "Compliant" }).Count
        $NonCompliantDevices = ($ComplianceResults | Where-Object { $_.ComplianceState -eq "Noncompliant" }).Count
        $UnknownDevices = ($ComplianceResults | Where-Object { $_.ComplianceState -eq "Unknown" }).Count
        
        Write-Information "=== COMPLIANCE REPORT SUMMARY ===" -InformationAction Continue
        Write-Information "Total Devices: $TotalDevices" -InformationAction Continue
        Write-Information "Compliant Devices: $CompliantDevices" -InformationAction Continue
        Write-Information "Non-Compliant Devices: $NonCompliantDevices" -InformationAction Continue
        Write-Information "Unknown Status Devices: $UnknownDevices" -InformationAction Continue
        Write-Information "Report saved to: $OutputPath" -InformationAction Continue
        
        return $ComplianceResults
        
    }
    catch {
        Write-Error "Error generating compliance report: $($_.Exception.Message)"
        throw
    }
    finally {
        # Disconnect from Microsoft Graph
        try {
            Disconnect-MgGraph
            Write-Information "Disconnected from Microsoft Graph" -InformationAction Continue
        }
        catch {
            Write-Warning "Failed to disconnect from Microsoft Graph: $($_.Exception.Message)"
        }
    }
}

# Export the function
Export-ModuleMember -Function Get-AdvancedComplianceReport
