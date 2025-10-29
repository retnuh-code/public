# 🏢 On-Prem Scripts

Scripts in this folder focus on **local infrastructure, networking, and system diagnostics**.  

They're typically used to verify configurations or test internal services such as SMTP relays or DNS.

---

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

`[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
irm https://github.com/retnuh-code/public/raw/main/utilities/find-ios-app.ps1 | iex
find-ios-app -Name "YouTube"`

---

## 📧 test-smtp-server.ps1

### Purpose

Sends a test email to validate SMTP relay connectivity and authentication from on-prem servers.

### Usage

#### Run Locally

```powershell

.\test-smtp-server.ps1 -SmtpServer "HNL-TST-WEB-02.holo.pan" -From "hhearne.test@holo.pan" -To "hhearne@initusa.com"
```

Run from GitHub

```powershell

irm https://github.com/retnuh-code/public/raw/main/on-prem/test-smtp-server.ps1 | iex
```
```powershell
Test-SMTP -SmtpServer "test-server-01.localdomain.com" -From "localemail@localdomain.com" -To "hostedemail@provider.com"
```
Parameters

Parameter  Description

-SmtpServer  Hostname or IP of SMTP relay

-From  Sender email address

-To  Recipient email address

-Subject  Custom email subject

-Body  Email body text

-Port  SMTP port (default 25)

-UseSsl  Enables SSL/TLS

Output

Displays connection status and email result in PowerShell.

If successful, you'll see a green "✅ Email sent successfully!" message.
