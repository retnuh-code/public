<#
.SYNOPSIS
    Universal installer for EXE or MSI packages from any URL.

.DESCRIPTION
    Prompts for or accepts manual input of an installer URL and optional arguments.
    Downloads the file to a temporary directory, runs the installer silently,
    and optionally verifies installation by checking a file or process name.

.EXAMPLES
    .\install-generic-software.ps1
    .\install-generic-software.ps1 -Url "https://example.com/setup.msi" -Arguments "/qn /norestart"

.NOTES
    Author: retnuh-code
    Version: 1.0
#>

param(
    [string]$Url,
    [string]$Arguments,
    [string]$VerifyPath,
    [string]$VerifyProcess
)

# ====== Prerequisites ======
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$TempDir = Join-Path $env:TEMP "GenericInstaller"
New-Item -Path $TempDir -ItemType Directory -Force | Out-Null

# Prompt for inputs if not provided
if (-not $Url) {
    $Url = Read-Host "Enter the full installer download URL"
}
if (-not $Arguments) {
    $Arguments = Read-Host "Enter installation arguments (or leave blank)"
}

# Detect file type
$FileName = Split-Path $Url -Leaf
$DownloadPath = Join-Path $TempDir $FileName

Write-Host " Downloading installer..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $Url -OutFile $DownloadPath -UseBasicParsing -ErrorAction Stop
    Write-Host "Downloaded to $DownloadPath" -ForegroundColor Green
} catch {
    Write-Host " Failed to download file: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ====== Installation ======
Write-Host " Running installer..." -ForegroundColor Cyan

try {
    if ($DownloadPath -match "\.msi$") {
        # Run MSI via msiexec
        $cmdArgs = "/i `"$DownloadPath`" $Arguments"
        Start-Process -FilePath "msiexec.exe" -ArgumentList $cmdArgs -Wait
    } else {
        # Assume EXE
        Start-Process -FilePath $DownloadPath -ArgumentList $Arguments -Wait
    }
    Write-Host " Installation process completed." -ForegroundColor Green
} catch {
    Write-Host " Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ====== Verification (optional) ======
if ($VerifyPath) {
    if (Test-Path $VerifyPath) {
        Write-Host " Verified file exists: $VerifyPath" -ForegroundColor Green
    } else {
        Write-Host "File not found at: $VerifyPath" -ForegroundColor Yellow
    }
}
elseif ($VerifyProcess) {
    $proc = Get-Process -Name $VerifyProcess -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host " Verified process running: $VerifyProcess" -ForegroundColor Green
    } else {
        Write-Host " Process not found: $VerifyProcess" -ForegroundColor Yellow
    }
} else {
    Write-Host "No verification criteria provided." -ForegroundColor DarkGray
}

Write-Host "Done." -ForegroundColor Cyan
