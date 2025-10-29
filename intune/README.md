☁️ Intune & Azure AD Scripts
============================

Scripts in this folder automate **Microsoft Intune** and **Azure AD** administrative tasks --- including group creation, device organization, and dynamic membership management.

They're designed for repeatable, real-world use with proper authentication and module checks built in.

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
`irm https://github.com/retnuh-code/public/raw/main/intune/create-dynamic-device-groups.ps1 | iex`\
`create-dynamic-device-groups -Single`

* * * * *

🧩 create-dynamic-device-groups.ps1
-----------------------------------

### Purpose

Creates one or more **Azure AD dynamic device groups** using the `New-AzureADMSGroup` cmdlet.\
The script automatically:

-   Checks and installs the **AzureAD module** if missing

-   Prompts you to log in with `Connect-AzureAD` if not connected

-   Allows either **interactive creation** or **bulk import from CSV**

* * * * *

### Usage

#### 🧠 Interactive (Prompt-Based)

`.\create-dynamic-device-groups.ps1 -Single`

You'll be prompted for:

-   **Display Name**

-   **Description**

-   **Membership Rule** (e.g. `(device.deviceOSType -eq "Windows")`)

* * * * *

#### ⚙️ Parameterized (Non-Interactive)

`.\create-dynamic-device-groups.ps1 -Single `\
    `-DisplayName "[IT]WindowsLaptops" `\
    `-Description "Dynamic group for IT-managed Windows laptops" `\
    `-MembershipRule "(device.deviceOSType -eq 'Windows')"`

* * * * *

#### 📁 Bulk Creation via CSV

`.\create-dynamic-device-groups.ps1 -CsvPath "C:\temp\CreateDynamicGroups.csv"`

**Example CSV:**

`Description,DisplayName,MembershipRule`\
`Full build apps/configurations/policies for HR Laptops,[HR]WindowsLaptops,(device.devicePhysicalIds -any (_ -contains "HR")) -and (device.deviceOSType -eq "Windows")`\
`Full build apps/configurations/policies for IT Laptops,[IT]WindowsLaptops,(device.devicePhysicalIds -any (_ -contains "IT")) -and (device.deviceOSType -eq "Windows")`\

* * * * *

#### 🌐 Run from GitHub

`[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12`\
`irm https://github.com/retnuh-code/public/raw/main/intune/create-dynamic-device-groups.ps1 | iex`\
`create-dynamic-device-groups -CsvPath "C:\temp\CreateDynamicGroups.csv"`\

* * * * *

### Parameters

| Parameter | Description |
| --- | --- |
| `-Single` | Creates one group interactively or via parameters |
| `-DisplayName` | The display name for the group (used with `-Single`) |
| `-Description` | Description for the group (used with `-Single`) |
| `-MembershipRule` | The dynamic membership rule (used with `-Single`) |
| `-CsvPath` | Path to a CSV file containing group definitions |

* * * * *

### Output

Displays creation progress for each group:

-   ✅ **Green** for successfully created groups

-   ❌ **Red** for failed creations (with error message)

Each success line includes the group's **DisplayName** and **ObjectId**.

* * * * *

### Requirements

-   PowerShell 5.1 or newer

-   AzureAD module

-   Azure AD credentials with permission to create groups

* * * * *

### 🧑‍💻 Author

**retnuh-code**\[GitHub -- retnuh-code](https://github.com/retnuh-code)
