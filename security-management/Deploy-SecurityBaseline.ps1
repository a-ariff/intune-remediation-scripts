# Deploy-SecurityBaseline.ps1
# Security Management Script for Windows Security Baseline Configuration
# Author: Azure Admin
# Date: $(Get-Date -Format 'yyyy-MM-dd')
# Description: Deploys and configures Windows security baseline settings for Intune managed devices

param(
    [Parameter(Mandatory = $false)]
    [string]$LogPath = "C:\Windows\Temp\SecurityBaseline.log",
    
    [Parameter(Mandatory = $false)]
    [switch]$Remediate = $false
)

# Initialize logging
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Output $logEntry
    Add-Content -Path $LogPath -Value $logEntry -Force
}

# Function to check if running as administrator
function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to configure Windows Defender settings
function Set-DefenderConfiguration {
    Write-Log "Configuring Windows Defender settings..."
    
    try {
        # Enable real-time protection
        Set-MpPreference -DisableRealtimeMonitoring $false
        Write-Log "Real-time protection enabled"
        
        # Enable cloud-delivered protection
        Set-MpPreference -MAPSReporting Advanced
        Write-Log "Cloud-delivered protection enabled"
        
        # Enable automatic sample submission
        Set-MpPreference -SubmitSamplesConsent SendAllSamples
        Write-Log "Automatic sample submission enabled"
        
        # Configure scan settings
        Set-MpPreference -ScanScheduleDay Everyday
        Set-MpPreference -ScanScheduleTime 02:00:00
        Write-Log "Scheduled scan configured for daily at 2:00 AM"
        
        return $true
    }
    catch {
        Write-Log "Error configuring Windows Defender: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to configure Windows Firewall
function Set-FirewallConfiguration {
    Write-Log "Configuring Windows Firewall settings..."
    
    try {
        # Enable firewall for all profiles
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
        Write-Log "Windows Firewall enabled for all profiles"
        
        # Configure default actions
        Set-NetFirewallProfile -Profile Domain -DefaultInboundAction Block -DefaultOutboundAction Allow
        Set-NetFirewallProfile -Profile Public -DefaultInboundAction Block -DefaultOutboundAction Allow
        Set-NetFirewallProfile -Profile Private -DefaultInboundAction Block -DefaultOutboundAction Allow
        Write-Log "Firewall default actions configured"
        
        return $true
    }
    catch {
        Write-Log "Error configuring Windows Firewall: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to configure User Account Control (UAC)
function Set-UACConfiguration {
    Write-Log "Configuring User Account Control settings..."
    
    try {
        # Set UAC to highest level
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        Set-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorAdmin" -Value 2
        Set-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorUser" -Value 3
        Set-ItemProperty -Path $regPath -Name "EnableLUA" -Value 1
        Set-ItemProperty -Path $regPath -Name "PromptOnSecureDesktop" -Value 1
        Write-Log "UAC configured to highest security level"
        
        return $true
    }
    catch {
        Write-Log "Error configuring UAC: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to disable unnecessary services
function Set-ServiceConfiguration {
    Write-Log "Configuring service settings..."
    
    $servicesToDisable = @(
        "Telnet",
        "RemoteRegistry",
        "SSDPSRV",
        "upnphost",
        "WMPNetworkSvc"
    )
    
    $successCount = 0
    
    foreach ($service in $servicesToDisable) {
        try {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc) {
                Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
                Set-Service -Name $service -StartupType Disabled
                Write-Log "Service '$service' disabled"
                $successCount++
            }
            else {
                Write-Log "Service '$service' not found - skipping"
            }
        }
        catch {
            Write-Log "Error configuring service '$service': $($_.Exception.Message)" "ERROR"
        }
    }
    
    return $successCount -eq $servicesToDisable.Count
}

# Function to configure registry security settings
function Set-RegistrySecurityConfiguration {
    Write-Log "Configuring registry security settings..."
    
    try {
        # Disable SMBv1
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters"
        Set-ItemProperty -Path $regPath -Name "SMB1" -Value 0 -Force
        Write-Log "SMBv1 disabled"
        
        # Enable DEP for all programs
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
        if (!(Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "NoDataExecutionPrevention" -Value 0 -Force
        Write-Log "DEP enabled for all programs"
        
        # Disable AutoRun
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        if (!(Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "NoDriveTypeAutoRun" -Value 255 -Force
        Write-Log "AutoRun disabled"
        
        return $true
    }
    catch {
        Write-Log "Error configuring registry security settings: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to check current security baseline compliance
function Test-SecurityBaseline {
    Write-Log "Checking security baseline compliance..."
    
    $compliance = @{
        DefenderEnabled = $false
        FirewallEnabled = $false
        UACEnabled = $false
        ServicesConfigured = $false
        RegistryConfigured = $false
    }
    
    try {
        # Check Windows Defender
        $defenderStatus = Get-MpComputerStatus
        $compliance.DefenderEnabled = $defenderStatus.RealTimeProtectionEnabled -and 
                                     $defenderStatus.AntispywareEnabled -and 
                                     $defenderStatus.AntivirusEnabled
        
        # Check Windows Firewall
        $firewallProfiles = Get-NetFirewallProfile
        $compliance.FirewallEnabled = ($firewallProfiles | Where-Object { $_.Enabled -eq $false }).Count -eq 0
        
        # Check UAC
        $uacValue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -ErrorAction SilentlyContinue
        $compliance.UACEnabled = $uacValue.EnableLUA -eq 1
        
        # Check services
        $servicesToCheck = @("Telnet", "RemoteRegistry", "SSDPSRV", "upnphost", "WMPNetworkSvc")
        $disabledServices = 0
        foreach ($service in $servicesToCheck) {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc -and $svc.StartType -eq "Disabled") {
                $disabledServices++
            }
        }
        $compliance.ServicesConfigured = $disabledServices -eq $servicesToCheck.Count
        
        # Check registry settings
        $smb1Disabled = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" -Name "SMB1" -ErrorAction SilentlyContinue).SMB1 -eq 0
        $autorunDisabled = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -ErrorAction SilentlyContinue).NoDriveTypeAutoRun -eq 255
        $compliance.RegistryConfigured = $smb1Disabled -and $autorunDisabled
        
        return $compliance
    }
    catch {
        Write-Log "Error checking security baseline: $($_.Exception.Message)" "ERROR"
        return $compliance
    }
}

# Main execution
try {
    Write-Log "Starting Deploy-SecurityBaseline.ps1 script"
    Write-Log "Remediate mode: $Remediate"
    
    # Check if running as administrator
    if (-not (Test-IsAdmin)) {
        Write-Log "Script must be run as administrator" "ERROR"
        exit 1
    }
    
    # Check current compliance
    $currentCompliance = Test-SecurityBaseline
    $complianceReport = $currentCompliance.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" }
    Write-Log "Current compliance status: $($complianceReport -join ', ')"
    
    if ($Remediate) {
        Write-Log "Remediation mode enabled - applying security baseline configurations"
        
        $results = @()
        
        # Apply configurations
        $results += Set-DefenderConfiguration
        $results += Set-FirewallConfiguration
        $results += Set-UACConfiguration
        $results += Set-ServiceConfiguration
        $results += Set-RegistrySecurityConfiguration
        
        $successfulConfigurations = ($results | Where-Object { $_ -eq $true }).Count
        $totalConfigurations = $results.Count
        
        Write-Log "Security baseline deployment completed: $successfulConfigurations/$totalConfigurations configurations successful"
        
        # Recheck compliance after remediation
        Start-Sleep -Seconds 5
        $postCompliance = Test-SecurityBaseline
        $postComplianceReport = $postCompliance.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" }
        Write-Log "Post-remediation compliance status: $($postComplianceReport -join ', ')"
        
        if ($successfulConfigurations -eq $totalConfigurations) {
            Write-Log "All security baseline configurations applied successfully"
            exit 0
        }
        else {
            Write-Log "Some security baseline configurations failed" "ERROR"
            exit 1
        }
    }
    else {
        Write-Log "Detection mode - checking compliance only"
        
        $nonCompliantItems = $currentCompliance.GetEnumerator() | Where-Object { $_.Value -eq $false }
        
        if ($nonCompliantItems.Count -eq 0) {
            Write-Log "Device is compliant with security baseline"
            exit 0
        }
        else {
            $nonCompliantList = $nonCompliantItems.Name -join ', '
            Write-Log "Device is not compliant. Non-compliant items: $nonCompliantList" "WARNING"
            exit 1
        }
    }
}
catch {
    Write-Log "Unexpected error in Deploy-SecurityBaseline.ps1: $($_.Exception.Message)" "ERROR"
    exit 1
}
finally {
    Write-Log "Deploy-SecurityBaseline.ps1 script completed"
}
