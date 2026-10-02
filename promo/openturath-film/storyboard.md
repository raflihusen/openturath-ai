# OpenTurath: storyboard

Film teks kinetik dengan satu dunia 3D: rak kitab monokrom, sebuah kitab yang ditarik keluar dan dibuka, lembar catatan, lalu logo OpenTurath versi 3D. Tidak ada tangkapan layar aplikasi. Format utama 1080 × 1920 (9:16), 30 fps, 30 detik. Versi 1920 × 1080 (16:9) memakai scene dan copy yang sama, dengan teks di kolom kiri.

Warna mengikuti palet monokrom aplikasi (#171717, #FAFAFA, abu-abu). Font: Newsreader untuk judul, Outfit untuk teks, Inter untuk transliterasi, dan Scheherazade New untuk Arab. Semuanya font bawaan aplikasi.

| Waktu | Gambar | Teks di layar |
| --- | --- | --- |
| 0:00–0:04 | Kamera menyusuri rak kitab yang gelap. Lampu sorot menyapu punggung kitab bertuliskan judul Arab. | "Turats itu luas." lalu "Mulai dari mana?" |
| 0:04–0:08 | Rak meredup ke hitam. Logo OpenTurath 3D berputar masuk, berbahan logam satin. | "OpenTurath" · "Membaca kitab, menelusuri ibarah." |
| 0:08–0:14 | Logo melebar dan kamera menembus kembali ke rak, berhenti di satu baris. | PUSTAKA RUJUKAN · "Kenali kitabnya dulu." · "Katalog per bidang, lengkap dengan pengarang, muhaqqiq, penerbit, jilid, dan halaman." |
| 0:11–0:14 | Satu kitab keluar dari rak dan melayang ke depan kamera. | DARI KATALOG FIKIH SYAFI'I · منهاج الطالبين · "Minhāj al-Ṭālibīn · Imam al-Nawawi, w. 676 H" · "Dār al-Fikr · 1 jilid · 370 halaman" |
| 0:14–0:21 | Sampul kitab terbuka, kamera turun ke halaman. Satu baris disorot pelan dari kanan ke kiri. | ASISTEN · "Ajukan mas'alah." · pertanyaan diketik: "Apa syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn?" · "Telusuri pembahasannya langsung dari naskah turats." · label "Rujukan [1]" |
| 0:21–0:25 | Tiga lembar catatan terangkat dari halaman dan bertumpuk di depan kamera. Lembar teratas berjudul منهاج الطالبين. | CATATAN · "Simpan yang penting." · "Jawaban dan ibarah tersimpan di Catatan, siap dibaca lagi kapan saja." |
| 0:25–0:30 | Kamera mundur ke ruang gelap. Logo 3D kembali. | "OpenTurath" · "Membaca kitab, menelusuri ibarah." · tombol "openturath.id" · "Jawaban AI tetap perlu diperiksa pada kitab rujukan." |

## Dasar setiap klaim

- Tagline "Membaca kitab, menelusuri ibarah." berasal dari `appTagline` (`lib/core/copy_catalog.dart`).
- Katalog per bidang dengan pengarang, muhaqqiq, penerbit, jilid, dan halaman sesuai layar Katalog kitab dan Rujukan Kitab di aplikasi.
- Data منهاج الطالبين (al-Nawawi, w. 676 H, Dār al-Fikr, 1 jilid, 370 halaman) diambil dari `assets/data/01_KATALOG_FIKIH_SYAFII.json`.
- Pertanyaan contoh adalah salah satu `suggestedPrompts` asisten Fikih Syafi'i (`lib/models/agent_model.dart`). Film tidak menampilkan jawaban AI apa pun.
- "Telusuri pembahasannya langsung dari naskah turats" mengikuti copy kartu Beranda. Label "Rujukan [n]" adalah format sitasi pada chat asisten.
- Jawaban dan ibarah memang bisa disimpan ke tab Catatan ("Simpan ke Catatan").
- Kalimat penutup mengikuti prinsip aplikasi: jawaban AI perlu diperiksa pada kitab yang dirujuk.
- Judul pada punggung kitab di rak adalah judul singkat asli dari katalog bawaan aplikasi, dipilih acak oleh `tools/make_titles.py`.
- Halaman kitab yang terbuka hanya berisi garis abstrak, bukan teks kitab yang dikarang.

## Audio

Musik latar disintesis sendiri oleh `tools/make_audio.py` (pad, denyut rendah, desir transisi, nada lonceng saat logo muncul). Tidak ada sampel atau musik pihak ketiga. Film tetap bisa dipahami tanpa suara.
