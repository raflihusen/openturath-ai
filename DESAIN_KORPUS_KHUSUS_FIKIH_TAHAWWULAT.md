# Dokumen Desain & Blueprint Spesifikasi: Korpus Khusus Fikih Tahawwulat (Ultra Suite)

**Versi Dokumen:** 1.0.0  
**Status:** Draf Tinjauan Copywriting & Desain Visual  
**Filosofi Desain:** *The Quiet Scholar (Al-'Alim Al-Khamus)*  
**Lokasi File Acuan Visual:** `creative_assets/tahawwulat_ui_mockup.jpg`

---

## 1. Visi & Kedudukan Fikih Tahawwulat

Fikih Tahawwulat (karya al-Allamah al-Habib Abu Bakar al-Adni bin Ali al-Masyhur) diposisikan sebagai **Korpus Mahkota (*The Crown Jewel*)** di dalam ekosistem OpenTurath AI.

Berbeda dari modul spesialis biasa yang hadir sebagai asisten tunggal pencari teks, Fikih Tahawwulat hadir sebagai **"Halaqah Riset 4 Persona"** yang komprehensif:
1. **Penelusuran Teks & Tahkik** (*Al-Muhaqqiq*)
2. **Penyederhanaan Konsep & Istilah** (*Al-Bayan*)
3. **Ujian Nalar & Evaluasi Pemahaman** (*Al-Mumtahin*)
4. **Khazanah Rekaman Lisan** (*Arsip Muhadharah Habib Abu Bakar*)

---

## 2. Spesifikasi Visual: Kemewahan yang Teduh (*Understated Luxury*)

Menjaga kesetiaan 100% pada pedoman [DESIGN.md](file:///Users/apple/Downloads/ramadhan/DESIGN.md), desain kartu ini **menolak warna emas kuning komersial yang norak (`#D4AF37`)**, dan sebaliknya menggunakan material kehormatan naskah klasik:

### A. Tiga Pilihan Background Luxury (Silakan Pilih/Koreksi)

| Opsi | Nama Konsep | Palet Gradien Hex | Karakter Visual & Filosofi |
|---|---|---|---|
| **Opsi 1 (Rekomendasi)** | **Deep Emerald Twilight** *(Zamrud Malam Hadrami)* | `[Color(0xFF0D201A), Color(0xFF050D0A)]` | Hijau batu zamrud kuno yang nyaris hitam di kegelapan malam. Memberikan kontras sejuk dan berbeda 180° dari beranda/profil abu-hitam. Identik dengan kubah hijau Tarim (*Al-Qubbah Al-Khadhra'*). |
| **Opsi 2** | **Obsidian Antique Bronze** *(Tembaga Naskah Kuno)* | `[Color(0xFF1C1612), Color(0xFF0A0807)]` | Hitam pekat dengan bias cokelat espresso dan tembaga tua. Terasa hangat seperti memegang jilid kulit naskah abad ke-7 Hijriah. |
| **Opsi 3** | **Kiswah Noir & Muqarnas** *(Hitam Beludru Berfaset)* | `[Color(0xFF121215), Color(0xFF08080A)]` | Tetap monokromatis hitam-arang, namun memiliki pahatan kontur garis lengkung kubah bertingkat (*Muqarnas*) 3D yang sangat halus. |

### B. Detail Ornamen & Hairline Border
- **Garis Batas (Border)**: `0.8px` hairline menggunakan warna **`sovereignAmber` (`#D97706`)** yang bersahaja dan tenang.
- **Watermark Geometri**: Garis lengkung kubah mihrab khas OpenTurath di latar belakang kartu dengan opasitas sangat rendah (5% - 7%).
- **Satu-Satunya Kartu Berlogo**: Di sudut kanan atas kartu, disematkan emblem kubah cahaya khas OpenTurath dengan siluet monokromatis halus.

---

## 3. Matriks Copywriting Lengkap (Untuk Ditinjau & Dikoreksi)

*Bagian ini memuat seluruh teks yang akan tampil di aplikasi. Anda dapat mengoreksi, mengganti istilah, atau menyempurnakan redaksinya.*

### A. Bagian Kepala Kartu (Card Header & Overview)

| Elemen UI | Copy Saat Ini | Catatan Desain / Konteks | Rekomendasi Koreksi Anda |
|---|---|---|---|
| **Eyebrow Pill** | `KORPUS KHUSUS · TAHKIK MANDIRI` | Micro-caps dengan latar wash amber 10% (`#1AD97706`) dan titik indikator. Menegaskan modul ini independen. | *(Bisa disesuaikan)* |
| **Judul Utama** | `Fikih Tahawwulat` | Font Editorial Serif (*Newsreader*), tebal, ukuran 24–26sp, putih tajam (`#FAFAFA`). | *(Tetap / Ada tambahan?)* |
| **Sub-Judul / Deskripsi** | `Menjawab realitas kontemporer dengan metodologi fikih yang kokoh.` | Font *Outfit Sans*, ukuran 13sp, warna `textSecondary` (`#A1A1AA`), tinggi baris 1.4. | *(Silakan ubah jika ada kalimat yang lebih mantap)* |

---

### B. Kisi 4 Bilik Asisten (The 4 Scholar Chambers)

Ke-4 asisten ini disusun dalam kisi 2x2 (*two-column grid*) dengan micro-surface elegan yang masing-masing memiliki ikon dan indikator panah navigasi:

#### Bilik 1: Al-Muhaqqiq (المحقق)
- **Nomor / Indeks**: `01`
- **Ikon**: Buku Terbuka Ilmiah (`Icons.menu_book_rounded`)
- **Nama Asisten**: `Al-Muhaqqiq`
- **Gelar Penjelas**: `Teks Matan & Ibarah`
- **Deskripsi Detail (saat diklik/tooltip)**:
  > *"Menelusuri ibarah otentik, nash matan, syarah, dan maraji' primer kitab-kitab Fikih Tahawwulat dengan presisi rujukan jilid dan halaman."*

#### Bilik 2: Al-Bayan (البيان)
- **Nomor / Indeks**: `02`
- **Ikon**: Lembar Naskah / Pena (`Icons.description_outlined`)
- **Nama Asisten**: `Al-Bayan`
- **Gelar Penjelas**: `Penyederhanaan Konsep`
- **Deskripsi Detail (saat diklik/tooltip)**:
  > *"Menguraikan istilah-istilah rumit Nusus as-Sa'ah, kaidah sunnatullah, dan metodologi peradaban dengan analogi zaman yang ramah dan mudah dipahami."*

#### Bilik 3: Al-Mumtahin (الممتحن)
- **Nomor / Indeks**: `03`
- **Ikon**: Topi Akademik / Timbangan Nalar (`Icons.school_outlined`)
- **Nama Asisten**: `Al-Mumtahin`
- **Gelar Penjelas**: `Ujian Pemahaman Interaktif`
- **Deskripsi Detail (saat diklik/tooltip)**:
  > *"Menguji ketajaman nalar santri melalui studi kasus fenomena mutakhir, menilai ketepatan jawaban, dan meluruskan kerancuan pemahaman secara sokratik."*

#### Bilik 4: Khazanah Lisan (مستودع المحاضرات)
- **Nomor / Indeks**: `04`
- **Ikon**: Gelombang Suara / Audio Rekaman (`Icons.graphic_eq_rounded`)
- **Nama Asisten**: `Khazanah Lisan`
- **Gelar Penjelas**: `Arsip Muhadharah Habib Abu Bakar`
- **Deskripsi Detail (saat diklik/tooltip)**:
  > *"Menyajikan hikmah, adab dakwah, dan fatwa lisan langsung dari transkrip ribuan jam ceramah dan muhadharah al-Habib Abu Bakar al-Adni."*

---

### C. Tombol Aksi Utama (Call-to-Action / CTA)

| Kondisi Pengguna | Teks Tombol | Aksi yang Terjadi Saat Ditekan |
|---|---|---|
| **Belum Berlangganan** | `Masuk Majelis Telaah →` | Membuka lembar dialog eksklusif: penjelasan 4 asisten, preview singkat, dan opsi paket langganan DOKU. |
| **Sudah Berlangganan (Aktif)** | `Buka Majelis 4 Asisten →` | Membuka ruang multi-tab yang langsung memuat ke-4 asisten secara instan di bilah tab atas. |

---

### D. Tampilan di Lembar Langganan (DOKU Checkout Sheet)

Ketika pengguna menekan tombol untuk berlangganan Fikih Tahawwulat, muncul pilihan paket mandiri dengan rincian berikut:

| Nama Paket | Durasi | Harga | Label Diskon / Penghematan | Rincian Nilai |
|---|---|---|---|---|
| **Paket Riset Bulanan** | 1 Bulan | **Rp 300.000** | `Standar Peneliti` | Akses penuh 4 AI Fikih Tahawwulat selama 30 hari. |
| **Paket Riset Semester** | 6 Bulan | **Rp 1.500.000** | `Hemat Rp 300.000` | Setara Rp 250.000 / bulan. |
| **Paket Riset Tahunan** | 1 Tahun | **Rp 2.000.000** | `Pilihan Utama (Hemat 45%)` | Setara ~Rp 166.000 / bulan. Akses tanpa batas selama 365 hari. |

- **Catatan Hak Akses (*Scope*)**:
  > *"Langganan ini khusus mencakup 4 Asisten Riset Fikih Tahawwulat & Arsip Muhadharah. Modul turats lainnya memiliki hak akses terpisah."*

---

### E. Status & Lencana di Layar Profil Pengguna ([profile_screen.dart](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/profile_screen.dart))

Bagi pengguna yang telah mengaktifkan paket ini, tampilan kartu keanggotaan di layar profil menampilkan lencana khusus:

- **Badge Kategori**: `✦ PENELITI FIKIH TAHAWWULAT`
- **Status Hak Akses**: `Akses 4 Bilik Asisten & Khazanah Muhadharah Aktif`
- **Masa Berlaku**: `Berlaku hingga: [Tanggal Sesuai Pembayaran DOKU]`

---

## 4. Langkah Tinjauan Anda

Silakan periksa berkas ini dan beri masukan pada poin-poin berikut:
1. **Pilihan Background**: Apakah Anda lebih sreg dengan **Opsi 1 (Deep Emerald Twilight)**, **Opsi 2 (Tembaga Kuno)**, atau **Opsi 3 (Kiswah Noir)**?
2. **Koreksi Copywriting**:
   - Apakah sub-judul *"Menjawab realitas kontemporer dengan metodologi fikih yang kokoh"* sudah sesuai, atau ingin disempurnakan?
   - Apakah penamaan 4 asisten (*Al-Muhaqqiq, Al-Bayan, Al-Mumtahin, Khazanah Lisan*) sudah mantap?
3. **Pemberian Lampu Hijau**: Setelah copy dan visual disepakati, kita akan langsung implementasikan kartu ini ke dalam kode Flutter [specialist_list_screen.dart](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/specialist_list_screen.dart).
