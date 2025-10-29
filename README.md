# 🧰 Retnuh-Code Public PowerShell Scripts  

**Author:** [retnuh-code](https://github.com/retnuh-code)

---

## 🧩 Overview

This repository contains a curated collection of **PowerShell scripts** and **administrative utilities** created by **retnuh-code** for testing, automation, and systems management.  
Each folder represents a different operational context — from on-premises infrastructure to general utilities and Intune-related support tools.

All scripts are written for **Windows PowerShell 5.1+** and **PowerShell 7.x**, with full inline comments and examples for easy reuse.

---

## 📂 Repository Structure

| Folder | Purpose |
|---------|----------|
| **on-prem/** | Scripts and tools for on-premises systems — such as SMTP relay tests, Windows Server utilities, and infrastructure diagnostics. |
| **utilities/** | General-purpose helper scripts that support admin workflows, data collection, or integrations (e.g., iOS app lookups, API data fetchers). |
| **intune/** | Scripts related to Microsoft Intune and Azure AD device management (deployment, enrollment, configuration, reporting). |

---

## 🧪 Execution Options

### 1️⃣ Run Locally
Clone or download any script and execute:

```powershell
.\script-name.ps1 -Parameter value
```

### 2️⃣ Run Directly from GitHub

Each script can also be executed on demand using:

`irm https://github.com/retnuh-code/public/raw/main/<folder>/<script>.ps1 | iex`

**Example:**

`irm https://github.com/retnuh-code/public/raw/main/utilities/find-ios-app.ps1 | iex
find-ios-app -Name "YouTube"`

* * * * *

🧾 Example Scripts
------------------

| Script | Location | Description |
| --- | --- | --- |
| **test-smtp-server.ps1** | `/on-prem/` | Send test emails to verify SMTP relay functionality and connectivity. |
| **find-ios-app.ps1** | `/utilities/` | Retrieves iOS app metadata from the Apple App Store for Intune packaging or documentation. |

* * * * *

🧭 Standards & Conventions
--------------------------

-   Each script includes:

    -   Full comment-based help block (`.SYNOPSIS`, `.EXAMPLE`, `.NOTES`)

    -   Consistent variable naming and inline documentation

    -   CLI argument support for automation

    -   Optional CSV input/output functionality

-   All scripts are self-contained (no dependencies or modules required).

-   Output formatting is designed for readability and easy export.

* * * * *

🧑‍💻 About
-----------

This repository is part of ongoing internal automation and system integration work --- shared publicly for community reference and educational use.\
It reflects real-world tools used across **on-prem, cloud, and hybrid** environments.
