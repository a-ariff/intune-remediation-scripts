<#
.SYNOPSIS
    Get-IntuneDeviceReport.ps1 - Generate comprehensive Intune device compliance and inventory report
.DESCRIPTION
    This script connects to Microsoft Graph API to retrieve detailed information about
    Intune-managed devices including compliance status, hardware inventory, and policies.
    Exports results to CSV format for analysis and reporting.
.PARAMETER TenantId
    Azure AD Tenant ID
.PARAMETER ClientId
    Azure AD Application (Client) ID with appropriate Graph permissions
.PARAMETER CertificateThumbprint
    Certificate thumbprint for certificate-based authentication
.PARAMETER OutputPath
    Path where the CSV report will be saved (default: current directory)
.PARAMETER IncludeNonCompliant
    Switch to include only non-compliant devices in the report
.EXAMPLE
    .\Get-IntuneDeviceReport.ps1 -TenantId "your-tenant-id" -ClientId "your-client-id" -CertificateThumbprint "your-cert-thumbprint"
.EXAMPLE
    .\Get-IntuneDeviceReport.ps1 -TenantId "your-tenant-id" -ClientId "your-client-id" -CertificateThumbprint "your-cert-thumbprint" -IncludeNonCompliant
.NOTES
    Required Graph API Permissions:
    - DeviceManagementManagedDevices.Read.All
    - DeviceManagementConfiguration.Read.All
    
    Certificate-based authentication is more secure than using client secrets.
    
    Author: Microsoft Graph API Scripts
    Version: 2.0 - Updated to use certificate-based authentication
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $true)]
    [string]$ClientId,
    
    [Parameter(Mandatory = $true)]
    [string]$CertificateThumbprint,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "./",
    
    [Parameter(Mandatory = $false)]
    [switch]$IncludeNonCompliant
)

# Import required modules
try {
    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
    Import-Module Microsoft.Graph.DeviceManagement -ErrorAction Stop
    Write-Information "Required modules imported successfully" -InformationAction Continue
}
catch {
    Write-Error "Failed to import required modules: $($_.Exception.Message)"
    exit 1
}

# Connect to Microsoft Graph using certificate-based authentication
try {
    Write-Information "Connecting to Microsoft Graph..." -InformationAction Continue
    
    Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $CertificateThumbprint -NoWelcome
    
    Write-Information "Successfully connected to Microsoft Graph" -InformationAction Continue
}
catch {
    Write-Error "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
    exit 1
}

# Get all managed devices
try {
    Write-Information "Retrieving Intune managed devices..." -InformationAction Continue
    
    $devices = Get-MgDeviceManagementManagedDevice -All
    
    Write-Information "Retrieved $($devices.Count) devices" -InformationAction Continue
}
catch {
    Write-Error "Failed to retrieve devices: $($_.Exception.Message)"
    Disconnect-MgGraph
    exit 1
}

# Process device data
$deviceReport = @()

foreach ($device in $devices) {
    try {
        # Filter for non-compliant devices if specified
        if ($IncludeNonCompliant -and $device.ComplianceState -eq "Compliant") {
            continue
        }
        
        $deviceInfo = [PSCustomObject]@{
            DeviceName = $device.DeviceName
            UserPrincipalName = $device.UserPrincipalName
            OperatingSystem = $device.OperatingSystem
            OSVersion = $device.OSVersion
            ComplianceState = $device.ComplianceState
            LastSyncDateTime = $device.LastSyncDateTime
            EnrolledDateTime = $device.EnrolledDateTime
            Manufacturer = $device.Manufacturer
            Model = $device.Model
            SerialNumber = $device.SerialNumber
            IMEI = $device.Imei
            WiFiMacAddress = $device.WiFiMacAddress
            EthernetMacAddress = $device.EthernetMacAddress
            TotalStorageSpaceInBytes = $device.TotalStorageSpaceInBytes
            FreeStorageSpaceInBytes = $device.FreeStorageSpaceInBytes
            ManagedDeviceOwnerType = $device.ManagedDeviceOwnerType
            DeviceEnrollmentType = $device.DeviceEnrollmentType
            AzureADRegistered = $device.AzureADRegistered
            AzureADDeviceId = $device.AzureADDeviceId
            DeviceRegistrationState = $device.DeviceRegistrationState
        }
        
        $deviceReport += $deviceInfo
    }
    catch {
        Write-Warning "Error processing device $($device.DeviceName): $($_.Exception.Message)"
        continue
    }
}

# Generate output file name with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
if ($IncludeNonCompliant) {
    $fileName = "IntuneDeviceReport_NonCompliant_$timestamp.csv"
} else {
    $fileName = "IntuneDeviceReport_All_$timestamp.csv"
}

$fullPath = Join-Path $OutputPath $fileName

# Export to CSV
try {
    $deviceReport | Export-Csv -Path $fullPath -NoTypeInformation -Encoding UTF8
    
    Write-Information "Report generated successfully: $fullPath" -InformationAction Continue
    Write-Information "Total devices in report: $($deviceReport.Count)" -InformationAction Continue
    
    if ($IncludeNonCompliant) {
        $nonCompliantCount = ($deviceReport | Where-Object { $_.ComplianceState -ne "Compliant" }).Count
        Write-Information "Non-compliant devices: $nonCompliantCount" -InformationAction Continue
    }
}
catch {
    Write-Error "Failed to export report: $($_.Exception.Message)"
}
finally {
    # Disconnect from Microsoft Graph
    Disconnect-MgGraph
    Write-Information "Disconnected from Microsoft Graph" -InformationAction Continue
}

Write-Information "Script execution completed" -InformationAction Continue
