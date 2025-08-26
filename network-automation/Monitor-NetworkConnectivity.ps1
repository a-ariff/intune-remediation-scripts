<#
.SYNOPSIS
    Monitor Network Connectivity Script for Intune Remediation

.DESCRIPTION
    This script monitors network connectivity by testing connections to specified endpoints.
    It checks for internet connectivity, DNS resolution, and specific service availability.
    Used as a detection script in Intune remediation scenarios.

.PARAMETER TestEndpoints
    Array of endpoints to test connectivity against

.PARAMETER TimeoutSeconds
    Timeout value for each connectivity test in seconds

.EXAMPLE
    .\Monitor-NetworkConnectivity.ps1
    
.NOTES
    Author: IT Administrator
    Date: August 2025
    Version: 1.0
#>

param(
    [string[]]$TestEndpoints = @(
        "8.8.8.8",          # Google DNS
        "1.1.1.1",          # Cloudflare DNS
        "microsoft.com",    # Microsoft
        "office.com"        # Office 365
    ),
    [int]$TimeoutSeconds = 5
)

# Initialize variables
$connectivityIssues = @()
$testResults = @()

try {
    Write-Output "Starting network connectivity monitoring..."
    
    # Test each endpoint
    foreach ($endpoint in $TestEndpoints) {
        Write-Output "Testing connectivity to: $endpoint"
        
        try {
            # Test connection using Test-NetConnection if available, otherwise use Test-Connection
            if (Get-Command Test-NetConnection -ErrorAction SilentlyContinue) {
                $result = Test-NetConnection -ComputerName $endpoint -InformationLevel Quiet -WarningAction SilentlyContinue
                $isReachable = $result
            } else {
                # Fallback for older PowerShell versions
                $result = Test-Connection -ComputerName $endpoint -Count 1 -Quiet -TimeoutSeconds $TimeoutSeconds
                $isReachable = $result
            }
            
            $testResult = [PSCustomObject]@{
                Endpoint = $endpoint
                Status = if ($isReachable) { "Success" } else { "Failed" }
                Reachable = $isReachable
                Timestamp = Get-Date
            }
            
            $testResults += $testResult
            
            if (-not $isReachable) {
                $connectivityIssues += "Failed to reach: $endpoint"
                Write-Warning "Connectivity test failed for: $endpoint"
            } else {
                Write-Output "Successfully connected to: $endpoint"
            }
            
        } catch {
            $errorMsg = "Error testing $endpoint : $($_.Exception.Message)"
            $connectivityIssues += $errorMsg
            Write-Error $errorMsg
            
            $testResult = [PSCustomObject]@{
                Endpoint = $endpoint
                Status = "Error"
                Reachable = $false
                Timestamp = Get-Date
                Error = $_.Exception.Message
            }
            
            $testResults += $testResult
        }
    }
    
    # Check DNS resolution
    Write-Output "Testing DNS resolution..."
    try {
        $dnsTest = Resolve-DnsName "microsoft.com" -ErrorAction Stop
        Write-Output "DNS resolution successful"
    } catch {
        $connectivityIssues += "DNS resolution failed: $($_.Exception.Message)"
        Write-Warning "DNS resolution test failed"
    }
    
    # Check default gateway
    Write-Output "Checking default gateway..."
    try {
        $gateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1
        if ($gateway) {
            $gatewayTest = Test-Connection -ComputerName $gateway.NextHop -Count 1 -Quiet -TimeoutSeconds $TimeoutSeconds
            if ($gatewayTest) {
                Write-Output "Default gateway is reachable: $($gateway.NextHop)"
            } else {
                $connectivityIssues += "Default gateway unreachable: $($gateway.NextHop)"
            }
        } else {
            $connectivityIssues += "No default gateway found"
        }
    } catch {
        $connectivityIssues += "Error checking default gateway: $($_.Exception.Message)"
    }
    
    # Generate summary report
    $totalTests = $testResults.Count
    $successfulTests = ($testResults | Where-Object { $_.Status -eq "Success" }).Count
    $failedTests = $totalTests - $successfulTests
    
    $summary = [PSCustomObject]@{
        TotalTests = $totalTests
        Successful = $successfulTests
        Failed = $failedTests
        SuccessRate = if ($totalTests -gt 0) { [math]::Round(($successfulTests / $totalTests) * 100, 2) } else { 0 }
        Issues = $connectivityIssues
        TestResults = $testResults
        Timestamp = Get-Date
    }
    
    # Output results
    Write-Output "Network Connectivity Test Summary:"
    Write-Output "Total Tests: $($summary.TotalTests)"
    Write-Output "Successful: $($summary.Successful)"
    Write-Output "Failed: $($summary.Failed)"
    Write-Output "Success Rate: $($summary.SuccessRate)%"
    
    # Determine exit code based on connectivity issues
    if ($connectivityIssues.Count -eq 0) {
        Write-Output "All connectivity tests passed. Network appears healthy."
        exit 0  # Success - no remediation needed
    } else {
        Write-Warning "Network connectivity issues detected:"
        foreach ($issue in $connectivityIssues) {
            Write-Warning "- $issue"
        }
        
        # Calculate failure threshold (if more than 50% of tests fail, trigger remediation)
        if ($summary.SuccessRate -lt 50) {
            Write-Output "Critical network connectivity issues detected. Remediation required."
            exit 1  # Failure - remediation needed
        } else {
            Write-Output "Minor network connectivity issues detected. Monitoring continues."
            exit 0  # Success - issues exist but not critical
        }
    }
    
} catch {
    Write-Error "Critical error during network connectivity monitoring: $($_.Exception.Message)"
    Write-Error "Stack Trace: $($_.ScriptStackTrace)"
    exit 1  # Failure - remediation needed
}
