# Katalog Metadata Kitab V9.2

Dibuat oleh `04_PIPELINE_DAN_RUANG_KERJA/v9_2/26_katalog_app.py`, diperiksa oleh `27_cek_katalog.py`.

**Aturan: nol karangan.** Setiap kolom diambil dari sumber apa adanya. Yang tidak ada di sumber ditulis `غير متوفر في المصدر`. Tidak ada deskripsi templat; `نبذة_عن_الكتاب` hanya diisi bila kartu sumber memuatnya, dengan `مصدر_النبذة`.

| Kolom | Sumber |
|---|---|
| الاسم_الكامل | judul cetakan terpilih, persis |
| الاسم_المختصر | judul yang sama tanpa keterangan cetakan/tahun (diturunkan secara mekanis) |
| المؤلف | kartu kitab / tabel pengarang / koreksi terverifikasi |
| سنة_الوفاة + مصدر_سنة_الوفاة | tabel pengarang, kartu, judul sumber, atau koreksi berbukti; "بعد/نحو/كان حيا" ditulis seperti di sumber |
| المحقق_أو_المعتني، الناشر، الطبعة، عدد_الأجزاء، عدد_الصفحات | kartu cetakan terpilih |
| مصدر_النص | perpustakaan + nomor kitab |
| ملاحظة | "المتن فقط" untuk kitab bermuhaqqiq salafi; kitab yang di sumber terpecah ke beberapa berkas |
| الأجزاء_المتوفرة | hanya untuk kitab yang terpecah di sumber |

Status: staging; belum disalin ke `03_APLIKASI_OPENTURATH_DEV/assets/data/`.
