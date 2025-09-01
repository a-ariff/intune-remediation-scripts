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
param
(
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
    Write-Information "Starting network connectivity monitoring..." -InformationAction Continue

    # Test each endpoint
    foreach ($endpoint in $TestEndpoints) {
        Write-Information "Testing connectivity to: $endpoint" -InformationAction Continue

        try {
            # Test connection using Test-NetConnection if available, otherwise use Test-Connection
            if (Get-Command Test-NetConnection -ErrorAction SilentlyContinue) {
                $result = Test-NetConnection -ComputerName $endpoint -InformationLevel Quiet -WarningAction SilentlyContinue
                $isReachable = $result
            } else {
                # Fallback to Test-Connection for older PowerShell versions
                $result = Test-Connection -ComputerName $endpoint -Count 1 -TimeToLive $TimeoutSeconds -Quiet -ErrorAction SilentlyContinue
                $isReachable = $result
            }

            $testResult = [PSCustomObject]@{
                Endpoint = $endpoint
                Status = if ($isReachable) { "Success" } else { "Failed" }
                Timestamp = Get-Date
                Details = if ($isReachable) { "Connection successful" } else { "Connection failed" }
            }

            $testResults += $testResult

            if (-not $isReachable) {
                $connectivityIssues += "Failed to connect to $endpoint"
            }

        } catch {
            $errorMessage = "Error testing $endpoint`: $($_.Exception.Message)"
            $connectivityIssues += $errorMessage

            $testResult = [PSCustomObject]@{
                Endpoint = $endpoint
                Status = "Error"
                Timestamp = Get-Date
                Details = $errorMessage
            }

            $testResults += $testResult
        }
    }

    # Check default gateway connectivity
    try {
        $defaultGateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($defaultGateway) {
            $gatewayTest = Test-Connection -ComputerName $defaultGateway.NextHop -Count 1 -Quiet -ErrorAction SilentlyContinue
            if (-not $gatewayTest) {
                $connectivityIssues += "Default gateway ($($defaultGateway.NextHop)) is not reachable"
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
    Write-Information "Network Connectivity Test Summary:" -InformationAction Continue
    Write-Information "Total Tests: $($summary.TotalTests)" -InformationAction Continue
    Write-Information "Successful: $($summary.Successful)" -InformationAction Continue
    Write-Information "Failed: $($summary.Failed)" -InformationAction Continue
    Write-Information "Success Rate: $($summary.SuccessRate)%" -InformationAction Continue

    # Determine exit code based on connectivity issues
    if ($connectivityIssues.Count -eq 0) {
        Write-Information "All connectivity tests passed. Network appears healthy." -InformationAction Continue
        exit 0  # Success - no remediation needed
    } else {
        Write-Warning "Network connectivity issues detected:"
        foreach ($issue in $connectivityIssues) {
            Write-Warning "- $issue"
        }

        # Calculate failure threshold (if more than 50% of tests fail, trigger remediation)
        if ($summary.SuccessRate -lt 50) {
            Write-Information "Critical network connectivity issues detected. Remediation required." -InformationAction Continue
            exit 1  # Failure - remediation needed
        } else {
            Write-Information "Minor network connectivity issues detected. Monitoring continues." -InformationAction Continue
            exit 0  # Success - issues exist but not critical
        }
    }

} catch {
    Write-Error "Critical error during network connectivity monitoring: $($_.Exception.Message)"
    Write-Error "Stack Trace: $($_.ScriptStackTrace)"
    exit 1  # Failure - remediation needed
}
