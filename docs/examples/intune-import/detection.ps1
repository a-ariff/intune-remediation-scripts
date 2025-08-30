<#
.SYNOPSIS
    Sample Intune detection script demonstrating proper structure and exit codes.

.DESCRIPTION
    This script detects if a specific system condition exists and returns appropriate
    exit codes for Intune remediation. This example checks for a sample registry key
    that should be present for compliance.
    
    Exit Codes:
    0 - Compliant (no remediation needed)
    1 - Non-compliant (remediation required)

.NOTES
    File Name  : detection.ps1
    Author     : IT Administration
    Requires   : PowerShell 5.1 or later
    
.EXAMPLE
    .\detection.ps1
    
    This will run the detection and return appropriate exit code.
#>

[CmdletBinding()]
param()

begin {
    # Initialize variables
    $LogPrefix = "[DETECTION]"
    $RegistryPath = "HKLM:\SOFTWARE\Company\Configuration"
    $ValueName = "ComplianceStatus"
    $ExpectedValue = "Configured"
    
    Write-Information "$LogPrefix Starting detection script" -InformationAction Continue
}

process {
    try {
        Write-Information "$LogPrefix Checking registry path: $RegistryPath" -InformationAction Continue
        
        # Check if registry path exists
        if (-not (Test-Path -Path $RegistryPath)) {
            Write-Information "$LogPrefix Registry path does not exist - Non-compliant" -InformationAction Continue
            exit 1
        }
        
        # Check if the specific value exists and has correct data
        $CurrentValue = Get-ItemProperty -Path $RegistryPath -Name $ValueName -ErrorAction SilentlyContinue
        
        if ($null -eq $CurrentValue) {
            Write-Information "$LogPrefix Registry value '$ValueName' does not exist - Non-compliant" -InformationAction Continue
            exit 1
        }
        
        if ($CurrentValue.$ValueName -ne $ExpectedValue) {
            Write-Information "$LogPrefix Current value '$($CurrentValue.$ValueName)' does not match expected value '$ExpectedValue' - Non-compliant" -InformationAction Continue
            exit 1
        }
        
        # Additional compliance check - ensure service is running
        $ServiceName = "Spooler"  # Example service
        $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        
        if ($null -eq $Service) {
            Write-Information "$LogPrefix Service '$ServiceName' not found - Non-compliant" -InformationAction Continue
            exit 1
        }
        
        if ($Service.Status -ne "Running") {
            Write-Information "$LogPrefix Service '$ServiceName' is not running (Status: $($Service.Status)) - Non-compliant" -InformationAction Continue
            exit 1
        }
        
        # If we reach here, all checks passed
        Write-Information "$LogPrefix All compliance checks passed - Compliant" -InformationAction Continue
        exit 0
        
    }
    catch {
        Write-Error "$LogPrefix Detection failed with error: $($_.Exception.Message)"
        Write-Information "$LogPrefix Full error details: $($_.Exception.ToString())" -InformationAction Continue
        exit 1
    }
}

end {
    # This block typically won't be reached due to exit statements above
    Write-Information "$LogPrefix Detection script completed" -InformationAction Continue
}
