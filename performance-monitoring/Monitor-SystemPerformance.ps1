<#
.SYNOPSIS
    System Performance Monitoring Script for Intune Remediation

.DESCRIPTION
    Monitors key system performance metrics including CPU usage, memory utilization,
    disk space, and network activity. Designed for use with Microsoft Intune
    remediation scripts to proactively identify performance issues.

.PARAMETER LogPath
    Path where performance logs will be stored

.PARAMETER ThresholdCPU
    CPU usage threshold percentage (default: 80)

.PARAMETER ThresholdMemory
    Memory usage threshold percentage (default: 85)

.PARAMETER ThresholdDisk
    Disk usage threshold percentage (default: 90)

.EXAMPLE
    .\Monitor-SystemPerformance.ps1
    Runs with default thresholds

.EXAMPLE
    .\Monitor-SystemPerformance.ps1 -ThresholdCPU 70 -ThresholdMemory 80
    Runs with custom CPU and memory thresholds

.NOTES
    Author: Intune Remediation Scripts
    Version: 1.0
    Created: $(Get-Date -Format 'yyyy-MM-dd')
#>

param(
    [string]$LogPath = "$env:TEMP\SystemPerformance.log",
    [int]$ThresholdCPU = 80,
    [int]$ThresholdMemory = 85,
    [int]$ThresholdDisk = 90
)

# Initialize variables
$ExitCode = 0
$Issues = @()
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Function to write to log file
function Write-Log {
    param([string]$Message)
    $LogEntry = "[$Timestamp] $Message"
    Write-Output $LogEntry
    Add-Content -Path $LogPath -Value $LogEntry -ErrorAction SilentlyContinue
}

# Function to get CPU usage
function Get-CPUUsage {
    try {
        $CPU = Get-WmiObject -Class Win32_Processor | 
               Measure-Object -Property LoadPercentage -Average | 
               Select-Object -ExpandProperty Average
        return [math]::Round($CPU, 2)
    }
    catch {
        Write-Log "Error getting CPU usage: $($_.Exception.Message)"
        return $null
    }
}

# Function to get memory usage
function Get-MemoryUsage {
    try {
        $OS = Get-WmiObject -Class Win32_OperatingSystem
        $TotalMemory = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
        $FreeMemory = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
        $UsedMemory = $TotalMemory - $FreeMemory
        $MemoryPercent = [math]::Round(($UsedMemory / $TotalMemory) * 100, 2)
        
        return @{
            TotalGB = $TotalMemory
            UsedGB = $UsedMemory
            FreeGB = $FreeMemory
            UsedPercent = $MemoryPercent
        }
    }
    catch {
        Write-Log "Error getting memory usage: $($_.Exception.Message)"
        return $null
    }
}

# Function to get disk usage
function Get-DiskUsage {
    try {
        $Disks = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3"
        $DiskInfo = @()
        
        foreach ($Disk in $Disks) {
            $TotalSize = [math]::Round($Disk.Size / 1GB, 2)
            $FreeSpace = [math]::Round($Disk.FreeSpace / 1GB, 2)
            $UsedSpace = $TotalSize - $FreeSpace
            $UsedPercent = [math]::Round(($UsedSpace / $TotalSize) * 100, 2)
            
            $DiskInfo += [PSCustomObject]@{
                Drive = $Disk.DeviceID
                TotalGB = $TotalSize
                UsedGB = $UsedSpace
                FreeGB = $FreeSpace
                UsedPercent = $UsedPercent
            }
        }
        
        return $DiskInfo
    }
    catch {
        Write-Log "Error getting disk usage: $($_.Exception.Message)"
        return $null
    }
}

# Function to get top processes by CPU
function Get-TopProcessesCPU {
    try {
        $Processes = Get-Process | 
                    Where-Object { $_.CPU -gt 0 } | 
                    Sort-Object CPU -Descending | 
                    Select-Object -First 5 ProcessName, CPU, WorkingSet
        return $Processes
    }
    catch {
        Write-Log "Error getting top CPU processes: $($_.Exception.Message)"
        return $null
    }
}

# Function to get network adapter statistics
function Get-NetworkStats {
    try {
        $Adapters = Get-WmiObject -Class Win32_PerfRawData_Tcpip_NetworkInterface | 
                   Where-Object { $_.Name -notlike "*Loopback*" -and $_.Name -notlike "*Isatap*" } |
                   Select-Object Name, BytesReceivedPerSec, BytesSentPerSec
        return $Adapters
    }
    catch {
        Write-Log "Error getting network statistics: $($_.Exception.Message)"
        return $null
    }
}

# Main monitoring logic
Write-Log "Starting system performance monitoring"
Write-Log "Thresholds - CPU: $ThresholdCPU%, Memory: $ThresholdMemory%, Disk: $ThresholdDisk%"

# Check CPU usage
$CPUUsage = Get-CPUUsage
if ($CPUUsage -ne $null) {
    Write-Log "CPU Usage: $CPUUsage%"
    if ($CPUUsage -gt $ThresholdCPU) {
        $Issues += "High CPU usage detected: $CPUUsage%"
        $ExitCode = 1
    }
}

# Check memory usage
$MemoryUsage = Get-MemoryUsage
if ($MemoryUsage -ne $null) {
    Write-Log "Memory Usage: $($MemoryUsage.UsedGB)GB / $($MemoryUsage.TotalGB)GB ($($MemoryUsage.UsedPercent)%)"
    if ($MemoryUsage.UsedPercent -gt $ThresholdMemory) {
        $Issues += "High memory usage detected: $($MemoryUsage.UsedPercent)%"
        $ExitCode = 1
    }
}

# Check disk usage
$DiskUsage = Get-DiskUsage
if ($DiskUsage -ne $null) {
    foreach ($Disk in $DiskUsage) {
        Write-Log "Disk $($Disk.Drive) Usage: $($Disk.UsedGB)GB / $($Disk.TotalGB)GB ($($Disk.UsedPercent)%)"
        if ($Disk.UsedPercent -gt $ThresholdDisk) {
            $Issues += "High disk usage on $($Disk.Drive): $($Disk.UsedPercent)%"
            $ExitCode = 1
        }
    }
}

# Get top CPU processes
$TopProcesses = Get-TopProcessesCPU
if ($TopProcesses -ne $null) {
    Write-Log "Top 5 CPU consuming processes:"
    foreach ($Process in $TopProcesses) {
        $CPUTime = [math]::Round($Process.CPU, 2)
        $MemoryMB = [math]::Round($Process.WorkingSet / 1MB, 2)
        Write-Log "  $($Process.ProcessName): CPU=$CPUTime, Memory=$MemoryMB MB"
    }
}

# Get network statistics
$NetworkStats = Get-NetworkStats
if ($NetworkStats -ne $null) {
    Write-Log "Network Adapters:"
    foreach ($Adapter in $NetworkStats) {
        Write-Log "  $($Adapter.Name): Bytes Received/Sent per second"
    }
}

# System uptime
try {
    $OS = Get-WmiObject -Class Win32_OperatingSystem
    $Uptime = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime)
    Write-Log "System Uptime: $($Uptime.Days) days, $($Uptime.Hours) hours, $($Uptime.Minutes) minutes"
}
catch {
    Write-Log "Error getting system uptime: $($_.Exception.Message)"
}

# Summary
if ($Issues.Count -gt 0) {
    Write-Log "Performance issues detected:"
    foreach ($Issue in $Issues) {
        Write-Log "  - $Issue"
    }
    Write-Log "Remediation may be required"
}
else {
    Write-Log "All performance metrics are within acceptable thresholds"
}

Write-Log "Performance monitoring completed"
Write-Log "Exit code: $ExitCode"

# Return appropriate exit code for Intune
# 0 = No issues detected
# 1 = Performance issues detected, remediation needed
exit $ExitCode
