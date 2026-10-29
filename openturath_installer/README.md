# OpenTurath Installer

Layar pemasang Windows OpenTurath AI, dibuat dengan Flutter dalam bahasa desain
Monochrome Editorial. Satu layar: tanda arch menelusuri dirinya, terisi
mengikuti kemajuan nyata, gema arch memuai di belakangnya.

## Cara kerja

```
OpenTurath_AI_Windows_Setup.exe   (pembungkus Inno, tanpa wizard)
 ├─ ui.zip     → layar Flutter ini + install_manifest.json
 └─ core.exe   → mesin pemasang Inno (installer_core.iss), dijalankan senyap
```

Layar ini menjalankan `core.exe /VERYSILENT /LOG=...` dan membaca log
(satu baris `Dest filename:` per berkas) untuk menghitung kemajuan.
Pencopotan tetap lewat uninstaller Inno yang terdaftar di Windows.

## Pratinjau di macOS

```bash
flutter run -d macos --dart-define=OT_AUTOSTART=true
```

Memakai `FakeInstallEngine`; tidak memasang apa pun.

## Build Windows

`openturath_ai/tool/build_windows_installer.ps1` (hanya di Windows).

## Belum teruji di Windows

Tampilan, gerak, dan alurnya sudah diuji di macOS (tes widget dan jalan
langsung). Yang belum pernah dijalankan: `WindowsInstallEngine`,
`installer_stub.iss`, dan skrip build.
