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

.PARAMETER ClientSecret
    Azure AD Application Client Secret

.PARAMETER OutputPath
    Path where the CSV report will be saved (default: current directory)

.PARAMETER IncludeNonCompliant
    Switch to include only non-compliant devices in the report

.EXAMPLE
    .\Get-IntuneDeviceReport.ps1 -TenantId "your-tenant-id" -ClientId "your-client-id" -ClientSecret "your-secret"

.EXAMPLE
    .\Get-IntuneDeviceReport.ps1 -TenantId "your-tenant-id" -ClientId "your-client-id" -ClientSecret "your-secret" -IncludeNonCompliant

.NOTES
    Required Graph API Permissions:
    - DeviceManagementManagedDevices.Read.All
    - DeviceManagementConfiguration.Read.All
    
    Author: Microsoft Graph API Scripts
    Version: 1.0
    Date: $(Get-Date -Format 'yyyy-MM-dd')
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $true)]
    [string]$ClientId,
    
    [Parameter(Mandatory = $true)]
    [string]$ClientSecret,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".",
    
    [Parameter(Mandatory = $false)]
    [switch]$IncludeNonCompliant
)

# Import required modules
try {
    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
    Import-Module Microsoft.Graph.DeviceManagement -ErrorAction Stop
    Write-Host "Required modules imported successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to import required modules. Please install Microsoft.Graph modules: Install-Module Microsoft.Graph"
    exit 1
}

# Function to connect to Microsoft Graph
function Connect-ToGraph {
    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )
    
    try {
        $SecureSecret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($ClientId, $SecureSecret)
        
        Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $Credential -NoWelcome
        Write-Host "Successfully connected to Microsoft Graph" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
        return $false
    }
}

# Function to get all managed devices
function Get-IntuneDevices {
    try {
        Write-Host "Retrieving Intune managed devices..." -ForegroundColor Yellow
        
        $devices = Get-MgDeviceManagementManagedDevice -All
        Write-Host "Retrieved $($devices.Count) devices" -ForegroundColor Green
        
        return $devices
    }
    catch {
        Write-Error "Failed to retrieve devices: $($_.Exception.Message)"
        return $null
    }
}

# Function to get device compliance policies
function Get-DeviceCompliancePolicies {
    try {
        Write-Host "Retrieving device compliance policies..." -ForegroundColor Yellow
        
        $policies = Get-MgDeviceManagementDeviceCompliancePolicy -All
        Write-Host "Retrieved $($policies.Count) compliance policies" -ForegroundColor Green
        
        return $policies
    }
    catch {
        Write-Error "Failed to retrieve compliance policies: $($_.Exception.Message)"
        return $null
    }
}

# Function to process device data and create report
function New-DeviceReport {
    param(
        [array]$Devices,
        [array]$CompliancePolicies,
        [bool]$NonCompliantOnly
    )
    
    $report = @()
    $totalDevices = $devices.Count
    $processedCount = 0
    
    foreach ($device in $devices) {
        $processedCount++
        Write-Progress -Activity "Processing Devices" -Status "Device $processedCount of $totalDevices" -PercentComplete (($processedCount / $totalDevices) * 100)
        
        # Skip compliant devices if only non-compliant requested
        if ($NonCompliantOnly -and $device.ComplianceState -eq "compliant") {
            continue
        }
        
        # Create device report object
        $deviceReport = [PSCustomObject]@{
            DeviceName = $device.DeviceName
            UserPrincipalName = $device.UserPrincipalName
            UserDisplayName = $device.UserDisplayName
            DeviceId = $device.Id
            SerialNumber = $device.SerialNumber
            Manufacturer = $device.Manufacturer
            Model = $device.Model
            OperatingSystem = $device.OperatingSystem
            OSVersion = $device.OSVersion
            ComplianceState = $device.ComplianceState
            DeviceEnrollmentType = $device.DeviceEnrollmentType
            ManagementAgent = $device.ManagementAgent
            IsEncrypted = $device.IsEncrypted
            IsSupervised = $device.IsSupervised
            ExchangeAccessState = $device.ExchangeAccessState
            ExchangeAccessStateReason = $device.ExchangeAccessStateReason
            LastSyncDateTime = $device.LastSyncDateTime
            EasActivated = $device.EasActivated
            AzureADRegistered = $device.AzureADRegistered
            DeviceRegistrationState = $device.DeviceRegistrationState
            DeviceCategoryDisplayName = $device.DeviceCategoryDisplayName
            IsRooted = $device.IsRooted
            ManagementState = $device.ManagementState
            EmailAddress = $device.EmailAddress
            WiFiMacAddress = $device.WiFiMacAddress
            EthernetMacAddress = $device.EthernetMacAddress
            TotalStorageSpaceInBytes = [math]::Round($device.TotalStorageSpaceInBytes / 1GB, 2)
            FreeStorageSpaceInBytes = [math]::Round($device.FreeStorageSpaceInBytes / 1GB, 2)
            IMEI = $device.IMEI
            MEID = $device.MEID
            SubscriberCarrier = $device.SubscriberCarrier
            PhoneNumber = $device.PhoneNumber
            AndroidSecurityPatchLevel = $device.AndroidSecurityPatchLevel
            ConfigurationManagerClientEnabledFeatures = $device.ConfigurationManagerClientEnabledFeatures
        }
        
        $report += $deviceReport
    }
    
    Write-Progress -Activity "Processing Devices" -Completed
    return $report
}

# Function to export report to CSV
function Export-ReportToCsv {
    param(
        [array]$ReportData,
        [string]$OutputPath,
        [bool]$NonCompliantOnly
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $suffix = if ($NonCompliantOnly) { "_NonCompliant" } else { "_All" }
    $fileName = "IntuneDeviceReport$suffix`_$timestamp.csv"
    $fullPath = Join-Path $OutputPath $fileName
    
    try {
        $ReportData | Export-Csv -Path $fullPath -NoTypeInformation -Encoding UTF8
        Write-Host "Report exported successfully to: $fullPath" -ForegroundColor Green
        Write-Host "Total devices in report: $($ReportData.Count)" -ForegroundColor Cyan
        
        return $fullPath
    }
    catch {
        Write-Error "Failed to export report: $($_.Exception.Message)"
        return $null
    }
}

# Function to display summary statistics
function Show-ReportSummary {
    param([array]$ReportData)
    
    Write-Host "`n=== INTUNE DEVICE REPORT SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Total Devices: $($ReportData.Count)" -ForegroundColor White
    
    # Compliance Summary
    $complianceStats = $ReportData | Group-Object ComplianceState
    Write-Host "`nCompliance Status:" -ForegroundColor Yellow
    foreach ($stat in $complianceStats) {
        $percentage = [math]::Round(($stat.Count / $ReportData.Count) * 100, 1)
        Write-Host "  $($stat.Name): $($stat.Count) ($percentage%)" -ForegroundColor White
    }
    
    # OS Summary
    $osStats = $ReportData | Group-Object OperatingSystem
    Write-Host "`nOperating Systems:" -ForegroundColor Yellow
    foreach ($stat in $osStats) {
        $percentage = [math]::Round(($stat.Count / $ReportData.Count) * 100, 1)
        Write-Host "  $($stat.Name): $($stat.Count) ($percentage%)" -ForegroundColor White
    }
    
    # Encryption Summary
    $encryptionStats = $ReportData | Group-Object IsEncrypted
    Write-Host "`nDevice Encryption:" -ForegroundColor Yellow
    foreach ($stat in $encryptionStats) {
        $percentage = [math]::Round(($stat.Count / $ReportData.Count) * 100, 1)
        $encryptionStatus = if ($stat.Name -eq "True") { "Encrypted" } else { "Not Encrypted" }
        Write-Host "  $encryptionStatus: $($stat.Count) ($percentage%)" -ForegroundColor White
    }
    
    Write-Host "`n====================================" -ForegroundColor Cyan
}

# Main execution
Write-Host "Starting Intune Device Report Generation..." -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Gray

# Connect to Microsoft Graph
if (-not (Connect-ToGraph -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret)) {
    Write-Error "Unable to connect to Microsoft Graph. Exiting."
    exit 1
}

# Get devices and compliance policies
$devices = Get-IntuneDevices
if (-not $devices) {
    Write-Error "No devices retrieved. Exiting."
    Disconnect-MgGraph
    exit 1
}

$compliancePolicies = Get-DeviceCompliancePolicies

# Generate report
Write-Host "Generating device report..." -ForegroundColor Yellow
$reportData = New-DeviceReport -Devices $devices -CompliancePolicies $compliancePolicies -NonCompliantOnly $IncludeNonCompliant.IsPresent

if ($reportData.Count -eq 0) {
    Write-Warning "No devices match the specified criteria."
    Disconnect-MgGraph
    exit 0
}

# Export report
$exportedFile = Export-ReportToCsv -ReportData $reportData -OutputPath $OutputPath -NonCompliantOnly $IncludeNonCompliant.IsPresent

if ($exportedFile) {
    # Display summary
    Show-ReportSummary -ReportData $reportData
    
    Write-Host "`nReport generation completed successfully!" -ForegroundColor Green
    Write-Host "File location: $exportedFile" -ForegroundColor Cyan
} else {
    Write-Error "Failed to export report."
}

# Cleanup
Disconnect-MgGraph
Write-Host "Disconnected from Microsoft Graph" -ForegroundColor Gray

# End of script
