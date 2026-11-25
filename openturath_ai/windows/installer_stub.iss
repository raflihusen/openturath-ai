; Pembungkus satu berkas (OpenTurath_AI_Windows_Setup.exe). Tidak menampilkan
; wizard: mengekstrak layar pemasang Flutter dan mesin pemasang ke folder
; sementara, menjalankan layar pemasang, lalu keluar saat layar itu ditutup.
#define MyAppName "OpenTurath AI"
#define MyAppPublisher "OpenTurath AI"
#define MyAppURL "https://openturath.id"
#ifndef MyAppVersion
#define MyAppVersion "2.0.0"
#endif

[Setup]
AppId={{B6E0D2A4-5C1F-4B7A-9D3E-7A1F0C2E8B55}
AppName={#MyAppName} Setup
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
VersionInfoVersion={#MyAppVersion}.0
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppName} Setup
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}
VersionInfoCopyright=Copyright (C) 2026 {#MyAppPublisher}. All rights reserved.
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
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Files]
Source: "..\build\installer_core\OpenTurath_AI_Core_Setup.exe"; DestName: "core.exe"; Flags: dontcopy
Source: "..\build\installer_stage\ui\*"; DestDir: "ui"; Flags: dontcopy recursesubdirs createallsubdirs

[Code]
var
  OtaMode: Boolean;
  OtaTarget: String;
  OtaExitCode: Integer;

function GetCustomSetupExitCode: Integer;
begin
  Result := OtaExitCode;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var Rc: Integer;
begin
  if OtaMode and (CurStep = ssPostInstall) then
  begin
    if Exec(ExpandConstant('{tmp}\core.exe'),
        '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR="' + OtaTarget + '"',
        '', SW_HIDE, ewWaitUntilTerminated, Rc) then OtaExitCode := Rc
    else OtaExitCode := 2;
  end;
end;

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
      Exit;
    end;
    OtaMode := True;
    OtaTarget := OtaDir;
    OtaExitCode := 2;
    Result := True;
    Exit;
  end;
  ExtractTemporaryFiles('ui\*');
  UiDir := ExpandConstant('{tmp}\ui');
  UiExe := UiDir + '\openturath_installer.exe';
  if not FileExists(UiExe) then
  begin
    MsgBox('Tidak dapat menyiapkan pemasang. / Could not prepare the installer.', mbError, MB_OK);
    Exit;
  end;
  Exec(UiExe, '', UiDir, SW_SHOW, ewWaitUntilTerminated, Rc);
end;
