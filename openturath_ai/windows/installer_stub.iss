; Pembungkus satu berkas (OpenTurath_AI_Windows_Setup.exe). Tidak menampilkan
; wizard: mengekstrak layar pemasang Flutter dan mesin pemasang ke folder
; sementara, menjalankan layar pemasang, lalu keluar saat layar itu ditutup.
#define MyAppName "OpenTurath AI"

[Setup]
AppId={{B6E0D2A4-5C1F-4B7A-9D3E-7A1F0C2E8B55}
AppName={#MyAppName} Setup
AppVersion=1
CreateAppDir=no
Uninstallable=no
PrivilegesRequired=lowest
OutputDir=..\..\
OutputBaseFilename=OpenTurath_AI_Windows_Setup
SetupIconFile=runner\resources\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
DisableWelcomePage=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableFinishedPage=yes
ArchitecturesAllowed=x64compatible arm64
ArchitecturesInstallIn64BitMode=x64compatible arm64

[Files]
Source: "..\build\installer_stage\ui.zip"; Flags: dontcopy
Source: "..\build\installer_core\OpenTurath_AI_Core_Setup.exe"; DestName: "core.exe"; Flags: dontcopy

[Code]
procedure ExitProcess(ExitCode: Integer);
  external 'ExitProcess@kernel32.dll stdcall';

function IsOtaUpdate: Boolean;
var I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if CompareText(ParamStr(I), '/OTAUPDATE') = 0 then Result := True;
end;

function InitializeSetup: Boolean;
var
  Rc: Integer;
  UiDir, UiExe, OtaDir: String;
begin
  Result := False; { tidak pernah menampilkan wizard bawaan }
  ExtractTemporaryFile('core.exe');
  if IsOtaUpdate then
  begin
    OtaDir := ExpandConstant('{param:OTADIR|}');
    if (OtaDir = '') or (Pos('"', OtaDir) > 0) or
       not FileExists(OtaDir + '\openturath_ai.exe') then
    begin
      ExitProcess(2);
      Exit;
    end;
    if not Exec(ExpandConstant('{tmp}\core.exe'),
        '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR="' + OtaDir + '"',
        '', SW_HIDE, ewWaitUntilTerminated, Rc) then Rc := 2;
    ExitProcess(Rc);
    Exit;
  end;
  ExtractTemporaryFile('ui.zip');
  UiDir := ExpandConstant('{tmp}\ui');
  ForceDirectories(UiDir);
  { tar.exe tersedia bawaan di Windows 10 1803 ke atas. }
  if not Exec(ExpandConstant('{sys}\tar.exe'),
      '-xf "' + ExpandConstant('{tmp}\ui.zip') + '" -C "' + UiDir + '"',
      '', SW_HIDE, ewWaitUntilTerminated, Rc) or (Rc <> 0) then
  begin
    MsgBox('Tidak dapat menyiapkan pemasang. / Could not prepare the installer.', mbError, MB_OK);
    Exit;
  end;
  UiExe := UiDir + '\openturath_installer.exe';
  Exec(UiExe, '', UiDir, SW_SHOW, ewWaitUntilTerminated, Rc);
end;
