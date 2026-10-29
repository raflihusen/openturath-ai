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
DisableReadyPage=yes
ShowLanguageDialog=no
OutputDir=..\..\
OutputBaseFilename=OpenTurath_AI_Windows_Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible arm64
ArchitecturesInstallIn64BitMode=x64compatible arm64
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "installer\mark.bmp"; Flags: dontcopy
Source: "..\..\OpenTurath_AI_Windows\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\OpenTurath_AI_Windows\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\OpenTurath_AI_Windows\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Check: WantDesktopIcon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{#MyAppName}"; Flags: nowait postinstall skipifsilent unchecked

[Code]
{ Antarmuka installer OpenTurath: satu layar monokrom (Monochrome Editorial),
  tanpa halaman Next-Next. Warna mengikuti situs: #09090B, #FAFAFA, #A1A1AA,
  #27272A. Urutan Inno tetap berjalan di belakang layar; halaman bawaan
  disembunyikan dan digantikan panel di bawah ini. Warna dalam format BGR. }

const
  ClBg   = $0B0909;   { #09090B }
  ClInk  = $FAFAFA;   { #FAFAFA }
  ClSub  = $AAA1A1;   { #A1A1AA }
  ClLine = $2A2A27;   { #27272A }
  ClDark = $0B0909;
  TrackW = 360;

function DwmSetWindowAttribute(hwnd: HWND; attr: Cardinal; var val: Integer;
  cb: Cardinal): Integer;
  external 'DwmSetWindowAttribute@dwmapi.dll stdcall delayload';
function GetSystemMetrics(nIndex: Integer): Integer;
  external 'GetSystemMetrics@user32.dll stdcall';

var
  Lang: Integer;            { 0 = Indonesia, 1 = English, 2 = Arab }
  Logo: TBitmapImage;
  TitleP, SubP, FooterP, OptP, PathP, ChangeP, IconP: TPanel;
  BtnInstall, BtnOpen, BtnClose: TPanel;
  LangP: array[0..2] of TPanel;
  TrackP, FillP, PctP, StatusP, DoneTitleP, DoneSubP: TPanel;
  OptionsOpen, DesktopIcon, Revealed: Boolean;

function T(const Id, En, Ar: String): String;
begin
  case Lang of
    1: Result := En;
    2: Result := Ar;
  else
    Result := Id;
  end;
end;

function WantDesktopIcon: Boolean;
begin
  Result := DesktopIcon;
end;

function Mix(A, B, K: Integer): Integer;
var
  Ra, Ga, Ba, Rb, Gb, Bb: Integer;
begin
  Ra := A and $FF; Ga := (A shr 8) and $FF; Ba := (A shr 16) and $FF;
  Rb := B and $FF; Gb := (B shr 8) and $FF; Bb := (B shr 16) and $FF;
  Result := (Ra + (Rb - Ra) * K div 100)
         or ((Ga + (Gb - Ga) * K div 100) shl 8)
         or ((Ba + (Bb - Ba) * K div 100) shl 16);
end;

function MakeP(const Cap: String; L, Tp, W, H, Sz: Integer; Bold: Boolean;
  Ink: Integer; const Face: String): TPanel;
begin
  Result := TPanel.Create(WizardForm);
  Result.Parent := WizardForm;
  Result.BevelOuter := bvNone;
  Result.Color := ClBg;
  Result.SetBounds(L, Tp, W, H);
  Result.Caption := Cap;
  Result.Font.Name := Face;
  Result.Font.Size := Sz;
  Result.Font.Color := Ink;
  if Bold then Result.Font.Style := [fsBold];
end;

{ Teks yang tampak dari latar ke warna tujuan, dengan akselerasi lembut. }
procedure FadeText(P: TPanel; Target: Integer);
var
  I, K: Integer;
begin
  for I := 1 to 8 do
  begin
    K := I * 100 div 8;
    K := 100 - (100 - K) * (100 - K) div 100;
    P.Font.Color := Mix(ClBg, Target, K);
    Application.ProcessMessages;
    Sleep(14);
  end;
  P.Font.Color := Target;
end;

procedure FadeButton(P: TPanel);
var
  I, K: Integer;
begin
  for I := 1 to 8 do
  begin
    K := I * 100 div 8;
    K := 100 - (100 - K) * (100 - K) div 100;
    P.Color := Mix(ClBg, ClInk, K);
    P.Font.Color := Mix(ClBg, ClDark, K);
    Application.ProcessMessages;
    Sleep(14);
  end;
  P.Color := ClInk;
  P.Font.Color := ClDark;
end;

procedure InkOff(P: TPanel);
begin
  P.Font.Color := ClBg;
end;

procedure PaintChips;
var
  I: Integer;
begin
  for I := 0 to 2 do
    if I = Lang then LangP[I].Font.Color := ClInk
    else LangP[I].Font.Color := ClSub;
end;

procedure ApplyLang;
begin
  TitleP.Caption := 'OpenTurath AI';
  SubP.Caption := T('AI untuk penuntut ilmu, bersumber dari kitab.',
    'AI for students of knowledge, grounded in the books.',
    'ذكاء اصطناعي لطلبة العلم، مستند إلى الكتب.');
  BtnInstall.Caption := T('Pasang', 'Install', 'تثبيت');
  OptP.Caption := T('Opsi pemasangan', 'Install options', 'خيارات التثبيت');
  ChangeP.Caption := T('Ubah', 'Change', 'تغيير');
  if DesktopIcon then
    IconP.Caption := T('☑  Pintasan di desktop', '☑  Desktop shortcut', '☑  اختصار على سطح المكتب')
  else
    IconP.Caption := T('☐  Pintasan di desktop', '☐  Desktop shortcut', '☐  اختصار على سطح المكتب');
  StatusP.Caption := T('Memasang OpenTurath AI', 'Installing OpenTurath AI', 'جارٍ تثبيت OpenTurath AI');
  DoneTitleP.Caption := T('Siap digunakan.', 'You''re all set.', 'أصبح جاهزًا.');
  DoneSubP.Caption := T('OpenTurath AI sudah terpasang.', 'OpenTurath AI is installed.', 'تم تثبيت OpenTurath AI.');
  BtnOpen.Caption := T('Buka OpenTurath', 'Open OpenTurath', 'فتح OpenTurath');
  BtnClose.Caption := T('Tutup', 'Close', 'إغلاق');
  PaintChips;
end;

procedure ShowGroup(Welcome, Busy, Done: Boolean);
begin
  Logo.Visible := True;
  TitleP.Visible := Welcome; SubP.Visible := Welcome;
  BtnInstall.Visible := Welcome; OptP.Visible := Welcome;
  PathP.Visible := Welcome and OptionsOpen;
  ChangeP.Visible := Welcome and OptionsOpen;
  IconP.Visible := Welcome and OptionsOpen;
  LangP[0].Visible := Welcome; LangP[1].Visible := Welcome; LangP[2].Visible := Welcome;
  TrackP.Visible := Busy; FillP.Visible := Busy; PctP.Visible := Busy; StatusP.Visible := Busy;
  DoneTitleP.Visible := Done; DoneSubP.Visible := Done;
  BtnOpen.Visible := Done; BtnClose.Visible := Done;
end;

{ Penampilan bertahap layar sambutan: tanda, judul, kalimat, tombol. }
procedure RevealWelcome;
begin
  ShowGroup(True, False, False);
  InkOff(TitleP); InkOff(SubP); InkOff(OptP); InkOff(FooterP);
  BtnInstall.Color := ClBg; BtnInstall.Font.Color := ClBg;
  FadeText(TitleP, ClInk);
  FadeText(SubP, ClSub);
  FadeButton(BtnInstall);
  FadeText(OptP, ClSub);
  FadeText(FooterP, ClSub);
  Revealed := True;
end;

procedure ChipClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to 2 do
    if Sender = LangP[I] then Lang := I;
  ApplyLang;
end;

procedure ToggleOptions(Sender: TObject);
begin
  OptionsOpen := not OptionsOpen;
  PathP.Visible := OptionsOpen;
  ChangeP.Visible := OptionsOpen;
  IconP.Visible := OptionsOpen;
  if OptionsOpen then OptP.Font.Color := ClInk else OptP.Font.Color := ClSub;
end;

procedure ToggleIcon(Sender: TObject);
begin
  DesktopIcon := not DesktopIcon;
  ApplyLang;
end;

procedure ChangeDir(Sender: TObject);
var
  Dir: String;
begin
  Dir := WizardForm.DirEdit.Text;
  if BrowseForFolder(T('Pilih folder pemasangan', 'Choose install folder', 'اختر مجلد التثبيت'), Dir, True) then
  begin
    if CompareText(ExtractFileName(RemoveBackslash(Dir)), '{#MyAppName}') <> 0 then
      Dir := AddBackslash(Dir) + '{#MyAppName}';
    WizardForm.DirEdit.Text := Dir;
    PathP.Caption := Dir;
  end;
end;

procedure InstallClick(Sender: TObject);
begin
  if Trim(WizardForm.DirEdit.Text) = '' then Exit;
  WizardForm.NextButton.OnClick(WizardForm.NextButton);
end;

procedure OpenClick(Sender: TObject);
begin
  if WizardForm.RunList.Items.Count > 0 then
    WizardForm.RunList.Checked[0] := True;
  WizardForm.NextButton.OnClick(WizardForm.NextButton);
end;

procedure CloseClick(Sender: TObject);
begin
  WizardForm.NextButton.OnClick(WizardForm.NextButton);
end;

procedure InitializeWizard;
var
  Dark: Integer;
  X: Integer;
begin
  case GetUILanguage and $3FF of
    $21: Lang := 0;
    $01: Lang := 2;
  else
    Lang := 1;
  end;
  DesktopIcon := True;

  WizardForm.ClientWidth := 720;
  WizardForm.ClientHeight := 480;
  WizardForm.Left := (GetSystemMetrics(0) - WizardForm.Width) div 2;
  WizardForm.Top := (GetSystemMetrics(1) - WizardForm.Height) div 2;
  WizardForm.Color := ClBg;
  WizardForm.Caption := '{#MyAppName}';

  { Halaman bawaan disembunyikan. Tombol Next dipindah ke luar layar (bukan
    disembunyikan) agar Enter tetap memicunya dan tombol Tutup jendela tetap
    berfungsi. }
  WizardForm.OuterNotebook.Visible := False;
  WizardForm.MainPanel.Visible := False;
  WizardForm.Bevel.Visible := False;
  WizardForm.Bevel1.Visible := False;
  WizardForm.BackButton.Left := -600;
  WizardForm.NextButton.Left := -600;
  WizardForm.CancelButton.Left := -600;

  { Bilah judul gelap dan menyatu dengan latar (Windows 10 20H1+ / 11). }
  try
    Dark := 1;
    DwmSetWindowAttribute(WizardForm.Handle, 20, Dark, 4);
    Dark := ClBg;
    DwmSetWindowAttribute(WizardForm.Handle, 35, Dark, 4);
  except
  end;

  ExtractTemporaryFile('mark.bmp');
  Logo := TBitmapImage.Create(WizardForm);
  Logo.Parent := WizardForm;
  Logo.AutoSize := True;
  Logo.Bitmap.LoadFromFile(ExpandConstant('{tmp}\mark.bmp'));
  Logo.Left := (720 - Logo.Width) div 2;
  Logo.Top := 70;

  TitleP := MakeP('', 0, 190, 720, 48, 28, False, ClInk, 'Georgia');
  SubP := MakeP('', 0, 244, 720, 28, 11, False, ClSub, 'Segoe UI');
  BtnInstall := MakeP('', 260, 306, 200, 46, 11, True, ClDark, 'Segoe UI');
  BtnInstall.Color := ClInk;
  BtnInstall.Cursor := crHand;
  BtnInstall.OnClick := @InstallClick;
  OptP := MakeP('', 210, 368, 300, 24, 9, False, ClSub, 'Segoe UI');
  OptP.Cursor := crHand;
  OptP.OnClick := @ToggleOptions;
  PathP := MakeP(WizardForm.DirEdit.Text, 90, 398, 480, 22, 9, False, ClSub, 'Segoe UI');
  ChangeP := MakeP('', 574, 398, 56, 22, 9, True, ClInk, 'Segoe UI');
  ChangeP.Cursor := crHand;
  ChangeP.OnClick := @ChangeDir;
  IconP := MakeP('', 210, 424, 300, 22, 9, False, ClSub, 'Segoe UI');
  IconP.Cursor := crHand;
  IconP.OnClick := @ToggleIcon;
  FooterP := MakeP('openturath.id  ·  v{#MyAppVersion}', 0, 452, 720, 20, 8, False, ClSub, 'Segoe UI');

  for X := 0 to 2 do
  begin
    case X of
      0: LangP[X] := MakeP('ID', 560 + X * 44, 14, 40, 22, 9, True, ClSub, 'Segoe UI');
      1: LangP[X] := MakeP('EN', 560 + X * 44, 14, 40, 22, 9, True, ClSub, 'Segoe UI');
      2: LangP[X] := MakeP('AR', 560 + X * 44, 14, 40, 22, 9, True, ClSub, 'Segoe UI');
    end;
    LangP[X].Cursor := crHand;
    LangP[X].OnClick := @ChipClick;
  end;

  PctP := MakeP('0%', 0, 196, 720, 70, 40, False, ClInk, 'Georgia');
  StatusP := MakeP('', 0, 330, 720, 24, 10, False, ClSub, 'Segoe UI');
  TrackP := MakeP('', (720 - TrackW) div 2, 300, TrackW, 3, 8, False, ClSub, 'Segoe UI');
  TrackP.Color := ClLine;
  FillP := MakeP('', (720 - TrackW) div 2, 300, 0, 3, 8, False, ClSub, 'Segoe UI');
  FillP.Color := ClInk;

  DoneTitleP := MakeP('', 0, 190, 720, 48, 28, False, ClInk, 'Georgia');
  DoneSubP := MakeP('', 0, 244, 720, 28, 11, False, ClSub, 'Segoe UI');
  BtnOpen := MakeP('', 200, 306, 200, 46, 11, True, ClDark, 'Segoe UI');
  BtnOpen.Color := ClInk;
  BtnOpen.Cursor := crHand;
  BtnOpen.OnClick := @OpenClick;
  BtnClose := MakeP('', 420, 306, 100, 46, 11, False, ClInk, 'Segoe UI');
  BtnClose.Cursor := crHand;
  BtnClose.OnClick := @CloseClick;

  ApplyLang;
  ShowGroup(True, False, False);
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := (PageID = wpSelectDir) or (PageID = wpReady) or
            (PageID = wpSelectProgramGroup) or (PageID = wpSelectTasks);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpWelcome then
  begin
    PathP.Caption := WizardForm.DirEdit.Text;
    if not Revealed then RevealWelcome else ShowGroup(True, False, False);
  end
  else if CurPageID = wpFinished then
  begin
    ShowGroup(False, False, True);
    InkOff(DoneTitleP); InkOff(DoneSubP);
    BtnOpen.Color := ClBg; BtnOpen.Font.Color := ClBg;
    FadeText(DoneTitleP, ClInk);
    FadeText(DoneSubP, ClSub);
    FadeButton(BtnOpen);
  end
  else
    ShowGroup(False, True, False);
end;

procedure CurInstallProgressChanged(CurProgress, MaxProgress: Integer);
var
  Target, Pct: Integer;
begin
  if MaxProgress <= 0 then Exit;
  Target := Trunc(TrackW * 1.0 * CurProgress / MaxProgress);
  Pct := Trunc(100.0 * CurProgress / MaxProgress);
  if Target <> FillP.Width then FillP.Width := Target;
  if PctP.Caption <> IntToStr(Pct) + '%' then
    PctP.Caption := IntToStr(Pct) + '%';
end;
