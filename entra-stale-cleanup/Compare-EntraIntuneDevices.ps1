<#
.SYNOPSIS
Compares an Entra ID device export with an Intune non-compliance export to find devices missing from Intune.

.DESCRIPTION
This script reads two CSV files (one from Entra ID, one from Intune), compares the device IDs, and outputs a new CSV containing all devices that exist in Entra ID but are completely missing from the Intune export.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$EntraCsvPath,

    [Parameter(Mandatory=$true)]
    [string]$IntuneCsvPath,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\EntraDevicesNotInIntune.csv"
)

$entraDevices = Import-Csv $EntraCsvPath
$intuneDevices = Import-Csv $IntuneCsvPath

$intuneIds = $intuneDevices | Where-Object { ![string]::IsNullOrWhiteSpace($_.AadDeviceId) } | Select-Object -ExpandProperty AadDeviceId | ForEach-Object { $_.ToLower() }
$missingFromIntune = @()

foreach ($device in $entraDevices) {
    if (![string]::IsNullOrWhiteSpace($device.deviceId)) {
        if ($intuneIds -notcontains $device.deviceId.ToLower()) {
            $missingFromIntune += $device
        }
    }
}

if ($missingFromIntune.Count -gt 0) {
    $missingFromIntune | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "Exported $($missingFromIntune.Count) devices to $OutputPath"
} else {
    Write-Host "No missing devices found."
}
