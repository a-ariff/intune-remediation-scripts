# Entra ID Stale Device Cleanup

This folder contains scripts used to clean up stale and orphaned devices from Microsoft Entra ID that are no longer managed by Intune.

## Files in this Folder

1. **delete-109-devices.ps1**: A one-off script we used to manually delete 109 specific devices from a CSV list. 
   - *How to use in the future*: If you ever export another CSV of specific devices you want to force-delete, you can edit this script, update the `$csvPath` variable to point to your new CSV, and run it.

---

## Azure Automation Runbook Setup Guide (Monthly Automated Cleanup)

To fully automate this process so that stale Entra ID devices are cleaned up automatically (or a report is generated) every month, you should use an **Azure Automation Account with a Managed Identity**. 

Using a Managed Identity is Microsoft's best practice because it avoids hardcoding any passwords or client secrets. 

**Official MS Learn References:**
* [Using a system-assigned managed identity for an Azure Automation account](https://learn.microsoft.com/en-us/azure/automation/enable-managed-identity-for-automation)
* [Assign a managed identity access to Microsoft Graph](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-to-assign-app-role-managed-identity-powershell)

### Step 1: Create the Automation Account
1. Go to the [Azure Portal](https://portal.azure.com).
2. Search for **Automation Accounts** and click **Create**.
3. Fill in the required details (Name, Resource Group, Region).
4. On the **Advanced** tab, ensure **System assigned** Managed Identity is checked.
5. Click **Review + Create**.

### Step 2: Grant the Managed Identity Graph Permissions
By default, the Managed Identity has no permissions. You must grant it `Device.ReadWrite.All` so it can delete devices. Run this script once from your local computer (you must be a Global Admin):

```powershell
Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All", "Directory.ReadWrite.All"

$TenantID = "<Your-Tenant-ID>"
$ManagedIdentityName = "<Your-Automation-Account-Name>"

# Get the Managed Identity Service Principal
$MI = Get-MgServicePrincipal -Filter "displayName eq '$ManagedIdentityName'"
# Get the Microsoft Graph Service Principal
$GraphApp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"

# Find the Device.ReadWrite.All permission role
$AppRole = $GraphApp.AppRoles | Where-Object {$_.Value -eq "Device.ReadWrite.All"}

# Grant the permission to the Managed Identity
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MI.Id -PrincipalId $MI.Id -ResourceId $GraphApp.Id -AppRoleId $AppRole.Id
```

### Step 3: Add Modules to Azure Automation
1. Open your Automation Account in the Azure Portal.
2. Under **Shared Resources**, select **Modules**.
3. Click **Add a module** -> **Browse from gallery**.
4. Import `Microsoft.Graph.Authentication` and `Microsoft.Graph.Identity.DirectoryManagement`.

### Step 4: Create the Runbook
1. Under **Process Automation**, select **Runbooks**.
2. Click **Create a runbook**.
3. Name it `Entra-Stale-Device-Cleanup`, set Runbook type to **PowerShell**, and choose Runtime version **7.2**.
4. Click **Create**.
5. Paste the following script into the editor:

```powershell
<#
.SYNOPSIS
Finds and deletes devices from Entra ID that haven't signed in for 90 days.
Uses the Automation Account's System-Assigned Managed Identity.
#>

Write-Output "Authenticating to Microsoft Graph using Managed Identity..."
# -Identity tells it to use the Automation Account's identity
Connect-MgGraph -Identity

$cutoffDate = (Get-Date).AddDays(-90).ToString("yyyy-MM-ddTHH:mm:ssZ")
Write-Output "Searching for devices inactive since $cutoffDate..."

# Using ConsistencyLevel eventual for advanced filtering
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
        Write-Output "Deleting $($device.displayName) ($($device.id))..."
        Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/devices/$($device.id)"
    } catch {
        Write-Output "Error deleting $($device.displayName): $_"
    }
}

Write-Output "Cleanup complete."
Disconnect-MgGraph
```

### Step 5: Test and Schedule
1. Click **Test pane** at the top and click **Start** to verify it connects and runs correctly.
2. Once verified, click **Publish**.
3. From the Runbook overview page, click **Link to schedule**, create a new schedule (e.g., Monthly on the 1st), and link it. 
