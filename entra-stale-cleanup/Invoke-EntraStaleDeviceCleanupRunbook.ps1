<#
.SYNOPSIS
Finds and deletes devices from Entra ID that haven't signed in for 90 days.
Uses the Automation Account's System-Assigned Managed Identity.
#>

Write-Output "Authenticating to Microsoft Graph using Managed Identity..."
Connect-MgGraph -Identity

$cutoffDate = (Get-Date).AddDays(-90).ToString("yyyy-MM-ddTHH:mm:ssZ")
Write-Output "Searching for devices inactive since $cutoffDate..."

$uri = "https://graph.microsoft.com/v1.0/devices?`$filter=approximateLastSignInDateTime le $cutoffDate&`$select=id,displayName,approximateLastSignInDateTime,operatingSystem,mdmAppId"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri -Headers @{ConsistencyLevel="eventual"}
$staleDevices = $response.value

if ($staleDevices.Count -eq 0) {
    Write-Output "No stale devices found."
    Disconnect-MgGraph
    exit
}

Write-Output "Found $($staleDevices.Count) stale devices. Beginning cleanup..."
foreach ($device in $staleDevices) {
    try {
        Write-Output "Deleting $($device.displayName)..."
        Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/devices/$($device.id)"
    } catch {
        Write-Output "Error deleting $($device.displayName): $_"
    }
}

Write-Output "Cleanup complete."
Disconnect-MgGraph
