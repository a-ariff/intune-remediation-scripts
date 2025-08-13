# Software Update Remediation Script
# Purpose: Update installed software packages with safe execution
# Author: Intune Remediation Scripts
# Date: 2025-08-14

param(
    [switch]$WhatIf = $false,
    [string[]]$IncludePackages = @(),
    [string[]]$ExcludePackages = @()
)

# Set execution policy temporarily for script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Function to check if Winget is available
function Test-WingetAvailability {
    try {
        $winget = Get-Command winget -ErrorAction Stop
        Write-Output "Winget is available at: $($winget.Source)"
        return $true
    } catch {
        Write-Warning "Winget is not available on this system"
        return $false
    }
}

# Function to get outdated packages
function Get-OutdatedPackages {
    try {
        Write-Output "Checking for available software updates..."
        $upgrades = winget upgrade --accept-source-agreements 2>$null | Out-String
        
        if ($upgrades -match "No available upgrades") {
            Write-Output "No software updates available"
            return @()
        }
        
        # Parse winget output to get package list
        $lines = $upgrades -split "`n" | Where-Object { $_ -match "^[^-]+\s+[^-]+\s+[^-]+\s+[^-]+" -and $_ -notmatch "^Name" }
        
        $packages = @()
        foreach ($line in $lines) {
            if ($line.Trim() -ne "") {
                $parts = $line -split "\s{2,}" | Where-Object { $_.Trim() -ne "" }
                if ($parts.Count -ge 3) {
                    $packages += [PSCustomObject]@{
                        Name = $parts[0].Trim()
                        Id = $parts[1].Trim()
                        Version = $parts[2].Trim()
                        Available = if ($parts.Count -gt 3) { $parts[3].Trim() } else { "Unknown" }
                    }
                }
            }
        }
        
        Write-Output "Found $($packages.Count) packages with available updates"
        return $packages
        
    } catch {
        Write-Error "Failed to check for software updates: $($_.Exception.Message)"
        return @()
    }
}

# Function to filter packages based on include/exclude lists
function Get-FilteredPackages {
    param(
        [array]$Packages,
        [string[]]$IncludeList,
        [string[]]$ExcludeList
    )
    
    $filtered = $Packages
    
    # Apply include filter if specified
    if ($IncludeList.Count -gt 0) {
        $filtered = $filtered | Where-Object {
            $package = $_
            $IncludeList | ForEach-Object {
                if ($package.Name -like "*$_*" -or $package.Id -like "*$_*") {
                    return $package
                }
            }
        }
        Write-Output "After include filter: $($filtered.Count) packages"
    }
    
    # Apply exclude filter
    if ($ExcludeList.Count -gt 0) {
        $filtered = $filtered | Where-Object {
            $package = $_
            $exclude = $false
            foreach ($excludePattern in $ExcludeList) {
                if ($package.Name -like "*$excludePattern*" -or $package.Id -like "*$excludePattern*") {
                    $exclude = $true
                    break
                }
            }
            return -not $exclude
        }
        Write-Output "After exclude filter: $($filtered.Count) packages"
    }
    
    return $filtered
}

# Function to update software packages safely
function Update-SoftwarePackages {
    param(
        [array]$Packages,
        [switch]$WhatIf
    )
    
    if ($Packages.Count -eq 0) {
        Write-Output "No packages to update"
        return $true
    }
    
    $successCount = 0
    $failureCount = 0
    
    foreach ($package in $Packages) {
        try {
            if ($WhatIf) {
                Write-Output "[WHATIF] Would update: $($package.Name) ($($package.Id)) from $($package.Version) to $($package.Available)"
                $successCount++
            } else {
                Write-Output "Updating: $($package.Name) ($($package.Id))..."
                
                # Update the package using winget
                $result = winget upgrade --id $package.Id --accept-package-agreements --accept-source-agreements --silent 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "Successfully updated: $($package.Name)"
                    $successCount++
                } else {
                    Write-Warning "Failed to update $($package.Name): $result"
                    $failureCount++
                }
            }
        } catch {
            Write-Error "Error updating $($package.Name): $($_.Exception.Message)"
            $failureCount++
        }
    }
    
    Write-Output "Update summary: $successCount successful, $failureCount failed"
    
    # Return success if more than 80% succeeded or no failures
    return ($failureCount -eq 0 -or ($successCount / ($successCount + $failureCount)) -gt 0.8)
}

# Function to check system requirements
function Test-SystemRequirements {
    try {
        # Check Windows version (Winget requires Windows 10 1709 or later)
        $osVersion = [System.Environment]::OSVersion.Version
        if ($osVersion.Major -lt 10) {
            Write-Error "This script requires Windows 10 or later"
            return $false
        }
        
        # Check if running as administrator for some updates
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        if (-not $isAdmin) {
            Write-Warning "Running without administrator privileges. Some updates may fail."
        }
        
        Write-Output "System requirements check passed"
        return $true
        
    } catch {
        Write-Warning "Cannot verify system requirements: $($_.Exception.Message)"
        return $true  # Assume compatible if we can't check
    }
}

# Main execution
try {
    Write-Output "Starting software update remediation script"
    
    if ($WhatIf) {
        Write-Output "[WHATIF] Running in simulation mode - no changes will be made"
    }
    
    if ($IncludePackages.Count -gt 0) {
        Write-Output "Include filter: $($IncludePackages -join ', ')"
    }
    
    if ($ExcludePackages.Count -gt 0) {
        Write-Output "Exclude filter: $($ExcludePackages -join ', ')"
    }
    
    # Check system requirements
    if (-not (Test-SystemRequirements)) {
        Write-Error "System requirements not met"
        exit 1
    }
    
    # Check if Winget is available
    if (-not (Test-WingetAvailability)) {
        Write-Error "Winget package manager is required but not available"
        exit 1
    }
    
    # Get list of outdated packages
    $outdatedPackages = Get-OutdatedPackages
    
    if ($outdatedPackages.Count -eq 0) {
        Write-Output "All software packages are up to date"
        exit 0
    }
    
    # Apply filters
    $packagesToUpdate = Get-FilteredPackages -Packages $outdatedPackages -IncludeList $IncludePackages -ExcludeList $ExcludePackages
    
    if ($packagesToUpdate.Count -eq 0) {
        Write-Output "No packages match the specified criteria for update"
        exit 0
    }
    
    # Update packages
    $success = Update-SoftwarePackages -Packages $packagesToUpdate -WhatIf:$WhatIf
    
    if ($success) {
        Write-Output "Software update remediation completed successfully"
        exit 0
    } else {
        Write-Error "Software update remediation completed with errors"
        exit 1
    }
    
} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}

# End of script
