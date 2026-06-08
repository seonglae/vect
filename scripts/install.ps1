# Vect installer (Windows).
# Usage: irm https://raw.githubusercontent.com/seonglae/vect-app/main/scripts/install.ps1 | iex
$ErrorActionPreference = 'Stop'
$Repo = 'seonglae/vect-app'

Write-Host '→ Fetching latest release metadata' -ForegroundColor Cyan
$Latest = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
$Asset = $Latest.assets | Where-Object { $_.name -like '*x64-setup.exe' -or $_.name -like '*x64_en-US.msi' } | Select-Object -First 1
if (-not $Asset) { throw 'No Windows installer in the latest release' }

$TmpFile = Join-Path $env:TEMP $Asset.name
Write-Host "→ Downloading $($Asset.name)" -ForegroundColor Cyan
Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile $TmpFile

Write-Host '→ Launching installer' -ForegroundColor Cyan
if ($TmpFile -like '*.msi') {
  Start-Process msiexec.exe -ArgumentList "/i `"$TmpFile`" /qb" -Wait
} else {
  Start-Process -FilePath $TmpFile -Wait
}

Remove-Item $TmpFile -Force
Write-Host '✓ Done' -ForegroundColor Green
