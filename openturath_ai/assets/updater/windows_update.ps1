param([Parameter(Mandatory=$true)][string]$Plan)
$ErrorActionPreference = 'Stop'
$cfg = Get-Content -LiteralPath $Plan -Raw | ConvertFrom-Json
$target = [IO.Path]::GetFullPath([string]$cfg.target)
$package = [IO.Path]::GetFullPath([string]$cfg.package)
$stage = [IO.Path]::GetFullPath([string]$cfg.stage)
$oldPid = [int]$cfg.parentPid
try {
if ($target.Contains('"') -or $target.Contains("`n") -or $target.Contains("`r")) { throw 'Invalid target' }
if (!(Test-Path -LiteralPath (Join-Path $target 'openturath_ai.exe'))) { throw 'Installed application not found' }
if ((Split-Path $stage -Parent) -ne (Split-Path $target -Parent)) { throw 'Invalid staging location' }
if ((Get-FileHash -LiteralPath $package -Algorithm SHA256).Hash.ToLower() -ne $cfg.sha256) { throw 'Package checksum changed' }
if (!$cfg.allowAdhocTest) {
  $signature = Get-AuthenticodeSignature -LiteralPath $package
  if ($signature.Status -ne 'Valid') { throw 'Installer signature is not trusted' }
  $oldSignature = Get-AuthenticodeSignature -LiteralPath (Join-Path $target 'openturath_ai.exe')
  if ($oldSignature.Status -eq 'Valid' -and $oldSignature.SignerCertificate.Subject -ne $signature.SignerCertificate.Subject) { throw 'Installer publisher changed' }
}
$status = Join-Path $stage 'status'
$backup = Join-Path $stage 'previous'
New-Item -ItemType Directory -Path $backup -Force | Out-Null
Get-ChildItem -LiteralPath $target -Force | Copy-Item -Destination $backup -Recurse -Force
'waiting' | Set-Content -LiteralPath $status
New-Item -ItemType File -Path (Join-Path $stage 'ready') | Out-Null
$process = Get-Process -Id $oldPid -ErrorAction SilentlyContinue
$quitDeadline = (Get-Date).AddSeconds(120)
while ($process -and !$process.HasExited) {
  if (Test-Path -LiteralPath (Join-Path $stage 'cancelled')) { throw 'Install cancelled' }
  if ((Get-Date) -gt $quitDeadline) { throw 'Application did not close' }
  Start-Sleep -Milliseconds 200
}
if (Test-Path -LiteralPath (Join-Path $stage 'cancelled')) { throw 'Install cancelled' }
$replaced = $false
try {
  $replaced = $true
  $arguments = '/OTAUPDATE /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /OTADIR="' + $target + '"'
  $install = Start-Process -FilePath $package -ArgumentList $arguments -Wait -PassThru
  if ($install.ExitCode -ne 0) { throw "Installer failed: $($install.ExitCode)" }
  'installed' | Set-Content -LiteralPath $status
  $newProcess = Start-Process -FilePath (Join-Path $target 'openturath_ai.exe') -WorkingDirectory $target -PassThru
  $deadline = (Get-Date).AddSeconds(90)
  while (!(Test-Path -LiteralPath (Join-Path $stage 'confirmed'))) {
    if ((Get-Date) -gt $deadline -or $newProcess.HasExited) { throw 'Updated application did not confirm startup' }
    Start-Sleep -Milliseconds 500
  }
  $replaced = $false
  'confirmed' | Set-Content -LiteralPath $status
} catch {
  if ($newProcess -and !$newProcess.HasExited) { Stop-Process -Id $newProcess.Id -ErrorAction SilentlyContinue }
  if ($replaced) {
    # Restore the previous application, never the user profile or cookies.
    Move-Item -LiteralPath $target -Destination (Join-Path $stage 'failed')
    Move-Item -LiteralPath $backup -Destination $target
    'rolled_back' | Set-Content -LiteralPath $status
    Start-Process -FilePath (Join-Path $target 'openturath_ai.exe') -WorkingDirectory $target
  }
  throw
}

} catch {
  'failed' | Set-Content -LiteralPath (Join-Path $stage 'failed')
  throw
}
