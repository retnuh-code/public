<#
.SYNOPSIS
    Find iOS apps in the App Store using Name, AppID, or BundleID.
.DESCRIPTION
    Queries the iTunes API to retrieve metadata for iOS apps — including
    Bundle ID, App Name, Store URL, and Publisher. Supports single lookups
    or batch imports from a CSV list.
.EXAMPLES
    .\find-ios-app.ps1 -Name "YouTube"
    .\find-ios-app.ps1 -AppID "544007664"
    .\find-ios-app.ps1 -BundleID "com.google.ios.youtube"
    .\find-ios-app.ps1 -CsvPath "C:\temp\apps.csv" -CsvType "Name"
.NOTES
    Author: retnuh-code
    Version: 2.0
#>

param(
    [string]$Name,
    [string]$AppID,
    [string]$BundleID,
    [string]$CsvPath,
    [ValidateSet('Name','AppID','BundleID')]
    [string]$CsvType,
    [string]$CsvOut
)

# ========== FUNCTIONS ==========
function Get-AppInfo {
    param([string]$Uri)

    $data = Invoke-WebRequest -Uri $Uri -UseBasicParsing
    $json = $data.Content | ConvertFrom-Json

    if ($json.resultCount -gt 0) {
        return $json.results | ForEach-Object {
            if ($_.trackViewUrl -like "*?uo=4*") {
                $_.trackViewUrl = $_.trackViewUrl -replace "\?uo=4$", ""
            }
            [PSCustomObject]@{
                "Bundle ID" = $_.bundleId
                "App Name"  = $_.trackName
                "Store Url" = $_.trackViewUrl
                "Publisher" = $_.sellerName
            }
        }
    }
}

# ========== DIRECT LOOKUPS ==========

# -- Search by App Name (interactive) --
if ($Name) {
    $continue = $true
    while ($continue) {
        $iTunesUrl = "https://itunes.apple.com/search?entity=software&term={0}" -f $Name
        $apps = Invoke-RestMethod -Uri $iTunesUrl -Method Get

        if ($apps.resultCount -gt 0) {
            $bundleIdsAndTrackNames = $apps.results | ForEach-Object {
                if ($_.trackViewUrl -like "*?uo=4*") {
                    $_.trackViewUrl = $_.trackViewUrl -replace "\?uo=4$", ""
                }
                [PSCustomObject]@{
                    "Bundle ID" = $_.bundleId
                    "App Name"  = $_.trackName
                    "Store Url" = $_.trackViewUrl
                    "Publisher" = $_.sellerName
                }
            }

            $count = 1
            foreach ($a in $bundleIdsAndTrackNames.'App Name') {
                Write-Host "$count. $a"
                $count++
            }

            $selected = Read-Host "Select an app by number (or 'exit' to quit)"
            if ($selected -eq 'exit') {
                $continue = $false
            } elseif ($selected -ge 1 -and $selected -le $bundleIdsAndTrackNames.Count) {
                $chosen = $bundleIdsAndTrackNames[$selected - 1]

                Write-Host -ForegroundColor Yellow "Selected App Info:"
                Write-Host -ForegroundColor Cyan "Store Url: $($chosen.'Store Url')"
                Write-Host -ForegroundColor Green "App Name: $($chosen.'App Name')"
                Write-Host -ForegroundColor DarkCyan "Bundle ID: $($chosen.'Bundle ID')"
                Write-Host -ForegroundColor DarkGreen "Publisher: $($chosen.'Publisher')"

                if ($CsvOut) {
                    $chosen | Export-Csv -Path $CsvOut -NoTypeInformation
                    Write-Host "`n✅ Exported to $CsvOut" -ForegroundColor Green
                }
            } else {
                Write-Host "Invalid selection. Please enter a valid app number or 'exit'."
            }
        } else {
            Write-Host "No results found for '$Name'."
        }
        break
    }
}

# -- Search by AppID --
if ($AppID) {
    $uri = "https://itunes.apple.com/lookup?id=$AppID"
    Get-AppInfo -Uri $uri | Format-Table
}

# -- Search by BundleID --
if ($BundleID) {
    $uri = "https://itunes.apple.com/lookup?bundleId=$BundleID"
    Get-AppInfo -Uri $uri | Format-Table
}

# ========== CSV INPUT SUPPORT ==========
if ($CsvPath) {
    if (-not (Test-Path $CsvPath)) {
        Write-Host "❌ CSV file not found: $CsvPath" -ForegroundColor Red
        exit
    }

    $rows = Import-Csv $CsvPath
    $results = @()

    foreach ($row in $rows) {
        switch ($CsvType) {
            'Name' {
                $url = "https://itunes.apple.com/search?entity=software&term=$($row.Name)"
            }
            'AppID' {
                $url = "https://itunes.apple.com/lookup?id=$($row.AppID)"
            }
            'BundleID' {
                $url = "https://itunes.apple.com/lookup?bundleId=$($row.BundleID)"
            }
        }

        $results += Get-AppInfo -Uri $url
    }

    if ($CsvOut) {
        $results | Export-Csv -Path $CsvOut -NoTypeInformation
        Write-Host "`n✅ Exported $($results.Count) results to $CsvOut" -ForegroundColor Green
    } else {
        $results | Format-Table
    }
}
