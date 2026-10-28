$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Resolve-Path (Join-Path $scriptDir '..')
$windowsDir = Join-Path $projectDir 'windows'
$issFile = Join-Path $windowsDir 'installer.iss'

$isccCandidates = @(
  'C:\Users\apple\AppData\Local\Programs\Inno Setup 6\ISCC.exe',
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
)
$iscc = $isccCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) {
  throw "ISCC.exe not found. Please install Inno Setup 6 (winget install JRSoftware.InnoSetup)."
}

Write-Host "Compiling Inno Setup installer..." -ForegroundColor Cyan
& $iscc $issFile

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
