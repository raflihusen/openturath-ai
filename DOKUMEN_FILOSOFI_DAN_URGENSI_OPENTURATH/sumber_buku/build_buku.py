#!/usr/bin/env python3
"""Membangun OpenTurath_Buku_Identitas.pdf dari awal (HTML -> Chrome headless).
Jalankan:  python3 build_buku.py
Hasil:     ../OpenTurath_Buku_Identitas.pdf  (dan buku.html di folder ini)
"""
import re, subprocess, pathlib, sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent  # /ramadhan
FONTDIR = ROOT / "openturath_ai/assets/native_fonts"
SVG = (ROOT / "OpenTurath_logo_transparent.svg").read_text()
paths = re.findall(r'<path d="([^"]+)" fill="#100f0e"', SVG)
SYMBOL = '<svg width="0" height="0" style="position:absolute"><symbol id="ot" viewBox="204 175 616 674">' + \
         "".join(f'<path d="{d}"/>' for d in paths) + "</symbol></svg>"

# ---------- helper ----------
def lum(h):
    h = h.lstrip("#"); r, g, b = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    f = lambda c: c / 12.92 if c <= .03928 else ((c + .055) / 1.055) ** 2.4
    return .2126 * f(r) + .7152 * f(g) + .0722 * f(b)
def contrast(a, b):
    la, lb = sorted([lum(a), lum(b)], reverse=True)
    return (la + .05) / (lb + .05)

def logo(w, color="var(--ink)", extra=""):
    h = w * 673 / 615
    return f'<svg class="lg" style="width:{w}mm;height:{h:.1f}mm;color:{color};{extra}" viewBox="0 0 616 674"><use href="#ot"/></svg>'

def lockup(h, color="var(--ink)", vertical=False):
    w = h * 615 / 673
    fs = h * 0.46 * 2.835 / 1  # mm -> pt approx (1mm = 2.835pt)
    if vertical:
        return f'<div style="display:inline-flex;flex-direction:column;align-items:center;gap:{h*.22}mm;color:{color}">{logo(w, color)}<span class="wm" style="font-size:{h*.30*2.835:.0f}pt">OpenTurath</span></div>'
    return f'<div class="lock" style="gap:{h*.2}mm;color:{color}">{logo(w, color)}<span class="wm" style="font-size:{fs*0.78:.0f}pt;line-height:1">OpenTurath</span></div>'

pages = []
def pg(inner, cls="", foot=True, title=""):
    n = len(pages) + 1
    f = f'<div class="pn"><span>OpenTurath &middot; Buku Identitas</span><span>{title}{"  " if title else ""}{n:02d}</span></div>' if foot else ""
    pages.append(f'<section class="pg {cls}"><div class="in">{inner}</div>{f}</section>')

def sec(no, name): return f'<div class="kick">{no} &mdash; {name}</div>'

# ---------- 1 Sampul ----------
pg(f'''<div style="height:100%;display:flex;flex-direction:column;justify-content:space-between">
<div style="display:flex;justify-content:space-between;font-size:8pt;letter-spacing:.2em;text-transform:uppercase;color:#9a9a9a"><span>Buku Identitas</span><span>Versi 1.0 &middot; Oktober 2026</span></div>
<div style="display:flex;align-items:center;gap:22mm">{logo(62,"var(--bone)")}
<div><h1 style="font-size:64pt;margin:0 0 4mm">OpenTurath</h1>
<div class="lead" style="color:#cfcfcf;font-style:italic">Membaca kitab, menelusuri ibarah.</div></div></div>
<div style="font-size:8pt;letter-spacing:.2em;text-transform:uppercase;color:#9a9a9a;display:flex;justify-content:space-between"><span>Pedoman resmi nama, logo, warna, huruf, suara, dan penerapan</span><span>openturath.id</span></div>
</div>''', "dark", foot=False)

# ---------- 2 Daftar isi ----------
toc = [("01","Pengantar","Untuk apa buku ini dan siapa yang memakainya"),
       ("02","Siapa Kami","Cerita, apa yang kami bangun, dan untuk siapa"),
       ("03","Fondasi","Visi, misi, nilai, posisi, dan kepribadian"),
       ("04","Nama","Arti, penulisan, dan susunan nama"),
       ("05","Logo","Filosofi, versi, ruang aman, dan penggunaan"),
       ("06","Warna","Palet monokrom dan cara memakainya"),
       ("07","Huruf","Empat keluarga huruf dan hierarkinya"),
       ("08","Suara","Cara OpenTurath berbicara dan menulis"),
       ("09","Citra","Ilustrasi, ikon, motif, dan gerak"),
       ("10","Tata Letak","Grid, jarak, sudut, dan komponen"),
       ("11","Penerapan","Aplikasi, website, media sosial, dan dokumen"),
       ("12","Penggunaan Bersama","Aturan bagi pihak lain dan tata kelola")]
rows = "".join(f'<div style="display:flex;gap:6mm;padding:2.6mm 0;border-bottom:.3mm solid var(--g3)"><span class="serif" style="width:12mm;color:var(--g2);font-size:13pt">{a}</span><span style="width:52mm;font-weight:600">{b}</span><span class="small" style="padding-top:.5mm">{c}</span></div>' for a,b,c in toc)
pg(f'''{sec("","Isi")}<h2>Daftar isi</h2><div style="max-width:200mm">{rows}</div>''', title="Isi")

# ---------- 3 Pengantar ----------
pg(f'''{sec("01","Pengantar")}<h1 style="max-width:230mm">Satu buku untuk membuat apa pun atas nama OpenTurath.</h1>
<div class="row" style="margin-top:8mm"><div class="col">
<p class="lead">Aplikasi, website, poster, video, surat, presentasi: semuanya harus terasa datang dari satu tempat yang sama.</p>
<p>Buku ini menetapkan siapa OpenTurath, bagaimana ia terlihat, dan bagaimana ia berbicara. Isinya cukup rinci agar perancang, pengembang, dan penulis dapat bekerja tanpa harus bertanya, dan cukup ringkas agar mudah dibuka kembali di tengah pekerjaan.</p></div>
<div class="col"><div class="card"><h3>Cara memakainya</h3>
<table><tr><td style="width:36mm"><b>Perancang</b></td><td>Bab 05 sampai 10: logo, warna, huruf, citra, tata letak.</td></tr>
<tr><td><b>Pengembang</b></td><td>Bab 06, 07, dan 10: token warna, huruf, jarak, sudut, komponen.</td></tr>
<tr><td><b>Penulis</b></td><td>Bab 02, 03, 04, dan 08: cerita, nilai, nama, suara.</td></tr>
<tr><td><b>Mitra dan media</b></td><td>Bab 02, 04, 05, dan 12: cara menyebut dan menampilkan OpenTurath.</td></tr></table></div></div></div>''', title="Pengantar")

# ---------- 4 Siapa kami ----------
pg(f'''{sec("02","Siapa Kami")}<h2 style="font-size:34pt;max-width:240mm">OpenTurath adalah pendamping belajar kitab Islam berbasis AI.</h2>
<p class="lead" style="margin-top:6mm">Kami membantu pembaca menelusuri pembahasan, membaca kutipan, dan menemukan rujukan dalam kitab-kitab turath, lalu mengajak mereka membuka kitabnya sendiri.</p>
<div class="grid4" style="margin-top:12mm">
<div class="card"><div class="small">Nama</div><h3 style="margin:1mm 0 0">OpenTurath</h3></div>
<div class="card"><div class="small">Perintis</div><h3 style="margin:1mm 0 0">Rafli Husen</h3></div>
<div class="card"><div class="small">Hadir di</div><h3 style="margin:1mm 0 0">Android, macOS, Windows, web</h3></div>
<div class="card"><div class="small">Alamat</div><h3 style="margin:1mm 0 0">openturath.id</h3></div></div>
<div class="card" style="margin-top:6mm;display:flex;gap:8mm;align-items:center"><span class="tag">Tagline</span><span class="serif" style="font-size:20pt;font-style:italic">Membaca kitab, menelusuri ibarah.</span></div>''', title="Siapa Kami")

# ---------- 5 Cerita ----------
pg(f'''{sec("02","Cerita Kami")}<div class="row"><div style="width:90mm"><h2>Berawal dari seorang pelajar yang hampir menyerah.</h2>
<div style="margin-top:8mm">{logo(34)}</div></div>
<div class="col" style="padding-top:2mm"><p class="lead" style="font-size:14.5pt">Kitab-kitab turath adalah warisan terbesar yang ditinggalkan para ulama. Tetapi bagi pemula, pintunya terasa terlalu tinggi: bahasa Arab klasik, istilah teknis, dan struktur berlapis dari matan ke syarah dan hasyiyah.</p>
<p>Rafli Husen pernah berdiri di depan pintu itu. Ia belajar Fikih Tahawwulat sendirian, di antara kitab-kitab tebal dan rekaman kajian yang jumlahnya tak terhitung, dan berkali-kali nyaris berhenti, bukan karena tidak mau, tetapi karena tidak ada pegangan.</p>
<p>Dari pengalaman itu lahir satu keyakinan: orang tidak seharusnya menyerah hanya karena tidak tahu harus mulai dari mana. Maka ia membangun alat yang ia sendiri butuhkan, sebuah pendamping yang membantu menemukan pembahasan dan rujukannya, lalu mengantar pembaca kembali kepada kitab dan gurunya.</p>
<p style="font-weight:600">Itulah OpenTurath: dibuat oleh pelajar, untuk para pelajar.</p></div></div>''', title="Cerita")

# ---------- 6 Apa yang kami bangun ----------
def feat(t, d): return f'<div class="card"><h3>{t}</h3><p class="small" style="color:var(--ink);font-size:9.5pt">{d}</p></div>'
pg(f'''{sec("02","Apa yang Kami Bangun")}<h2>Satu ruang belajar, banyak bidang ilmu.</h2>
<div class="grid3" style="margin-top:6mm">
{feat("Asisten per bidang","Dua puluh empat asisten, masing-masing berpegang pada kumpulan rujukan bidangnya: fikih empat mazhab, hadis dan syarah, tafsir, ushul fikih, akidah, tasawuf, bahasa Arab, sirah, dan lainnya.")}
{feat("Fikih Tahawwulat","Lima cabang khusus untuk disiplin Fikih Tahawwulat: Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, dan Al-Khatib.")}
{feat("Rujukan yang bisa diperiksa","Jawaban disertai arah ke kitab dan bagian yang dirujuk, supaya pembaca dapat membuka sumbernya sendiri.")}
{feat("Catatan","Simpan jawaban dan kutipan penting, lalu kembali membacanya kapan saja.")}
{feat("Satu akun, banyak perangkat","Belajar di ponsel, laptop, atau komputer meja dengan akun yang sama.")}
{feat("Tampilan tenang","Antarmuka monokrom yang tidak bersaing dengan teks kitab.")}</div>
<p class="small" style="margin-top:6mm">Percakapan AI berjalan menggunakan NotebookLM dari Google. OpenTurath adalah layanan mandiri dan tidak berafiliasi dengan Google.</p>''', title="Apa yang Kami Bangun")

# ---------- 7 Untuk siapa ----------
def persona(t, need, help_):
    return f'<div class="card"><div class="tag" style="margin-bottom:3mm">{t}</div><p style="font-size:9.5pt"><b>Kebutuhan.</b> {need}</p><p style="font-size:9.5pt;margin:0"><b>Bantuan kami.</b> {help_}</p></div>'
pg(f'''{sec("02","Untuk Siapa")}<h2>Empat jenis pembaca yang kami layani.</h2>
<div class="grid2" style="margin-top:5mm">
{persona("Santri pemula","Ingin mulai memahami kitab tetapi kewalahan oleh bahasa dan istilah.","Penjelasan bertahap, rujukan yang bisa dibuka, dan ruang bertanya tanpa takut salah.")}
{persona("Mahasiswa dan peneliti","Perlu menemukan dan membandingkan pembahasan lintas kitab dengan cepat.","Penelusuran per bidang, perbandingan keterangan, dan Catatan untuk menyusun rujukan.")}
{persona("Pengajar dan penceramah","Menyiapkan materi dan memeriksa dalil serta ibarah sebelum mengajar.","Pencarian pembahasan yang cepat, lengkap dengan arah ke kitab untuk dicek ulang.")}
{persona("Pembelajar Fikih Tahawwulat","Mempelajari disiplin yang literaturnya sangat luas dan istilahnya baru.","Lima asisten khusus yang membagi disiplin menurut cara belajarnya.")}</div>''', title="Untuk Siapa")

# ---------- 8 Visi misi ----------
pg(f'''{sec("03","Fondasi")}<div class="row" style="gap:14mm"><div class="col"><div class="tag">Visi</div>
<h2 style="font-size:27pt;margin-top:5mm">Setiap orang yang ingin belajar kitab dapat memulainya dengan tenang, dan sampai kepada rujukannya.</h2></div>
<div class="col"><div class="tag">Misi</div><div style="margin-top:6mm">
<div style="display:flex;gap:5mm;margin-bottom:5mm"><span class="num">1</span><p>Membangun alat yang membantu pembaca menemukan pembahasan dalam kitab.</p></div>
<div style="display:flex;gap:5mm;margin-bottom:5mm"><span class="num">2</span><p>Membantu pembaca membandingkan keterangan para ulama tanpa mencampurkannya.</p></div>
<div style="display:flex;gap:5mm;margin-bottom:5mm"><span class="num">3</span><p>Menyimpan hasil penelusuran agar bisa dipelajari kembali.</p></div>
<div style="display:flex;gap:5mm"><span class="num">4</span><p>Menumbuhkan kebiasaan membaca yang teliti dan beradab.</p></div></div></div></div>''', title="Fondasi")

# ---------- 9 Nilai ----------
vals = [("Kembali kepada sumber","Setiap pembahasan mengarah ke kitabnya. Jawaban adalah pintu masuk, bukan tempat berhenti."),
        ("Menjaga konteks","Syarat, pengecualian, dan perbedaan pendapat ditampilkan utuh, bukan dipotong demi ringkas."),
        ("Menghormati proses belajar","Teknologi membantu mencari. Pemahaman tumbuh dari membaca, berdiskusi, dan berguru."),
        ("Jujur tentang kemampuan","Cakupan dan batas layanan dinyatakan apa adanya. Kami tidak melebih-lebihkan."),
        ("Terbuka terhadap koreksi","Kesalahan yang dilaporkan disambut, diperiksa, dan diperbaiki."),
        ("Tenang dan bersahaja","Antarmuka tidak berteriak. Teks kitab adalah bintangnya; aplikasi adalah ruangnya.")]
cards = "".join(f'<div class="card"><div class="num">{i+1:02d}</div><h3 style="margin-top:2mm">{t}</h3><p class="small" style="color:var(--ink);font-size:9.5pt;margin:0">{d}</p></div>' for i,(t,d) in enumerate(vals))
pg(f'''{sec("03","Enam Nilai")}<h2>Nilai yang memandu setiap keputusan.</h2><div class="grid3" style="margin-top:5mm">{cards}</div>''', title="Nilai")

# ---------- 10 Posisi ----------
pg(f'''{sec("03","Posisi")}<div class="row" style="gap:12mm"><div class="col"><h2>Di mana OpenTurath berdiri.</h2>
<div class="card" style="background:var(--ink);color:var(--bone);border:none"><div class="small" style="color:#aaa;margin-bottom:2mm">Pernyataan posisi</div>
<p class="serif" style="font-size:15pt;line-height:1.4;margin:0;max-width:none">Bagi pembelajar kitab Islam yang ingin memahami dan memeriksa rujukan, OpenTurath adalah pendamping belajar berbasis AI yang mengarahkan setiap pembahasan kembali kepada kitabnya, berbeda dari asisten AI umum yang menjawab tanpa sandaran pada teks.</p></div></div>
<div class="col"><table><tr><th style="width:50%">Kami adalah</th><th>Kami bukan</th></tr>
<tr><td>Pendamping belajar kitab</td><td>Pemberi fatwa</td></tr>
<tr><td>Penunjuk jalan ke rujukan</td><td>Pengganti guru dan ulama</td></tr>
<tr><td>Ruang belajar yang tenang</td><td>Aplikasi yang ramai dan memburu perhatian</td></tr>
<tr><td>Alat bagi pelajar, oleh pelajar</td><td>Lembaga yang mengaku mewakili ulama</td></tr>
<tr><td>Layanan mandiri</td><td>Produk resmi Google</td></tr>
<tr><td>Jujur tentang batas</td><td>Penjual janji akurasi mutlak</td></tr></table></div></div>''', title="Posisi")

# ---------- 11 Kepribadian ----------
def slider(a, b, pos):
    return f'<div style="margin-bottom:6mm"><div style="display:flex;justify-content:space-between;font-size:9pt;font-weight:600"><span>{a}</span><span style="color:var(--g2)">{b}</span></div><div style="height:.4mm;background:var(--ink);position:relative;margin-top:3mm"><span style="position:absolute;left:{pos}%;top:-2mm;width:4.4mm;height:4.4mm;border-radius:50%;background:var(--ink);transform:translateX(-50%)"></span></div></div>'
pg(f'''{sec("03","Kepribadian")}<div class="row" style="gap:16mm"><div style="width:100mm"><h2>Seperti perpustakaan manuskrip yang hening.</h2>
<p>OpenTurath meminjam karakter seorang pendamping yang sabar: tidak tergesa, tidak menggurui, tidak mengaku lebih tahu daripada gurunya.</p>
<p class="serif" style="font-size:16pt;font-style:italic">The Quiet Islamic Scholar</p></div>
<div class="col" style="padding-top:3mm">{slider("Tenang","Ramai",12)}{slider("Teliti","Serampangan",14)}{slider("Rendah hati","Menggurui",16)}{slider("Hangat","Kaku",30)}{slider("Klasik","Kekinian",32)}</div></div>''', title="Kepribadian")

# ---------- 12 Nama ----------
pg(f'''{sec("04","Nama")}<div class="row" style="gap:14mm"><div class="col"><h1 style="font-size:46pt">OpenTurath</h1>
<p class="lead">Dua kata menjadi satu: <i>open</i> dan <i>turath</i>.</p>
<p><b>Turath</b> (<span class="ar" style="font-size:14pt">التراث</span>) adalah warisan keilmuan yang diturunkan: kitab-kitab para ulama dari matan hingga syarah dan hasyiyah.</p>
<p><b>Open</b> membawa tiga makna sekaligus.</p>
<p style="margin-bottom:1.5mm"><b>Terbuka untuk dibaca.</b> Kitab tidak hanya milik yang sudah lama akrab dengannya.</p>
<p style="margin-bottom:1.5mm"><b>Terbuka untuk diperiksa.</b> Setiap jawaban mengajak pembaca membuka kitabnya.</p>
<p><b>Terbuka secara jujur.</b> Cakupan dan batas layanan dinyatakan apa adanya.</p></div>
<div class="col"><div class="card"><h3>Cara menulis</h3><table>
<tr><td style="width:40mm"><span class="yes">Benar</span><b>OpenTurath</b></td><td>Satu kata. Huruf besar pada O dan T.</td></tr>
<tr><td><span class="no">Salah</span>Open Turath</td><td>Jangan dipisah.</td></tr>
<tr><td><span class="no">Salah</span>Openturath, openturath</td><td>Jangan huruf kecil semua, kecuali alamat <code>openturath.id</code>.</td></tr>
<tr><td><span class="no">Salah</span>OPENTURATH</td><td>Huruf kapital semua hanya untuk label kecil bergaya kapitalisasi.</td></tr>
<tr><td><span class="no">Salah</span>OpenTurats</td><td>Gunakan ejaan <i>turath</i>.</td></tr></table>
<p class="small" style="margin:4mm 0 0">Pengucapan: <b>ō-pen-tu-rāts</b>. Padanan Arab untuk kaligrafi: <span class="ar" style="font-size:14pt">أوبن تراث</span></p></div></div></div>''', title="Nama")

# ---------- 13 Arsitektur merek ----------
def lvl(t, d, ind=0, dark=False):
    bg = "background:var(--ink);color:var(--bone);border:none" if dark else ""
    return f'<div class="card" style="margin-left:{ind}mm;padding:4mm 6mm;margin-bottom:3mm;{bg}"><div style="display:flex;gap:6mm;align-items:baseline"><b style="min-width:52mm;font-size:12pt">{t}</b><span style="font-size:9.5pt;opacity:.85">{d}</span></div></div>'
pg(f'''{sec("04","Susunan Nama")}<h2>Satu merek induk, nama turunan yang sederhana.</h2>
<div style="margin-top:6mm">{lvl("OpenTurath","Merek induk. Dipakai di semua materi.",0,True)}
{lvl("OpenTurath AI","Nama aplikasi di toko aplikasi dan perangkat. Dalam teks, cukup tulis OpenTurath bila sudah jelas.",12)}
{lvl("openturath.id","Alamat website resmi. Selalu huruf kecil.",12)}
{lvl("Asisten + nama bidang","Contoh: Asisten Fikih Syafi'i, Asisten Hadis. Nama bidang mengikuti ejaan baku.",12)}
{lvl("Cabang Fikih Tahawwulat","Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, Al-Khatib. Ditulis dengan tanda hubung dan huruf besar awal.",24)}</div>
<p class="small" style="margin-top:4mm">Aturan: jangan menciptakan sub-merek baru dengan awalan atau akhiran "Open" tanpa persetujuan Pemilik. Nama fitur ditulis sederhana dan berbahasa Indonesia (Catatan, Pustaka, Percakapan).</p>''', title="Susunan Nama")

# ---------- 14 Logo: simbol ----------
pg(f'''<div style="display:flex;height:100%;align-items:center;gap:26mm"><div style="width:110mm;display:flex;justify-content:center">{logo(95)}</div>
<div class="col">{sec("05","Logo")}<h1>Simbol OpenTurath</h1>
<p class="lead">Satu lengkung yang menaungi tiga bidang.</p><p>Simbol ini satu warna, dibuat agar tetap terbaca dari ikon sekecil 16 piksel sampai spanduk setinggi gedung. Ia adalah wajah OpenTurath di mana pun merek ini hadir.</p></div></div>''', "white", title="Logo")

# ---------- 15 Filosofi (beranotasi) ----------
# titik anotasi dalam koordinat viewBox simbol (204,175)-(820,849)
def callout(n, px, py, tx, ty):
    px-=204; tx-=204; py-=175; ty-=175
    return (f'<line x1="{px}" y1="{py}" x2="{tx}" y2="{ty}" stroke="#100F0E" stroke-width="2.2"/>'
            f'<circle cx="{tx}" cy="{ty}" r="22" fill="#100F0E"/><text x="{tx}" y="{ty+9}" text-anchor="middle" font-size="26" font-family="OT Outfit" font-weight="600" fill="#fff">{n}</text>'
            f'<circle cx="{px}" cy="{py}" r="6" fill="#100F0E"/>')
ann = (callout(1, 512, 404, 1000, 404) + callout(2, 640, 650, 1000, 650) + callout(3, 262, 360, -100, 330) +
       callout(4, 238, 830, -100, 830))
pg(f'''<div class="row" style="gap:12mm;height:100%;align-items:center"><div style="width:120mm;display:flex;justify-content:center">
<svg viewBox="-364 -25 1240 720" style="width:118mm;color:var(--ink)"><svg x="0" y="0" width="616" height="674" viewBox="0 0 616 674"><use href="#ot"/></svg>{ann}</svg></div>
<div class="col">{sec("05","Filosofi Logo")}<h2>Apa yang dikatakan simbol ini.</h2>
<div style="display:flex;gap:4mm;margin-bottom:3.5mm"><span class="num" style="font-size:15pt;width:7mm">1</span><div><h3 style="margin:0">Tiga bidang di dalam: Islam, Iman, Ihsan</h3><p class="small" style="margin:0;color:var(--ink)">Tiga tingkatan agama dalam hadis Jibril. Ketiganya berdiri berdampingan dan utuh, tidak saling menumpuk.</p></div></div>
<div style="display:flex;gap:4mm;margin-bottom:3.5mm"><span class="num" style="font-size:15pt;width:7mm">2</span><div><h3 style="margin:0">Dua bidang bawah: kitab yang terbuka</h3><p class="small" style="margin:0;color:var(--ink)">Dua halaman yang bertemu di satu celah. Agama dipelajari dari kitab dan guru, dan perbedaan pendapat ulama dijaga, tidak dilebur.</p></div></div>
<div style="display:flex;gap:4mm;margin-bottom:3.5mm"><span class="num" style="font-size:15pt;width:7mm">3</span><div><h3 style="margin:0">Lengkung luar: Fikih Tahawwulat</h3><p class="small" style="margin:0;color:var(--ink)">Fikih Tahawwulat dan ilmu-ilmu yang menaungi serta menjaga tiga bidang di dalamnya, laksana peta navigasi di tengah badai zaman. Bentuk runcingnya menunjuk ke atas.</p></div></div>
<div style="display:flex;gap:4mm"><span class="num" style="font-size:15pt;width:7mm">4</span><div><h3 style="margin:0">Kaki lengkung terbuka: &ldquo;Open&rdquo;</h3><p class="small" style="margin:0;color:var(--ink)">Tidak ada ambang yang tertutup. Siapa pun boleh masuk dan belajar. Kakinya menancap, tanda bahwa ilmu berpijak pada tradisi.</p></div></div></div></div>''', "white", title="Filosofi Logo")

# ---------- 16 Versi logo ----------
def tile(inner, bg, h=62, fg="var(--ink)", border=""):
    return f'<div class="tile" style="height:{h}mm;background:{bg};color:{fg};{border}">{inner}</div>'
pg(f'''{sec("05","Versi Logo")}<h2>Empat bentuk, satu simbol.</h2>
<div class="grid4" style="margin-top:4mm">
<div>{tile('<div style="width:34mm;height:34mm;background:#F6F6F3;border-radius:8mm;display:flex;align-items:center;justify-content:center;box-shadow:0 0 0 .3mm #ddd">'+logo(17,"#100F0E")+'</div>',"#fff",border="border:.3mm solid var(--g3)")}<div class="cap"><b>Ikon aplikasi</b><br>Simbol di kotak membulat. Ikon perangkat, toko aplikasi, avatar.</div></div>
<div>{tile(logo(24),"#fff",border="border:.3mm solid var(--g3)")}<div class="cap"><b>Simbol</b><br>Tanpa kotak. Watermark, sudut kartu, ruang sempit.</div></div>
<div>{tile(lockup(17),"#fff",border="border:.3mm solid var(--g3)")}<div class="cap"><b>Horizontal</b><br>Simbol di kiri, nama di kanan. Header website, surat, tanda tangan surel.</div></div>
<div>{tile(lockup(26,vertical=True),"#fff",border="border:.3mm solid var(--g3)")}<div class="cap"><b>Vertikal</b><br>Simbol di atas, nama di bawah. Sampul, poster, slide judul.</div></div></div>
<p class="small" style="margin-top:6mm">Nama pada gabungan logo memakai huruf Outfit 600. Tinggi huruf besar sekitar sepertiga tinggi simbol, jarak ke simbol sekitar seperlima tinggi simbol.</p>''', title="Versi Logo")

# ---------- 17 Ruang aman ----------
pg(f'''<div class="row" style="gap:14mm;align-items:center;height:100%"><div style="width:125mm;display:flex;justify-content:center">
<div style="position:relative;padding:14mm;border:.35mm dashed #777;background:repeating-linear-gradient(45deg,#fff 0 2mm,#f1f1ee 2mm 4mm)">
<div style="background:#fff;padding:0">{logo(60)}</div>
<span style="position:absolute;top:2mm;left:50%;transform:translateX(-50%);font-size:8pt;background:#fff;padding:0 1.5mm">x</span><span style="position:absolute;left:3mm;top:50%;font-size:8pt;background:#fff;padding:0 1.5mm">x</span></div></div>
<div class="col">{sec("05","Ruang Aman dan Ukuran Minimum")}<h2>Beri simbol ruang untuk bernapas.</h2>
<p><b>Ruang aman:</b> kosongkan di sekeliling simbol sejarak <b>x</b>, yaitu seperlima lebar simbol. Tidak boleh ada teks, tepi halaman, atau gambar lain di dalamnya.</p>
<table style="margin-top:4mm"><tr><th>Bentuk</th><th>Layar</th><th>Cetak</th></tr>
<tr><td>Simbol</td><td>16 px</td><td>6 mm</td></tr>
<tr><td>Gabungan horizontal</td><td>24 px (tinggi simbol)</td><td>8 mm</td></tr>
<tr><td>Gabungan vertikal</td><td>32 px (tinggi simbol)</td><td>12 mm</td></tr></table>
<p class="small" style="margin-top:4mm">Di bawah 24 px, pakai simbol tanpa kotak. Pada ikon aplikasi, biarkan platform memotong sudut sesuai aturannya.</p></div></div>''', "white", title="Ruang Aman")

# ---------- 18 Warna logo ----------
pg(f'''{sec("05","Warna Logo")}<h2>Satu warna, selalu kontras.</h2>
<div class="grid4" style="margin-top:4mm">
<div>{tile(logo(26,"#100F0E"),"#F6F6F3",h=56,border="border:.3mm solid var(--g3)")}<div class="cap"><b>Utama</b><br>Tinta <code>#100F0E</code> di atas Kertas <code>#F6F6F3</code> atau putih.</div></div>
<div>{tile(logo(26,"#FAFAFA"),"#09090B",h=56)}<div class="cap"><b>Gelap</b><br>Putih Tulang <code>#FAFAFA</code> di atas Obsidian <code>#09090B</code>.</div></div>
<div>{tile(logo(26,"#FAFAFA"),"#27272A",h=56)}<div class="cap"><b>Abu gelap</b><br>Putih Tulang di atas Batu <code>#27272A</code>.</div></div>
<div>{tile(logo(26,"#000"),"#fff",h=56,border="border:.3mm solid var(--g3)")}<div class="cap"><b>Cetak satu warna</b><br>Hitam 100% di atas putih untuk cetak, stempel, dan faks.</div></div></div>
<div class="card" style="margin-top:6mm;padding:4mm 6mm"><p style="margin:0;max-width:none"><b>Tidak ada versi berwarna.</b> Di atas foto atau latar ramai, pakai putih atau hitam penuh yang paling kontras, dengan lapisan peredam di bawahnya. Kontras Tinta di atas Kertas: <b>{contrast("#100F0E","#F6F6F3"):.1f} : 1</b>. Putih Tulang di atas Obsidian: <b>{contrast("#FAFAFA","#09090B"):.1f} : 1</b>.</p></div>''', title="Warna Logo")

# ---------- 19 Pelanggaran ----------
bad = [("Jangan diregangkan", "transform:scaleX(1.5)"),
       ("Jangan diberi warna", "filter:invert(32%) sepia(95%) saturate(3000%) hue-rotate(205deg)"),
       ("Jangan dimiringkan", "transform:rotate(-14deg)"),
       ("Jangan diberi bayangan atau cahaya", "filter:drop-shadow(1.5mm 1.5mm 1mm rgba(0,0,0,.45))"),
       ("Jangan diberi garis tepi", "filter:drop-shadow(0 0 0 #000) drop-shadow(.8mm 0 0 #888) drop-shadow(-.8mm 0 0 #888)"),
       ("Jangan dipakai di atas latar ramai", "opacity:1"),
       ("Jangan digambar ulang atau dipisah", "clip-path:inset(0 0 0 50%)"),
       ("Jangan dipakai dua kali pada satu layar", "")]
def badtile(t, st, i):
    if i == 5:
        inner = '<div style="position:absolute;inset:0;background:repeating-linear-gradient(60deg,#999 0 3mm,#444 3mm 6mm,#bbb 6mm 9mm)"></div>' + f'<div style="position:relative">{logo(18,"#100F0E")}</div>'
    elif i == 7:
        inner = f'<div style="display:flex;gap:6mm">{logo(14)}{logo(14)}</div>'
    elif i == 6:
        inner = f'<div style="display:flex;gap:2mm">{logo(18,"var(--ink)","clip-path:inset(0 50% 0 0);")}{logo(18,"var(--ink)","clip-path:inset(0 0 0 50%);transform:translateY(5mm)")}</div>'
    else:
        inner = logo(18, "var(--ink)", st)
    return f'<div><div class="tile cross" style="height:40mm;background:#fff;border:.3mm solid var(--g3)">{inner}</div><div class="cap">{t}</div></div>'
pg(f'''{sec("05","Penggunaan yang Keliru")}<h2>Delapan hal yang tidak boleh dilakukan.</h2>
<div class="grid4" style="margin-top:3mm;row-gap:3mm">{"".join(badtile(t,s,i) for i,(t,s) in enumerate(bad))}</div>''', title="Penggunaan Keliru")

# ---------- 20 Warna: palet ----------
def sw(name, hexv, role, fg="#fff", ln=""):
    return f'<div class="sw" style="background:{hexv};color:{fg}"><b>{name}</b><span>{hexv}<br>{role}</span></div>'
pg(f'''{sec("06","Warna")}<h2>Monokrom, seperti tinta di atas kertas.</h2>
<p class="lead" style="font-size:13pt;max-width:210mm">Tidak ada oranye, kuning, emas, biru, atau gradien. Kedalaman dibangun dari kontras terang dan gelap, garis halus, dan ruang kosong.</p>
<div class="small" style="margin:5mm 0 2mm;letter-spacing:.14em;text-transform:uppercase;font-weight:600">Warna merek</div>
<div class="grid4" style="grid-template-columns:repeat(6,1fr);gap:3mm">
{sw("Tinta","#100F0E","Logo, teks utama","#FAFAFA")}{sw("Kertas","#F6F6F3","Latar ikon, halaman cetak","#100F0E")}{sw("Obsidian","#09090B","Latar gelap utama","#FAFAFA")}{sw("Arang","#18181B","Kartu pada latar gelap","#FAFAFA")}{sw("Batu","#27272A","Garis dan permukaan gelap","#FAFAFA")}{sw("Tulang","#FAFAFA","Teks pada latar gelap","#100F0E")}</div>
<div class="small" style="margin:5mm 0 2mm;letter-spacing:.14em;text-transform:uppercase;font-weight:600">Abu-abu antarmuka</div>
<div class="grid4" style="grid-template-columns:repeat(6,1fr);gap:3mm">
{sw("Abu 1","#606060","Teks sekunder","#fff")}{sw("Abu 2","#767676","Garis tegas","#fff")}{sw("Abu 3","#DADADA","Garis kartu","#100F0E")}{sw("Abu 4","#EDEDED","Permukaan tonal","#100F0E")}{sw("Abu 5","#F6F6F6","Kanvas aplikasi terang","#100F0E")}{sw("Putih","#FFFFFF","Kartu dan panel","#100F0E")}</div>''', title="Warna")

# ---------- 21 Warna: pemakaian ----------
pairs = [("Teks utama di kanvas terang","#171717","#F6F6F6"),("Teks sekunder di kanvas terang","#606060","#F6F6F6"),
         ("Teks utama di kanvas gelap","#F5F5F5","#151515"),("Teks sekunder di kanvas gelap","#B8B8B8","#151515"),
         ("Tulang di atas Obsidian","#FAFAFA","#09090B")]
rows = "".join(f'<tr><td>{a}</td><td><span style="display:inline-block;width:5mm;height:5mm;background:{f};border:.2mm solid #888;vertical-align:middle;margin-right:2mm"></span>{f}</td><td><span style="display:inline-block;width:5mm;height:5mm;background:{b};border:.2mm solid #888;vertical-align:middle;margin-right:2mm"></span>{b}</td><td><b>{contrast(f,b):.1f} : 1</b></td></tr>' for a,f,b in pairs)
pg(f'''{sec("06","Pemakaian Warna")}<div class="row" style="gap:12mm"><div class="col"><h2>Dua suasana, satu bahasa.</h2>
<div class="row" style="gap:4mm;margin-bottom:5mm">
<div class="tile" style="background:#F6F6F6;height:50mm;flex:1;flex-direction:column;align-items:flex-start;justify-content:flex-start;padding:5mm;border:.3mm solid #ddd"><b style="font-size:8pt;letter-spacing:.14em">TERANG</b><div style="background:#fff;border:.3mm solid #DADADA;border-radius:3mm;padding:3mm;margin-top:4mm;width:100%"><b style="font-size:10pt;color:#171717">Fikih Syafi'i</b><div style="font-size:8pt;color:#606060">Asisten bidang</div></div></div>
<div class="tile" style="background:#151515;height:50mm;flex:1;flex-direction:column;align-items:flex-start;justify-content:flex-start;padding:5mm"><b style="font-size:8pt;letter-spacing:.14em;color:#F5F5F5">GELAP</b><div style="background:#292929;border:.3mm solid #454545;border-radius:3mm;padding:3mm;margin-top:4mm;width:100%"><b style="font-size:10pt;color:#F5F5F5">Fikih Syafi'i</b><div style="font-size:8pt;color:#B8B8B8">Asisten bidang</div></div></div></div>
<p>Mode terang seperti kertas kitab yang hangat; mode gelap seperti belajar malam yang tidak menyilaukan. Warna Arab dan Latin selalu sama dalam satu layar.</p>
<p class="small">Proporsi: sekitar 70% kanvas, 20% permukaan dan teks, 10% garis dan penekanan.</p></div>
<div class="col"><h3>Kontras terukur (WCAG)</h3><table><tr><th>Pasangan</th><th>Depan</th><th>Latar</th><th>Rasio</th></tr>{rows}</table>
<p class="small" style="margin-top:3mm">Teks biasa butuh minimal 4,5 : 1, teks besar 3 : 1. Semua pasangan di atas lolos.</p></div></div>''', title="Pemakaian Warna")

# ---------- 22 Huruf ----------
def fam(name, css, use, sample):
    return f'<div class="card"><div class="small">{use}</div><div style="{css};font-size:46pt;line-height:1.1;margin:2mm 0">{sample}</div><b>{name}</b></div>'
pg(f'''{sec("07","Huruf")}<h2>Empat keluarga huruf, masing-masing satu tugas.</h2>
<div class="grid2" style="margin-top:3mm">
{fam("Outfit","font-family:'OT Outfit';font-weight:600","Antarmuka, tombol, label, nama merek","Aa Rr")}
{fam("Newsreader","font-family:'OT Newsreader'","Judul editorial dan bacaan Latin panjang","Aa Rr")}
<div class="card"><div class="small">Teks kitab berbahasa Arab</div><div class="ar" style="font-size:40pt;line-height:1.5;margin:2mm 0">بِسْمِ اللَّهِ</div><b>Scheherazade New</b></div>
<div class="card"><div class="small">Antarmuka berbahasa Arab saja</div><div class="ar" style="font-family:'OT Cairo';font-weight:700;font-size:34pt;line-height:1.6;margin:2mm 0">أوبن تراث</div><b>Cairo</b> 400 / 600 / 700</div></div>''', title="Huruf")

# ---------- 23 Hierarki huruf ----------
pg(f'''{sec("07","Hierarki")}<div class="row" style="gap:14mm"><div class="col" style="flex:1.2">
<div style="font-family:'OT Newsreader';font-size:30pt;line-height:1.1;margin-bottom:2mm">Judul besar, Newsreader</div>
<div style="font-family:'OT Newsreader';font-size:18pt;margin-bottom:2mm">Judul bagian, Newsreader 18</div>
<div style="font-size:9pt;letter-spacing:.14em;text-transform:uppercase;font-weight:600;color:var(--g2);margin-bottom:2mm">Label kategori, Outfit 11 kapital</div>
<div style="font-size:11pt;margin-bottom:2mm;max-width:130mm">Teks antarmuka dan bacaan ringkas memakai Outfit 14 dengan jarak baris 1,5. Kalimat dibuat pendek dan satu gagasan per kalimat.</div>
<div style="font-size:8.5pt;color:var(--g2);margin-bottom:5mm">Keterangan dan metadata, Outfit 12</div>
<div class="ar" style="font-size:22pt;line-height:1.9;margin-bottom:2mm">وَالْعِلْمُ يَرْفَعُ بَيْتًا لَا عِمَادَ لَهُ</div></div>
<div class="col"><div class="card"><h3>Aturan</h3><table>
<tr><td>Arab kitab</td><td>Selalu Scheherazade New, tidak pernah huruf antarmuka.</td></tr>
<tr><td>Jarak baris Arab</td><td>Longgar, minimal 1,8.</td></tr>
<tr><td>Rata teks</td><td>Latin kiri; Arab kanan. Jangan dicampur dalam satu baris tanpa pembatas.</td></tr>
<tr><td>Kapital semua</td><td>Hanya label pendek dengan jarak huruf lebar.</td></tr>
<tr><td>Cetak miring</td><td>Istilah asing dan tagline.</td></tr>
<tr><td>Harakat</td><td>Dipertahankan bila sumbernya berharakat.</td></tr></table></div></div></div>''', title="Hierarki")

# ---------- 24 Suara ----------
pg(f'''{sec("08","Suara")}<h2>Cara OpenTurath berbicara.</h2>
<div class="grid4" style="margin-top:4mm">
<div class="card"><h3>Tenang</h3><p class="small" style="color:var(--ink);margin:0">Kalimat pendek dan lapang. Tidak ada tanda seru berlebihan, tidak ada desakan.</p></div>
<div class="card"><h3>Teliti</h3><p class="small" style="color:var(--ink);margin:0">Menyebut sumber, menjaga istilah, dan konsisten dalam ejaan.</p></div>
<div class="card"><h3>Rendah hati</h3><p class="small" style="color:var(--ink);margin:0">Berkata &ldquo;mari kita lihat kitabnya&rdquo;, bukan &ldquo;pokoknya begini&rdquo;.</p></div>
<div class="card"><h3>Hangat</h3><p class="small" style="color:var(--ink);margin:0">Menyapa seperti teman belajar yang sabar, bukan layanan pelanggan yang kaku.</p></div></div>
<div class="grid2" style="margin-top:6mm"><div class="card"><span class="yes">Kami menulis seperti ini</span><p class="serif" style="font-size:13pt;margin:0;max-width:none">&ldquo;Berikut pembahasan yang kami temukan. Buka kitabnya untuk membaca konteks lengkapnya.&rdquo;</p></div>
<div class="card"><span class="no">Kami tidak menulis seperti ini</span><p class="serif" style="font-size:13pt;margin:0;max-width:none;color:var(--g2)">&ldquo;Ini dia jawabannya! Pasti benar dan terpercaya 100%!&rdquo;</p></div></div>''', title="Suara")

# ---------- 25 Nada menurut situasi + kosakata ----------
pg(f'''{sec("08","Nada dan Kosakata")}<div class="row" style="gap:10mm"><div class="col" style="flex:1.1"><h3>Nada menurut situasi</h3><table>
<tr><th>Situasi</th><th>Contoh</th></tr>
<tr><td>Selamat datang</td><td>Pilih bidang yang ingin dipelajari.</td></tr>
<tr><td>Rujukan belum ketemu</td><td>Kami belum menemukan rujukan yang jelas. Coba ubah kata kunci, atau tanyakan kepada guru Anda.</td></tr>
<tr><td>Galat</td><td>Percakapan belum bisa dibuka. Periksa koneksi, lalu coba lagi.</td></tr>
<tr><td>Akses berakhir</td><td>Masa akses modul ini telah berakhir. Anda dapat memperpanjang kapan saja.</td></tr>
<tr><td>Berhasil</td><td>Tersimpan di Catatan.</td></tr></table>
<p class="small" style="margin-top:3mm">Tanpa emoji dan tanpa tanda seru beruntun di antarmuka dan materi resmi.</p></div>
<div class="col"><h3>Kosakata</h3><table><tr><th>Pakai</th><th>Hindari</th></tr>
<tr><td>menelusuri, mencari rujukan</td><td>memutuskan hukum, mengeluarkan fatwa</td></tr>
<tr><td>tanya jawab, percakapan</td><td>telaah (untuk fitur obrolan)</td></tr>
<tr><td>perlu diperiksa pada kitabnya</td><td>dijamin benar, akurat 100%</td></tr>
<tr><td>asisten bidang</td><td>ustaz AI, ulama digital</td></tr>
<tr><td>dirintis oleh pelajar</td><td>didukung para pakar (tanpa bukti tertulis)</td></tr>
<tr><td>Anda</td><td>kamu, lo, gue</td></tr></table></div></div>''', title="Nada dan Kosakata")

# ---------- 26 Menulis ----------
pg(f'''{sec("08","Menulis dengan Rapi")}<div class="row" style="gap:12mm"><div class="col"><h2>Ejaan dan istilah.</h2>
<table><tr><th>Tulis</th><th>Bukan</th></tr>
<tr><td>Syafi'i</td><td>Syafii, Shafi'i</td></tr><tr><td>fikih</td><td>fiqh, fiqih</td></tr><tr><td>hadis</td><td>hadits</td></tr>
<tr><td>Al-Qur'an</td><td>Alquran, Quran</td></tr><tr><td>ibarah</td><td>ibaroh</td></tr><tr><td>turath</td><td>turats, turost</td></tr>
<tr><td>Fikih Tahawwulat</td><td>Fiqh Tahawulat</td></tr></table>
<p class="small" style="margin-top:3mm">Satu ejaan di seluruh materi. Istilah Arab diberi penjelasan singkat pada kemunculan pertama.</p></div>
<div class="col"><h2>Pernyataan baku.</h2>
<div class="card" style="margin-bottom:4mm"><div class="small">Catatan pada jawaban AI</div><p class="serif" style="font-size:12pt;margin:1mm 0 0;max-width:none">Jawaban AI dapat keliru atau kurang lengkap. Periksa kutipan pada kitab yang dirujuk dan bacalah bersama konteksnya. Untuk amal dan fatwa, tanyakan kepada guru atau ulama yang berkompeten.</p></div>
<div class="card"><div class="small">Hubungan dengan Google</div><p class="serif" style="font-size:12pt;margin:1mm 0 0;max-width:none">Percakapan AI pada OpenTurath menggunakan NotebookLM dari Google. OpenTurath adalah layanan mandiri dan tidak berafiliasi dengan, didukung oleh, atau disahkan oleh Google.</p></div></div></div>''', title="Menulis")

# ---------- 27 Citra ----------
arch = lambda w,h,extra="": f'<div class="arch" style="width:{w}mm;height:{h}mm;{extra}"></div>'
pg(f'''{sec("09","Citra")}<h2>Lengkung, garis halus, dan ruang kosong.</h2>
<div class="grid4" style="margin-top:4mm">
<div><div class="tile" style="height:56mm;background:#fff;border:.3mm solid var(--g3);align-items:flex-end">{arch(34,44)}</div><div class="cap"><b>Motif lengkung</b><br>Bingkai kartu kitab dan penanda bab, dipakai hemat. Bukan pola latar yang ramai.</div></div>
<div><div class="tile" style="height:56mm;background:#fff;border:.3mm solid var(--g3);flex-direction:column;gap:2.5mm;padding:8mm"><div style="width:100%;height:.3mm;background:#100F0E"></div><div style="width:100%;height:.3mm;background:#DADADA"></div><div style="width:100%;height:.3mm;background:#DADADA"></div><div style="width:60%;height:.3mm;background:#DADADA;align-self:flex-start"></div></div><div class="cap"><b>Garis halus</b><br>Garis 0,5 sampai 1 px menggantikan bayangan tebal.</div></div>
<div><div class="tile" style="height:56mm;background:#151515;border:.3mm solid var(--g3)"><div style="width:30mm;height:38mm;border:.35mm solid #F5F5F5;border-radius:50% 50% 0 0/20% 20% 0 0;display:flex;align-items:center;justify-content:center">{logo(14,"#F5F5F5")}</div></div><div class="cap"><b>Ilustrasi</b><br>Garis monokrom sederhana: buku, lengkung, lampu baca, rak kitab. Tanpa tokoh kartun dan tanpa efek 3D.</div></div>
<div><div class="tile" style="height:56mm;background:#fff;border:.3mm solid var(--g3);flex-direction:column;gap:3mm"><div style="display:flex;gap:4mm"><div style="width:9mm;height:9mm;border:.4mm solid #100F0E;border-radius:2mm"></div><div style="width:9mm;height:9mm;border:.4mm solid #100F0E;border-radius:50%"></div><div style="width:9mm;height:9mm;border:.4mm solid #100F0E;border-radius:2mm 2mm 50% 50%"></div></div><div class="small">Ikon garis, ujung bulat</div></div><div class="cap"><b>Ikon</b><br>Garis seragam, satu warna, sudut dan ujung membulat seirama.</div></div></div>
<div class="grid2" style="margin-top:5mm"><div class="card" style="padding:4mm 6mm"><b>Foto</b><p class="small" style="margin:1mm 0 0;color:var(--ink)">Dipakai jarang. Hitam putih atau netral, cahaya alami, tanpa filter dramatis. Subjek: kitab, tangan yang membaca, ruang belajar. Tidak memuat wajah tokoh tanpa izin tertulis.</p></div>
<div class="card" style="padding:4mm 6mm"><b>Gerak</b><p class="small" style="margin:1mm 0 0;color:var(--ink)">Pendek, halus, dan fungsional: pudar masuk dan geser kecil. Tanpa partikel, kilau, atau efek cahaya. Video memakai simbol apa adanya.</p></div></div>''', title="Citra")

# ---------- 28 Tata letak ----------
pg(f'''{sec("10","Tata Letak dan Komponen")}<div class="row" style="gap:10mm"><div class="col"><h2>Ritme jarak dan sudut.</h2>
<table><tr><th>Token</th><th>Nilai</th><th>Kegunaan</th></tr>
<tr><td>Jarak</td><td>kelipatan 4 px</td><td>4, 8, 12, 16, 24, 32</td></tr>
<tr><td>Sudut kartu</td><td>16 px</td><td>Kartu, panel, dialog</td></tr>
<tr><td>Sudut tombol</td><td>12 px</td><td>Tombol dan kolom isian</td></tr>
<tr><td>Garis</td><td>0,5 sampai 1 px</td><td>Batas kartu dan pemisah</td></tr>
<tr><td>Bayangan</td><td>tidak ada</td><td>Kedalaman lewat garis dan tonal</td></tr>
<tr><td>Kolom baca</td><td>maks. 720 px</td><td>Percakapan dan teks panjang</td></tr></table>
<p class="small" style="margin-top:3mm">Nilai persis berada di <code>OPENTURATH_DESIGN_SYSTEM.md</code> dan <code>openturath_ai/docs/design-system.json</code>.</p></div>
<div class="col"><h3>Komponen</h3>
<div style="display:flex;gap:3mm;margin-bottom:4mm"><div style="background:#171717;color:#fff;border-radius:3mm;padding:3mm 6mm;font-size:9.5pt;font-weight:600">Tombol utama</div><div style="border:.35mm solid #767676;border-radius:3mm;padding:3mm 6mm;font-size:9.5pt;font-weight:600;background:#fff">Tombol garis</div><div style="background:#EDEDED;border-radius:3mm;padding:3mm 6mm;font-size:9.5pt;font-weight:600">Sekunder</div></div>
<div style="background:#fff;border:.3mm solid #DADADA;border-radius:4mm;padding:5mm;margin-bottom:4mm"><div class="small" style="letter-spacing:.14em;text-transform:uppercase;font-weight:600">Asisten bidang</div><div class="serif" style="font-size:15pt;margin:1mm 0">Fikih Syafi'i</div><div class="small">Telusuri pembahasan dan rujukan dalam kitab mazhab Syafi'i.</div></div>
<div style="background:#fff;border:.35mm solid #767676;border-radius:3mm;padding:3mm 4mm;font-size:9.5pt;color:#6B6B6B">Tanyakan sesuatu tentang kitab...</div></div></div>''', title="Tata Letak")

# ---------- 29 Penerapan: aplikasi ----------
def phone(inner, bg="#F6F6F6"):
    return f'<div style="width:50mm;height:104mm;border-radius:8mm;border:1.2mm solid #100F0E;background:{bg};padding:5mm 4mm;overflow:hidden;position:relative">{inner}</div>'
scr1 = f'<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;gap:4mm;text-align:center">{logo(16)}<div class="wm" style="font-size:13pt">OpenTurath</div><div style="font-size:6.5pt;color:#606060;font-style:italic">Membaca kitab, menelusuri ibarah.</div><div style="background:#171717;color:#fff;border-radius:3mm;padding:2.5mm 0;width:100%;font-size:7pt;font-weight:600;margin-top:4mm">Masuk dengan Google</div></div>'
scr2 = '<div style="font-size:6pt;letter-spacing:.14em;text-transform:uppercase;color:#606060;font-weight:600">Beranda</div><div class="serif" style="font-size:12pt;margin:1mm 0 3mm">Pilih bidang</div>' + "".join(f'<div style="background:#fff;border:.25mm solid #DADADA;border-radius:2.5mm;padding:2.5mm;margin-bottom:2mm"><div style="font-size:7.5pt;font-weight:600">{t}</div><div style="font-size:5.5pt;color:#606060">{d}</div></div>' for t,d in [("Fikih Syafi'i","Mazhab Imam Asy-Syafi'i"),("Hadis","Kitab induk hadis"),("Tafsir","Eksegesis Al-Qur'an"),("Fikih Tahawwulat","Lima cabang khusus")])
scr3 = '<div style="font-size:7pt;font-weight:600;margin-bottom:3mm">Fikih Syafi\'i</div><div style="background:#EDEDED;border-radius:2.5mm;padding:2.5mm;font-size:6pt;margin-bottom:2mm">Apa syarat sah wudhu?</div><div style="background:#fff;border:.25mm solid #DADADA;border-radius:2.5mm;padding:2.5mm;font-size:6pt;line-height:1.5">Pembahasan ditemukan pada bab thaharah.<div class="ar" style="font-size:9pt;margin-top:1.5mm">فُرُوضُ الْوُضُوءِ سِتَّةٌ</div><div style="color:#606060;margin-top:1.5mm">Buka kitab untuk membaca konteksnya.</div></div>'
pg(f'''{sec("11","Penerapan: Aplikasi")}<div class="row" style="gap:12mm;align-items:center"><div style="width:80mm"><h2>Aplikasi OpenTurath AI</h2><p>Satu logo per layar. Latar kanvas tenang, kartu putih bergaris halus, satu tombol utama berwarna Tinta.</p><p class="small">Ikon aplikasi memakai versi kotak membulat. Nama di toko aplikasi: <b>OpenTurath AI</b>.</p></div>
<div class="row" style="gap:8mm">{phone(scr1)}{phone(scr2)}{phone(scr3)}</div></div>''', title="Aplikasi")

# ---------- 30 Penerapan: website & sosial ----------
site = f'''<div style="width:150mm;border:.4mm solid #100F0E;border-radius:3mm;overflow:hidden;background:#F6F6F6"><div style="background:#fff;border-bottom:.3mm solid #DADADA;padding:3mm 5mm;display:flex;justify-content:space-between;align-items:center">{lockup(7)}<div style="font-size:7pt;display:flex;gap:5mm;color:#606060"><span>Asisten</span><span>Kitab rujukan</span><span>Harga</span><span style="background:#171717;color:#fff;border-radius:2mm;padding:1mm 3mm">Masuk</span></div></div>
<div style="padding:12mm 10mm 10mm"><div class="serif" style="font-size:25pt;line-height:1.05">Telusuri kitab.<br>Pelajari pembahasannya.</div><p style="font-size:8pt;color:#606060;margin:4mm 0;max-width:90mm">OpenTurath membantu Anda mencari kutipan, membandingkan keterangan dalam kitab, dan menyimpan rujukan untuk dipelajari kembali.</p><div style="display:flex;gap:3mm"><span style="background:#171717;color:#fff;border-radius:2.5mm;padding:2mm 5mm;font-size:8pt;font-weight:600">Jelajahi asisten</span><span style="border:.3mm solid #767676;border-radius:2.5mm;padding:2mm 5mm;font-size:8pt;font-weight:600;background:#fff">Lihat kitab rujukan</span></div></div></div>'''
post = f'<div style="width:50mm;height:62mm;background:#09090B;color:#FAFAFA;border-radius:2mm;padding:6mm;display:flex;flex-direction:column;justify-content:space-between"><div>{logo(8,"#FAFAFA")}</div><div class="serif" style="font-size:14pt;line-height:1.15">Jawaban adalah pintu masuk, bukan kata akhir.</div><div style="font-size:5.5pt;letter-spacing:.14em;color:#999">OPENTURATH.ID</div></div>'
avatar = f'<div style="width:24mm;height:24mm;border-radius:50%;background:#F6F6F3;display:flex;align-items:center;justify-content:center;border:.3mm solid #ccc">{logo(11)}</div>'
pg(f'''{sec("11","Penerapan: Website dan Media Sosial")}<div class="row" style="gap:10mm;align-items:flex-start;margin-top:3mm"><div>{site}<div class="cap">Header memakai gabungan horizontal. Judul dan deskripsi berasal dari naskah baku.</div></div>
<div><div style="display:flex;gap:6mm;align-items:flex-end">{post}<div>{avatar}<div class="cap">Avatar: ikon aplikasi</div></div></div>
<div class="card" style="margin-top:5mm;padding:4mm 5mm;width:98mm"><div class="small">Biografi (di bawah 150 karakter)</div><p style="font-size:9pt;margin:1mm 0 0">Membaca kitab, menelusuri ibarah. Pendamping belajar kitab Islam berbasis AI. openturath.id</p></div></div></div>''', title="Website dan Sosial")

# ---------- 31 Penerapan: dokumen ----------
letter = f'<div style="width:78mm;height:104mm;background:#fff;border:.3mm solid #ccc;padding:7mm;position:relative">{lockup(8)}<div style="height:.3mm;background:#100F0E;margin:3mm 0 5mm"></div><div style="font-size:5.5pt;color:#606060;margin-bottom:3mm">22 Oktober 2026 &middot; No. OT-SRT-001</div><div style="font-size:6pt;line-height:1.7;color:#333">Yth. Bapak/Ibu,<br><br>Dengan hormat, kami menyampaikan...<br><div style="height:.25mm;background:#ddd;margin:2mm 0"></div><div style="height:.25mm;background:#ddd;margin:2mm 0"></div><div style="height:.25mm;background:#ddd;margin:2mm 0;width:70%"></div></div><div style="position:absolute;bottom:5mm;left:7mm;right:7mm;font-size:5pt;color:#606060;border-top:.25mm solid #ddd;padding-top:2mm;display:flex;justify-content:space-between"><span>openturath.id</span><span>Halaman 1</span></div></div>'
slide = f'<div style="width:96mm;height:54mm;background:#09090B;color:#FAFAFA;border-radius:1.5mm;padding:7mm;position:relative"><div style="position:absolute;top:6mm;right:7mm">{logo(7,"#FAFAFA")}</div><div class="kick" style="font-size:5.5pt;color:#999;margin-bottom:3mm">BAB 01</div><div class="serif" style="font-size:17pt;line-height:1.1;max-width:60mm">Mengapa belajar kitab terasa berat?</div></div>'
slide2 = f'<div style="width:96mm;height:54mm;background:#F6F6F3;border-radius:1.5mm;padding:7mm;border:.3mm solid #ccc"><div class="serif" style="font-size:12pt;margin-bottom:3mm">Tiga langkah memulai</div><div style="display:flex;gap:3mm">' + "".join(f'<div style="flex:1;background:#fff;border:.25mm solid #DADADA;border-radius:2mm;padding:3mm"><div class="num" style="font-size:12pt">{i}</div><div style="font-size:6pt">{t}</div></div>' for i,t in [(1,"Pilih bidang ilmu"),(2,"Ajukan pertanyaan"),(3,"Buka kitab rujukan")]) + '</div></div>'
pg(f'''{sec("11","Penerapan: Dokumen dan Presentasi")}<div class="row" style="gap:12mm;align-items:flex-start"><div>{letter}<div class="cap">Kop surat: gabungan horizontal, garis tipis, tanpa warna.</div></div>
<div><div style="display:flex;flex-direction:column;gap:5mm">{slide}{slide2}</div><div class="cap">Slide: judul Newsreader, latar Obsidian atau Kertas, logo di sudut.</div></div>
<div class="col"><div class="card"><h3>Penomoran dokumen</h3><p class="small" style="color:var(--ink)">Format <code>OT-JENIS-NNN</code>, contoh <code>OT-ID-001</code> untuk buku ini dan <code>OT-SRT-001</code> untuk surat.</p><h3 style="margin-top:4mm">Tanda tangan surel</h3><p class="small" style="color:var(--ink);margin:0">Nama, jabatan<br><b>OpenTurath</b><br>openturath.id</p></div></div></div>''', title="Dokumen")

# ---------- 32 Penggunaan bersama ----------
pg(f'''{sec("12","Penggunaan Bersama")}<div class="row" style="gap:10mm"><div class="col"><h2>Bagi pihak di luar OpenTurath.</h2>
<div class="card" style="margin-bottom:4mm"><span class="yes">Boleh tanpa izin</span><p style="font-size:9.5pt;margin:0">Menyebut nama OpenTurath secara wajar dalam berita, ulasan, dan tulisan. Menampilkan logo apa adanya untuk mengarahkan pembaca ke OpenTurath.</p></div>
<div class="card"><span class="no" style="color:var(--ink)">Perlu izin tertulis</span><p style="font-size:9.5pt;margin:0">Memakai nama atau logo pada produk atau layanan lain; menyiratkan kemitraan atau dukungan; membuat turunan logo, akun, atau domain yang tampak resmi; memakai logo untuk kegiatan komersial atau penggalangan dana.</p></div></div>
<div class="col"><h2>Tata kelola.</h2><table>
<tr><td style="width:34mm"><b>Pemilik buku</b></td><td>Pemilik OpenTurath. Hanya Pemilik yang mengubah isi buku ini.</td></tr>
<tr><td><b>Versi</b></td><td>1.0, Oktober 2026</td></tr>
<tr><td><b>Perubahan</b></td><td>Kecil (typo): 1.0.x. Isi: 1.x. Logo, nama, atau nilai: versi mayor.</td></tr>
<tr><td><b>Berkas</b></td><td>Aset logo ada di folder <code>aset_logo</code>. Buku ini dibangun dari <code>sumber_buku/build_buku.py</code>.</td></tr>
<tr><td><b>Pertanyaan</b></td><td>Sebelum menerbitkan materi yang tidak diatur di sini, minta tinjauan Pemilik.</td></tr></table></div></div>''', title="Penggunaan Bersama")

# ---------- 33 Penutup ----------
pg(f'''<div style="height:100%;display:flex;flex-direction:column;justify-content:center;align-items:center;text-align:center;gap:10mm">{logo(26,"var(--bone)")}
<div class="serif" style="font-size:21pt;line-height:1.5;max-width:190mm;font-style:italic">Kami percaya kitab adalah warisan yang harus tetap bisa dibuka oleh siapa pun yang ingin belajar. Kami membantu menemukan, bukan memutuskan. Kami menunjukkan rujukan, dan mengajak Anda memeriksanya. Kami belajar bersama guru, dan alat ini menemani di antara majelis.</div>
<div style="font-size:8pt;letter-spacing:.2em;color:#9a9a9a">OPENTURATH &middot; MEMBACA KITAB, MENELUSURI IBARAH &middot; OPENTURATH.ID</div></div>''', "dark", foot=False)

# ---------- rakit ----------
css = (HERE / "style.css").read_text().replace("FONTDIR", FONTDIR.as_posix())
html = f'<!doctype html><html lang="id"><head><meta charset="utf-8"><title>OpenTurath: Buku Identitas</title><style>{css}</style></head><body>{SYMBOL}{"".join(pages)}</body></html>'
out_html = HERE / "buku.html"; out_html.write_text(html, encoding="utf-8")
pdf = HERE.parent / "OpenTurath_Buku_Identitas.pdf"
chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
subprocess.run([chrome, "--headless", "--disable-gpu", "--no-pdf-header-footer", "--allow-file-access-from-files",
                f"--print-to-pdf={pdf}", f"file://{out_html}"], check=True, capture_output=True)
print("halaman:", len(pages), "->", pdf)
