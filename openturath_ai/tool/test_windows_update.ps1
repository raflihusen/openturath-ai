# Run the actual updater in PowerShell. OS process/signature APIs are fixtures;
# filesystem, hashing, arguments, backup and recovery use real operations.
$ErrorActionPreference = 'Stop'
$helper = Join-Path $PSScriptRoot '../assets/updater/windows_update.ps1'
$root = Join-Path ([IO.Path]::GetTempPath()) ('ot updater tests ' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $root | Out-Null
$global:mode = ''
$global:launches = 0
$global:caseStage = ''
function Get-Process { param($Id, $ErrorAction) return $null }
function Get-AuthenticodeSignature {
  param($LiteralPath)
  if ($global:mode -eq 'untrusted') { return @{Status='NotSigned'} }
  return @{Status='Valid'; SignerCertificate=@{Subject='CN=OpenTurath Test'}}
}
function Stop-Process { param($Id, $ErrorAction) }
function Start-Process {
  param($FilePath, $ArgumentList, [switch]$Wait, [switch]$PassThru, $WorkingDirectory)
  if ($FilePath -eq $global:casePackage) {
    if ($ArgumentList -notlike '*/OTAUPDATE*' -or
        $ArgumentList -notlike ('*/OTADIR="' + $global:caseTarget + '"*')) { throw 'Invalid installer handoff arguments' }
    if ($global:mode -eq 'install_fail') { return @{ExitCode=2} }
    'new' | Set-Content -LiteralPath (Join-Path $global:caseTarget 'openturath_ai.exe')
    return @{ExitCode=0}
  }
  $global:launches++
  $bytes = (Get-Content -LiteralPath $FilePath -Raw).Trim()
  if ($bytes -eq 'new' -and $global:mode -eq 'success') {
    '88' | Set-Content -LiteralPath (Join-Path $global:caseStage 'confirmed')
  }
  return @{HasExited=($global:mode -eq 'startup_fail'); Id=987654}
}
function Assert($Condition, $Message) { if (!$Condition) { throw $Message } }
try {
  foreach ($mode in @('success','install_fail','startup_fail','bad_hash','untrusted')) {
    $global:mode=$mode; $global:launches=0
    $case=Join-Path $root $mode
    $global:caseTarget=Join-Path $case "Installed App's Name"
    $global:caseStage=Join-Path $case '.ot-update-fixture'
    $global:casePackage=Join-Path $case 'cached update.exe'
    New-Item -ItemType Directory -Path $global:caseTarget,$global:caseStage -Force | Out-Null
    'old' | Set-Content -LiteralPath (Join-Path $global:caseTarget 'openturath_ai.exe')
    'unchanged' | Set-Content -LiteralPath (Join-Path $case 'user-session')
    'verified-package' | Set-Content -LiteralPath $global:casePackage
    $hash=(Get-FileHash -LiteralPath $global:casePackage -Algorithm SHA256).Hash.ToLower()
    if ($mode -eq 'bad_hash') { $hash='a'*64 }
    $plan=Join-Path $case 'plan.json'
    @{target=$global:caseTarget; stage=$global:caseStage; package=$global:casePackage;
      parentPid=123456; sha256=$hash; build=88; allowAdhocTest=$false} |
      ConvertTo-Json | Set-Content -LiteralPath $plan
    $failed=$false
    try { & $helper -Plan $plan } catch { $failed=$true; Write-Output ("Observed ${mode}: " + $_.Exception.Message) }
    $actual=(Get-Content -LiteralPath (Join-Path $global:caseTarget 'openturath_ai.exe') -Raw).Trim()
    Assert ($failed -eq ($mode -ne 'success')) "${mode}: incorrect success status"
    Assert ($actual -eq $(if($mode -eq 'success'){'new'}else{'old'})) "${mode}: application was not preserved/replaced correctly"
    Assert ((Get-Content -LiteralPath (Join-Path $case 'user-session') -Raw).Trim() -eq 'unchanged') 'User session changed'
    if ($mode -in @('install_fail','startup_fail')) {
      Assert ((Get-Content -LiteralPath (Join-Path $global:caseStage 'status') -Raw).Trim() -eq 'rolled_back') 'Rollback missing'
      Assert ($global:launches -ge 1) 'Previous app was not reopened'
    }
    if ($mode -in @('bad_hash','untrusted')) {
      Assert (!(Test-Path -LiteralPath (Join-Path $global:caseStage 'ready'))) 'Untrusted installer was accepted'
    }
    Write-Output "PASS $mode"
  }
} finally {
  Remove-Item -LiteralPath $root -Recurse -Force
}
