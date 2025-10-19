# Windows Updates Remediation Script
# Purpose: Install available Windows updates with safe execution
# Author: Intune Remediation Scripts
# Date: 2025-08-14

param(
    [switch]$WhatIf = $false
)

## Removed execution policy change - script runs under default policy
S#et-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Import required modules
try {
    Import-Module PSWindowsUpdate -ErrorAction Stop
    Write-Output "PSWindowsUpdate module imported successfully"
} catch {
    Write-Warning "PSWindowsUpdate module not available. Installing..."
    if (-not $WhatIf) {
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
        Import-Module PSWindowsUpdate
    } else {
        Write-Output "[WHATIF] Would install PSWindowsUpdate module"
        return
    }
}

# Function to check for available updates
function Get-AvailableUpdates {
    try {
        $updates = Get-WUList -Verbose:$false
        return $updates
    } catch {
        Write-Error "Failed to retrieve available updates: $($_.Exception.Message)"
        return $null
    }
}

# Function to install updates safely
function Install-WindowsUpdates {
    param(
        [switch]$WhatIf
    )
    
    try {
        $updates = Get-AvailableUpdates
        
        if ($null -eq $updates -or $updates.Count -eq 0) {
            Write-Output "No updates available"
            return $true
        }
        
        Write-Output "Found $($updates.Count) available updates"
        
        if ($WhatIf) {
            Write-Output "[WHATIF] Would install the following updates:"
            foreach ($update in $updates) {
                Write-Output "  - $($update.Title)"
            }
            return $true
        }
        
        # Install updates (excluding driver updates for safety)
        $result = Install-WindowsUpdate -AcceptAll -IgnoreReboot -NotCategory "Drivers" -Confirm:$false
        
        if ($result) {
            Write-Output "Updates installed successfully"
            return $true
        } else {
            Write-Warning "Some updates may not have installed correctly"
            return $false
        }
        
    } catch {
        Write-Error "Failed to install updates: $($_.Exception.Message)"
        return $false
    }
}

# Main execution
try {
    Write-Output "Starting Windows Updates remediation script"
    
    if ($WhatIf) {
        Write-Output "[WHATIF] Running in simulation mode - no changes will be made"
    }
    
    $success = Install-WindowsUpdates -WhatIf:$WhatIf
    
    if ($success) {
        Write-Output "Windows Updates remediation completed successfully"
        exit 0
    } else {
        Write-Error "Windows Updates remediation failed"
        exit 1
    }
    
} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}

# End of script
