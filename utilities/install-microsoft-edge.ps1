<#
.SYNOPSIS
    Installs the latest stable version of Microsoft Edge (Enterprise x64).

.DESCRIPTION
    Downloads the official Microsoft Edge Enterprise x64 MSI installer via Microsoft’s
    fwlink redirect and installs it silently using msiexec.

.EXAMPLE
    .\install-microsoft-edge.ps1

.NOTES
    Author: retnuh-code
    Version: 1.0
#>

# Ensure TLS 1.2 support
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create a temporary working directory
$EdgeDir = "$env:TEMP\EdgeInstall"
New-Item -Path $EdgeDir -ItemType Directory -Force | Out-Null

# Define the download path
$DownloadPath = Join-Path $EdgeDir "MicrosoftEdgeEnterpriseX64.msi"

# Official Microsoft Edge Enterprise x64 (latest stable) redirect
$Uri = "https://go.microsoft.com/fwlink/?LinkID=2093437"

Write-Host " Downloading Microsoft Edge Enterprise (x64)..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $Uri -OutFile $DownloadPath -UseBasicParsing -ErrorAction Stop
}
catch {
    Write-Host " Failed to download Edge installer: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $DownloadPath)) {
    Write-Error "Download failed: file not found at $DownloadPath"
    exit 1
}

# Install silently
Write-Host " Installing Microsoft Edge..." -ForegroundColor Cyan
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$DownloadPath`" /qn /norestart" -Wait

# Verify installation
$EdgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (Test-Path $EdgePath) {
    Write-Host " Microsoft Edge installation completed successfully." -ForegroundColor Green
} else {
    Write-Host " Installation completed, but Edge executable not found." -ForegroundColor Yellow
}
