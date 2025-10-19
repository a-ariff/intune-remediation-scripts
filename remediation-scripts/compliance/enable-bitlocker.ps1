# BitLocker Enablement Remediation Script
# Purpose: Enable BitLocker encryption on system drives with safe execution
# Author: Intune Remediation Scripts
# Date: 2025-08-14

param(
    [switch]$WhatIf = $false
)

# Set execution policy temporarily for script execution
# Removed execution policy - script runs under default policy

# Import required modules
try {
    Import-Module BitLocker -ErrorAction Stop
    Write-Output "BitLocker module imported successfully"
} catch {
    Write-Error "BitLocker module not available. This script requires Windows 8/Server 2012 or newer with BitLocker feature installed."
    exit 1
}

# Function to check BitLocker status
function Get-BitLockerStatus {
    param(
        [string]$Drive = "C:"
    )
    
    try {
        $blvStatus = Get-BitLockerVolume -MountPoint $Drive -ErrorAction Stop
        return $blvStatus
    } catch {
        Write-Error "Failed to get BitLocker status for drive ${Drive}: $($_.Exception.Message)"
        return $null
    }
}

# Function to check TPM status
function Get-TpmStatus {
    try {
        $tpm = Get-Tpm -ErrorAction Stop
        return [PSCustomObject]@{
            TpmPresent = $tpm.TpmPresent
            TpmReady = $tpm.TpmReady
            TpmEnabled = $tpm.TpmEnabled
            TpmActivated = $tpm.TpmActivated
        }
    } catch {
        Write-Warning "Failed to get TPM status: $($_.Exception.Message)"
        return [PSCustomObject]@{
            TpmPresent = $false
            TpmReady = $false
            TpmEnabled = $false
            TpmActivated = $false
        }
    }
}

# Function to check if system is ready for BitLocker
function Test-BitLockerReadiness {
    $issues = @()
    
    # Check TPM
    $tpmStatus = Get-TpmStatus
    if (-not $tpmStatus.TpmPresent) {
        $issues += "TPM is not present on this system"
    } elseif (-not $tpmStatus.TpmReady) {
        $issues += "TPM is present but not ready"
    }
    
    # Check if system drive is NTFS
    $systemDrive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
    if ($systemDrive.FileSystem -ne "NTFS") {
        $issues += "System drive is not formatted with NTFS"
    }
    
    # Check available space (BitLocker needs some free space)
    $freeSpaceGB = [math]::Round($systemDrive.FreeSpace / 1GB, 2)
    if ($freeSpaceGB -lt 1) {
        $issues += "Insufficient free space on system drive (requires at least 1GB)"
    }
    
    return [PSCustomObject]@{
        IsReady = ($issues.Count -eq 0)
        Issues = $issues
    }
}

# Function to enable BitLocker
function Enable-BitLockerEncryption {
    param(
        [string]$Drive = "C:",
        [switch]$WhatIf
    )
    
    try {
        if ($WhatIf) {
            Write-Output "[WHATIF] Would enable BitLocker encryption on drive $Drive"
            Write-Output "[WHATIF] Would use TPM as key protector"
            Write-Output "[WHATIF] Would start encryption process"
            return $true
        }
        
        Write-Output "Enabling BitLocker on drive $Drive..."
        
        # Enable BitLocker with TPM protector
        $result = Enable-BitLocker -MountPoint $Drive -TpmProtector -ErrorAction Stop
        
        if ($result) {
            Write-Output "BitLocker enabled successfully on drive $Drive"
            
            # Start encryption
            Write-Output "Starting encryption process..."
            Resume-BitLocker -MountPoint $Drive -ErrorAction Stop
            
            return $true
        } else {
            Write-Warning "Failed to enable BitLocker on drive $Drive"
            return $false
        }
        
    } catch {
        Write-Error "Failed to enable BitLocker: $($_.Exception.Message)"
        return $false
    }
}

# Function to check encryption progress
function Get-EncryptionProgress {
    param([string]$Drive = "C:")
    
    try {
        $status = Get-BitLockerVolume -MountPoint $Drive -ErrorAction Stop
        
        return [PSCustomObject]@{
            VolumeStatus = $status.VolumeStatus
            EncryptionPercentage = $status.EncryptionPercentage
            ProtectionStatus = $status.ProtectionStatus
        }
    } catch {
        Write-Warning "Failed to get encryption progress: $($_.Exception.Message)"
        return $null
    }
}

# Main execution
try {
    Write-Output "Starting BitLocker enablement remediation script"
    
    if ($WhatIf) {
        Write-Output "[WHATIF] Running in simulation mode - no changes will be made"
    }
    
    # Check current BitLocker status
    Write-Output "Checking current BitLocker status..."
    $currentStatus = Get-BitLockerStatus -Drive "C:"
    
    if ($currentStatus) {
        Write-Output "Current BitLocker Status:"
        Write-Output "  - Volume Status: $($currentStatus.VolumeStatus)"
        Write-Output "  - Protection Status: $($currentStatus.ProtectionStatus)"
        Write-Output "  - Encryption Percentage: $($currentStatus.EncryptionPercentage)%"
        
        # Check if BitLocker is already fully enabled and encrypted
        if ($currentStatus.VolumeStatus -eq "FullyEncrypted" -and $currentStatus.ProtectionStatus -eq "On") {
            Write-Output "BitLocker is already fully enabled and encrypted on drive C:"
            exit 0
        }
        
        # Check if encryption is in progress
        if ($currentStatus.VolumeStatus -eq "EncryptionInProgress") {
            Write-Output "BitLocker encryption is already in progress on drive C:"
            Write-Output "Current progress: $($currentStatus.EncryptionPercentage)%"
            exit 0
        }
    }
    
    # Check system readiness
    Write-Output "Checking system readiness for BitLocker..."
    $readinessCheck = Test-BitLockerReadiness
    
    if (-not $readinessCheck.IsReady) {
        Write-Warning "System is not ready for BitLocker encryption:"
        foreach ($issue in $readinessCheck.Issues) {
            Write-Warning "  - $issue"
        }
        exit 1
    }
    
    Write-Output "System is ready for BitLocker encryption"
    
    # Enable BitLocker
    $enableResult = Enable-BitLockerEncryption -Drive "C:" -WhatIf:$WhatIf
    
    if ($enableResult) {
        if (-not $WhatIf) {
            Write-Output "Waiting for encryption to start..."
            Start-Sleep -Seconds 5
            
            # Check encryption progress
            $progress = Get-EncryptionProgress -Drive "C:"
            if ($progress) {
                Write-Output "Encryption Progress:"
                Write-Output "  - Volume Status: $($progress.VolumeStatus)"
                Write-Output "  - Encryption Percentage: $($progress.EncryptionPercentage)%"
                Write-Output "  - Protection Status: $($progress.ProtectionStatus)"
            }
        }
        
        Write-Output "BitLocker enablement completed successfully"
        exit 0
    } else {
        Write-Error "Failed to enable BitLocker"
        exit 1
    }
    
} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}

# End of script
