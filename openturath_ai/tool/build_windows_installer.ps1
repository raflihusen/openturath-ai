# Membangun OpenTurath_AI_Windows_Setup.exe (pembungkus satu berkas):
#   1. mesin pemasang Inno (installer_core.iss) -> OpenTurath_AI_Core_Setup.exe
#   2. layar pemasang Flutter (openturath_installer) -> build Windows rilis
#   3. staging ui\ + install_manifest.json (tanpa tar.exe / ui.zip dropper pattern)
#   4. pembungkus (installer_stub.iss) -> OpenTurath_AI_Windows_Setup.exe
# Opsional: set OT_WIN_CERT_SHA1 (atau OT_WIN_SIGN_COMMAND dengan placeholder {file})
# untuk penandatanganan Authenticode SHA-256 + RFC 3161 dari dalam ke luar.
# Hanya untuk Windows. Tidak mengunggah atau menyiarkan rilis apa pun.
param([switch]$LocalOnly, [string]$PayloadDirectory = '')
$ErrorActionPreference = 'Stop'

function Invoke-OptionalCodeSign {
  param([Parameter(Mandatory = $true)][string]$FilePath)
  if (!(Test-Path $FilePath)) { throw "Sign target missing: $FilePath" }

  $customCmd = $env:OT_WIN_SIGN_COMMAND
  $certSha1 = $env:OT_WIN_CERT_SHA1
  $timestampUrl = if ($env:OT_WIN_TIMESTAMP_URL) { $env:OT_WIN_TIMESTAMP_URL } else { 'http://timestamp.digicert.com' }

  if ($customCmd) {
    $resolved = $customCmd.Replace('{file}', "`"$FilePath`"")
    Write-Host "  [Sign] Custom signer -> $FilePath" -ForegroundColor DarkCyan
    cmd /c $resolved
    if ($LASTEXITCODE -ne 0) { throw "Custom Authenticode signing failed ($LASTEXITCODE) for $FilePath" }
    return $true
  }

  if ($certSha1) {
    $signtool = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin\*\x64\signtool.exe" -ErrorAction SilentlyContinue |
      Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
    if (-not $signtool) { $signtool = (Get-Command signtool.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source) }
    if (-not $signtool) { throw 'OT_WIN_CERT_SHA1 is set but signtool.exe was not found.' }
    Write-Host "  [Sign] signtool SHA-256 + RFC 3161 -> $FilePath" -ForegroundColor DarkCyan
    & $signtool sign /sha1 $certSha1 /fd sha256 /tr $timestampUrl /td sha256 /d 'OpenTurath AI' /du 'https://openturath.id' $FilePath
    if ($LASTEXITCODE -ne 0) { throw "signtool failed ($LASTEXITCODE) for $FilePath" }
    & $signtool verify /pa $FilePath
    if ($LASTEXITCODE -ne 0) { throw "signtool verify failed ($LASTEXITCODE) for $FilePath" }
    return $true
  }

  return $false
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Resolve-Path (Join-Path $scriptDir '..')
$repoDir = Resolve-Path (Join-Path $projectDir '..')
$windowsDir = Join-Path $projectDir 'windows'
$uiProject = Join-Path $repoDir 'openturath_installer'
$stage = Join-Path $projectDir 'build\installer_stage'
$defaultReleaseDir = Join-Path $projectDir 'build\windows\x64\runner\Release'
$payloadDir = if ($PayloadDirectory) {
  [IO.Path]::GetFullPath($PayloadDirectory)
} elseif (Test-Path (Join-Path $defaultReleaseDir 'prerequisites\vc_redist.x64.exe')) {
  $defaultReleaseDir
} else {
  Join-Path $repoDir 'OpenTurath_AI_Windows'
}
if (!(Test-Path (Join-Path $payloadDir 'openturath_ai.exe'))) {
  throw "Payload tidak ditemukan di $payloadDir. Jalankan 'flutter build windows --release' (x64) lalu '.\tool\package_windows.ps1' terlebih dahulu."
}
$env:CMAKE_POLICY_VERSION_MINIMUM = '3.5'

$isccCandidates = @(
  "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
)
$iscc = $isccCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) { throw "ISCC.exe not found. Install Inno Setup 6 (winget install JRSoftware.InnoSetup)." }

$versionLine = Select-String -Path (Join-Path $projectDir 'pubspec.yaml') -Pattern '^version:\s*(\S+)'
if (!$versionLine) { throw 'Missing app version' }
$versionParts = $versionLine.Matches[0].Groups[1].Value.Split('+')
$appVersion = $versionParts[0]
$appBuild = [int]$versionParts[1]

Write-Host "1/4 Mesin pemasang (Inno)..." -ForegroundColor Cyan
$signedAny = $false
if (Invoke-OptionalCodeSign (Join-Path $payloadDir 'openturath_ai.exe')) { $signedAny = $true }
& $iscc ("/DMyAppVersion=$appVersion") ("/DPayloadRoot=$payloadDir") (Join-Path $windowsDir 'installer_core.iss')
if ($LASTEXITCODE -ne 0) { throw "ISCC gagal pada installer_core.iss" }
$coreExe = Join-Path $projectDir 'build\installer_core\OpenTurath_AI_Core_Setup.exe'
if (Invoke-OptionalCodeSign $coreExe) { $signedAny = $true }

Write-Host "2/4 Layar pemasang (Flutter)..." -ForegroundColor Cyan
Push-Location $uiProject
flutter build windows --release
if ($LASTEXITCODE -ne 0) { Pop-Location; throw "flutter build windows gagal" }
Pop-Location
$uiRelease = Join-Path $uiProject 'build\windows\x64\runner\Release'
if (!(Test-Path $uiRelease)) {
  throw "Output build x64 tidak ditemukan di $uiRelease. Pastikan memakai Flutter SDK x64 (bukan ARM64)."
}

Write-Host "3/4 Paket antarmuka (native Inno, tanpa tar.exe)..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force $stage | Out-Null
# Jumlah berkas yang akan ditulis mesin pemasang: exe + dll + data\*
$files = (Get-ChildItem $payloadDir -Filter '*.exe' | Where-Object Name -eq 'openturath_ai.exe').Count +
         (Get-ChildItem $payloadDir -Filter '*.dll').Count +
         (Get-ChildItem (Join-Path $payloadDir 'data') -Recurse -File).Count
$utf8NoBom = [Text.UTF8Encoding]::new($false)
$manifestJson = @{ core = '..\core.exe'; files = $files } | ConvertTo-Json
[IO.File]::WriteAllText((Join-Path $uiRelease 'install_manifest.json'), $manifestJson, $utf8NoBom)
# Bundel DLL VC++ runtime app-local agar UI pemasang Flutter bisa berjalan di PC Windows baru sebelum vc_redist dipasang.
foreach ($dll in @('vcruntime140.dll', 'vcruntime140_1.dll', 'msvcp140.dll')) {
  $sysDll = Join-Path "$env:SystemRoot\System32" $dll
  if (Test-Path $sysDll) {
    Copy-Item $sysDll (Join-Path $uiRelease $dll) -Force
  }
}
if (Invoke-OptionalCodeSign (Join-Path $uiRelease 'openturath_installer.exe')) { $signedAny = $true }
$uiStage = Join-Path $stage 'ui'
if (Test-Path $uiStage) { Remove-Item $uiStage -Recurse -Force }
Copy-Item -Path $uiRelease -Destination $uiStage -Recurse -Force

Write-Host "4/4 Pembungkus satu berkas..." -ForegroundColor Cyan
$outputDir = if ($LocalOnly) { $stage } else { $repoDir }
$outputName = if ($LocalOnly) { 'OpenTurath_AI_Windows_LocalTest_Setup' } else { 'OpenTurath_AI_Windows_Setup' }
& $iscc ("/DMyAppVersion=$appVersion") ("/O$outputDir") ("/F$outputName") (Join-Path $windowsDir 'installer_stub.iss')
if ($LASTEXITCODE -ne 0) { throw "ISCC gagal pada installer_stub.iss" }

$outputExe = Join-Path $outputDir ($outputName + '.exe')
if (Test-Path $outputExe) {
  if (Invoke-OptionalCodeSign $outputExe) { $signedAny = $true }
  if (-not $signedAny) {
    Write-Host "Info: Installer belum ditandatangani (gratis). Submit 1x ke Microsoft Security Intelligence (https://www.microsoft.com/en-us/wdsi/filesubmission -> Software developer) setelah build rilis." -ForegroundColor DarkYellow
  }
  $hash = (Get-FileHash $outputExe -Algorithm SHA256).Hash.ToLower()
  "$hash  OpenTurath_AI_Windows_Setup.exe" | Set-Content "$outputExe.sha256" -Encoding ascii
  $publicDir = Join-Path $projectDir 'public'
  if (!$LocalOnly) {
    Copy-Item $outputExe (Join-Path $publicDir 'OpenTurath_AI_Windows_Setup.exe') -Force
    Copy-Item "$outputExe.sha256" (Join-Path $publicDir 'OpenTurath_AI_Windows_Setup.exe.sha256') -Force
  }
  # Local metadata for the future, explicitly authorized publication step.
  $updateJson = @{version=$appVersion; build=$appBuild; sha256=$hash; installer_protocol=1;
    url='https://openturath.web.app/OpenTurath_AI_Windows_Setup.exe'} | ConvertTo-Json
  [IO.File]::WriteAllText("$outputExe.update.json", $updateJson, $utf8NoBom)
  Write-Host "Installer ready: $outputExe" -ForegroundColor Green
  Write-Host "SHA256: $hash" -ForegroundColor Yellow
}
