# Workspace Rules — OpenTurath AI

## 1. Automatic Checkpoint Protocol (MANDATORY)
- **Setiap perubahan sekecil apapun WAJIB langsung dibuatkan check point (Git commit) secara otomatis.**
- Setiap kali file kode, aset, UI, konfigurasi, atau unit test dimodifikasi atau ditambahkan:
  1. Jalankan `git add <files>`
  2. Lakukan commit dengan pesan yang deskriptif dan terstruktur: `git commit -m "<type>(<scope>): <pesan detail perubahan>"`
- Jangan pernah membiarkan perubahan menumpuk tanpa check point.
- Check point harus selalu dibuat secara otomatis tanpa menunggu instruksi tambahan dari pengguna.

## 2. Integritas Build & Release
- Setiap pembuatan APK rilis harus memverifikasi bahwa proses kompilasi Gradle selesai 100% dan file binary rilis yang disalin ke `/Users/apple/Downloads/ramadhan/app-release-latest.apk` memiliki timestamp baru yang valid.
