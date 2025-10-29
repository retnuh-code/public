# 🏢 On-Prem Scripts

Scripts in this folder focus on **local infrastructure, networking, and system diagnostics**.  

They're typically used to verify configurations or test internal services such as SMTP relays or DNS.

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

powershell

Copy code

irm https://github.com/retnuh-code/public/raw/main/on-prem/test-smtp-server.ps1 | iex

test-smtp -SmtpServer "HNL-TST-WEB-02.holo.pan" -From "hhearne.test@holo.pan" -To "hhearne@initusa.com"

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
