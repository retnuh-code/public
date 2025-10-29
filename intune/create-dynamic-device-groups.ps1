<#
.SYNOPSIS
    Creates Azure AD / Intune Dynamic Device Groups.

.DESCRIPTION
    Supports:
      • Single group creation (prompts for details or accepts parameters)
      • Bulk creation from CSV

.EXAMPLES
    .\create-dynamic-device-groups.ps1 -Single
    .\create-dynamic-device-groups.ps1 -DisplayName "[IT]WindowsLaptops" -Description "IT laptop configs" -MembershipRule "(device.deviceOSType -eq 'Windows')"
    .\create-dynamic-device-groups.ps1 -CsvPath "C:\temp\CreateDynamicGroups.csv"

.NOTES
    Author: renuth-code
    Version: 1.1
#>

param(
    [switch]$Single,
    [string]$DisplayName,
    [string]$Description,
    [string]$MembershipRule,
    [string]$CsvPath
)

# ========== Prerequisites ==========
Write-Host " Checking for AzureAD module..." -ForegroundColor Cyan
if (-not (Get-Module -ListAvailable -Name AzureAD)) {
    Write-Host "Installing AzureAD module..." -ForegroundColor Yellow
    Install-Module AzureAD -Force -Scope CurrentUser
}
Import-Module AzureAD

# Ensure connection
try {
    if (-not (Get-AzureADTenantDetail -ErrorAction SilentlyContinue)) {
        Write-Host " Connecting to Azure AD..." -ForegroundColor Cyan
        Connect-AzureAD
    }
} catch {
    Write-Host "Connection to AzureAD failed. Please run Connect-AzureAD manually and retry." -ForegroundColor Red
    exit
}

# ========== SINGLE CREATION ==========
if ($Single) {
    Write-Host "Creating a single dynamic group..." -ForegroundColor Cyan

    # Prompt if missing
    if (-not $DisplayName)     { $DisplayName   = Read-Host "Enter Display Name for the group" }
    if (-not $Description)     { $Description   = Read-Host "Enter Description for the group" }
    if (-not $MembershipRule)  { $MembershipRule = Read-Host "Enter Membership Rule (e.g. (device.devicePhysicalIds -any (_ -contains ""TECH"" -and _ -notcontains ""Kiosk"")) -and (device.deviceOSType -eq ""Windows""))" }

    $newGroup = @{
        Description                   = $Description
        DisplayName                   = $DisplayName
        MailEnabled                   = $false 
        SecurityEnabled               = $true 
        GroupTypes                    = "DynamicMembership"
        MailNickName                  = "Group"
        MembershipRule                = $MembershipRule
        MembershipRuleProcessingState = "On"
    }

    try {
        $group = New-AzureADMSGroup @newGroup
        Write-Host "Created group: $($group.DisplayName)  |  ObjectId: $($group.Id)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create group: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ========== CSV CREATION ==========
if ($CsvPath) {
    if (-not (Test-Path $CsvPath)) {
        Write-Host "CSV file not found: $CsvPath" -ForegroundColor Red
        exit
    }

    $groups = Import-Csv -Path $CsvPath
    Write-Host "`n📂 Creating $($groups.Count) groups from CSV..." -ForegroundColor Cyan

    foreach ($g in $groups) {
        $newGroup = @{
            Description                   = $g.Description
            DisplayName                   = $g.DisplayName
            MailEnabled                   = $false 
            SecurityEnabled               = $true 
            GroupTypes                    = "DynamicMembership"
            MailNickName                  = "Group"
            MembershipRule                = $g.MembershipRule
            MembershipRuleProcessingState = "On"
        }

        try {
            $created = New-AzureADMSGroup @newGroup
            Write-Host "Created: $($created.DisplayName)" -ForegroundColor Green
        } catch {
            Write-Host "Failed: $($g.DisplayName) | $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
