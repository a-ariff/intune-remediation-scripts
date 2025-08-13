<#
.SYNOPSIS
    Memory Usage Detection Script for Microsoft Intune

.DESCRIPTION
    Detects high memory usage conditions on Windows systems.
    This script monitors memory consumption and reports if it exceeds specified thresholds.
    Safe for production use with comprehensive error handling and WhatIf support.

.PARAMETER MaxMemoryUsagePercent
    Maximum allowed memory usage percentage (default: 85)

.PARAMETER WhatIf
    Shows what would be detected without making any changes

.NOTES
    Version: 1.0
    Author: Intune Remediation Scripts
    Creation Date: 2025-08-14
    
    Exit Codes:
    0 = Success (normal memory usage)
    1 = Issue detected (high memory usage)
    2 = Script error
    
.EXAMPLE
    .\memory-usage-detection.ps1
    .\memory-usage-detection.ps1 -MaxMemoryUsagePercent 90 -WhatIf
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$MaxMemoryUsagePercent = 85,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Initialize logging
$LogPath = "$env:TEMP\IntuneRemediation_MemoryUsageDetection.log"
$TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Write-LogEntry {
    param([string]$Message, [string]$Level = "INFO")
    $LogEntry = "[$TimeStamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $LogEntry -Force
    Write-Output $LogEntry
}

try {
    Write-LogEntry "Starting memory usage detection script"
    Write-LogEntry "Maximum allowed memory usage: $MaxMemoryUsagePercent%"
    
    if ($WhatIf) {
        Write-LogEntry "Running in WhatIf mode - no changes will be made" "INFO"
    }
    
    # Get memory information
    $MemoryInfo = Get-WmiObject -Class Win32_OperatingSystem
    $TotalMemoryGB = [math]::Round($MemoryInfo.TotalVisibleMemorySize / 1MB, 2)
    $FreeMemoryGB = [math]::Round($MemoryInfo.FreePhysicalMemory / 1MB, 2)
    $UsedMemoryGB = $TotalMemoryGB - $FreeMemoryGB
    $MemoryUsagePercent = [math]::Round(($UsedMemoryGB / $TotalMemoryGB) * 100, 2)
    
    Write-LogEntry "Memory Statistics:"
    Write-LogEntry "  Total Memory: $TotalMemoryGB GB"
    Write-LogEntry "  Used Memory: $UsedMemoryGB GB"
    Write-LogEntry "  Free Memory: $FreeMemoryGB GB"
    Write-LogEntry "  Memory Usage: $MemoryUsagePercent%"
    
    # Check if memory usage exceeds threshold
    if ($MemoryUsagePercent -gt $MaxMemoryUsagePercent) {
        Write-LogEntry "WARNING: Memory usage ($MemoryUsagePercent%) exceeds threshold ($MaxMemoryUsagePercent%)" "WARNING"
        
        # Get top memory consuming processes for additional context
        $TopProcesses = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5
        Write-LogEntry "Top 5 memory consuming processes:"
        foreach ($Process in $TopProcesses) {
            $ProcessMemoryMB = [math]::Round($Process.WorkingSet / 1MB, 2)
            Write-LogEntry "  $($Process.Name): $ProcessMemoryMB MB"
        }
        
        if ($WhatIf) {
            Write-LogEntry "WhatIf: Would report high memory usage for remediation"
            exit 0  # In WhatIf mode, don't trigger remediation
        }
        
        Write-LogEntry "High memory usage detected - remediation required"
        exit 1  # Trigger remediation
    } else {
        Write-LogEntry "Memory usage is within acceptable limits"
        exit 0  # No remediation needed
    }
    
} catch {
    Write-LogEntry "Error occurred: $($_.Exception.Message)" "ERROR"
    Write-LogEntry "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    exit 2  # Script error
}
