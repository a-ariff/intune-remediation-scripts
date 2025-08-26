<#
.SYNOPSIS
    Remediation script to remove stale devices from Microsoft Intune

.DESCRIPTION
    This script removes devices that have been marked as stale based on last check-in date.
    It connects to Microsoft Graph API to identify and remove devices that haven't communicated
    with Intune within the specified threshold period.

.PARAMETER DaysThreshold
    Number of days since last check-in to consider a device stale (default: 90 days)

.PARAMETER WhatIf
    Performs a dry run without actually removing devices

.EXAMPLE
    .\Remediate-StaleDevices.ps1
    Removes devices that haven't checked in for 90+ days

.EXAMPLE
    .\Remediate-StaleDevices.ps1 -DaysThreshold 60 -WhatIf
    Shows what devices would be removed (60+ days old) without actually removing them

.NOTES
    Author: a-ariff
    Version: 1.0
    Requires: Microsoft.Graph.Authentication, Microsoft.Graph.DeviceManagement modules
    Permissions: DeviceManagementManagedDevices.ReadWrite.All
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$DaysThreshold = 90,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Import required modules
try {
    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
    Import-Module Microsoft.Graph.DeviceManagement -ErrorAction Stop
    Write-Host "✓ Successfully imported required modules" -ForegroundColor Green
}
catch {
    Write-Error "Failed to import required modules: $_"
    exit 1
}

# Function to connect to Microsoft Graph
function Connect-ToGraph {
    try {
        # Connect using device code flow (interactive)
        Connect-MgGraph -Scopes "DeviceManagementManagedDevices.ReadWrite.All" -ErrorAction Stop
        Write-Host "✓ Successfully connected to Microsoft Graph" -ForegroundColor Green
        
        # Verify connection
        $context = Get-MgContext
        if ($context) {
            Write-Host "Connected as: $($context.Account)" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Error "Failed to connect to Microsoft Graph: $_"
        exit 1
    }
}

# Function to get stale devices
function Get-StaleDevices {
    param(
        [int]$ThresholdDays
    )
    
    try {
        Write-Host "Searching for devices older than $ThresholdDays days..." -ForegroundColor Yellow
        
        # Calculate cutoff date
        $cutoffDate = (Get-Date).AddDays(-$ThresholdDays)
        Write-Host "Cutoff date: $($cutoffDate.ToString('yyyy-MM-dd'))" -ForegroundColor Cyan
        
        # Get all managed devices
        $allDevices = Get-MgDeviceManagementManagedDevice -All
        Write-Host "Found $($allDevices.Count) total managed devices" -ForegroundColor Cyan
        
        # Filter stale devices
        $staleDevices = $allDevices | Where-Object {
            $lastSync = $null
            if ($_.LastSyncDateTime) {
                $lastSync = [DateTime]$_.LastSyncDateTime
                return $lastSync -lt $cutoffDate
            }
            return $true  # Consider devices with no sync date as stale
        }
        
        Write-Host "Found $($staleDevices.Count) stale devices" -ForegroundColor $(if ($staleDevices.Count -gt 0) { 'Red' } else { 'Green' })
        
        return $staleDevices
    }
    catch {
        Write-Error "Failed to retrieve stale devices: $_"
        return @()
    }
}

# Function to remove stale devices
function Remove-StaleDevices {
    param(
        [array]$DevicesToRemove,
        [bool]$DryRun = $false
    )
    
    if ($DevicesToRemove.Count -eq 0) {
        Write-Host "✓ No stale devices found to remove" -ForegroundColor Green
        return
    }
    
    Write-Host "`nStale devices found:" -ForegroundColor Yellow
    Write-Host "===================" -ForegroundColor Yellow
    
    foreach ($device in $DevicesToRemove) {
        $lastSync = if ($device.LastSyncDateTime) { 
            [DateTime]$device.LastSyncDateTime 
        } else { 
            "Never" 
        }
        
        $daysSinceSync = if ($lastSync -ne "Never") {
            [math]::Round((New-TimeSpan -Start $lastSync -End (Get-Date)).TotalDays)
        } else {
            "N/A"
        }
        
        Write-Host "Device: $($device.DeviceName)" -ForegroundColor White
        Write-Host "  - ID: $($device.Id)" -ForegroundColor Gray
        Write-Host "  - OS: $($device.OperatingSystem)" -ForegroundColor Gray
        Write-Host "  - Last Sync: $lastSync" -ForegroundColor Gray
        Write-Host "  - Days Since Sync: $daysSinceSync" -ForegroundColor Gray
        Write-Host "  - Enrollment: $($device.EnrolledDateTime)" -ForegroundColor Gray
        Write-Host ""
    }
    
    if ($DryRun) {
        Write-Host "[WHAT-IF] Would remove $($DevicesToRemove.Count) stale devices" -ForegroundColor Magenta
        return
    }
    
    # Confirm removal
    $confirmation = Read-Host "Are you sure you want to remove $($DevicesToRemove.Count) stale devices? (y/N)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-Host "Operation cancelled by user" -ForegroundColor Yellow
        return
    }
    
    # Remove devices
    $successCount = 0
    $failureCount = 0
    
    Write-Host "`nRemoving stale devices..." -ForegroundColor Yellow
    
    foreach ($device in $DevicesToRemove) {
        try {
            Write-Host "Removing: $($device.DeviceName)" -ForegroundColor Yellow
            Remove-MgDeviceManagementManagedDevice -ManagedDeviceId $device.Id -ErrorAction Stop
            Write-Host "✓ Successfully removed: $($device.DeviceName)" -ForegroundColor Green
            $successCount++
        }
        catch {
            Write-Error "✗ Failed to remove $($device.DeviceName): $_"
            $failureCount++
        }
    }
    
    # Summary
    Write-Host "`n" -NoNewline
    Write-Host "Remediation Summary:" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host "Successfully removed: $successCount devices" -ForegroundColor Green
    Write-Host "Failed to remove: $failureCount devices" -ForegroundColor Red
    Write-Host "Total processed: $($DevicesToRemove.Count) devices" -ForegroundColor White
}

# Main execution
try {
    Write-Host "Intune Stale Device Remediation Script" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "Threshold: $DaysThreshold days" -ForegroundColor White
    Write-Host "What-If Mode: $($WhatIf.IsPresent)" -ForegroundColor White
    Write-Host ""
    
    # Connect to Microsoft Graph
    Connect-ToGraph
    
    # Get stale devices
    $staleDevices = Get-StaleDevices -ThresholdDays $DaysThreshold
    
    # Remove stale devices
    Remove-StaleDevices -DevicesToRemove $staleDevices -DryRun $WhatIf.IsPresent
    
    Write-Host "`n✓ Script completed successfully" -ForegroundColor Green
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
finally {
    # Disconnect from Microsoft Graph
    try {
        Disconnect-MgGraph -ErrorAction SilentlyContinue
        Write-Host "✓ Disconnected from Microsoft Graph" -ForegroundColor Green
    }
    catch {
        # Ignore disconnection errors
    }
}
