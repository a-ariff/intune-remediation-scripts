# Temporary Files Cleanup Remediation Script
# Purpose: Clean up temporary files and folders to improve system performance
# Author: Intune Remediation Scripts
# Date: 2025-08-14

param(
    [switch]$WhatIf = $false,
    [int]$DaysOld = 7,
    [switch]$IncludeRecycleBin = $false
)

# Set execution policy temporarily for script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Define temp directories to clean
$TempDirectories = @(
    $env:TEMP,
    $env:TMP,
    "$env:LOCALAPPDATA\Temp",
    "$env:WINDIR\Temp",
    "$env:WINDIR\Prefetch",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
    "$env:LOCALAPPDATA\Microsoft\Windows\Temporary Internet Files"
)

# Define file extensions to clean
$TempExtensions = @(
    "*.tmp",
    "*.temp",
    "*.log",
    "*.dmp",
    "*.chk",
    "*.old",
    "*.bak"
)

# Function to get file size in a readable format
function Get-ReadableFileSize {
    param([long]$Size)
    
    $Units = @("B", "KB", "MB", "GB", "TB")
    $Index = 0
    
    while ($Size -gt 1024 -and $Index -lt $Units.Length - 1) {
        $Size = $Size / 1024
        $Index++
    }
    
    return "{0:N2} {1}" -f $Size, $Units[$Index]
}

# Function to safely delete files and folders
function Remove-TempItems {
    param(
        [string]$Path,
        [string[]]$Extensions,
        [int]$DaysOld,
        [switch]$WhatIf
    )
    
    $ItemsRemoved = 0
    $SizeFreed = 0
    $Errors = 0
    
    try {
        if (-not (Test-Path $Path)) {
            Write-Verbose "Path does not exist: $Path"
            return [PSCustomObject]@{ ItemsRemoved = 0; SizeFreed = 0; Errors = 0 }
        }
        
        Write-Output "Processing directory: $Path"
        
        # Calculate cutoff date
        $CutoffDate = (Get-Date).AddDays(-$DaysOld)
        
        # Get files to delete
        $FilesToDelete = @()
        foreach ($extension in $Extensions) {
            try {
                $files = Get-ChildItem -Path $Path -Filter $extension -Recurse -File -ErrorAction SilentlyContinue |
                         Where-Object { $_.LastWriteTime -lt $CutoffDate }
                $FilesToDelete += $files
            } catch {
                Write-Verbose "Error getting files with extension $extension in $Path: $($_.Exception.Message)"
            }
        }
        
        # Also get old directories (empty or containing only temp files)
        $DirectoriesToDelete = @()
        try {
            $DirectoriesToDelete = Get-ChildItem -Path $Path -Directory -Recurse -ErrorAction SilentlyContinue |
                                  Where-Object { $_.LastWriteTime -lt $CutoffDate }
        } catch {
            Write-Verbose "Error getting directories in $Path: $($_.Exception.Message)"
        }
        
        # Process files
        foreach ($file in $FilesToDelete) {
            try {
                if ($WhatIf) {
                    Write-Output "[WHATIF] Would delete file: $($file.FullName) ($(Get-ReadableFileSize $file.Length))"
                    $ItemsRemoved++
                    $SizeFreed += $file.Length
                } else {
                    $fileSize = $file.Length
                    Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                    Write-Verbose "Deleted file: $($file.FullName)"
                    $ItemsRemoved++
                    $SizeFreed += $fileSize
                }
            } catch {
                Write-Warning "Failed to delete file $($file.FullName): $($_.Exception.Message)"
                $Errors++
            }
        }
        
        # Process empty directories
        foreach ($directory in ($DirectoriesToDelete | Sort-Object FullName -Descending)) {
            try {
                # Check if directory is empty or contains only files we're about to delete
                $remainingItems = Get-ChildItem -Path $directory.FullName -Recurse -ErrorAction SilentlyContinue
                
                if ($remainingItems.Count -eq 0) {
                    if ($WhatIf) {
                        Write-Output "[WHATIF] Would delete empty directory: $($directory.FullName)"
                        $ItemsRemoved++
                    } else {
                        Remove-Item -Path $directory.FullName -Force -Recurse -ErrorAction Stop
                        Write-Verbose "Deleted empty directory: $($directory.FullName)"
                        $ItemsRemoved++
                    }
                }
            } catch {
                Write-Warning "Failed to delete directory $($directory.FullName): $($_.Exception.Message)"
                $Errors++
            }
        }
        
    } catch {
        Write-Error "Failed to process directory $Path: $($_.Exception.Message)"
        $Errors++
    }
    
    return [PSCustomObject]@{
        ItemsRemoved = $ItemsRemoved
        SizeFreed = $SizeFreed
        Errors = $Errors
    }
}

# Function to clean recycle bin
function Clear-RecycleBin {
    param([switch]$WhatIf)
    
    try {
        if ($WhatIf) {
            Write-Output "[WHATIF] Would empty the Recycle Bin"
            return [PSCustomObject]@{ Success = $true; Error = $null }
        } else {
            # Clear recycle bin using shell application
            $shell = New-Object -ComObject Shell.Application
            $recycleBin = $shell.Namespace(0xA)
            
            if ($recycleBin.Items().Count -gt 0) {
                $recycleBin.Items() | ForEach-Object { $_.InvokeVerb("delete") }
                Write-Output "Recycle Bin emptied successfully"
            } else {
                Write-Output "Recycle Bin is already empty"
            }
            
            return [PSCustomObject]@{ Success = $true; Error = $null }
        }
    } catch {
        $errorMsg = "Failed to empty Recycle Bin: $($_.Exception.Message)"
        Write-Warning $errorMsg
        return [PSCustomObject]@{ Success = $false; Error = $errorMsg }
    }
}

# Function to run disk cleanup
function Start-DiskCleanup {
    param([switch]$WhatIf)
    
    try {
        if ($WhatIf) {
            Write-Output "[WHATIF] Would run Windows Disk Cleanup utility"
            return $true
        } else {
            Write-Output "Running Windows Disk Cleanup..."
            
            # Run disk cleanup silently
            $cleanupProcess = Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait -PassThru -WindowStyle Hidden
            
            if ($cleanupProcess.ExitCode -eq 0) {
                Write-Output "Disk Cleanup completed successfully"
                return $true
            } else {
                Write-Warning "Disk Cleanup completed with exit code: $($cleanupProcess.ExitCode)"
                return $false
            }
        }
    } catch {
        Write-Warning "Failed to run Disk Cleanup: $($_.Exception.Message)"
        return $false
    }
}

# Function to check available disk space
function Get-DiskSpaceInfo {
    param([string]$Drive = "C:")
    
    try {
        $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$Drive'"
        
        return [PSCustomObject]@{
            Drive = $Drive
            TotalSize = $disk.Size
            FreeSpace = $disk.FreeSpace
            UsedSpace = $disk.Size - $disk.FreeSpace
            FreeSpacePercent = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)
        }
    } catch {
        Write-Warning "Failed to get disk space information for $Drive: $($_.Exception.Message)"
        return $null
    }
}

# Main execution
try {
    Write-Output "Starting temporary files cleanup remediation script"
    
    if ($WhatIf) {
        Write-Output "[WHATIF] Running in simulation mode - no changes will be made"
    }
    
    Write-Output "Configuration:"
    Write-Output "  - Days old threshold: $DaysOld"
    Write-Output "  - Include Recycle Bin: $IncludeRecycleBin"
    
    # Get initial disk space
    $initialDiskSpace = Get-DiskSpaceInfo
    if ($initialDiskSpace) {
        Write-Output "Initial disk space on $($initialDiskSpace.Drive):"
        Write-Output "  - Total: $(Get-ReadableFileSize $initialDiskSpace.TotalSize)"
        Write-Output "  - Free: $(Get-ReadableFileSize $initialDiskSpace.FreeSpace) ($($initialDiskSpace.FreeSpacePercent)%)"
    }
    
    $totalItemsRemoved = 0
    $totalSizeFreed = 0
    $totalErrors = 0
    
    # Clean temp directories
    foreach ($tempDir in $TempDirectories) {
        if ([string]::IsNullOrEmpty($tempDir)) { continue }
        
        $result = Remove-TempItems -Path $tempDir -Extensions $TempExtensions -DaysOld $DaysOld -WhatIf:$WhatIf
        $totalItemsRemoved += $result.ItemsRemoved
        $totalSizeFreed += $result.SizeFreed
        $totalErrors += $result.Errors
    }
    
    # Clear recycle bin if requested
    if ($IncludeRecycleBin) {
        $recycleBinResult = Clear-RecycleBin -WhatIf:$WhatIf
        if (-not $recycleBinResult.Success) {
            $totalErrors++
        }
    }
    
    # Run disk cleanup
    $diskCleanupSuccess = Start-DiskCleanup -WhatIf:$WhatIf
    if (-not $diskCleanupSuccess) {
        $totalErrors++
    }
    
    # Get final disk space
    if (-not $WhatIf) {
        Start-Sleep -Seconds 2  # Allow time for cleanup to complete
        $finalDiskSpace = Get-DiskSpaceInfo
        if ($finalDiskSpace -and $initialDiskSpace) {
            $spaceFreed = $finalDiskSpace.FreeSpace - $initialDiskSpace.FreeSpace
            Write-Output "Final disk space on $($finalDiskSpace.Drive):"
            Write-Output "  - Total: $(Get-ReadableFileSize $finalDiskSpace.TotalSize)"
            Write-Output "  - Free: $(Get-ReadableFileSize $finalDiskSpace.FreeSpace) ($($finalDiskSpace.FreeSpacePercent)%)"
            Write-Output "  - Space freed: $(Get-ReadableFileSize $spaceFreed)"
        }
    }
    
    # Summary
    Write-Output "Cleanup Summary:"
    Write-Output "  - Items processed: $totalItemsRemoved"
    Write-Output "  - Size freed: $(Get-ReadableFileSize $totalSizeFreed)"
    Write-Output "  - Errors encountered: $totalErrors"
    
    if ($totalErrors -eq 0) {
        Write-Output "Temporary files cleanup completed successfully"
        exit 0
    } else {
        Write-Warning "Temporary files cleanup completed with $totalErrors errors"
        exit 1
    }
    
} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}

# End of script
