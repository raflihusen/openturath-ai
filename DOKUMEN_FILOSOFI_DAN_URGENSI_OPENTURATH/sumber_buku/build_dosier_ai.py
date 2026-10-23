#!/usr/bin/env python3
"""Dosier Produk 01: OpenTurath AI  ->  ../OpenTurath_Dosier_01_OpenTurath_AI.pdf
Fakta diambil dari kode dan data aplikasi (openturath_ai/lib, assets/data) dan konten website.
Jalankan:  python3 build_dosier_ai.py
"""
import re, json, subprocess, pathlib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
FONTDIR = ROOT / "openturath_ai/assets/native_fonts"
INFO = json.load(open(ROOT / "openturath_ai/assets/data/info_ai.json", encoding="utf8"))
PENG = json.load(open(ROOT / "openturath_ai/assets/data/pengantar_tahawwulat.json", encoding="utf8"))
ADAB = json.load(open(ROOT / "website/content/adab.json", encoding="utf8"))
SVG = (ROOT / "OpenTurath_logo_transparent.svg").read_text()
paths = re.findall(r'<path d="([^"]+)" fill="#100f0e"', SVG)
SYMBOL = '<svg width="0" height="0" style="position:absolute"><symbol id="ot" viewBox="0 0 616 674">' + \
         "".join(f'<path transform="translate(-204,-175)" d="{d}"/>' for d in paths) + "</symbol></svg>"

def logo(w, color="var(--ink)"):
    h = w * 673 / 615
    return f'<svg class="lg" style="width:{w}mm;height:{h:.1f}mm;color:{color}" viewBox="0 0 616 674"><use href="#ot"/></svg>'

pages = []
def pg(inner, cls="", foot=True, title=""):
    n = len(pages) + 1
    f = f'<div class="pn"><span>Dosier Produk 01 &middot; OpenTurath AI</span><span>{title}{"  " if title else ""}{n:02d}</span></div>' if foot else ""
    pages.append(f'<section class="pg {cls}"><div class="in">{inner}</div>{f}</section>')
def sec(no, name): return f'<div class="kick">{no} &mdash; {name}</div>'
def small(t, c="var(--ink)"): return f'<p class="small" style="color:{c};margin:0;max-width:none">{t}</p>'

# 1 Sampul
pg(f'''<div style="height:100%;display:flex;flex-direction:column;justify-content:space-between">
<div style="display:flex;justify-content:space-between;font-size:8pt;letter-spacing:.2em;text-transform:uppercase;color:#9a9a9a"><span>Dosier Produk 01</span><span>Draf 1 &middot; 23 Oktober 2026</span></div>
<div style="display:flex;align-items:center;gap:20mm">{logo(52,"var(--bone)")}
<div><div class="kick" style="color:#9a9a9a">OpenTurath</div><h1 style="font-size:58pt;margin:0 0 4mm">OpenTurath AI</h1>
<div class="lead" style="color:#cfcfcf;font-style:italic">AI Islami berbasis turath.</div></div></div>
<div style="font-size:8pt;letter-spacing:.2em;text-transform:uppercase;color:#9a9a9a;display:flex;justify-content:space-between"><span>Penjelasan rinci setiap bagian produk</span><span>openturath.id</span></div></div>''', "dark", foot=False)

# 2 Ringkasan
pg(f'''{sec("01","Ringkasan")}<h2 style="font-size:30pt;max-width:245mm">OpenTurath AI membantu penuntut ilmu memahami kitab dan menemukan rujukan ibarahnya, bidang demi bidang.</h2>
<div class="grid3" style="margin-top:7mm">
<div class="card"><div class="small">Apa ini</div><p style="font-size:9.6pt;margin:2mm 0 0">Aplikasi percakapan dengan asisten AI yang dikelompokkan menurut bidang ilmu Islam. Tiap asisten berpegang pada kumpulan kitab bidangnya dan menjawab dengan ibarah serta arah ke kitab yang dirujuk.</p></div>
<div class="card"><div class="small">Untuk siapa</div><p style="font-size:9.6pt;margin:2mm 0 0">Santri dan pemula, mahasiswa dan peneliti, pengajar, penceramah, khatib, pemberi fatwa, dan pengkaji Fikih Tahawwulat.</p></div>
<div class="card"><div class="small">Posisi</div><p style="font-size:9.6pt;margin:2mm 0 0">Alat bantu, bukan pengganti guru dan bukan pemberi fatwa. Penjelasan AI selalu perlu diverifikasi kepada guru.</p></div></div>
<table style="margin-top:7mm"><tr><td style="width:46mm"><b>Status</b></td><td>Rilis publik perdana 23 Oktober 2026</td><td style="width:46mm"><b>Perangkat</b></td><td>Android, macOS, Windows</td></tr>
<tr><td><b>Bahasa antarmuka</b></td><td>Indonesia, Inggris, Arab</td><td><b>Bidang</b></td><td>Fikih empat mazhab, hadis, tafsir, ushul, akidah, tasawuf, bahasa Arab, sejarah, bibliografi, dan Fikih Tahawwulat</td></tr>
<tr><td><b>Akun</b></td><td>Masuk dengan akun Google</td><td><b>Akses</b></td><td>Per modul bidang</td></tr></table>''', title="Ringkasan")

# 3 Masalah
pg(f'''{sec("02","Masalah yang Diselesaikan")}<h2>Tiga kesulitan yang dialami hampir setiap penuntut ilmu.</h2>
<table style="margin-top:3mm;font-size:10pt"><tr><th style="width:62mm">Kesulitan</th><th style="width:100mm">Yang terjadi</th><th>Jawaban OpenTurath AI</th></tr>
<tr><td><b>Bahasa dan istilah</b></td><td>Kitab berbahasa Arab klasik. Menerjemahkan kata demi kata menghabiskan waktu, dan istilah teknis tetap membingungkan.</td><td>Asisten yang menjelaskan konsep dan istilah dengan bahasa sederhana (di Fikih Tahawwulat: Al-Bayan), dengan teks Arab aslinya tetap ditampilkan.</td></tr>
<tr><td><b>Mencari ibarah</b></td><td>Menemukan satu nas bisa memakan waktu lama, apalagi bila tidak tahu kata kunci di maktabah.</td><td>Cukup bertanya dengan bahasa sehari-hari. Asisten menelusuri kumpulan kitab bidangnya dan menunjukkan ibarah serta rujukannya.</td></tr>
<tr><td><b>AI umum yang tidak bersandar pada teks</b></td><td>AI umum sering mengarang ayat, kitab, atau ibarah, sementara banyak orang bertanya perkara agama kepadanya.</td><td>Tiap asisten dibatasi pada korpus yang dikurasi bidangnya, dan jawaban diarahkan ke rujukan.</td></tr></table>''', title="Masalah")

# 4 Cara kerja
steps = [("Pilih bidang","Pilih asisten sesuai ilmu yang ditanyakan."),("Ajukan pertanyaan","Tulis dengan bahasa sehari-hari, atau pakai pertanyaan contoh."),
         ("Asisten menelusuri","Hanya dari kumpulan kitab bidangnya."),("Baca jawaban","Penjelasan, ibarah Arab, dan nomor rujukan."),
         ("Periksa kitab","Buka keterangan kitab, cocokkan dengan edisi."),("Simpan dan tanya guru","Simpan ke Catatan, bawa ke guru.")]
sc = "".join(f'<div style="flex:1;position:relative"><div class="card" style="padding:5mm;height:46mm"><div class="num" style="font-size:20pt">{i+1}</div><b style="font-size:10pt">{t}</b><p class="small" style="color:var(--ink);margin:1.5mm 0 0;font-size:8.4pt">{d}</p></div></div>' for i,(t,d) in enumerate(steps))
pg(f'''{sec("03","Cara Kerja")}<h2>Dari pertanyaan sampai rujukan, enam langkah.</h2>
<div style="display:flex;gap:3mm;margin-top:5mm">{sc}</div>
<p class="small" style="margin-top:7mm;max-width:240mm">Percakapan AI berjalan dengan memanfaatkan teknologi Google. OpenTurath adalah layanan mandiri yang mengatur bidang, kumpulan rujukan, tampilan, Catatan, dan akses.</p>''', title="Cara Kerja")

# 5 Di balik layar
def pr(n, t, d): return f'<div class="card" style="padding:5mm"><div class="num" style="font-size:18pt">{n}</div><b style="font-size:10.5pt">{t}</b><p class="small" style="color:var(--ink);margin:1.5mm 0 0;font-size:8.8pt">{d}</p></div>'
pg(f'''{sec("03","Di Balik Layar")}<h2>Enam prinsip penyusunan korpus.</h2>
<div class="grid3" style="margin-top:4mm">
{pr("01","Satu bidang, satu korpus","Setiap asisten hanya berpegang pada kitab bidangnya, sehingga metodologi tiap ilmu tidak tercampur.")}
{pr("02","Sumber kanonikal","Teks diambil dari basis data kitab resmi yang bersih, bukan salinan sembarang.")}
{pr("03","Kitab tidak dipotong sembarang","Kitab ditaruh utuh. Kitab besar dibagi hanya mengikuti sekat jilid yang resmi.")}
{pr("04","Stempel rujukan","Setiap potongan teks diberi penanda: judul kitab, pengarang dan tahun wafat, penerbit atau pentahqiq, jilid, halaman, dan kode kitab.")}
{pr("05","Kurasi wasathiyyah syar'iyyah","Kitab dipilih satu per satu agar tidak terpolitisasi dan tidak dipakai menjatuhkan kelompok lain.")}
{pr("06","Pemeriksaan sebelum unggah","Berkas melewati pemeriksaan otomatis sebelum masuk ke korpus.")}</div>
<p class="small" style="margin-top:5mm;max-width:250mm">Prinsip ini bersumber dari rancangan arsitektur korpus (dokumen 02). Pemilik perlu mengonfirmasi bahwa semuanya masih berlaku pada versi korpus yang dipakai saat ini.</p>''', title="Di Balik Layar")

# 6-8 Bidang ilmu
byid = {x["id"]: x for x in INFO}
def bcard(i):
    x = byid[i]
    return (f'<div class="card" style="padding:4.5mm"><div style="display:flex;justify-content:space-between;align-items:baseline;gap:3mm"><b style="font-size:10.2pt">{x["judul"]}</b>'
            f'<span class="ar" style="font-size:12pt;color:var(--g2);white-space:nowrap">{x["nama_arab"]}</span></div>'
            f'<div class="small" style="margin:.8mm 0 2mm;font-size:7.6pt">{x["subjudul"]}</div>'
            f'<p style="font-size:7.9pt;line-height:1.42;margin:0;max-width:none">{x["tentang"]}</p></div>')
def bpage(heading, ids, title):
    pg(f'{sec("04","Peta Bidang Ilmu")}<h2 style="font-size:20pt;margin-bottom:3mm">{heading}</h2><div class="grid3" style="gap:4mm">{"".join(bcard(i) for i in ids)}</div>', title=title)
bpage("Fikih dan ushul.", ["fiqh_syafii","fiqh_hanafi","fiqh_maliki","fiqh_hanbali","fiqh_muqaran","ushul_fiqh"], "Bidang")
bpage("Hadis dan Al-Qur'an.", ["hadits","syarah_hadits","musthalah_hadits","thabaqat_tarajim","tafsir","tajwid_qiraat"], "Bidang")
bpage("Akidah, tasawuf, bahasa, sejarah, dan bibliografi.", ["aqidah","tasawwuf","nahwu_sharaf","tarikh","bibliografi_faharis"], "Bidang")

# 9 Fikih Tahawwulat: empat rukun (dari Pengantar)
rk = [s for s in PENG["slide"] if s["id"] == "empat-rukun"][0]["rukun"]
rkc = "".join(f'<div class="card" style="padding:5mm;text-align:center"><div class="ar" style="font-size:20pt;line-height:1.5">{r["arab"]}</div><b>{r["nama"]}</b><div class="small" style="margin-top:1mm;color:var(--ink)">{r["ilmu"]}</div></div>' for r in rk)
pg(f'''{sec("05","Fikih Tahawwulat")}<div class="row" style="gap:12mm;align-items:center"><div class="col"><h2>Rukun keempat agama, dan sebab kami memilihnya sebagai bidang pertama.</h2>
<p style="font-size:10pt">Dalam hadis Jibril, Nabi menjawab empat pertanyaan: Islam, iman, ihsan, dan tanda-tanda kiamat. Menurut Fikih Tahawwulat, keempatnya adalah rukun agama. Tiga yang pertama berpadu dengan fikih, akidah, dan tasawuf. Yang keempat, ilmu tentang tanda-tanda zaman, menjadi peta navigasi yang menjaga ketiganya saat keadaan membingungkan.</p>
<p style="font-size:10pt">Inilah yang tergambar pada logo OpenTurath: tiga bidang di dalam, lengkung yang menaunginya di luar.</p>
<p class="small" style="margin:0">Sumber: An-Nubdzah ash-Shughra, hlm. 9 sampai 12 (materi Pengantar Fikih Tahawwulat di aplikasi).</p></div>
<div class="col"><div class="grid2" style="gap:4mm">{rkc}</div></div></div>''', title="Fikih Tahawwulat")

# 10 lima cabang
br = [("Al-Muhaqqiq","المحقق","Teks matan dan ibarah","Mencari, memeriksa, dan mengaitkan teks dengan sumbernya.","Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?"),
      ("Al-Bayan","البيان","Penyederhanaan konsep","Menjelaskan konsep dan istilah dengan bahasa sederhana secara metodis.","Bagaimana penjelasan al-ghutsa'iyyah dalam kitab?"),
      ("Al-Mukhtabir","المختبر","Uji pemahaman dan nalar","Menilai pemahaman dan menguji persoalan kontemporer.","Uji pemahaman saya tentang rukun agama yang empat."),
      ("Al-Habib","الحبيب","Arsip muhadharah","Gudang ceramah dan rekaman Al-Habib Abu Bakar, dengan tautan video pada menit yang tepat.","Muhadharah mana yang membahas sikap saat masa fitnah?"),
      ("Al-Khatib","الخطيب","Materi dakwah dan khutbah","Menyusun khutbah dan materi ceramah serta mengarahkan persoalan dakwah.","Susun kerangka khutbah tentang sikap saat masa fitnah.")]
rows = "".join(f'<tr><td style="width:38mm"><b style="font-size:11pt">{a}</b><div class="ar" style="font-size:13pt;color:var(--g2)">{b}</div></td><td style="width:48mm"><b>{c}</b></td><td>{d}</td><td style="width:70mm;font-style:italic">&ldquo;{e}&rdquo;</td></tr>' for a,b,c,d,e in br)
pg(f'''{sec("05","Lima Cabang Fikih Tahawwulat")}<h2>Satu bidang, lima cara belajar.</h2>
<p style="font-size:10pt;max-width:240mm">Korpusnya adalah kitab karya Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur dan arsip muhadharah beliau dari tiga kanal resmi. Lima asisten membagi disiplin ini menurut kebutuhan pembelajar.</p>
<table style="margin-top:2mm"><tr><th>Asisten</th><th>Peran</th><th>Fungsi</th><th>Contoh pertanyaan</th></tr>{rows}</table>
<p class="small" style="margin-top:3mm">Contoh pertanyaan untuk Al-Muhaqqiq, Al-Bayan, dan Al-Habib berasal dari pertanyaan contoh di aplikasi; sisanya contoh ilustratif.</p>''', title="Lima Cabang")

# 11-12 Fitur
feat = [("Pilih bidang","Beranda menampilkan kartu asisten per bidang, dengan satu ketukan langsung ke percakapan.","Ketuk kartu bidang."),
        ("Percakapan per bidang","Bertanya dalam bahasa sehari-hari. Tersedia pertanyaan contoh di tiap bidang.","Ketik pertanyaan atau pilih pertanyaan contoh."),
        ("Jawaban dengan rujukan","Jawaban memuat penjelasan, ibarah Arab, dan nomor rujukan. Kitab, jilid, dan halaman ditampilkan bila tersedia.","Baca bersama konteks, lalu cocokkan dengan edisi Anda."),
        ("Info bidang","Keterangan isi tiap asisten: cabang ilmu, kitab induk, dan rentang pengarang.","Ketuk ikon info pada asisten."),
        ("Pustaka dan metadata kitab","Keterangan tiap kitab: judul, pengarang dan tahun wafat, pentahqiq, penerbit, edisi, jilid, halaman, dan jenis naskah (matan, syarah, hasyiyah), termasuk peringatan edisi.","Buka Pustaka, saring menurut jenis naskah."),
        ("Catatan","Simpan jawaban beserta kutipan Arab, kitab, dan halamannya. Dapat disunting, disalin, dibagikan, dan dihapus. Rujukan ikut tersimpan agar catatan tetap bisa ditelusuri.","Simpan dari jawaban, buka kembali di Catatan.")]
feat2 = [("Multi-tab","Membuka beberapa percakapan sekaligus: lima tab di macOS, tiga tab di perangkat lain.","Buka tab baru dari ruang kerja."),
         ("Pintasan papan ketik","Di desktop: cari, tab baru, tutup tab, muat ulang, pengaturan, lewat pintasan ⌘.","Gunakan ⌘F, ⌘T, ⌘W, ⌘R, dan ⌘,."),
         ("Tiga bahasa","Antarmuka dalam bahasa Indonesia, Inggris, dan Arab, termasuk tata letak kanan ke kiri.","Pilih di pengalih bahasa."),
         ("Kalender Hijriah","Tanggal Hijriah berdampingan dengan Masehi (perhitungan tabular, bukan penetapan rukyat).","Tampil pada beranda."),
         ("Pengantar Fikih Tahawwulat","Video pengantar sekitar dua belas menit dalam lima belas bab, dengan ibarah dan sumbernya.","Buka dari kartu Fikih Tahawwulat."),
         ("Akun dan akses","Masuk dengan akun Google. Akses per modul bidang, dengan kode tebus bila ada.","Masuk, lalu pilih modul."),
         ("Pembaruan","Pemberitahuan di dalam aplikasi saat pembaruan tersedia.","Ikuti petunjuk di spanduk pembaruan.")]
def ftable(items): return '<table><tr><th style="width:46mm">Fitur</th><th>Fungsi</th><th style="width:70mm">Cara memakai</th></tr>' + "".join(f'<tr><td><b>{a}</b></td><td>{b}</td><td>{c}</td></tr>' for a,b,c in items) + '</table>'
pg(f'''{sec("06","Fitur Satu per Satu")}<h2 style="font-size:20pt">Membaca, bertanya, dan menyimpan.</h2>{ftable(feat)}''', title="Fitur")
pg(f'''{sec("06","Fitur Satu per Satu")}<h2 style="font-size:20pt">Ruang kerja dan kenyamanan.</h2>{ftable(feat2)}''', title="Fitur")

# 13 Contoh jawaban
ib = [s for s in PENG["slide"] if s["id"] == "empat-rukun"][0]
pg(f'''{sec("07","Contoh Tampilan Jawaban")}<div class="row" style="gap:12mm;align-items:center"><div class="col"><h2>Seperti inilah bentuk jawaban yang kami tuju.</h2>
<p class="small" style="margin:0 0 3mm;max-width:none">Ilustrasi disusun dari materi Pengantar Fikih Tahawwulat di aplikasi, bukan hasil percakapan langsung.</p>
<div style="background:#fff;border:.4mm solid var(--g3);border-radius:4mm;padding:6mm"><div style="display:inline-block;background:var(--g4);border-radius:3mm;padding:2.4mm 5mm;font-size:9.4pt;margin-bottom:4mm">Berapa rukun agama menurut Fikih Tahawwulat?</div>
<div class="small" style="letter-spacing:.14em;text-transform:uppercase;font-weight:600;margin-bottom:2mm">AI Fikih Tahawwulat &middot; Al-Muhaqqiq</div>
<p style="font-size:9.8pt;max-width:none;margin-bottom:3mm">Menurut Fikih Tahawwulat, rukun agama ada empat: Islam, iman, ihsan, dan tanda-tanda kiamat. Hal itu dipahami dari rangkaian pertanyaan dalam hadis Jibril, yang ditutup dengan sabda Nabi bahwa Jibril datang mengajarkan agama kalian [1].</p>
<div class="ar" style="font-size:15pt;line-height:1.9;background:var(--g5);border-radius:3mm;padding:3mm 5mm;margin-bottom:2mm">{ib["ibarah"].replace("…"," … ")}</div>
<div class="small" style="margin:0">[1] {ib["sumber"]}</div></div></div>
<div class="col"><div class="card"><h3>Yang perlu terlihat pada setiap jawaban</h3><table>
<tr><td><b>Penjelasan</b></td><td>Bahasa sederhana, satu gagasan per kalimat.</td></tr>
<tr><td><b>Ibarah Arab</b></td><td>Kutipan asli, bukan terjemahan saja.</td></tr>
<tr><td><b>Nomor rujukan</b></td><td>Menunjuk kitab, jilid, dan halaman bila tersedia.</td></tr>
<tr><td><b>Pembeda</b></td><td>Ibarah asli, terjemahan, dan ringkasan AI dibedakan jelas.</td></tr></table></div></div></div>''', title="Contoh")

# 14 Adab penggunaan
pr_ = ADAB["principles"][:6]
ac = "".join(f'<div class="card" style="padding:4.5mm"><b style="font-size:10.4pt">{p["heading"][0]}</b><p class="small" style="color:var(--ink);margin:1.5mm 0 0;font-size:8.3pt;line-height:1.45;max-width:none">{p["body"][0]}</p></div>' for p in pr_)
pg(f'''{sec("08","Cara Memakai dengan Adab")}<h2 style="font-size:21pt;margin-bottom:3mm">Panduan bagi pembaca.</h2><div class="grid3" style="gap:4mm">{ac}</div>''', title="Adab")

# 15 Jaminan dan batas
pg(f'''{sec("09","Yang Dijaga dan Batasnya")}<div class="row" style="gap:12mm"><div class="col"><h2>Yang kami jaga.</h2><table>
<tr><td>Jawaban diarahkan ke rujukan, bukan jawaban kosong.</td></tr>
<tr><td>Setiap asisten berpegang pada korpus bidangnya, tanpa mencampur metodologi.</td></tr>
<tr><td>Kitab dikurasi dengan wasathiyyah syar'iyyah.</td></tr>
<tr><td>Ibarah Arab ditampilkan apa adanya, dibedakan dari terjemahan dan ringkasan.</td></tr>
<tr><td>Tidak ada pernyataan sebagai dalil bila kitab, jilid, dan halaman belum tersedia.</td></tr>
<tr><td>Laporan kesalahan disambut dan diperiksa.</td></tr></table></div>
<div class="col"><h2>Batasnya.</h2><table>
<tr><td>Jawaban AI dapat keliru atau kurang lengkap.</td></tr>
<tr><td>Penjelasan AI perlu diverifikasi kepada guru, terutama untuk amal dan fatwa.</td></tr>
<tr><td>Nomor halaman dapat berbeda antar edisi cetak.</td></tr>
<tr><td>Tidak semua kitab ada di setiap bidang; cakupan dapat dilihat pada Info bidang dan Pustaka.</td></tr>
<tr><td>OpenTurath AI bukan pemberi fatwa dan tidak menggantikan guru.</td></tr>
<tr><td>Untuk persoalan pribadi yang mendesak, bertanyalah kepada ulama setempat.</td></tr></table></div></div>''', title="Jaminan dan Batas")

# 16 Peta jalan
def rm(st, t, d): return f'<div style="display:flex;gap:6mm;padding:4.5mm 0;border-bottom:.3mm solid var(--g3)"><span class="tag" style="height:fit-content;width:28mm;text-align:center">{st}</span><div><b style="font-size:11pt">{t}</b><p class="small" style="color:var(--ink);margin:1mm 0 0;max-width:190mm">{d}</p></div></div>'
pg(f'''{sec("10","Status dan Arah")}<h2>Dari satu bidang menuju seluruh ilmu.</h2><div style="max-width:245mm;margin-top:2mm">
{rm("Rilis","Rilis publik perdana, 23 Oktober 2026","Asisten bidang, Pustaka dan metadata kitab, Catatan, multi-tab, tiga bahasa, di Android, macOS, dan Windows.")}
{rm("Berikutnya","Perluasan bidang ilmu","Dari Fikih Tahawwulat dan bidang yang sudah ada, meluas ke seluruh ilmu Islam: nahwu, sharaf, bahasa Arab, fikih, ushul fikih, dan lainnya.")}
{rm("Berikutnya","Khazanah para ulama","Menghidupkan turath para ulama melalui kitab dan ceramah mereka, sehingga pemikiran seorang ulama dapat dikaji.")}
{rm("Terhubung","Bersama lini OpenTurath lain","Maktabah OpenTurath untuk kitabnya, AI Manuskrip untuk naskah lama, dan Akademi OpenTurath untuk belajar memakai AI.")}</div>''', title="Status")

# 17 FAQ
faq = [("Apakah OpenTurath AI mengeluarkan fatwa?","Tidak. Ia membantu menemukan pembahasan dan rujukan. Fatwa dan penerapan hukum pada keadaan tertentu tetap kepada ulama yang berkompeten."),
       ("Apakah ia menggantikan guru?","Tidak. Ia alat bantu yang menghemat waktu mencari ibarah. Pemahaman dan adab tumbuh bersama guru."),
       ("Dari mana jawabannya?","Dari kumpulan kitab yang dikurasi pada bidang yang Anda pilih, bukan dari seluruh internet."),
       ("Apa bedanya dengan AI umum?","Tiap bidang punya asisten dan metodologinya sendiri, kitabnya dikurasi, dan jawaban diarahkan ke rujukan."),
       ("Bagaimana jika menemukan kesalahan?","Laporkan lewat support@openturath.id dengan menyertakan kutipan dan rujukannya, agar mudah diperiksa."),
       ("Bahasa apa yang didukung?","Antarmuka dalam bahasa Indonesia, Inggris, dan Arab."),
       ("Di perangkat apa?","Android, macOS, dan Windows."),
       ("Berapa percakapan yang bisa dibuka bersamaan?","Lima tab di macOS dan tiga tab di perangkat lain.")]
fq = "".join(f'<div class="card" style="padding:4.2mm"><b style="font-size:9.8pt">{q}</b><p class="small" style="color:var(--ink);margin:1mm 0 0;font-size:8.6pt;max-width:none">{a}</p></div>' for q,a in faq)
pg(f'''{sec("11","Pertanyaan yang Sering Muncul")}<h2 style="font-size:21pt;margin-bottom:3mm">Jawaban singkat.</h2><div class="grid2" style="gap:4mm">{fq}</div>''', title="FAQ")

# 18 Catatan penyusun
pg(f'''{sec("","Lembar Catatan Penyusun")}<h2>Butir yang perlu Anda putuskan atau lengkapi.</h2><p class="small" style="margin-bottom:3mm;max-width:none">Halaman ini untuk Pemilik dan dibuang sebelum dosier diterbitkan.</p>
<table style="font-size:9.3pt"><tr><th style="width:8mm">#</th><th>Butir</th></tr>
<tr><td>1</td><td><b>Klaim ketepatan ibarah.</b> Dokumen verifikasi (dok. 08) mencatat 826 kutipan dalam 100 uji, dengan 59,7 persen cocok dengan teks fisik, dan konten website mencatat 10 kutipan contoh berstatus belum ditinjau. Dosier hanya memakai klaim kualitatif. Untuk menulis "akurasi sangat tinggi", dibutuhkan hasil pengujian terbaru pada korpus V9 yang dapat ditunjukkan.</td></tr>
<tr><td>2</td><td><b>Prinsip penyusunan korpus</b> (halaman Di Balik Layar) berasal dari rancangan V8. Mohon konfirmasi apa yang masih berlaku di V9.</td></tr>
<tr><td>3</td><td><b>Metodologi tiap bidang.</b> Dosier belum menjelaskan metodologi masing-masing asisten (misalnya urutan rujukan fikih Syafi'i). Itu perlu penjelasan Anda per bidang.</td></tr>
<tr><td>4</td><td><b>Proses tinjauan ulama.</b> Siapa meninjau, bagaimana, dan seberapa sering? Cukup dalam bentuk deskripsi tanpa nama.</td></tr>
<tr><td>5</td><td><b>Jumlah asisten.</b> Aplikasi memuat delapan belas asisten bidang plus lima cabang Fikih Tahawwulat. Sebut "puluhan" atau angka tertentu?</td></tr>
<tr><td>6</td><td><b>Pertanyaan contoh</b> untuk Al-Mukhtabir dan Al-Khatib masih ilustratif.</td></tr>
<tr><td>7</td><td><b>Pemakaian data dan privasi</b> dijelaskan di Kebijakan Privasi, bukan di dosier ini.</td></tr></table>''', title="Catatan")

css = (HERE / "style.css").read_text().replace("FONTDIR", FONTDIR.as_posix())
css += ".grid2,.grid3{align-items:start}"
html = f'<!doctype html><html lang="id"><head><meta charset="utf-8"><title>OpenTurath AI: Dosier Produk</title><style>{css}</style></head><body>{SYMBOL}{"".join(pages)}</body></html>'
out = HERE / "dosier_ai.html"; out.write_text(html, encoding="utf-8")
pdf = HERE.parent / "OpenTurath_Dosier_01_OpenTurath_AI.pdf"
chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
subprocess.run([chrome, "--headless", "--disable-gpu", "--no-pdf-header-footer", "--allow-file-access-from-files",
                f"--print-to-pdf={pdf}", f"file://{out}"], check=True, capture_output=True)
print("halaman:", len(pages), "->", pdf)
