<#
.SYNOPSIS
    Sample Intune remediation script demonstrating ShouldProcess support and proper logging.

.DESCRIPTION
    This script remediates the system issues detected by the detection script.
    It includes ShouldProcess support for safe testing with -WhatIf parameter
    and proper exit codes for Intune integration.
    
    Exit Codes:
    0 - Remediation successful
    1 - Remediation failed

.NOTES
    File Name  : remediation.ps1
    Author     : IT Administration
    Requires   : PowerShell 5.1 or later
    
.EXAMPLE
    .\remediation.ps1
    
    This will run the remediation.
    
.EXAMPLE
    .\remediation.ps1 -WhatIf
    
    This will show what the remediation would do without making changes.
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param()

begin {
    # Initialize variables
    $LogPrefix = "[REMEDIATION]"
    $RegistryPath = "HKLM:\SOFTWARE\Company\Configuration"
    $ValueName = "ComplianceStatus"
    $ExpectedValue = "Configured"
    $ServiceName = "Spooler"  # Example service
    
    Write-Information "$LogPrefix Starting remediation script" -InformationAction Continue
}

process {
    try {
        Write-Information "$LogPrefix Checking if remediation is needed" -InformationAction Continue
        
        # Create registry path if it doesn't exist
        if (-not (Test-Path -Path $RegistryPath)) {
            if ($PSCmdlet.ShouldProcess($RegistryPath, "Create registry path")) {
                Write-Information "$LogPrefix Creating registry path: $RegistryPath" -InformationAction Continue
                New-Item -Path $RegistryPath -Force | Out-Null
            }
        }
        
        # Set the registry value
        $CurrentValue = Get-ItemProperty -Path $RegistryPath -Name $ValueName -ErrorAction SilentlyContinue
        if ($null -eq $CurrentValue -or $CurrentValue.$ValueName -ne $ExpectedValue) {
            if ($PSCmdlet.ShouldProcess("$RegistryPath\$ValueName", "Set registry value to $ExpectedValue")) {
                Write-Information "$LogPrefix Setting registry value: $ValueName = $ExpectedValue" -InformationAction Continue
                Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $ExpectedValue -Force
            }
        } else {
            Write-Information "$LogPrefix Registry value already correct: $ValueName = $ExpectedValue" -InformationAction Continue
        }
        
        # Ensure service is running
        $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($null -ne $Service -and $Service.Status -ne "Running") {
            if ($PSCmdlet.ShouldProcess($ServiceName, "Start service")) {
                Write-Information "$LogPrefix Starting service: $ServiceName" -InformationAction Continue
                Start-Service -Name $ServiceName -ErrorAction Stop
                Write-Information "$LogPrefix Service $ServiceName started successfully" -InformationAction Continue
            }
        } elseif ($null -ne $Service) {
            Write-Information "$LogPrefix Service $ServiceName is already running" -InformationAction Continue
        } else {
            Write-Warning "$LogPrefix Service $ServiceName not found on this system"
        }
        
        # Verify remediation was successful
        if (-not $WhatIfPreference) {
            Write-Information "$LogPrefix Verifying remediation results" -InformationAction Continue
            
            # Check registry value
            $VerifyValue = Get-ItemProperty -Path $RegistryPath -Name $ValueName -ErrorAction SilentlyContinue
            if ($null -eq $VerifyValue -or $VerifyValue.$ValueName -ne $ExpectedValue) {
                throw "Registry value verification failed after remediation"
            }
            
            # Check service status
            $VerifyService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
            if ($null -ne $VerifyService -and $VerifyService.Status -ne "Running") {
                throw "Service $ServiceName is not running after remediation"
            }
        }
        
        Write-Information "$LogPrefix Remediation completed successfully" -InformationAction Continue
        exit 0
        
    }
    catch {
        Write-Error "$LogPrefix Remediation failed with error: $($_.Exception.Message)"
        Write-Information "$LogPrefix Full error details: $($_.Exception.ToString())" -InformationAction Continue
        exit 1
    }
}

end {
    # This block typically won't be reached due to exit statements above
    Write-Information "$LogPrefix Remediation script completed" -InformationAction Continue
}
