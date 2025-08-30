<#
.SYNOPSIS
    Deploy macOS Browser Password Policy Script

.DESCRIPTION
    This script configures browser password management policies on macOS devices
    for use with Microsoft Intune remediation framework.
    
    The script:
    - Configures Chrome password management policies
    - Configures Safari password management policies
    - Configures Edge password management policies
    - Validates policy deployment
    - Provides detailed logging

.NOTES
    File Name: Deploy-MacOSBrowserPasswordPolicy.ps1
    Author: IT Administrator
    Purpose: Browser Password Management Configuration
    Intune Remediation Script
    Version: 1.0
    
.PARAMETER LogPath
    Path for log file output
    
.PARAMETER ChromePolicyPath
    Path to Chrome policy configuration
    
.PARAMETER SafariPolicyPath
    Path to Safari policy configuration
    
.PARAMETER EdgePolicyPath
    Path to Edge policy configuration

.EXAMPLE
    .\Deploy-MacOSBrowserPasswordPolicy.ps1
    Deploys browser password policies with default settings

.EXAMPLE
    .\Deploy-MacOSBrowserPasswordPolicy.ps1 -LogPath "/var/log/intune/browser-policy.log"
    Deploys policies with custom log path
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$LogPath = "/var/log/intune/browser-password-policy.log",
    
    [Parameter(Mandatory = $false)]
    [string]$ChromePolicyPath = "/Library/Managed Preferences/com.google.Chrome.plist",
    
    [Parameter(Mandatory = $false)]
    [string]$SafariPolicyPath = "/Library/Managed Preferences/com.apple.Safari.plist",
    
    [Parameter(Mandatory = $false)]
    [string]$EdgePolicyPath = "/Library/Managed Preferences/com.microsoft.Edge.plist"
)

# Initialize logging
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('INFO', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Ensure log directory exists
    $logDir = Split-Path -Path $LogPath -Parent
    if (-not (Test-Path -Path $logDir)) {
        try {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
        catch {
            Write-Error "Failed to create log directory: $($_.Exception.Message)"
            return
        }
    }
    
    try {
        Add-Content -Path $LogPath -Value $logEntry -ErrorAction Stop
        Write-Output $logEntry
    }
    catch {
        Write-Error "Failed to write to log file: $($_.Exception.Message)"
    }
}

# Function to check if running on macOS
function Test-MacOS {
    try {
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        return $false
    }
    catch {
        # If Win32_OperatingSystem fails, likely on non-Windows system
        if ($PSVersionTable.Platform -eq 'Unix' -or $env:OS -eq 'Darwin') {
            return $true
        }
        return $false
    }
}

# Function to deploy Chrome password policy
function Deploy-ChromePasswordPolicy {
    param(
        [string]$PolicyPath
    )
    
    Write-Log "Deploying Chrome password management policy..."
    
    $chromePolicy = @{
        'PasswordManagerEnabled' = $false
        'AutofillAddressEnabled' = $false
        'AutofillCreditCardEnabled' = $false
        'PasswordProtectionWarningTrigger' = 2
        'PasswordProtectionLoginURLs' = @(
            'https://accounts.google.com/signin'
            'https://login.microsoftonline.com'
        )
        'SyncDisabled' = $true
    }
    
    try {
        # Create policy directory if it doesn't exist
        $policyDir = Split-Path -Path $PolicyPath -Parent
        if (-not (Test-Path -Path $policyDir)) {
            New-Item -Path $policyDir -ItemType Directory -Force | Out-Null
        }
        
        # Convert to plist format and write
        $plistContent = ConvertTo-PlistXml -InputObject $chromePolicy
        Set-Content -Path $PolicyPath -Value $plistContent -Encoding UTF8
        
        Write-Log "Chrome policy deployed successfully to: $PolicyPath"
        return $true
    }
    catch {
        Write-Log "Failed to deploy Chrome policy: $($_.Exception.Message)" -Level 'ERROR'
        return $false
    }
}

# Function to deploy Safari password policy
function Deploy-SafariPasswordPolicy {
    param(
        [string]$PolicyPath
    )
    
    Write-Log "Deploying Safari password management policy..."
    
    $safariPolicy = @{
        'AutoFillPasswords' = $false
        'AutoFillCreditCardData' = $false
        'AutoFillMiscellaneousForms' = $false
        'ShowPasswordsInPreferences' = $false
    }
    
    try {
        # Create policy directory if it doesn't exist
        $policyDir = Split-Path -Path $PolicyPath -Parent
        if (-not (Test-Path -Path $policyDir)) {
            New-Item -Path $policyDir -ItemType Directory -Force | Out-Null
        }
        
        # Convert to plist format and write
        $plistContent = ConvertTo-PlistXml -InputObject $safariPolicy
        Set-Content -Path $PolicyPath -Value $plistContent -Encoding UTF8
        
        Write-Log "Safari policy deployed successfully to: $PolicyPath"
        return $true
    }
    catch {
        Write-Log "Failed to deploy Safari policy: $($_.Exception.Message)" -Level 'ERROR'
        return $false
    }
}

# Function to deploy Edge password policy
function Deploy-EdgePasswordPolicy {
    param(
        [string]$PolicyPath
    )
    
    Write-Log "Deploying Edge password management policy..."
    
    $edgePolicy = @{
        'PasswordManagerEnabled' = $false
        'AutofillAddressEnabled' = $false
        'AutofillCreditCardEnabled' = $false
        'SyncDisabled' = $true
        'PasswordProtectionWarningTrigger' = 2
    }
    
    try {
        # Create policy directory if it doesn't exist
        $policyDir = Split-Path -Path $PolicyPath -Parent
        if (-not (Test-Path -Path $policyDir)) {
            New-Item -Path $policyDir -ItemType Directory -Force | Out-Null
        }
        
        # Convert to plist format and write
        $plistContent = ConvertTo-PlistXml -InputObject $edgePolicy
        Set-Content -Path $PolicyPath -Value $plistContent -Encoding UTF8
        
        Write-Log "Edge policy deployed successfully to: $PolicyPath"
        return $true
    }
    catch {
        Write-Log "Failed to deploy Edge policy: $($_.Exception.Message)" -Level 'ERROR'
        return $false
    }
}

# Function to convert hashtable to plist XML format
function ConvertTo-PlistXml {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$InputObject
    )
    
    $xml = @'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
'@
    
    foreach ($key in $InputObject.Keys) {
        $xml += "    <key>$key</key>`n"
        $value = $InputObject[$key]
        
        if ($value -is [bool]) {
            $xml += "    <$($value.ToString().ToLower())/>"+ "`n"
        }
        elseif ($value -is [int]) {
            $xml += "    <integer>$value</integer>`n"
        }
        elseif ($value -is [array]) {
            $xml += "    <array>`n"
            foreach ($item in $value) {
                $xml += "        <string>$item</string>`n"
            }
            $xml += "    </array>`n"
        }
        else {
            $xml += "    <string>$value</string>`n"
        }
    }
    
    $xml += @'
</dict>
</plist>
'@
    
    return $xml
}

# Function to validate policy deployment
function Test-PolicyDeployment {
    param(
        [string[]]$PolicyPaths
    )
    
    Write-Log "Validating policy deployment..."
    $allValid = $true
    
    foreach ($path in $PolicyPaths) {
        if (Test-Path -Path $path) {
            try {
                $content = Get-Content -Path $path -Raw
                if ($content -match '<plist' -and $content -match '</plist>') {
                    Write-Log "Policy file valid: $path"
                }
                else {
                    Write-Log "Policy file invalid format: $path" -Level 'WARNING'
                    $allValid = $false
                }
            }
            catch {
                Write-Log "Failed to read policy file: $path - $($_.Exception.Message)" -Level 'ERROR'
                $allValid = $false
            }
        }
        else {
            Write-Log "Policy file not found: $path" -Level 'ERROR'
            $allValid = $false
        }
    }
    
    return $allValid
}

# Main execution
try {
    Write-Log "Starting macOS Browser Password Policy deployment..."
    
    # Verify running on macOS
    if (-not (Test-MacOS)) {
        Write-Log "This script is designed for macOS systems only." -Level 'ERROR'
        exit 1
    }
    
    $deploymentResults = @()
    
    # Deploy Chrome policy
    $chromeResult = Deploy-ChromePasswordPolicy -PolicyPath $ChromePolicyPath
    $deploymentResults += $chromeResult
    
    # Deploy Safari policy
    $safariResult = Deploy-SafariPasswordPolicy -PolicyPath $SafariPolicyPath
    $deploymentResults += $safariResult
    
    # Deploy Edge policy
    $edgeResult = Deploy-EdgePasswordPolicy -PolicyPath $EdgePolicyPath
    $deploymentResults += $edgeResult
    
    # Validate deployment
    $validationResult = Test-PolicyDeployment -PolicyPaths @($ChromePolicyPath, $SafariPolicyPath, $EdgePolicyPath)
    
    # Check overall success
    if ($deploymentResults -contains $false -or -not $validationResult) {
        Write-Log "Browser password policy deployment completed with errors." -Level 'WARNING'
        exit 1
    }
    else {
        Write-Log "Browser password policy deployment completed successfully."
        Write-Output "SUCCESS: macOS Browser Password Policy deployed successfully"
        exit 0
    }
}
catch {
    Write-Log "Critical error during policy deployment: $($_.Exception.Message)" -Level 'ERROR'
    Write-Error "FAILED: macOS Browser Password Policy deployment failed"
    exit 1
}
finally {
    Write-Log "macOS Browser Password Policy deployment script completed."
}
