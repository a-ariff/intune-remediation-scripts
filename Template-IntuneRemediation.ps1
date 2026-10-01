<#
.SYNOPSIS
Standard template for Intune Proactive Remediation scripts.

.DESCRIPTION
This template enforces standard logging and strictly returns Exit 0 (Success) 
or Exit 1 (Fail) to ensure Intune correctly registers the remediation status.
#>

$ErrorActionPreference = "Stop"

function Write-Log {
    param ([string]$Message)
    $TimeStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Output "[$TimeStamp] $Message"
}

try {
    Write-Log "Starting remediation process..."
    
    # ---------------------------------------------------------
    # YOUR REMEDIATION LOGIC GOES HERE
    # ---------------------------------------------------------
    $remediationSuccessful = $true
    
    if ($remediationSuccessful) {
        Write-Log "Remediation completed successfully."
        Exit 0
    } else {
        Write-Log "Remediation was not required or failed gracefully."
        Exit 1
    }

} catch {
    Write-Log "Error during remediation: $($_.Exception.Message)"
    Exit 1
}
