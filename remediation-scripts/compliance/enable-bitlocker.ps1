# BitLocker Enablement Remediation Script
# Purpose: Enable BitLocker encryption on system drives with safe execution
# Author: Intune Remediation Scripts
# Date: 2025-08-14

param(
    [switch]$WhatIf = $false
)

# Set execution policy temporarily for script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

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
        Write-Error "Failed to get BitLocker status for drive $Drive: $($_.Exception.Message)"
        return $null
    }
}

# Function to check TPM availability
function Test-TPMAvailability {
    try {
        $tpm = Get-WmiObject -Namespace "Root\CIMV2\Security\MicrosoftTpm" -Class Win32_Tpm -ErrorAction Stop
        if ($tpm.IsEnabled_InitialValue -and $tpm.IsActivated_InitialValue) {
            Write-Output "TPM is available and activated"
            return $true
        } else {
            Write-Warning "TPM is not properly configured"
            return $false
        }
    } catch {
        Write-Warning "TPM not available or accessible: $($_.Exception.Message)"
        return $false
    }
}

# Function to enable BitLocker safely
function Enable-BitLockerSafely {
    param(
        [string]$Drive = "C:",
        [switch]$WhatIf
    )
    
    try {
        # Check current BitLocker status
        $status = Get-BitLockerStatus -Drive $Drive
        
        if ($null -eq $status) {
            Write-Error "Cannot determine BitLocker status for drive $Drive"
            return $false
        }
        
        if ($status.VolumeStatus -eq "FullyEncrypted") {
            Write-Output "Drive $Drive is already fully encrypted with BitLocker"
            return $true
        }
        
        if ($status.VolumeStatus -eq "EncryptionInProgress") {
            Write-Output "Drive $Drive encryption is already in progress"
            return $true
        }
        
        # Check TPM availability
        $tpmAvailable = Test-TPMAvailability
        
        if ($WhatIf) {
            Write-Output "[WHATIF] Would enable BitLocker on drive $Drive"
            Write-Output "[WHATIF] Current status: $($status.VolumeStatus)"
            Write-Output "[WHATIF] Protection status: $($status.ProtectionStatus)"
            if ($tpmAvailable) {
                Write-Output "[WHATIF] Would use TPM as key protector"
            } else {
                Write-Output "[WHATIF] Would use recovery password (TPM not available)"
            }
            return $true
        }
        
        Write-Output "Enabling BitLocker on drive $Drive..."
        
        if ($tpmAvailable) {
            # Enable BitLocker with TPM
            $result = Enable-BitLocker -MountPoint $Drive -TpmProtector -SkipHardwareTest
        } else {
            # Enable BitLocker with recovery password only
            $result = Enable-BitLocker -MountPoint $Drive -RecoveryPasswordProtector -SkipHardwareTest
        }
        
        if ($result) {
            Write-Output "BitLocker enabled successfully on drive $Drive"
            
            # Get recovery key if generated
            $recoveryKeys = Get-BitLockerVolume -MountPoint $Drive | Select-Object -ExpandProperty KeyProtector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"}
            if ($recoveryKeys) {
                Write-Output "IMPORTANT: BitLocker recovery password(s) generated. Store securely!"
                foreach ($key in $recoveryKeys) {
                    Write-Output "Recovery Key ID: $($key.KeyProtectorId)"
                }
            }
            
            return $true
        } else {
            Write-Error "Failed to enable BitLocker on drive $Drive"
            return $false
        }
        
    } catch {
        Write-Error "Failed to enable BitLocker: $($_.Exception.Message)"
        return $false
    }
}

# Function to check system compatibility
function Test-BitLockerCompatibility {
    try {
        # Check Windows version
        $osVersion = [System.Environment]::OSVersion.Version
        if ($osVersion.Major -lt 6 -or ($osVersion.Major -eq 6 -and $osVersion.Minor -lt 2)) {
            Write-Error "BitLocker requires Windows 8/Server 2012 or newer"
            return $false
        }
        
        # Check if BitLocker feature is available
        $blFeature = Get-WindowsOptionalFeature -Online -FeatureName "BitLocker" -ErrorAction SilentlyContinue
        if ($blFeature -and $blFeature.State -ne "Enabled") {
            Write-Warning "BitLocker feature is not enabled"
            return $false
        }
        
        Write-Output "System is compatible with BitLocker"
        return $true
        
    } catch {
        Write-Warning "Cannot verify BitLocker compatibility: $($_.Exception.Message)"
        return $true  # Assume compatible if we can't check
    }
}

# Main execution
try {
    Write-Output "Starting BitLocker enablement remediation script"
    
    if ($WhatIf) {
        Write-Output "[WHATIF] Running in simulation mode - no changes will be made"
    }
    
    # Check system compatibility
    if (-not (Test-BitLockerCompatibility)) {
        Write-Error "System is not compatible with BitLocker"
        exit 1
    }
    
    # Enable BitLocker on C: drive
    $success = Enable-BitLockerSafely -Drive "C:" -WhatIf:$WhatIf
    
    if ($success) {
        Write-Output "BitLocker remediation completed successfully"
        exit 0
    } else {
        Write-Error "BitLocker remediation failed"
        exit 1
    }
    
} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}

# End of script
