🧩 Utility Scripts
==================

Scripts in this folder are **supporting tools** that assist with data collection, lookup, or automation workflows.\
They're not tied to a specific platform but are often used alongside Intune, Azure, or other deployment processes.

* * * * *

All scripts in this repository can be executed directly from GitHub using PowerShell's `Invoke-RestMethod` (`irm`) command.

#### ⚠️ Important (TLS 1.2 Fix)

If you see:

`The request was aborted: Could not create SSL/TLS secure channel.`

it means your PowerShell session is using an outdated SSL/TLS version.

Run this once per session **before** calling `irm`:

`[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12`

You can also make this permanent by adding it to your PowerShell profile:

`Add-Content -Path $PROFILE -Value '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12'`

#### Example

`[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12`\
`irm https://github.com/retnuh-code/public/raw/main/utilities/find-ios-app.ps1 | iex`\
`find-ios-app -Name "YouTube"`

* * * * *

📱 find-ios-app.ps1
-------------------

### Purpose

Looks up iOS app details (Bundle ID, App Name, Store URL, and Publisher) from the Apple App Store.\
Useful for documenting or preparing iOS applications for Intune or other MDM deployments.

* * * * *

### Usage

#### Run Locally

`.\find-ios-app.ps1 -Name "YouTube"`

#### Run from GitHub

`irm https://github.com/retnuh-code/public/raw/main/utilities/find-ios-app.ps1 | iex
find-ios-app -Name "YouTube"`

* * * * *

### Batch CSV Input

Prepare a CSV file such as:

```csv
Name
Zoom
YouTube
Canva
```

Then run:

`.\find-ios-app.ps1 -CsvPath "C:\temp\apps.csv" -CsvType Name -CsvOut "C:\temp\results.csv"`

* * * * *

### Parameters

| Parameter | Description |
| --- | --- |
| `-Name` | Interactive search by app name |
| `-AppID` | Lookup a specific AppID |
| `-BundleID` | Lookup a specific bundle identifier |
| `-CsvPath` | Path to a CSV input file |
| `-CsvType` | Type of data in CSV: `Name`, `AppID`, or `BundleID` |
| `-CsvOut` | Optional output file path for CSV export |

* * * * *

### Output

Displays formatted results in PowerShell and optionally exports to CSV.

**Example Output**

| Bundle ID | App Name | Store URL | Publisher |
| --- | --- | --- | --- |
| com.google.ios.youtube | YouTube | https://apps.apple.com/app/youtube/id544007664 | Google LLC |


* * * * *

🌐 install-microsoft-edge.ps1
-----------------------------

### Purpose

Downloads and installs the latest stable version of **Microsoft Edge (Enterprise x64)** directly from Microsoft's CDN.\
The script automatically ensures TLS 1.2 compatibility, uses a temporary working directory, and performs a silent MSI installation.

* * * * *

### Usage

#### Run Locally

`.\install-microsoft-edge.ps1`

#### Run from GitHub

`[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12`\
`irm https://github.com/retnuh-code/public/raw/main/utilities/install-microsoft-edge.ps1 | iex`

* * * * *

### Behavior

-   Downloads the **official Edge Enterprise x64 MSI** using Microsoft's redirect

-   Installs silently with `/qn /norestart` (no user interaction)

-   Verifies installation by checking for the Edge executable

-   Displays progress and final success or error messages

* * * * *

### Output

✅ **Success:** `Microsoft Edge installation completed successfully.`\
⚠️ **Warning:** Installation finished but executable not found.\
❌ **Error:** Download or installation failure message with cause.

* * * * *
