; Mesin pemasangan OpenTurath AI. Dijalankan senyap oleh layar pemasang
; (openturath_installer); pengguna tidak melihat wizard ini.
#define MyAppName "OpenTurath AI"
#ifndef MyAppVersion
#define MyAppVersion "0.0.0"
#endif
#ifndef PayloadRoot
#define PayloadRoot "..\..\OpenTurath_AI_Windows"
#endif
#define MyAppPublisher "OpenTurath"
#define MyAppURL "https://openturath.id"
#define MyAppExeName "openturath_ai.exe"

[Setup]
AppId={{62908AC4-7835-4E7B-89E2-2E198516F71A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=runner\resources\app_icon.ico
DisableProgramGroupPage=yes
OutputDir=..\build\installer_core
OutputBaseFilename=OpenTurath_AI_Core_Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible arm64
ArchitecturesInstallIn64BitMode=x64compatible arm64
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#PayloadRoot}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#PayloadRoot}\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#PayloadRoot}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; Prasyarat resmi Microsoft disediakan oleh tool\package_windows.ps1. Berkas ini
; WAJIB ada: tanpa skipifsourcedoesntexist, kompilasi gagal bila paket dibuat
; lewat jalur lain yang tidak membawa runtime.
Source: "{#PayloadRoot}\prerequisites\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; Check: VCRedistNeeded

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; shellexec agar Windows meminta elevasi untuk pemasang Microsoft (pemasang ini berjalan tanpa hak admin).
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Memasang Microsoft Visual C++ Runtime..."; Flags: shellexec waituntilterminated; Check: VCRedistNeeded
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// Runtime VC++ 2015-2022 x64 terpasang bila Installed=1 pada kunci ini.
function VCRedistNeeded: Boolean;
var
  Installed: Cardinal;
begin
  Result := True;
  if RegQueryDWordValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) then
    Result := (Installed <> 1);
end;
