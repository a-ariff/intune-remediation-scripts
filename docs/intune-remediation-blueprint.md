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
- **security-management/Deploy-SecurityBaseline.ps1** – configures security settings.

Feel free to adapt and expand this blueprint to suit your organization's requirements.
