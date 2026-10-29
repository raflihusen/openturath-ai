; Mesin pemasangan OpenTurath AI. Dijalankan senyap oleh layar pemasang
; (openturath_installer); pengguna tidak melihat wizard ini.
#define MyAppName "OpenTurath AI"
#define MyAppVersion "1.0.83"
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
Source: "..\..\OpenTurath_AI_Windows\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\OpenTurath_AI_Windows\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\OpenTurath_AI_Windows\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
