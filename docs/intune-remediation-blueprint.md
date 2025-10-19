# Ready-to-Clone Intune Remediation Blueprint

## Purpose
This blueprint provides a reference structure for creating Microsoft Intune remediation packages. It includes example detection and remediation scripts, packaging recommendations, and guidance for scheduling and monitoring. Use it as a starting point for your own remediation projects.

## Directory Structure

```
remediation-scripts/
└── <remediation-name>/
    ├── detection.ps1    # detection script (exit 0 if healthy, 1 if remediation needed)
    ├── remediation.ps1  # remediation script (fixes the issue)
    └── README.md        # description and usage notes
```

## Detection Script Template (detection.ps1)

Use a detection script to determine whether a device requires remediation. The script should return exit code 1 when remediation is needed and exit code 0 when no action is required. Example:

```powershell
# Detect low free disk space (< 10 GB) on system drive
$thresholdGB = 10
$freeGB = (Get-PSDrive -Name C).Free / 1GB

if ($freeGB -lt $thresholdGB) {
    Write-Output "Low disk space detected: $([math]::Round($freeGB,2)) GB free"
    exit 1
} else {
    Write-Output "Disk space healthy: $([math]::Round($freeGB,2)) GB free"
    exit 0
}
```

## Remediation Script Template (remediation.ps1)

The remediation script should implement the fix for any condition detected by the detection script. It should not perform detection logic. Example:

```powershell
# Free disk space by clearing temporary files
try {
    Write-Output "Clearing temporary files..."
    Get-ChildItem -Path $env:TEMP -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Write-Output "Temporary files cleared successfully."
    exit 0
} catch {
    Write-Error "Failed to clear temporary files: $_"
    exit 1
}
```

## Packaging and Deployment

1. Place your detection and remediation scripts in their own folder inside **`remediation-scripts`**, following the structure above.
2. Add a `README.md` describing the purpose of the remediation, how the detection logic works, and what the remediation does.
3. In the Intune admin center, create a new remediation package by uploading your detection and remediation scripts. Use the package name to match your folder name.
4. Assign the package to the appropriate device groups and configure the schedule (Once, Hourly, Daily). Always test in a pilot group before broad deployment.
5. Monitor results via the Intune Remediation reports; devices that report exit code 1 for detection will run remediation.

## Best Practices

- **Write idempotent scripts:** remediation scripts should be safe to run repeatedly and only make changes when necessary.
- **Avoid `Set-ExecutionPolicy`:** rely on the Intune agent's default execution policy rather than modifying system policies.
- **Do not include sensitive data:** never hardcode passwords, tokens, or personal information.
- **Log output:** use `Write-Output` and `Write-Error` generously to surface useful information in Intune reports.
- **Test thoroughly:** validate detection and remediation scripts on isolated machines before deployment.

## Additional Examples

See the existing folders in `remediation-scripts` for real-world examples such as:
- **performance-monitoring/cleanup-temp-files.ps1** – cleans up temporary files.
- **security-management/Deploy-SecurityBaseline.ps1** – configures baseline security settings.

Feel free to adapt and expand this blueprint to suit your organization's requirements.

## Service Remediation Example: W32Time

This example shows how to remediate the Windows Time (W32Time) service when it is disabled or stopped. The detection script checks if the service is running and set to Automatic (or Automatic (Delayed Start)). If not, it signals remediation by exiting with code 1. The remediation script configures the service to start automatically and then starts it.

### Detection script (detection.ps1)

```powershell
# Detect if the Windows Time service is running and set to Automatic or Automatic (Delayed Start)
$service = Get-Service -Name W32Time -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Output "W32Time service not installed"
    exit 1
}

if ($service.Status -ne 'Running' -or $service.StartType -notin @('Automatic', 'AutomaticDelayedStart')) {
    Write-Output "W32Time service requires remediation. Status: $($service.Status), StartType: $($service.StartType)"
    exit 1
} else {
    Write-Output "W32Time service is running with the correct start type"
    exit 0
}
```

### Remediation script (remediation.ps1)

```powershell
# Configure and start the Windows Time service
try {
    Write-Output "Configuring W32Time service..."
    Set-Service -Name W32Time -StartupType Automatic
    Write-Output "Starting W32Time service..."
    Start-Service -Name W32Time
    Write-Output "W32Time service configured and started successfully"
    exit 0
} catch {
    Write-Error "Failed to remediate W32Time service: $_"
    exit 1
}
```

### Packaging and deployment for this example

1. Create a folder named `w32time-service` in the `remediation-scripts` directory.
2. Save the detection script above as `detection.ps1` and the remediation script as `remediation.ps1` inside this folder.
3. Add a `README.md` describing the purpose of this remediation (keeping the Windows Time service running and set to Automatic).
4. In Intune, create a remediation package using these scripts and assign it to the desired device group.
5. Monitor the remediation status via Intune reports.
