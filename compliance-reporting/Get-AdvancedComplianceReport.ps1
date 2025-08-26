# Get-AdvancedComplianceReport.ps1
# PowerShell script for generating advanced compliance reports for Intune devices

function Get-AdvancedComplianceReport {
    <#
    .SYNOPSIS
        Generates an advanced compliance report for Intune-managed devices
    
    .DESCRIPTION
        This script generates a comprehensive compliance report that includes device compliance status,
        policy assignments, and detailed compliance information for Microsoft Intune managed devices.
    
    .PARAMETER OutputPath
        Specifies the path where the report will be saved
    
    .PARAMETER Format
        Specifies the output format (CSV, JSON, HTML)
    
    .EXAMPLE
        Get-AdvancedComplianceReport -OutputPath "C:\Reports\ComplianceReport.csv" -Format CSV
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$OutputPath = "ComplianceReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv",
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("CSV", "JSON", "HTML")]
        [string]$Format = "CSV"
    )
    
    try {
        Write-Host "Starting Advanced Compliance Report generation..." -ForegroundColor Green
        
        # Connect to Microsoft Graph
        Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
        Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All", "DeviceManagementConfiguration.Read.All"
        
        # Get all managed devices
        Write-Host "Retrieving managed devices..." -ForegroundColor Yellow
        $devices = Get-MgDeviceManagementManagedDevice -All
        
        # Get compliance policies
        Write-Host "Retrieving compliance policies..." -ForegroundColor Yellow
        $compliancePolicies = Get-MgDeviceManagementDeviceCompliancePolicy -All
        
        # Initialize report array
        $report = @()
        
        foreach ($device in $devices) {
            Write-Progress -Activity "Processing devices" -Status "Processing device: $($device.DeviceName)" -PercentComplete (($devices.IndexOf($device) / $devices.Count) * 100)
            
            # Get device compliance status
            $complianceStatus = Get-MgDeviceManagementManagedDeviceCompliancePolicyState -ManagedDeviceId $device.Id
            
            # Create device report object
            $deviceReport = [PSCustomObject]@{
                DeviceName = $device.DeviceName
                DeviceId = $device.Id
                UserId = $device.UserId
                UserPrincipalName = $device.UserPrincipalName
                OperatingSystem = $device.OperatingSystem
                OSVersion = $device.OsVersion
                DeviceType = $device.DeviceType
                ManagementAgent = $device.ManagementAgent
                ComplianceState = $device.ComplianceState
                LastSyncDateTime = $device.LastSyncDateTime
                EnrolledDateTime = $device.EnrolledDateTime
                JailBroken = $device.JailBroken
                DeviceEnrollmentType = $device.DeviceEnrollmentType
                ManagementState = $device.ManagementState
                DeviceRegistrationState = $device.DeviceRegistrationState
                CompliancePoliciesCount = $complianceStatus.Count
                NonCompliantPolicies = ($complianceStatus | Where-Object { $_.State -eq 'nonCompliant' }).Count
                ErrorPolicies = ($complianceStatus | Where-Object { $_.State -eq 'error' }).Count
                UnknownPolicies = ($complianceStatus | Where-Object { $_.State -eq 'unknown' }).Count
                ReportGeneratedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            }
            
            $report += $deviceReport
        }
        
        Write-Progress -Activity "Processing devices" -Completed
        
        # Export report based on format
        switch ($Format) {
            "CSV" {
                $report | Export-Csv -Path $OutputPath -NoTypeInformation
                Write-Host "Report exported to: $OutputPath" -ForegroundColor Green
            }
            "JSON" {
                $report | ConvertTo-Json -Depth 3 | Out-File -FilePath $OutputPath -Encoding UTF8
                Write-Host "Report exported to: $OutputPath" -ForegroundColor Green
            }
            "HTML" {
                $htmlReport = $report | ConvertTo-Html -Title "Advanced Compliance Report" -PreContent "<h1>Advanced Compliance Report</h1><p>Generated on: $(Get-Date)</p>"
                $htmlReport | Out-File -FilePath $OutputPath -Encoding UTF8
                Write-Host "Report exported to: $OutputPath" -ForegroundColor Green
            }
        }
        
        # Display summary
        Write-Host "`nReport Summary:" -ForegroundColor Cyan
        Write-Host "Total Devices: $($report.Count)" -ForegroundColor White
        Write-Host "Compliant Devices: $(($report | Where-Object { $_.ComplianceState -eq 'compliant' }).Count)" -ForegroundColor Green
        Write-Host "Non-Compliant Devices: $(($report | Where-Object { $_.ComplianceState -eq 'noncompliant' }).Count)" -ForegroundColor Red
        Write-Host "Unknown State Devices: $(($report | Where-Object { $_.ComplianceState -eq 'unknown' }).Count)" -ForegroundColor Yellow
        
        return $report
        
    } catch {
        Write-Error "Error generating compliance report: $($_.Exception.Message)"
        throw
    } finally {
        # Disconnect from Microsoft Graph
        Disconnect-MgGraph -ErrorAction SilentlyContinue
    }
}

# Execute the function if script is run directly
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Get-AdvancedComplianceReport
}
