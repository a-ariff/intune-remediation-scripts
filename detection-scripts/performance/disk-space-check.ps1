<#
.SYNOPSIS
    Disk Space Detection Script for Microsoft Intune

.DESCRIPTION
    Detects low disk space conditions on system drives.
    This script checks available free space and reports if it falls below specified thresholds.
    Safe for production use with comprehensive error handling.

.PARAMETER MinimumFreeSpaceGB
    Minimum required free space in GB (default: 10)

.PARAMETER WhatIf
    Shows what would be detected without making any changes

.NOTES
    Version: 1.0
    Author: Intune Remediation Scripts
    Creation Date: 2025-08-14
    
    Exit Codes:
    0 = Success (sufficient disk space)
    1 = Issue detected (low disk space)
    2 = Script error
    
.EXAMPLE
    .\disk-space-check.ps1
    .\disk-space-check.ps1 -MinimumFreeSpaceGB 20 -WhatIf
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$MinimumFreeSpaceGB = 10,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Initialize logging
$LogPath = "$env:TEMP\IntuneRemediation_DiskSpaceDetection.log"
$TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Write-LogEntry {
    param([string]$Message, [string]$Level = "INFO")
    $LogEntry = "[$TimeStamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $LogEntry -Force
    Write-Output $LogEntry
}

try {
    Write-LogEntry "Starting disk space detection script"
    Write-LogEntry "Minimum required free space: $MinimumFreeSpaceGB GB"
    
    if ($WhatIf) {
        Write-LogEntry "Running in WhatIf mode - no changes will be made" "INFO"
    }
    
    # Get system drives (typically C: drive)
    $SystemDrives = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" | Where-Object { $_.DeviceID -eq "C:" }
    
    $IssueDetected = $false
    
    foreach ($Drive in $SystemDrives) {
        $FreeSpaceGB = [math]::Round($Drive.FreeSpace / 1GB, 2)
        $TotalSpaceGB = [math]::Round($Drive.Size / 1GB, 2)
        $UsedSpaceGB = $TotalSpaceGB - $FreeSpaceGB
        $PercentFree = [math]::Round(($FreeSpaceGB / $TotalSpaceGB) * 100, 2)
        
        Write-LogEntry "Drive $($Drive.DeviceID) - Total: $TotalSpaceGB GB, Free: $FreeSpaceGB GB, Used: $UsedSpaceGB GB ($PercentFree% free)"
        
        if ($FreeSpaceGB -lt $MinimumFreeSpaceGB) {
            Write-LogEntry "WARNING: Drive $($Drive.DeviceID) has insufficient free space: $FreeSpaceGB GB (minimum required: $MinimumFreeSpaceGB GB)" "WARNING"
            $IssueDetected = $true
        } else {
            Write-LogEntry "Drive $($Drive.DeviceID) has sufficient free space"
        }
    }
    
    if ($IssueDetected) {
        Write-LogEntry "Disk space issue detected - remediation required"
        if ($WhatIf) {
            Write-LogEntry "WhatIf: Would report disk space issue for remediation"
            exit 0  # In WhatIf mode, don't trigger remediation
        }
        exit 1  # Trigger remediation
    } else {
        Write-LogEntry "All drives have sufficient free space"
        exit 0  # No remediation needed
    }
    
} catch {
    Write-LogEntry "Error occurred: $($_.Exception.Message)" "ERROR"
    Write-LogEntry "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    exit 2  # Script error
}
