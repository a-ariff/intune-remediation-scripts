# Software Update Remediation Script
# Purpose: Update installed software packages with safe execution
# Author: Intune Remediation Scripts
# Date: 2025-08-14

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$WhatIf = $false,
    [string[]]$IncludePackage = @(),
    [string[]]$ExcludePackage = @()
)

# Set execution policy temporarily for script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Function to check if Winget is available
function Test-WingetAvailability {
    [CmdletBinding()]
    param()
    
    try {
        $winget = Get-Command winget -ErrorAction Stop
        Write-Output "Winget is available at: $($winget.Source)"
        return $true
    }
    catch {
        Write-Warning "Winget is not available on this system"
        return $false
    }
}

# Function to get outdated packages
function Get-OutdatedPackage {
    [CmdletBinding()]
    param()
    
    try {
        Write-Output "Checking for available software updates..."
        $upgrades = winget upgrade --accept-source-agreements 2>$null | Out-String
        
        if ($upgrades -match "No available upgrades") {
            Write-Output "No software updates available"
            return @()
        }
        
        # Parse winget output to get package information
        $lines = $upgrades -split "`n" | Where-Object { $_ -match "^\S+\s+\S+\s+\S+\s+\S+" }
        $packages = @()
        
        foreach ($line in $lines) {
            if ($line -notmatch "^Name\s+Id\s+" -and $line -notmatch "^-+\s+-+") {
                $parts = $line -split "\s{2,}" | Where-Object { $_ -ne "" }
                if ($parts.Count -ge 4) {
                    $packages += [PSCustomObject]@{
                        Name = $parts[0].Trim()
                        Id = $parts[1].Trim()
                        Version = $parts[2].Trim()
                        Available = $parts[3].Trim()
                    }
                }
            }
        }
        
        Write-Output "Found $($packages.Count) packages with available updates"
        return $packages
    }
    catch {
        Write-Error "Failed to get outdated packages: $($_.Exception.Message)"
        return @()
    }
}

# Function to update a specific package
function Update-Package {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$PackageId,
        
        [Parameter(Mandatory)]
        [string]$PackageName
    )
    
    try {
        Write-Output "Updating package: $PackageName ($PackageId)"
        
        if ($PSCmdlet.ShouldProcess($PackageName, "Update package")) {
            $result = winget upgrade --id $PackageId --accept-package-agreements --accept-source-agreements --silent 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Output "Successfully updated: $PackageName"
                return $true
            }
            else {
                Write-Warning "Failed to update $PackageName. Exit code: $LASTEXITCODE"
                Write-Warning "Output: $result"
                return $false
            }
        }
        else {
            Write-Output "Would update package: $PackageName ($PackageId)"
            return $true
        }
    }
    catch {
        Write-Error "Error updating package $PackageName : $($_.Exception.Message)"
        return $false
    }
}

# Function to filter packages based on include/exclude lists
function Get-FilteredPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Package,
        
        [string[]]$IncludePackage = @(),
        [string[]]$ExcludePackage = @()
    )
    
    $filteredPackages = $Package
    
    # Apply include filter if specified
    if ($IncludePackage.Count -gt 0) {
        $filteredPackages = $filteredPackages | Where-Object {
            $packageItem = $_
            $IncludePackage | Where-Object {
                $packageItem.Name -like "*$_*" -or $packageItem.Id -like "*$_*"
            }
        }
        Write-Output "Filtered to $($filteredPackages.Count) packages based on include list"
    }
    
    # Apply exclude filter
    if ($ExcludePackage.Count -gt 0) {
        $filteredPackages = $filteredPackages | Where-Object {
            $packageItem = $_
            $shouldExclude = $false
            foreach ($excludePattern in $ExcludePackage) {
                if ($packageItem.Name -like "*$excludePattern*" -or $packageItem.Id -like "*$excludePattern*") {
                    $shouldExclude = $true
                    break
                }
            }
            -not $shouldExclude
        }
        Write-Output "Filtered to $($filteredPackages.Count) packages after excluding specified packages"
    }
    
    return $filteredPackages
}

# Main execution
try {
    Write-Output "Starting software update remediation script"
    Write-Output "WhatIf mode: $WhatIf"
    
    # Check if Winget is available
    if (-not (Test-WingetAvailability)) {
        Write-Error "Winget is not available. Cannot proceed with software updates."
        exit 1
    }
    
    # Get outdated packages
    $outdatedPackages = Get-OutdatedPackage
    
    if ($outdatedPackages.Count -eq 0) {
        Write-Output "No packages need updating. Exiting."
        exit 0
    }
    
    # Filter packages based on include/exclude parameters
    $packagesToUpdate = Get-FilteredPackage -Package $outdatedPackages -IncludePackage $IncludePackage -ExcludePackage $ExcludePackage
    
    if ($packagesToUpdate.Count -eq 0) {
        Write-Output "No packages match the specified criteria. Exiting."
        exit 0
    }
    
    Write-Output "Packages to update: $($packagesToUpdate.Count)"
    
    # Update packages
    $successCount = 0
    $failureCount = 0
    
    foreach ($package in $packagesToUpdate) {
        Write-Output "Processing: $($package.Name) (Current: $($package.Version), Available: $($package.Available))"
        
        $updateResult = Update-Package -PackageId $package.Id -PackageName $package.Name -WhatIf:$WhatIf
        
        if ($updateResult) {
            $successCount++
        }
        else {
            $failureCount++
        }
    }
    
    # Summary
    Write-Output "Software update summary:"
    Write-Output "  Total packages processed: $($packagesToUpdate.Count)"
    Write-Output "  Successful updates: $successCount"
    Write-Output "  Failed updates: $failureCount"
    
    if ($failureCount -gt 0) {
        Write-Warning "Some packages failed to update. Check the logs above for details."
        exit 1
    }
    else {
        Write-Output "All packages updated successfully."
        exit 0
    }
}
catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}
finally {
    # Reset execution policy (optional, as Process scope is temporary)
    Write-Output "Script execution completed."
}
