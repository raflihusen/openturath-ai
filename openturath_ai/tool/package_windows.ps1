$ErrorActionPreference = 'Stop'
$bundle = Join-Path $PSScriptRoot '../build/windows/x64/runner/Release'
foreach ($required in @('openturath_ai.exe', 'flutter_windows.dll', 'data/icudtl.dat', 'data/app.so', 'data/flutter_assets')) {
  if (!(Test-Path (Join-Path $bundle $required))) { throw "Missing bundle component: $required" }
}
$prerequisites = Join-Path $bundle 'prerequisites'
New-Item -ItemType Directory -Force -Path $prerequisites | Out-Null
# Official signed Microsoft installers; no installation or public deployment here.
$downloads = @{
  'MicrosoftEdgeWebview2Setup.exe' = 'https://go.microsoft.com/fwlink/p/?LinkId=2124703'
  'vc_redist.x64.exe' = 'https://aka.ms/vs/17/release/vc_redist.x64.exe'
}
foreach ($name in $downloads.Keys) {
  $file = Join-Path $prerequisites $name
  Invoke-WebRequest -Uri $downloads[$name] -OutFile $file
  $signature = Get-AuthenticodeSignature $file
  if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'O=Microsoft Corporation') {
    throw "Invalid Microsoft signature: $name"
  }
}
@'
OpenTurath AI — Windows x64

1. Extract the entire ZIP into a writable folder. Keep data and all DLL files together.
2. Install prerequisites/vc_redist.x64.exe if Microsoft Visual C++ Runtime is missing.
3. Install prerequisites/MicrosoftEdgeWebview2Setup.exe if WebView2 is missing (requires internet).
4. Run openturath_ai.exe.

Google sign-in opens your browser. NotebookLM may require a separate browser sign-in.
This internal test package is not Authenticode-signed. Public release requires signing and desktop smoke tests.
'@ | Set-Content (Join-Path $bundle 'README-Windows.txt') -Encoding utf8
$files = Get-ChildItem $bundle -Recurse -File
$files | ForEach-Object {
  $relative = [IO.Path]::GetRelativePath($bundle, $_.FullName)
  "$((Get-FileHash $_.FullName -Algorithm SHA256).Hash)  $relative"
} | Set-Content (Join-Path $bundle 'SHA256SUMS.txt')
$archive = Join-Path $PSScriptRoot '../build/windows/OpenTurath_AI_Windows_x64.zip'
Compress-Archive -Path (Join-Path $bundle '*') -DestinationPath $archive -Force
Get-FileHash $archive -Algorithm SHA256
