# 📘 Panduan Pemeliharaan & Update OpenTurath AI
*SOP (Standard Operating Procedure) untuk mengelola aplikasi di masa depan.*

---

## 🚀 BAGIAN 1: Cara Meng-Unlock AI Baru (Mengaktifkan "Coming Soon")
Saat ini, selain Fiqh Tahawwulat, AI lainnya masih berstatus abu-abu ("Coming Soon"). Untuk mengaktifkannya, Anda HANYA perlu melakukan **2 langkah** mudah ini:

### Langkah 1: Masukkan URL di Server (Cloud Functions)
1. Buka file `functions/src/index.ts`
2. Cari variabel `AGENT_URLS` dan tambahkan ID agent beserta URL NotebookLM-nya.
   *Contoh jika Anda ingin mengaktifkan Ushul Fiqh:*
   ```typescript
   const AGENT_URLS: Record<string, string> = {
     fiqh_tahawwulat_muhaqqiq: "https://notebooklm.../preview",
     fiqh_tahawwulat_bayan: "https://notebooklm.../preview",
     
     // 👇 TAMBAHKAN BARIS INI 👇
     ushul_fiqh: "https://notebooklm.google.com/notebook/URL_BARU_ANDA/preview",
   };
   ```
3. Simpan file, buka terminal, jalankan:
   ```bash
   cd functions
   firebase deploy --only functions
   ```

### Langkah 2: Aktifkan Tombol di Aplikasi (Flutter)
1. Buka file `lib/models/agent_model.dart`
2. Cari `AgentModel` yang bernama `ushul_fiqh`.
3. Ubah tulisan `status: 'coming_soon'` menjadi `status: 'active'`.
4. Selesai! Saat aplikasi di-build ulang, kartu Ushul Fiqh akan langsung berwarna biru dan bisa di-klik oleh pengguna.

*(Catatan: Jika Anda ingin AI baru tersebut punya sub-pilihan seperti Al-Muhaqqiq/Al-Bayan, cukup tambahkan `subAgents: [...]` di dalam modelnya, persis seperti yang kita lakukan pada Fiqh Tahawwulat).*

---

## 🔄 BAGIAN 2: Tahapan Update Aplikasi di Kemudian Hari

Jika di masa depan Anda ingin mengubah warna, mengganti logo, memperbaiki bug, atau menambah fitur baru, ikuti urutan baku ini:

### 1. Edit Kode
Lakukan perubahan pada kode Flutter di dalam folder `lib/`.

### 2. Naikkan Versi Aplikasi (Sangat Penting)
Buka file `pubspec.yaml` (ada di folder utama proyek). Cari baris berikut:
```yaml
version: 1.0.0+1
```
Setiap kali Anda akan membagikan update ke pengguna, angka ini **WAJIB** dinaikkan agar HP pengguna tahu ada versi baru.
- Update kecil: Ubah jadi `1.0.1+2`
- Update sedang: Ubah jadi `1.1.0+3`
- Update besar: Ubah jadi `2.0.0+4`

### 3. Build APK / App Bundle Baru
Buka terminal atau Android Studio, lalu jalankan:
```bash
# Untuk di-share langsung via WhatsApp/Telegram (Android)
flutter build apk --release

# Untuk di-upload ke Google Play Store
flutter build appbundle --release
```

### 4. Distribusikan
Kirim file `app-release.apk` terbaru ke pengguna Anda. Begitu mereka menginstalnya, HP mereka akan menimpa (overwrite) aplikasi lama tanpa menghapus data login mereka.

---

## 🛡️ BAGIAN 3: Mengelola Harga & Kuota Trial

**Jika ingin mengubah batas Trial (misal dari 10 jadi 5 pertanyaan):**
Buka `lib/core/constants.dart`, ubah:
```dart
static const int trialQuestionLimit = 5;
```

**Jika ingin mengubah harga paket:**
1. Buka `lib/core/constants.dart`, ubah harganya:
   ```dart
   static const int priceTholib = 50000; // Harga baru
   ```
2. Buka `lib/screens/subscription_screen.dart` untuk menyesuaikan teks harga yang tertulis di layar (UI) agar sama dengan harga asli.
3. Build ulang APK Anda.
