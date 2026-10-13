# Rencana Perbaikan Defect GoAkal & Restrukturisasi Model Harga (Pricing Strategy)
**Dokumen Audit & Rencana Strategis Ekosistem OpenTurath AI**

---

## 1. Audit Forensik Masalah Integrasi GoAkal

### A. Temuan Status Server GoAkal (`goakal.com/openturath-ai`)
Berdasarkan investigasi dan pengecekan langsung terhadap seluruh endpoint GoAkal:

1. **20 Modul AI Satuan (100% VALID & AKTIF):**
   - Modul satuan berikut memiliki halaman pendaftaran checkout resmi yang aktif di GoAkal untuk durasi 1 Bulan, 6 Bulan, dan 12 Bulan (Total 60 URL aktif):
     - Super AI Fikih Syafi'i
     - Super AI Bahasa Arab
     - AI Fikih Tahawwulat
     - Super AI Ushul Fikih
     - Super AI Hadits Nabawi
     - Super AI Tafsir & Ulumul Qur'an
     - Super AI Aqidah & Ushuluddin
     - Super AI Fikih Hanafi
     - Super AI Fikih Maliki
     - Super AI Fikih Hanbali
     - Super AI Fikih Muqaran & Siyasah
     - Super AI Syarah Hadits
     - Super AI Musthalah Hadits
     - Super AI Qawaid Fiqhiyyah
     - Super AI Tajwid & Qira'at
     - Super AI Tarikh & Sirah Nabawiyyah
     - Super AI Tasawwuf & Adzkar
     - Super AI Thabaqat & Tarajim Rijal
     - Super AI Fatawa & Masail Fiqhiyyah
     - Super AI Bibliografi & Faharis Turath

2. **6 Paket Bundle / Tematik (100% DEFECT / ERROR 404):**
   - Paket-paket berikut mengalami error 404 (*Layanan Tidak Tersedia*):
     - `paket-sultan-all-access`
     - `paket-fikih-pesantren`
     - `paket-samudra-hadits`
     - `paket-mazhab-akbar`
     - `paket-tafsir-bahasa-arab`
     - `paket-fikih-tahawwulat`
   - **Akar Masalah:** Paket-paket ini **memang belum pernah dibuat di dashboard admin GoAkal**. Kode sebelumnya mengisi string ID fiktif seperti `cmu6rsr...` dan `cmu6rt...` yang tidak terdaftar di database GoAkal.

---

## 2. Audit Logika Penetapan Harga (Unit Economics & Cannibalization)

### A. Metrik Satuan (Baseline)
- **Harga Satuan 1 AI:** **Rp 49.000 / bulan** (Patokan resmi aplikasi).
- **Total Modul:** **24 AI** (20 Modul Turath Standar + Persona Fikih Tahawwulat).

### B. Nilai Eceran Riil (Jika Dibeli Terpisah)
- **1 Bulan:** $24 \times \text{Rp } 49.000 = \mathbf{Rp\ 1.176.000}$
- **6 Bulan:** $24 \times \text{Rp } 49.000 \times 6 = \mathbf{Rp\ 7.056.000}$
- **1 Tahun:** $24 \times \text{Rp } 49.000 \times 12 = \mathbf{Rp\ 14.112.000}$

### C. Masalah Kecacatan Logika pada Kode Lama
- Pada kode lama, "Paket Sultan All-Access (24 AI)" dipasang **Rp 249.000 / bulan**.
- **Dampak Fatal:**
  1. **Kanibalisasi Total:** Membeli 24 AI hanya Rp 249.000 berarti harga per AI turun menjadi **~Rp 10.375 / bulan** (diskon ~79%). Tidak ada pengguna yang akan mau membeli paket satuan Rp 49.000.
  2. **Beban Operasional LLM / Server:** Penggunaan 24 model AI sekaligus untuk pengguna aktif akan menghabiskan kuota token server, sehingga revenue Rp 249.000 berisiko defisit (boncos).

---

## 3. Usulan Struktur Harga Rasional & Berkelanjutan

### A. Paket Sultan All-Access (Akses Penuh Seluruh 24 AI + Fitur VIP)
*Nilai Eceran Asli: Rp 1.176.000 / bulan*

| Paket / Tier | Harga Usulan (Sweet Spot) | Nilai Riil / Bulan | Diskon Terhadap Eceran | Logika Bisnis & Nilai |
| :--- | :---: | :---: | :---: | :--- |
| **1 Bulan** | **Rp 499.000** | Rp 499.000 | **~58% OFF** | Setara harga 10 AI satuan, gratis 14 AI lainnya. Margin sehat, terasa prestisius. |
| **6 Bulan (1 Semester)** | **Rp 2.490.000** | Rp 415.000 | **~65% OFF** | Setara bayar 5 bulan gratis 1 bulan tambahan. |
| **12 Bulan (1 Tahun)** | **Rp 4.490.000** | Rp 374.000 | **~68% OFF** | Diskon tahunan maksimal bagi santri, asatidz, dan peneliti serius. |

*(Opsi Promo Santri Terbatas jika ingin batas bawah: 1 Bulan Rp 399.000 | 6 Bulan Rp 1.990.000 | 1 Tahun Rp 3.490.000)*

---

### B. Paket Tematik Rumpun Keilmuan (Isi 4 – 6 AI Terfokus)

| Nama Paket | Isi Modul AI | Nilai Eceran Asli | 1 Bulan | 6 Bulan (Semester) | 1 Tahun (Tahunan) |
| :--- | :--- | :---: | :---: | :--- | :---: |
| **Paket Fikih Pesantren** | Fikih Syafii, Ushul Fiqh, Qawaid, Fatawa *(4 AI)* | Rp 196.000 | **Rp 149.000** | **Rp 749.000** | **Rp 1.290.000** |
| **Paket Samudra Hadits** | Hadits Nabawi, Syarah, Musthalah, Thabaqat, Tarikh *(5 AI)* | Rp 245.000 | **Rp 179.000** | **Rp 890.000** | **Rp 1.490.000** |
| **Paket Tafsir & Bahasa Arab** | Tafsir, Tajwid, Bahasa Arab, Bibliografi *(4 AI)* | Rp 196.000 | **Rp 149.000** | **Rp 749.000** | **Rp 1.290.000** |
| **Paket Mazhab Akbar** | Fikih Hanafi, Maliki, Hanbali, Muqaran, Aqidah, Fatawa *(6 AI)* | Rp 294.000 | **Rp 199.000** | **Rp 990.000** | **Rp 1.790.000** |
| **Paket Fikih Tahawwulat** | 5 Persona Eksklusif Fikih Tahawwulat *(5 AI)* | Rp 245.000 | **Rp 169.000** | **Rp 849.000** | **Rp 1.450.000** |

---

## 4. Rencana Solusi Teknis Aplikasi

### 1. Eliminasi Link Error 404 (Zero Dead Links)
- Di `goakal_catalog_registry.dart`:
  - Hapus seluruh applyUrl fiktif yang menggunakan ID palsu (`cmu6rt...`).
  - Tandai paket bundle sebagai `availableViaAdmin` sampai produk resmi dibuat di GoAkal.

### 2. Smart Fallback: Aktivasi Cepat via WhatsApp Admin
- Di `subscription_screen.dart`:
  - Saat pengguna mengklik tombol "Ambil Akses" pada Paket Tematik atau Sultan:
    - Tidak lagi membuka WebView kosong yang menampilkan error 404.
    - Menampilkan modal konfirmasi yang mengarahkan langsung ke **WhatsApp Admin Resmi (`081292979189`)** dengan pesan otomatis:
      > *"Halo Admin OpenTurath AI, saya ingin aktivasi [Nama Paket] durasi [Durasi] seharga [Rp Harga]. Mohon dipandu proses pembayarannya."*
    - Menyertakan tombol alternatif untuk melihat etalase resmi di `https://goakal.com/openturath-ai`.

### 3. Pembaruan Nilai Harga & Coretan Diskon di UI
- Menyesuaikan angka harga baru di seluruh komponen UI:
  - Harga normal coret yang realistis (misal: Paket Sultan 1 Bulan coret Rp 1.176.000 $\rightarrow$ Rp 499.000).
  - Badge persentase hemat yang akurat.

---

## 5. Panduan Pembuatan Produk Paket di GoAkal (Untuk Admin)

Jika Anda ingin membuat 6 produk paket tersebut di dashboard GoAkal agar memiliki link apply mandiri:

| No | Nama Produk di GoAkal | Slug yang Direkomendasikan | Harga 1 Bulan | Harga 6 Bulan | Harga 1 Tahun |
| :-: | :--- | :--- | :-: | :-: | :-: |
| 1 | **Paket Sultan All-Access (24 AI)** | `paket-sultan-all-access` | Rp 499.000 | Rp 2.490.000 | Rp 4.490.000 |
| 2 | **Paket Fikih Pesantren & Salaf** | `paket-fikih-pesantren` | Rp 149.000 | Rp 749.000 | Rp 1.290.000 |
| 3 | **Paket Samudra Hadits Master** | `paket-samudra-hadits` | Rp 179.000 | Rp 890.000 | Rp 1.490.000 |
| 4 | **Paket Tafsir & Bahasa Arab** | `paket-tafsir-bahasa-arab` | Rp 149.000 | Rp 749.000 | Rp 1.290.000 |
| 5 | **Paket Mazhab Akbar (Komparatif)** | `paket-mazhab-akbar` | Rp 199.000 | Rp 990.000 | Rp 1.790.000 |
| 6 | **Paket Khusus Fikih Tahawwulat** | `paket-fikih-tahawwulat` | Rp 169.000 | Rp 849.000 | Rp 1.450.000 |

*Catatan: Setelah produk di atas dibuat di GoAkal, cukup salin kode shortId dari GoAkal (contoh: `kbp4j`, `1js2e`) dan masukkan ke dalam `goakal_catalog_registry.dart`.*
