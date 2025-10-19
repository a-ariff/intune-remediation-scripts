# Deploy-SecurityBaseline.ps1
# Security Management Script for Windows Security Baseline Configuration
# Author: Azure Admin
# Date: $(Get-Date -Format 'yyyy-MM-dd')
# Description: Deploys and configures Windows security baseline settings for Intune managed devices

[CmdletBinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory = $false)]
    [string]$LogPath = "C:\Windows\Temp\SecurityBaseline.log",
    
    [Parameter(Mandatory = $false)]
    [switch]$Remediate = $false
)

# Initialize logging
function Write-Log {
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    if ($PSCmdlet.ShouldProcess("Log file: $LogPath", "Write log entry")) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        Write-Output $logEntry
        
        # Ensure log directory exists
        $logDir = Split-Path -Path $LogPath -Parent
        if (-not (Test-Path -Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        
        Add-Content -Path $LogPath -Value $logEntry -Force
    }
}

# Function to check if running as administrator
function Test-IsAdmin {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if ($PSCmdlet.ShouldProcess("Current user context", "Check administrator privileges")) {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    return $false
}

# Function to configure Windows Defender settings
function Set-DefenderConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if ($PSCmdlet.ShouldProcess("Windows Defender", "Configure security settings")) {
        Write-Log "Configuring Windows Defender settings..."
        
        try {
            # Enable real-time protection
            Set-MpPreference -DisableRealtimeMonitoring $false -Force
            Write-Log "Real-time protection enabled" "SUCCESS"
            
            # Enable cloud protection
            Set-MpPreference -MAPSReporting Advanced -Force
            Write-Log "Cloud protection enabled" "SUCCESS"
            
            # Configure scan settings
            Set-MpPreference -ScanScheduleDay Everyday -Force
            Set-MpPreference -ScanScheduleTime 02:00:00 -Force
            Write-Log "Scan schedule configured" "SUCCESS"
            
            # Enable network protection
            Set-MpPreference -EnableNetworkProtection Enabled -Force
            Write-Log "Network protection enabled" "SUCCESS"
            
        } catch {
            Write-Log "Failed to configure Windows Defender: $($_.Exception.Message)" "ERROR"
            throw
        }
    }
}

# Function to configure Windows Firewall settings
function Set-FirewallConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if ($PSCmdlet.ShouldProcess("Windows Firewall", "Configure firewall settings")) {
        Write-Log "Configuring Windows Firewall settings..."
        
        try {
            # Enable firewall for all profiles
            Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
            Write-Log "Firewall enabled for all profiles" "SUCCESS"
            
            # Configure default actions
            Set-NetFirewallProfile -Profile Domain -DefaultInboundAction Block -DefaultOutboundAction Allow
            Set-NetFirewallProfile -Profile Public -DefaultInboundAction Block -DefaultOutboundAction Allow
            Set-NetFirewallProfile -Profile Private -DefaultInboundAction Block -DefaultOutboundAction Allow
            Write-Log "Default firewall actions configured" "SUCCESS"
            
        } catch {
            Write-Log "Failed to configure Windows Firewall: $($_.Exception.Message)" "ERROR"
            throw
        }
    }
}

# Function to configure User Account Control settings
function Set-UACConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if ($PSCmdlet.ShouldProcess("User Account Control", "Configure UAC settings")) {
        Write-Log "Configuring User Account Control settings..."
        
        try {
            $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            
            # Set UAC to prompt for consent for non-Windows binaries
            Set-ItemProperty -Path $registryPath -Name "ConsentPromptBehaviorAdmin" -Value 5 -Type DWord
            Set-ItemProperty -Path $registryPath -Name "ConsentPromptBehaviorUser" -Value 3 -Type DWord
            Set-ItemProperty -Path $registryPath -Name "EnableInstallerDetection" -Value 1 -Type DWord
            Set-ItemProperty -Path $registryPath -Name "EnableLUA" -Value 1 -Type DWord
            Set-ItemProperty -Path $registryPath -Name "EnableVirtualization" -Value 1 -Type DWord
            Set-ItemProperty -Path $registryPath -Name "PromptOnSecureDesktop" -Value 1 -Type DWord
            
            Write-Log "UAC settings configured successfully" "SUCCESS"
            
        } catch {
            Write-Log "Failed to configure UAC: $($_.Exception.Message)" "ERROR"
            throw
        }
    }
}

# Function to configure PowerShell execution policy
function Set-PowerShellSecurityConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if ($PSCmdlet.ShouldProcess("PowerShell Execution Policy", "Configure security settings")) {
        Write-Log "Configuring PowerShell security settings..."
        
        try {
            ## Execution policy managed externally; no changes necessary
        
            if (-not (Test-Path $registryPath)) {
                New-Item -Path $registryPath -Force | Out-Null
            }
            Set-ItemProperty -Path $registryPath -Name "EnableModuleLogging" -Value 1 -Type DWord
            
            $scriptBlockPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
            if (-not (Test-Path $scriptBlockPath)) {
                New-Item -Path $scriptBlockPath -Force | Out-Null
            }
            Set-ItemProperty -Path $scriptBlockPath -Name "EnableScriptBlockLogging" -Value 1 -Type DWord
            
            Write-Log "PowerShell logging enabled" "SUCCESS"
            
        } catch {
            Write-Log "Failed to configure PowerShell security: $($_.Exception.Message)" "ERROR"
            throw
        }
    }
}

# Function to configure Windows Update settings
function Set-WindowsUpdateConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if ($PSCmdlet.ShouldProcess("Windows Update", "Configure update settings")) {
        Write-Log "Configuring Windows Update settings..."
        
        try {
            $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
            if (-not (Test-Path $registryPath)) {
                New-Item -Path $registryPath -Force | Out-Null
            }
            
            # Configure automatic updates
            Set-ItemProperty -Path $registryPath -Name "NoAutoUpdate" -Value 0 -Type DWord
            Set-ItemProperty -Path $registryPath -Name "AUOptions" -Value 4 -Type DWord # Auto download and install
            Set-ItemProperty -Path $registryPath -Name "ScheduledInstallDay" -Value 0 -Type DWord # Every day
            Set-ItemProperty -Path $registryPath -Name "ScheduledInstallTime" -Value 3 -Type DWord # 3 AM
            
            Write-Log "Windows Update settings configured" "SUCCESS"
            
        } catch {
            Write-Log "Failed to configure Windows Update: $($_.Exception.Message)" "ERROR"
            throw
        }
    }
}

# Function to perform security baseline assessment
function Test-SecurityBaseline {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if ($PSCmdlet.ShouldProcess("Security Baseline", "Perform assessment")) {
        Write-Log "Starting security baseline assessment..."
        
        $results = @{
            DefenderEnabled = $false
            FirewallEnabled = $false
            UACEnabled = $false
            PowerShellSecure = $false
            WindowsUpdateEnabled = $false
        }
        
        try {
            # Check Windows Defender
            $defenderStatus = Get-MpComputerStatus
            $results.DefenderEnabled = $defenderStatus.RealTimeProtectionEnabled
            
            # Check Firewall
            $firewallProfiles = Get-NetFirewallProfile
            $results.FirewallEnabled = ($firewallProfiles | Where-Object { $_.Enabled -eq $false }).Count -eq 0
            
            # Check UAC
            $uacStatus = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -ErrorAction SilentlyContinue
            $results.UACEnabled = ($uacStatus.EnableLUA -eq 1)
            
            # Check PowerShell execution policy
            $executionPolicy = Get-ExecutionPolicy -Scope LocalMachine
            $results.PowerShellSecure = ($executionPolicy -ne "Unrestricted")
            
            # Check Windows Update
            $updateStatus = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -ErrorAction SilentlyContinue
            $results.WindowsUpdateEnabled = ($updateStatus.NoAutoUpdate -eq 0)
            
            Write-Log "Security baseline assessment completed" "SUCCESS"
            return $results
            
        } catch {
            Write-Log "Failed to perform security assessment: $($_.Exception.Message)" "ERROR"
            throw
        }
    }
    
    return @{}
}

# Main execution logic
function Invoke-SecurityBaseline {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$Remediate,
        [string]$LogPath
    )
    
    if ($PSCmdlet.ShouldProcess("Security Baseline Deployment", "Execute main logic")) {
        Write-Log "Starting security baseline deployment..." "INFO"
        
        # Check if running as administrator
        if (-not (Test-IsAdmin)) {
            Write-Log "Script must be run as administrator" "ERROR"
            throw "Insufficient privileges. Please run as administrator."
        }
        
        try {
            # Perform initial assessment
            $initialAssessment = Test-SecurityBaseline
            Write-Log "Initial assessment completed" "INFO"
            
            if ($Remediate) {
                Write-Log "Remediation mode enabled. Applying security configurations..." "INFO"
                
                # Apply security configurations
                Set-DefenderConfiguration
                Set-FirewallConfiguration
                Set-UACConfiguration
                Set-PowerShellSecurityConfiguration
                Set-WindowsUpdateConfiguration
                
                # Perform final assessment
                Start-Sleep -Seconds 5
                $finalAssessment = Test-SecurityBaseline
                Write-Log "Final assessment completed" "INFO"
                
                # Compare results
                Write-Log "=== Security Baseline Results ===" "INFO"
                foreach ($key in $initialAssessment.Keys) {
                    $initial = $initialAssessment[$key]
                    $final = $finalAssessment[$key]
                    $status = if ($final) { "PASS" } else { "FAIL" }
                    Write-Log "$key : $status (Initial: $initial, Final: $final)" "INFO"
                }
                
            } else {
                Write-Log "Assessment mode only. Use -Remediate switch to apply fixes." "INFO"
                
                Write-Log "=== Current Security Status ===" "INFO"
                foreach ($key in $initialAssessment.Keys) {
                    $status = if ($initialAssessment[$key]) { "PASS" } else { "FAIL" }
                    Write-Log "$key : $status" "INFO"
                }
            }
            
            Write-Log "Security baseline deployment completed successfully" "SUCCESS"
            
        } catch {
            Write-Log "Security baseline deployment failed: $($_.Exception.Message)" "ERROR"
            throw
        }
    }
}

# Execute main function
try {
    Invoke-SecurityBaseline -Remediate:$Remediate -LogPath $LogPath
    exit 0
} catch {
    Write-Log "Script execution failed: $($_.Exception.Message)" "ERROR"
    exit 1
}
