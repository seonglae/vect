# Vect installer (Windows).
# Usage: irm https://raw.githubusercontent.com/seonglae/vect-app/main/scripts/install.ps1 | iex
$ErrorActionPreference = 'Stop'
$Repo = 'seonglae/vect-app'
# The key every release download is signed with, the one the app's updater trusts.
$PublicKey = 'RWQY6le0WOYq1SK6aFpv/yMkyKdqnfO+SZ3R+Qf+X0IcnPuBlKsCcOjR'
# Windows has no verifier for that signature, so minisign 0.12 checks it. Its download is pinned by
# hash and refused if it changes.
$MinisignUrl = 'https://github.com/jedisct1/minisign/releases/download/0.12/minisign-0.12-win64.zip'
$MinisignSha256 = '37B600344E20C19314B2E82813DB2BFDCC408B77B876F7727889DBD46D539479'

Write-Host '→ Fetching latest release metadata' -ForegroundColor Cyan
$Latest = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
$Asset = $Latest.assets | Where-Object { $_.name -like '*x64-setup.exe' -or $_.name -like '*x64_en-US.msi' } | Select-Object -First 1
if (-not $Asset) { throw 'No Windows installer in the latest release' }
$Signature = $Latest.assets | Where-Object { $_.name -eq "$($Asset.name).sig" } | Select-Object -First 1
if (-not $Signature) { throw "No signature is published for $($Asset.name)" }

$Work = Join-Path $env:TEMP ('vect-install-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $Work | Out-Null
$TmpFile = Join-Path $Work $Asset.name
Write-Host "→ Downloading $($Asset.name)" -ForegroundColor Cyan
Invoke-WebRequest -UseBasicParsing -Uri $Asset.browser_download_url -OutFile $TmpFile

Write-Host '→ Checking the signature' -ForegroundColor Cyan
$SigFile = "$TmpFile.sig"
Invoke-WebRequest -UseBasicParsing -Uri $Signature.browser_download_url -OutFile $SigFile
$Minisig = "$TmpFile.minisig"
[IO.File]::WriteAllBytes($Minisig, [Convert]::FromBase64String((Get-Content -Raw $SigFile).Trim()))
$Zip = Join-Path $Work 'minisign.zip'
Invoke-WebRequest -UseBasicParsing -Uri $MinisignUrl -OutFile $Zip
if ((Get-FileHash -Algorithm SHA256 $Zip).Hash -ne $MinisignSha256) { throw 'The minisign download does not match its pinned hash' }
Expand-Archive -Path $Zip -DestinationPath $Work
$Arch = 'x86_64'
if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { $Arch = 'aarch64' }
$Minisign = Join-Path $Work "minisign-win64\$Arch\minisign.exe"
& $Minisign -Vm $TmpFile -x $Minisig -P $PublicKey | Out-Null
if ($LASTEXITCODE -ne 0) { throw "The signature of $($Asset.name) does not match Vect's key" }
Write-Host '✓ Signed by Vect' -ForegroundColor Green

Write-Host '→ Launching installer' -ForegroundColor Cyan
if ($TmpFile -like '*.msi') {
  Start-Process msiexec.exe -ArgumentList "/i `"$TmpFile`" /qb" -Wait
} else {
  Start-Process -FilePath $TmpFile -Wait
}

Remove-Item -Recurse -Force $Work
Write-Host '✓ Done' -ForegroundColor Green
