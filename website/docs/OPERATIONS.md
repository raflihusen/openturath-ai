# Operasi dan pemeliharaan

Tetapkan penanggung jawab konten, rilis aplikasi, bantuan dan insiden sebelum peluncuran. Satu orang boleh memegang beberapa peran; tidak ada janji dukungan 24/7 di situs.

## Laporan privat

Jalankan pada mesin server sebagai user layanan dengan `OT_DATA_DIR` yang sama dengan WSGI:

```sh
OT_DATA_DIR=/var/lib/openturath python3 server/manage.py list
OT_DATA_DIR=/var/lib/openturath python3 server/manage.py export --output /PRIVATE_PATH/reports.json
OT_DATA_DIR=/var/lib/openturath python3 server/manage.py delete --id OT_REPLACE_WITH_ACTUAL_ID
OT_DATA_DIR=/var/lib/openturath python3 server/manage.py purge
```

Ekspor dapat berisi email dan isi laporan; jangan simpan di `dist/`, commit ke repo publik, atau lampirkan ke ZIP website. `list` hanya menampilkan ID/waktu/topik/bahasa. Balasan dilakukan oleh operator melalui kanal yang disetujui, bukan email otomatis dari website.

Jadwalkan `purge` setiap hari, menggunakan user, direktori kerja dan variabel lingkungan yang benar. Pembersihan juga berlangsung saat layanan dibuka dan menerima permintaan valid. Database utama menghapus baris melewati masa retensi; backup, ekspor dan log memiliki siklus hidup terpisah yang harus diatur operator. Ini bukan janji penghapusan forensik seluruh media penyimpanan.

## Backup dan pemulihan

Backup SQLite aktif harus memakai API backup SQLite atau hentikan layanan secara terkontrol; jangan menyalin file utama saja saat WAL aktif. Contoh skrip lokal:

```python
import sqlite3
source = sqlite3.connect('/var/lib/openturath/reports.sqlite3')
target = sqlite3.connect('/PRIVATE_BACKUP_PATH/reports.sqlite3')
with target:
    source.backup(target)
target.close()
source.close()
```

Batasi akses backup (0700 direktori, 0600 file), enkripsi pada penyimpanan backup bila tersedia, tetapkan retensi sesuai kebijakan dan uji restore pada direktori terpisah. Jangan menimpa database aktif untuk percobaan. Restore produksi: hentikan WSGI, simpan salinan state lama, pulihkan database beserta izin user yang tepat, jalankan pemeriksaan integritas SQLite, mulai WSGI, uji laporan sintetis, lalu hapus laporan tes.

## Jadwal

| Waktu | Tindakan |
|---|---|
| Setiap rilis | Cek sumber naskah, metadata, tiga bahasa, link unduh, checksum/tanda tangan, changelog, kebijakan dan hasil QA |
| Harian | Purge retensi; pantau kesehatan HTTP dan kegagalan API melalui infrastruktur pengelola |
| Mingguan | Tindak lanjuti laporan; periksa unduhan dan URL sumber kritis |
| Bulanan | Tinjau katalog, konfigurasi akses, dependensi produksi dan kapasitas penyimpanan |
| Berkala | Uji rollback build serta restore backup privat |

## Insiden

- **APK/listing salah atau dicabut:** tandai `revoked:true` atau hapus dari daftar aktif, build ulang, hapus cache unduh, uji halaman dan komunikasikan perubahan melalui kanal resmi. Tanpa rilis aktif, halaman menyatakan unduhan belum tersedia; build produksi ketat akan menolak peluncuran awal tanpa satu rilis aktif. Dalam insiden live, gunakan build terakhir yang aman atau maintenance yang ditinjau, jangan mengisi unduhan palsu agar gerbang lolos.
- **Kesalahan kutipan/penilaian:** simpan arsip asli, tambahkan koreksi berversi, perbarui catatan bukti, dan sesuaikan klaim yang bergantung padanya.
- **Formulir tidak dapat dioperasikan:** set `reports.enabled=false`, build dan terbitkan; pengunjung memperoleh salinan lokal dan kontak yang dikonfigurasi. Setelah perbaikan, uji penyimpanan lalu aktifkan kembali.
- **Kontak/privasi berubah:** ubah konfigurasi dan artikel terkait, telaah seluruh bahasa, lalu terbitkan versi baru.

## Pengukuran

Tidak ada penyedia analitik, perekaman sesi, fingerprint, atau pixel iklan. `analytics.enabled=true` ditolak karena integrasi belum ditetapkan. Jika nanti dibutuhkan, gunakan peristiwa minimum yang dijelaskan MASTER_SPEC bagian 17 dan tinjau kebijakan: kelas perangkat, bahasa, case/collection ID atau versi rilis. Jangan mengirim pertanyaan, isi laporan, email atau parameter URL. Klik unduh tidak membuktikan instalasi.

Status layanan dan jurnal tidak ditampilkan karena belum ada monitoring atau konten terbit yang mendasarinya. Tambahkan hanya bersama proses pembaruan yang benar-benar dijalankan.
