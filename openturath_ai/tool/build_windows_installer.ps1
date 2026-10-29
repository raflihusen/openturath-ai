# Membangun OpenTurath_AI_Windows_Setup.exe (pembungkus satu berkas):
#   1. mesin pemasang Inno (installer_core.iss) -> OpenTurath_AI_Core_Setup.exe
#   2. layar pemasang Flutter (openturath_installer) -> build Windows rilis
#   3. ui.zip + install_manifest.json
#   4. pembungkus (installer_stub.iss) -> OpenTurath_AI_Windows_Setup.exe
# Hanya untuk Windows. Tidak mengunggah atau menyiarkan rilis apa pun.
$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Resolve-Path (Join-Path $scriptDir '..')
$repoDir = Resolve-Path (Join-Path $projectDir '..')
$windowsDir = Join-Path $projectDir 'windows'
$uiProject = Join-Path $repoDir 'openturath_installer'
$stage = Join-Path $projectDir 'build\installer_stage'
$payloadDir = Join-Path $repoDir 'OpenTurath_AI_Windows'

$isccCandidates = @(
  'C:\Users\apple\AppData\Local\Programs\Inno Setup 6\ISCC.exe',
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
)
$iscc = $isccCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) { throw "ISCC.exe not found. Install Inno Setup 6 (winget install JRSoftware.InnoSetup)." }

Write-Host "1/4 Mesin pemasang (Inno)..." -ForegroundColor Cyan
& $iscc (Join-Path $windowsDir 'installer_core.iss')
if ($LASTEXITCODE -ne 0) { throw "ISCC gagal pada installer_core.iss" }

Write-Host "2/4 Layar pemasang (Flutter)..." -ForegroundColor Cyan
Push-Location $uiProject
flutter build windows --release --target-platform windows-x64
if ($LASTEXITCODE -ne 0) { throw "flutter build windows gagal" }
Pop-Location
$uiRelease = Join-Path $uiProject 'build\windows\x64\runner\Release'

Write-Host "3/4 Paket antarmuka..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force $stage | Out-Null
# Jumlah berkas yang akan ditulis mesin pemasang: exe + dll + data\*
$files = (Get-ChildItem $payloadDir -Filter '*.exe' | Where-Object Name -eq 'openturath_ai.exe').Count +
         (Get-ChildItem $payloadDir -Filter '*.dll').Count +
         (Get-ChildItem (Join-Path $payloadDir 'data') -Recurse -File).Count
@{ core = '..\core.exe'; files = $files } | ConvertTo-Json | Set-Content (Join-Path $uiRelease 'install_manifest.json') -Encoding utf8
$zip = Join-Path $stage 'ui.zip'
if (Test-Path $zip) { Remove-Item $zip }
Compress-Archive -Path (Join-Path $uiRelease '*') -DestinationPath $zip

Write-Host "4/4 Pembungkus satu berkas..." -ForegroundColor Cyan
& $iscc (Join-Path $windowsDir 'installer_stub.iss')
if ($LASTEXITCODE -ne 0) { throw "ISCC gagal pada installer_stub.iss" }

$outputExe = Join-Path $projectDir '..\OpenTurath_AI_Windows_Setup.exe'
if (Test-Path $outputExe) {
  $hash = (Get-FileHash $outputExe -Algorithm SHA256).Hash.ToLower()
  "$hash  OpenTurath_AI_Windows_Setup.exe" | Set-Content "$outputExe.sha256" -Encoding ascii
  $publicDir = Join-Path $projectDir 'public'
  Copy-Item $outputExe (Join-Path $publicDir 'OpenTurath_AI_Windows_Setup.exe') -Force
  Copy-Item "$outputExe.sha256" (Join-Path $publicDir 'OpenTurath_AI_Windows_Setup.exe.sha256') -Force
  Write-Host "Installer ready: $outputExe" -ForegroundColor Green
  Write-Host "SHA256: $hash" -ForegroundColor Yellow
}
