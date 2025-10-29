<#
.SYNOPSIS
    Lightweight SMTP relay test script.

.DESCRIPTION
    This script defines a function `Test-SMTP` that sends a test message using
    `Send-MailMessage`. Designed for GitHub hosting so you can run it directly
    via one-liner using `irm | iex`.

.EXAMPLE
    irm https://github.com/retnuh-code/public/raw/main/on-prem/test-smtp-server.ps1 | iex
    Test-SMTP -SmtpServer "test-server-01.localdomain.com" -From "localemail@localdomain.com" -To "hostedemail@provider.com"

.NOTES
    Author: retnuh-code
    Version: 1.0
#>

function Test-SMTP {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SmtpServer,

        [Parameter(Mandatory = $true)]
        [string]$From,

        [Parameter(Mandatory = $true)]
        [string]$To,

        [Parameter(Mandatory = $false)]
        [string]$Subject = "PowerShell SMTP Test",

        [Parameter(Mandatory = $false)]
        [string]$Body = "Hi, this is a test email sent via PowerShell to test the SMTP relay server.",

        [Parameter(Mandatory = $false)]
        [int]$Port = 25,

        [switch]$UseSsl
    )

    Write-Host "SMTP Relay Test" -ForegroundColor Cyan
    Write-Host "Server : $SmtpServer"
    Write-Host "From   : $From"
    Write-Host "To     : $To"
    Write-Host "Port   : $Port"
    if ($UseSsl) { Write-Host "SSL    : Enabled" } else { Write-Host "SSL    : Disabled" }
    Write-Host "---------------------------------------"

    try {
        Send-MailMessage `
            -SmtpServer $SmtpServer `
            -Port $Port `
            -To $To `
            -From $From `
            -Subject $Subject `
            -Body $Body `
            -UseSsl:$UseSsl.IsPresent

        Write-Host "Email sent successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to send email: $($_.Exception.Message)" -ForegroundColor Red
    }
}
