<#
.SYNOPSIS
Deletes a specific list of devices from Entra ID based on a CSV file.

.DESCRIPTION
Reads a CSV containing a 'deviceId' or 'id' column and deletes those specific devices from Entra ID using the Microsoft Graph API.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath
)

Connect-MgGraph -Scopes "Device.ReadWrite.All"
$devices = Import-Csv $CsvPath
$count = 0

Write-Host "Starting deletion of $($devices.Count) devices..."

foreach ($device in $devices) {
    $targetId = if ($device.id) { $device.id } else { $device.deviceId }
    if (![string]::IsNullOrWhiteSpace($targetId)) {
        try {
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/devices/$targetId"
            Write-Host "Deleted $($device.displayName)"
            $count++
        } catch {
            Write-Host "Failed to delete $($device.displayName): $_"
        }
    }
}

Write-Host "Successfully deleted $count devices."
Disconnect-MgGraph
