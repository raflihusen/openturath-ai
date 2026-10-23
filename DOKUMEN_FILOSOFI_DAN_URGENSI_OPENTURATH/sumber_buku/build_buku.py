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
<div style="display:flex;justify-content:space-between;font-size:8pt;letter-spacing:.2em;text-transform:uppercase;color:#9a9a9a"><span>Buku Identitas</span><span>Versi 1.3 &middot; 23 Oktober 2026</span></div>
<div style="display:flex;align-items:center;gap:22mm">{logo(62,"var(--bone)")}
<div><h1 style="font-size:64pt;margin:0 0 4mm">OpenTurath</h1>
<div class="lead" style="color:#cfcfcf;font-style:italic">Menjaga asal, membuka cakrawala.</div><div class="ar" style="font-size:17pt;color:#9a9a9a;margin-top:3mm;text-align:left;direction:rtl">رسوخٌ في الأصول، وانفتاحٌ على الآفاق</div></div></div>
<div style="font-size:8pt;letter-spacing:.2em;text-transform:uppercase;color:#9a9a9a;display:flex;justify-content:space-between"><span>Pedoman resmi nama, logo, warna, huruf, suara, dan penerapan</span><span>openturath.id</span></div>
</div>''', "dark", foot=False)

# ---------- 2 Daftar isi ----------
toc = [("01","Pengantar","Untuk apa buku ini dan siapa yang memakainya"),
       ("02","Siapa Kami","Perintis, cerita, tonggak, ekosistem, dan untuk siapa"),
       ("03","Fondasi","Visi, misi, nilai, wasathiyyah syar'iyyah, dan posisi"),
       ("04","Nama dan Tagline","Arti, penulisan, susunan nama, dan tagline"),
       ("05","Logo","Filosofi, versi, ruang aman, dan penggunaan"),
       ("06","Warna","Palet monokrom dan cara memakainya"),
       ("07","Huruf","Empat keluarga huruf dan hierarkinya"),
       ("08","Citra","Ilustrasi, ikon, motif, dan gerak"),
       ("09","Tata Letak","Grid, jarak, sudut, dan komponen"),
       ("10","Penerapan","Aplikasi, website, media sosial, dan dokumen"),
       ("11","Penggunaan Bersama","Aturan bagi pihak lain dan tata kelola")]
rows = "".join(f'<div style="display:flex;gap:6mm;padding:2.6mm 0;border-bottom:.3mm solid var(--g3)"><span class="serif" style="width:12mm;color:var(--g2);font-size:13pt">{a}</span><span style="width:52mm;font-weight:600">{b}</span><span class="small" style="padding-top:.5mm">{c}</span></div>' for a,b,c in toc)
pg(f'''{sec("","Isi")}<h2>Daftar isi</h2><div style="max-width:200mm">{rows}</div>''', title="Isi")

# ---------- 3 Pengantar ----------
pg(f'''{sec("01","Pengantar")}<h1 style="max-width:230mm">Satu buku untuk membuat apa pun atas nama OpenTurath.</h1>
<div class="row" style="margin-top:8mm"><div class="col">
<p class="lead">Aplikasi, website, poster, video, surat, presentasi: semuanya harus terasa datang dari satu tempat yang sama.</p>
<p>Buku ini menetapkan siapa OpenTurath, bagaimana ia terlihat, dan bagaimana ia berbicara. Isinya cukup rinci agar perancang, pengembang, dan penulis dapat bekerja tanpa harus bertanya, dan cukup ringkas agar mudah dibuka kembali di tengah pekerjaan.</p></div>
<div class="col"><div class="card"><h3>Cara memakainya</h3>
<table><tr><td style="width:36mm"><b>Perancang</b></td><td>Bab 05 sampai 09: logo, warna, huruf, citra, tata letak.</td></tr>
<tr><td><b>Pengembang</b></td><td>Bab 06, 07, dan 09: token warna, huruf, jarak, sudut, komponen.</td></tr>
<tr><td><b>Penulis</b></td><td>Bab 02, 03, dan 04: cerita, nilai, nama.</td></tr>
<tr><td><b>Mitra dan media</b></td><td>Bab 02, 04, 05, dan 11: cara menyebut dan menampilkan OpenTurath.</td></tr></table></div></div></div>''', title="Pengantar")

# ---------- 4 Siapa kami ----------
pg(f'''{sec("02","Siapa Kami")}<h2 style="font-size:31pt;max-width:245mm">OpenTurath adalah AI Islami berbasis turath: setiap jawabannya berpijak pada kitab dan ceramah para ulama.</h2>
<p class="lead" style="margin-top:5mm">Kami membantu penuntut ilmu memahami kitab dan menemukan rujukan ibarahnya dengan cepat, lalu mengajak mereka kembali kepada guru.</p>
<div class="grid4" style="margin-top:9mm">
<div class="card"><div class="small">Perintis</div><h3 style="margin:1mm 0 0">Rafli Husen</h3></div>
<div class="card"><div class="small">Berkantor di</div><h3 style="margin:1mm 0 0">Bogor, Indonesia</h3></div>
<div class="card"><div class="small">Rilis publik perdana</div><h3 style="margin:1mm 0 0">23 Oktober 2026</h3></div>
<div class="card"><div class="small">Kontak</div><h3 style="margin:1mm 0 0">support@openturath.id</h3></div></div>
<div class="card" style="margin-top:6mm;display:flex;gap:8mm;align-items:center"><span class="tag">Tagline</span><span class="serif" style="font-size:20pt;font-style:italic">Menjaga asal, membuka cakrawala.</span><span class="small" style="margin-left:auto">Penjelas: AI Islami berbasis turath &middot; openturath.id</span></div>''', title="Siapa Kami")

# ---------- 5a Perintis ----------
pg(f'''{sec("02","Perintis")}<div class="row" style="gap:16mm"><div style="width:100mm"><h1 style="font-size:48pt">Rafli Husen</h1><p class="lead">Santri, mahasiswa pascasarjana di Yaman, dan satu-satunya orang di balik OpenTurath.</p></div>
<div class="col"><p>Ia berguru langsung kepada Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur rahimahullah dan para ulama Hadramaut. Sebagai santri, ia merasakan sendiri apa yang dibutuhkan para penuntut ilmu.</p>
<p>Di OpenTurath, ia adalah inisiator, pengembang, perancang, sekaligus pemasar. Ia mengerjakannya seorang diri, dengan para ulama yang memeriksa isi keilmuannya.</p>
<table style="margin-top:4mm"><tr><td style="width:36mm"><b>Pengelola</b></td><td>Perorangan: Rafli Husen</td></tr><tr><td><b>Berkantor di</b></td><td>Bogor, Indonesia</td></tr><tr><td><b>Pendidikan</b></td><td>S1 dan S2; kini menulis tugas akhir S2 di Yaman</td></tr><tr><td><b>Media sosial</b></td><td>@rafli_husen</td></tr></table></div></div>''', title="Perintis")

# ---------- 5b Cerita ----------
pg(f'''{sec("02","Cerita Kami")}<div class="row" style="gap:12mm"><div style="width:84mm"><h2>Satu halaman, satu jam, dan air mata yang nyaris jatuh.</h2><div style="margin-top:6mm">{logo(30)}</div></div>
<div class="col" style="padding-top:1mm"><p style="font-size:10.3pt">Suatu hari, saat murajaah seorang diri, Rafli membaca salah satu kitab terbesar Fikih Tahawwulat dan menerjemahkannya kata demi kata. Satu halaman menghabiskan sekitar satu jam. Setelah dibaca ulang, ia tetap belum paham, hingga hampir menangis karena sulitnya.</p>
<p style="font-size:10.3pt">Dari kesulitan itu lahir satu pertanyaan: bagaimana memudahkan penuntut ilmu menerjemahkan dan memahami kitab-kitab Fikih Tahawwulat, terutama istilah-istilahnya?</p>
<p style="font-size:10.3pt">Jawabannya ia cari lewat teknologi. Sejak 2023, ketika AI mulai ramai, ia membayangkan AI yang dapat menyebut rujukan dengan akurat dan terhubung ke maktabah. Namun AI umum sering berhalusinasi, dari ayat, kitab, hingga ibarah, padahal banyak muslim bertanya perkara agama kepadanya.</p>
<p style="font-size:10.3pt">Maka OpenTurath dibangun agar setiap jawaban punya rujukannya, dan penuntut ilmu terbantu memahami kitab tanpa kehilangan jalan menuju gurunya.</p>
<div style="display:inline-block;margin-top:5mm;border:.5mm solid var(--ink);border-radius:2.2mm;padding:2.6mm 6mm;font-weight:700;font-size:12pt;letter-spacing:.01em">Dibuat oleh pelajar, untuk para pelajar.</div></div></div>''', title="Cerita")

# ---------- 5c Tonggak ----------
def tl(d, t, x): return f'<div style="display:flex;gap:7mm;padding:5mm 0;border-bottom:.3mm solid var(--g3)"><div class="serif" style="width:42mm;font-size:15pt">{d}</div><div><b style="font-size:11pt">{t}</b><p class="small" style="color:var(--ink);margin:1mm 0 0;max-width:170mm">{x}</p></div></div>'
pg(f'''{sec("02","Tonggak")}<h2>Dari satu gagasan sampai rilis perdana.</h2><div style="max-width:235mm;margin-top:2mm">
{tl("2023","Gagasan lahir","Saat AI mulai populer, muncul pertanyaan: bagaimana jika AI dapat menyebut rujukan dengan sangat akurat dan terhubung ke maktabah?")}
{tl("2023 sampai 2026","Belajar dan membangun","Tiga tahun mempelajari AI dan cara membuat aplikasi secara mendalam, serta semua yang dibutuhkan untuk mencapai tujuan ini, termasuk menguji format RAG berulang kali hingga lebih dari sembilan revisi.")}
{tl("7 Mei 2026","Diumumkan di Hadramaut","Di Universitas Al-Wasatiyah, Hadramaut, Yaman, di hadapan para ulama, saat Rafli menerima penghargaan atas AI Fikih Tahawwulat pertama. Di sinilah visi OpenTurath dipaparkan untuk pertama kalinya.")}
{tl("23 Oktober 2026","Rilis publik perdana","OpenTurath AI dibuka untuk publik.")}</div>''', title="Tonggak")

# ---------- 5d Ekosistem ----------
ICON = lambda body, c="currentColor": f'<svg viewBox="0 0 48 48" width="26" height="26" fill="none" stroke="{c}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">{body}</svg>'
ic_book = '<rect x="7" y="10" width="9" height="28" rx="1.5"/><rect x="18" y="14" width="9" height="24" rx="1.5"/><path d="M30 38 L36 12 L44 14 L38 40 Z"/><path d="M5 43H45"/>'
ic_ms = '<path d="M13 6h20a4 4 0 0 1 4 4v14"/><path d="M13 6a4 4 0 0 0-4 4v28a4 4 0 0 0 4 4h14"/><path d="M16 15h16M16 22h16M16 29h8"/><path d="M30 42l11-11 3.5 3.5-11 11-5 1.5z"/>'
ic_cap = '<path d="M3 19 L24 8 L45 19 L24 30 Z"/><path d="M11 24v10c0 3.5 6 7 13 7s13-3.5 13-7V24"/><path d="M45 19v13"/>'
def eco(n, icon, dark, t, st, d):
    chip = f'<span class="tag" style="margin-left:auto;{"color:#cfcfcf" if dark else ""}">{st}</span>'
    box = f'width:15mm;height:15mm;border-radius:4mm;display:flex;align-items:center;justify-content:center;{"background:#FAFAFA;color:#100F0E" if dark else "background:#100F0E;color:#FAFAFA"}'
    st_card = "background:#100F0E;color:#FAFAFA;border:none" if dark else ""
    sub = "#bdbdbd" if dark else "#606060"
    return f'<div class="card" style="padding:7mm;{st_card}"><div style="display:flex;align-items:center;gap:5mm;margin-bottom:5mm"><div style="{box}">{icon}</div><div><div style="font-size:7.5pt;letter-spacing:.2em;color:{sub};font-weight:600">LINI {n}</div><h3 style="margin:0;font-size:15pt">{t}</h3></div>{chip}</div><p style="font-size:10pt;margin:0;max-width:none;color:{sub if dark else "var(--ink)"}">{d}</p></div>'
pg(f'''{sec("02","Ekosistem")}<h2>OpenTurath lebih besar dari satu aplikasi.</h2>
<p class="lead" style="font-size:13pt;margin-bottom:5mm">Satu merek, empat lini yang saling menguatkan.</p>
<div class="grid2" style="gap:5mm">
{eco("01", logo(8,"#100F0E"), True, "OpenTurath AI","Rilis 23 Okt 2026","AI Islami berbasis turath yang mencakup semua bidang ilmu dan khazanah para ulama. Tiap bidang punya asisten dan metodologinya sendiri, dan setiap jawaban disertai rujukan.")}
{eco("02", ICON(ic_book), False, "Maktabah OpenTurath","Dibangun","Pusat unduh kitab yang menyatukan semua cetakan dan banyak sumber unduh dalam satu halaman, supaya tidak lagi tercecer di berbagai tempat.")}
{eco("03", ICON(ic_ms), False, "AI Manuskrip","Tahap uji","Membantu membaca dan menahkik manuskrip: memberi makna bahasa, menjelaskan tokoh yang dimaksud, serta hadis atau ayat yang dikutip.")}
{eco("04", ICON(ic_cap), False, "Akademi OpenTurath","Rencana","Belajar memakai AI bagi penuntut ilmu dalam empat tahap: percakapan, gambar dan video untuk dakwah, membuat aplikasi, dan membuat AI agent.")}</div>''', title="Ekosistem")

# ---------- 6 Apa yang kami bangun ----------
def feat(t, d): return f'<div class="card"><h3>{t}</h3><p class="small" style="color:var(--ink);font-size:9.5pt">{d}</p></div>'
pg(f'''{sec("02","OpenTurath AI")}<h2>Satu ruang belajar, banyak bidang ilmu.</h2>
<div class="grid3" style="margin-top:6mm">
{feat("Asisten per bidang","Puluhan asisten, masing-masing berpegang pada kumpulan rujukan dan metodologi bidangnya: fikih, hadis dan syarah, tafsir, ushul fikih, akidah, tasawuf, bahasa Arab, sirah, dan lainnya.")}
{feat("Fikih Tahawwulat","Lima cabang khusus: Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, dan Al-Khatib.")}
{feat("Ibarah dan rujukan","Jawaban disertai ibarah dan arah ke kitab yang dirujuk, supaya dapat dibuka dan diperiksa.")}
{feat("Metadata kitab","Keterangan kitab dapat dilihat langsung di dalam aplikasi.")}
{feat("Catatan","Simpan jawaban dan kutipan penting, lalu kembali membacanya kapan saja.")}
{feat("Multi-tab dan waktu nyata","Buka beberapa percakapan sekaligus di desktop dan ponsel, dengan pembaruan secara langsung.")}</div>
<p class="small" style="margin-top:6mm">OpenTurath memanfaatkan teknologi Google dan merupakan layanan mandiri yang tidak berafiliasi dengan Google.</p>''', title="OpenTurath AI")

# ---------- 7 Untuk siapa ----------
def persona(t, need, help_):
    return f'<div class="card"><div class="tag" style="margin-bottom:3mm">{t}</div><p style="font-size:9.5pt"><b>Kebutuhan.</b> {need}</p><p style="font-size:9.5pt;margin:0"><b>Bantuan kami.</b> {help_}</p></div>'
pg(f'''{sec("02","Untuk Siapa")}<h2>Penuntut ilmu dalam semua tingkat.</h2>
<div class="grid2" style="margin-top:5mm">
{persona("Santri dan pemula","Ingin mulai memahami kitab tetapi kewalahan oleh bahasa dan istilah.","Penjelasan bertahap dan rujukan yang bisa dibuka, tanpa harus mencari kata kunci di maktabah.")}
{persona("Mahasiswa dan peneliti","Perlu menemukan ibarah dan membandingkan pembahasan lintas kitab, termasuk untuk skripsi dan tesis.","Pencarian per bidang, perbandingan keterangan, dan Catatan untuk menyusun rujukan.")}
{persona("Pengajar, penceramah, dan khatib","Menyiapkan materi ceramah atau khutbah dan memeriksa dalil serta ibarah sebelum menyampaikan.","Rujukan siap telusur pada tiap jawaban, sehingga persiapan jauh lebih singkat.")}
{persona("Pemberi fatwa dan pengkaji Fikih Tahawwulat","Mencari nas dan keterangan ulama dengan cepat; mempelajari disiplin yang literaturnya sangat luas.","Penelusuran ibarah yang cepat dan lima asisten khusus Fikih Tahawwulat.")}</div>''', title="Untuk Siapa")

# ---------- 8 Visi misi ----------
pg(f'''{sec("03","Fondasi")}<div class="row" style="gap:14mm"><div class="col"><div class="tag">Visi</div>
<h2 style="font-size:25pt;margin-top:5mm">Menjadi rumah baru bagi seluruh penuntut ilmu: tempat turath para ulama dapat dibuka, dipahami, dan dirujuk oleh siapa saja, dengan tetap kembali kepada guru.</h2></div>
<div class="col"><div class="tag">Misi</div><div style="margin-top:6mm">
<div style="display:flex;gap:5mm;margin-bottom:4mm"><span class="num">1</span><p style="margin:0">Memudahkan orang memahami kitab.</p></div>
<div style="display:flex;gap:5mm;margin-bottom:4mm"><span class="num">2</span><p style="margin:0">Mempercepat pencarian rujukan dan ibarah bagi penuntut ilmu, pemberi fatwa, penceramah, dan khatib.</p></div>
<div style="display:flex;gap:5mm;margin-bottom:4mm"><span class="num">3</span><p style="margin:0">Membangun AI per bidang dengan metodologi masing-masing, dikurasi dengan wasathiyyah syar'iyyah, dan ditinjau para ulama.</p></div>
<div style="display:flex;gap:5mm;margin-bottom:4mm"><span class="num">4</span><p style="margin:0">Meluaskan cakupan dari Fikih Tahawwulat ke seluruh ilmu Islam, dan menghidupkan turath para ulama.</p></div>
<div style="display:flex;gap:5mm"><span class="num">5</span><p style="margin:0">Menjadi alat bantu yang tidak pernah menggantikan guru.</p></div></div></div></div>''', title="Fondasi")

# ---------- 9 Nilai ----------
vals = [("Kembali kepada sumber","Setiap jawaban berpijak pada kitab dan ceramah ulama. Rujukan adalah bagian dari jawaban, bukan hiasannya."),
        ("Kembali berguru","AI hanyalah alat. Ia tidak menggantikan guru, dan selalu mengingatkan agar pembelajaran diteruskan kepada guru."),
        ("Amanah","Menjaga ketepatan ibarah, jujur tentang batas kemampuan, dan tidak mengatasnamakan ulama tanpa izin."),
        ("Wasathiyyah syar'iyyah","Kurasi yang tidak berlebihan dan tidak meremehkan, serta tidak dipakai untuk menjatuhkan kelompok lain."),
        ("Metodologi tiap ilmu dijaga","Fikih punya metodenya, hadis punya metodenya. Tidak dicampur menjadi satu jawaban yang berantakan."),
        ("Sarana baru, esensi terjaga","Memperbarui cara belajar tanpa merusak inti ajaran dan tradisi keilmuan. <span class=\"ar\" style=\"display:block;font-size:12pt;margin-top:1.5mm;color:var(--g2)\">تحديث الوسائل وتأصيل البدائل</span>")]
cards = "".join(f'<div class="card"><div class="num">{i+1:02d}</div><h3 style="margin-top:2mm">{t}</h3><p class="small" style="color:var(--ink);font-size:9.5pt;margin:0">{d}</p></div>' for i,(t,d) in enumerate(vals))
pg(f'''{sec("03","Enam Nilai")}<h2>Nilai yang memandu setiap keputusan.</h2><div class="grid3" style="margin-top:5mm">{cards}</div>''', title="Nilai")

# ---------- 9b Wasathiyyah ----------
def ring(n, t, d): return f'<div style="display:flex;gap:6mm;padding:4.5mm 0;border-bottom:.3mm solid var(--g3)"><div class="serif" style="font-size:26pt;width:12mm;color:var(--g2);line-height:1">{n}</div><div><h3 style="margin:0 0 1mm">{t}</h3><p style="font-size:9.6pt;margin:0;max-width:none">{d}</p></div></div>'
pg(f'''{sec("03","Wasathiyyah Syar'iyyah")}<div class="row" style="gap:16mm;align-items:center"><div style="width:100mm"><h2 style="font-size:27pt">Ukuran kami memilih kitab.</h2>
<div class="ar" style="font-size:25pt;line-height:1.7;margin:1mm 0 1mm">الوسطية الشرعية والاعتدال الواعي</div>
<p class="small" style="margin-bottom:5mm">Al-Wasathiyyah Asy-Syar'iyyah wal-I'tidal Al-Wa'i</p>
<p style="font-size:10pt">Wasathiyyah syar'iyyah bukan kompromi mekanis atau titik tengah politis. Ia bertumpu pada Al-Qur'an, sunnah, dan akhlak kenabian, dan menjaga dari dua jurang: berlebihan dan meremehkan. Dengannya kitab-kitab OpenTurath dikurasi, agar keilmuan tidak terpolitisasi dan tidak dipakai satu kelompok untuk menjatuhkan kelompok lain.</p></div>
<div class="col"><div class="small" style="letter-spacing:.14em;text-transform:uppercase;font-weight:600;margin-bottom:1mm">Tiga lapis kurasi</div>
{ring("1","Inti","Kitab induk bersanad yang menjadi dasar jawaban: mazhab fikih empat, akidah Asy'ari dan Maturidi, tasawuf yang lurus, dan Fikih Tahawwulat.")}
{ring("2","Pembanding terbatas","Pandangan yang tajam atau diperselisihkan disimpan hanya sebagai pembanding, tidak menjadi dasar hukum atau jawaban otomatis.")}
{ring("3","Dikecualikan","Naskah propaganda kekerasan, adu domba antar muslim, dan tulisan yang dirancang merusak akidah serta kehormatan ulama.")}
<div style="display:flex;gap:4mm;margin-top:5mm"><div style="flex:1;background:var(--ink);color:var(--bone);border-radius:3mm;padding:4mm 5mm"><b>Salamatul lisan</b><div style="font-size:8.6pt;opacity:.8;margin-top:1mm">AI tidak mencela, mengkafirkan, atau menyesatkan sesama muslim.</div></div><div style="flex:1;background:var(--ink);color:var(--bone);border-radius:3mm;padding:4mm 5mm"><b>Salamatul yad</b><div style="font-size:8.6pt;opacity:.8;margin-top:1mm">AI tidak memprovokasi kekerasan atau pertumpahan darah.</div></div></div></div></div>''', title="Wasathiyyah Syar'iyyah")

# ---------- 10 Posisi ----------
pg(f'''{sec("03","Posisi")}<div class="row" style="gap:12mm"><div class="col"><h2>Di mana OpenTurath berdiri.</h2>
<div class="card" style="background:var(--ink);color:var(--bone);border:none"><div class="small" style="color:#aaa;margin-bottom:2mm">Pernyataan posisi</div>
<p class="serif" style="font-size:14.5pt;line-height:1.4;margin:0;max-width:none">Bagi penuntut ilmu yang ingin memahami kitab dan menemukan rujukannya dengan cepat, OpenTurath adalah AI Islami berbasis turath, yang setiap jawabannya berpijak pada kitab atau ceramah ulama dan dijalankan dengan metodologi tiap bidang ilmu, berbeda dari AI umum yang menjawab tanpa sandaran pada teks.</p></div></div>
<div class="col"><table><tr><th style="width:50%">Kami adalah</th><th>Kami bukan</th></tr>
<tr><td>AI Islami berbasis turath</td><td>Pemberi fatwa</td></tr>
<tr><td>Alat bantu yang menghemat waktu mencari ibarah</td><td>Pengganti guru dan ulama</td></tr>
<tr><td>Satu asisten, satu metodologi bidang</td><td>Mesin pencari yang mencampur semua kitab</td></tr>
<tr><td>Dikurasi dengan wasathiyyah syar'iyyah</td><td>Alat kelompok untuk menjatuhkan kelompok lain</td></tr>
<tr><td>Dibangun dan ditinjau bersama ulama</td><td>Lembaga yang mengatasnamakan ulama</td></tr>
<tr><td>Layanan mandiri</td><td>Produk resmi Google</td></tr></table></div></div>''', title="Posisi")

# ---------- 10b Pembeda ----------
def why(t, d): return f'<div class="card"><h3>{t}</h3><p class="small" style="color:var(--ink);font-size:9.5pt;margin:0">{d}</p></div>'
pg(f'''{sec("03","Mengapa Jawaban Kami Berbeda")}<h2>Kualitas jawaban, bukan jumlah kitab.</h2>
<div class="grid2" style="margin-top:4mm">
{why("Satu bidang, satu metodologi","Banyak AI menjawab dari ribuan kitab sekaligus. Itu baik untuk kelengkapan, tetapi tidak untuk metodologi. Fikih Syafi'i dan hadis punya cara kerja yang berbeda; mencampurnya membuat jawaban tidak rapi. Karena itu tiap asisten OpenTurath bekerja dengan metodologinya sendiri.")}
{why("Kurasi, bukan pengumpulan","Setiap kitab dipilih satu per satu dengan wasathiyyah syar'iyyah. Jumlah kitab bukan ukuran. Yang diukur adalah ketepatan jawaban.")}
{why("Ditinjau para ulama","Para ulama diberi akses untuk memeriksa isi OpenTurath di bidangnya: fikih, Fikih Tahawwulat, hadis, bahasa Arab, dan lainnya. Pakar juga mengarahkan metodologi.")}
{why("Ibarah lebih dulu","Ketepatan ibarah dan rujukan adalah prioritas utama dan dalam pengujian berulang kami hasilnya sangat tinggi. Penjelasan AI tetap perlu diverifikasi kepada guru.")}</div>
<p class="small" style="margin-top:5mm">Perbandingan dengan sejumlah AI kelas dunia untuk ilmu agama Islam dapat dilihat di openturath.id.</p>''', title="Pembeda")

# ---------- 12 Nama ----------
pg(f'''{sec("04","Nama")}<div class="row" style="gap:14mm"><div class="col"><h1 style="font-size:46pt">OpenTurath</h1>
<p class="lead">Dua kata menjadi satu: <i>open</i> dan <i>turath</i>.</p>
<p><b>Turath</b> (<span class="ar" style="font-size:14pt">التراث</span>) adalah warisan keilmuan yang diturunkan: kitab-kitab para ulama dari matan hingga syarah, dan ceramah-ceramah mereka.</p>
<p><b>Open</b> membawa tiga makna.</p>
<p style="margin-bottom:1.5mm"><b>Terdepan.</b> Seperti AI umum punya garda terdepannya, OpenTurath bercita-cita menjadi garda terdepan AI Islami yang setiap jawabannya berbasis turath, baik kitab maupun ulama.</p>
<p style="margin-bottom:1.5mm"><b>Terbuka bagi siapa saja.</b> Ilmu agama boleh dipelajari oleh siapa pun. Kitab yang terbuka pada logo adalah tandanya.</p>
<p><b>Terbuka untuk diperiksa.</b> Setiap jawaban mengajak pembaca membuka kitabnya.</p></div>
<div class="col"><div class="card"><h3>Cara menulis</h3><table>
<tr><td style="width:40mm"><span class="yes">Benar</span><b>OpenTurath</b></td><td>Satu kata. Huruf besar pada O dan T.</td></tr>
<tr><td><span class="no">Salah</span>Open Turath</td><td>Jangan dipisah.</td></tr>
<tr><td><span class="no">Salah</span>Openturath, openturath</td><td>Jangan huruf kecil semua, kecuali alamat <code>openturath.id</code>.</td></tr>
<tr><td><span class="no">Salah</span>OPENTURATH</td><td>Huruf kapital semua hanya untuk label kecil bergaya kapitalisasi.</td></tr>
<tr><td><span class="no">Salah</span>OpenTurats, Open Torath</td><td>Gunakan ejaan <i>turath</i>.</td></tr></table>
<p class="small" style="margin:4mm 0 0">Pengucapan: <b>ō-pen-tu-rāts</b>.</p></div></div></div>''', title="Nama")

# ---------- 13 Arsitektur merek ----------
def lvl(t, d, ind=0, dark=False):
    bg = "background:var(--ink);color:var(--bone);border:none" if dark else ""
    return f'<div class="card" style="margin-left:{ind}mm;padding:3.4mm 6mm;margin-bottom:2.4mm;{bg}"><div style="display:flex;gap:6mm;align-items:baseline"><b style="min-width:54mm;font-size:11.5pt">{t}</b><span style="font-size:9.3pt;opacity:.85">{d}</span></div></div>'
pg(f'''{sec("04","Susunan Nama")}<h2>Satu merek induk, empat lini, nama yang sederhana.</h2>
<div style="margin-top:4mm">{lvl("OpenTurath","Merek induk. Dipakai di semua materi.",0,True)}
{lvl("OpenTurath AI","Aplikasi AI Islami berbasis turath. Nama di toko aplikasi. Dalam teks cukup tulis OpenTurath bila sudah jelas.",12)}
{lvl("Maktabah OpenTurath","Pusat unduh kitab. Dalam pembangunan.",12)}
{lvl("AI Manuskrip","Pembaca dan penahkik manuskrip. Nama produk akan ditetapkan sebelum rilis.",12)}
{lvl("Akademi OpenTurath","Pembelajaran menggunakan AI bagi penuntut ilmu.",12)}
{lvl("Asisten + nama bidang","Contoh: Asisten Fikih Syafi'i, Asisten Hadis.",12)}
{lvl("Cabang Fikih Tahawwulat","Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, Al-Khatib.",24)}
{lvl("openturath.id","Alamat website resmi. Selalu huruf kecil.",12)}</div>
<p class="small" style="margin-top:3mm">Aturan: jangan menciptakan sub-merek baru tanpa persetujuan Pemilik. Nama fitur ditulis sederhana dalam bahasa Indonesia: Catatan, Pustaka, Percakapan.</p>''', title="Susunan Nama")

# ---------- 13b Tagline ----------
pg(f'''{sec("04","Tagline")}<div class="row" style="gap:14mm;align-items:center"><div class="col" style="flex:1.25">
<h1 style="font-size:40pt;margin-bottom:5mm">Menjaga asal,<br>membuka cakrawala.</h1>
<div class="ar" style="font-size:25pt;line-height:1.7;margin-bottom:2mm;text-align:right;direction:rtl;max-width:140mm">رسوخٌ في الأصول، وانفتاحٌ على الآفاق</div>
<p class="serif" style="font-size:15pt;font-style:italic;color:var(--g2)">Rooted in origins. Open to new horizons.</p></div>
<div class="col"><div class="card"><h3>Dua bagian, satu napas</h3>
<p style="font-size:9.8pt"><b>Menjaga asal</b> berarti setia pada sumber: Al-Qur'an, sunnah, dan turath para ulama. Itulah yang tidak berubah.</p>
<p style="font-size:9.8pt"><b>Membuka cakrawala</b> berarti memanfaatkan teknologi paling mutakhir sebagai sarana, supaya turath dapat dijangkau, dipahami, dan dikembangkan lebih jauh. Itulah &ldquo;Open&rdquo;.</p>
<p class="small" style="margin:0">Sejalan dengan prinsip memperbarui sarana tanpa merusak esensi.</p></div>
<table style="margin-top:4mm"><tr><th>Aturan pemakaian</th></tr>
<tr><td>Selalu bersama nama OpenTurath, tidak berdiri sendiri.</td></tr>
<tr><td>Jangan diubah, dipotong, atau diganti urutannya.</td></tr>
<tr><td>Teks Arab memakai Scheherazade New; Latin memakai Newsreader miring.</td></tr>
<tr><td>Pada materi satu bahasa, pakai versi bahasa itu; pada materi internasional, boleh ketiganya.</td></tr></table></div></div>''', title="Tagline")

# ---------- 14 Logo: simbol ----------
pg(f'''<div style="display:flex;height:100%;align-items:center;gap:26mm"><div style="width:110mm;display:flex;justify-content:center">{logo(95)}</div>
<div class="col">{sec("05","Logo")}<h1>Simbol OpenTurath</h1>
<p class="lead">Satu lengkung yang menaungi tiga bidang.</p><p>Simbol ini satu warna, dibuat agar tetap terbaca dari ikon sekecil 16 piksel sampai spanduk setinggi gedung. Ia adalah wajah OpenTurath di mana pun merek ini hadir.</p></div></div>''', "white", title="Logo")

# ---------- 15 Filosofi (beranotasi) ----------
def callout(n, px, py, tx, ty):
    px-=204; tx-=204; py-=175; ty-=175
    return (f'<line x1="{px}" y1="{py}" x2="{tx}" y2="{ty}" stroke="#100F0E" stroke-width="2.2"/>'
            f'<circle cx="{tx}" cy="{ty}" r="22" fill="#100F0E"/><text x="{tx}" y="{ty+9}" text-anchor="middle" font-size="26" font-family="OT Outfit" font-weight="600" fill="#fff">{n}</text>'
            f'<circle cx="{px}" cy="{py}" r="6" fill="#100F0E"/>')
ann = (callout(1, 420, 690, -100, 690) + callout(2, 612, 690, 1000, 690) + callout(3, 512, 404, 1000, 404) +
       callout(4, 262, 360, -100, 330) + callout(5, 238, 830, -100, 830))
def fi(n, t, d): return f'<div style="display:flex;gap:4mm;margin-bottom:3mm"><span class="num" style="font-size:14pt;width:6mm">{n}</span><div><h3 style="margin:0;font-size:12pt">{t}</h3><p class="small" style="margin:0;color:var(--ink);font-size:8.8pt;max-width:none">{d}</p></div></div>'
pg(f'''<div class="row" style="gap:10mm;height:100%;align-items:center"><div style="width:112mm;display:flex;justify-content:center">
<svg viewBox="-364 -25 1240 720" style="width:112mm;color:var(--ink)"><svg x="0" y="0" width="616" height="674" viewBox="0 0 616 674"><use href="#ot"/></svg>{ann}</svg></div>
<div class="col">{sec("05","Filosofi Logo")}<h2 style="font-size:22pt">Apa yang dikatakan simbol ini.</h2>
{fi(1,"Halaman kiri: Islam","Rukun-rukun amal lahir, fondasi yang paling dahulu dipelajari.")}
{fi(2,"Halaman kanan: Iman","Keyakinan yang menjadi pasangan Islam. Keduanya berdiri sejajar dan saling menopang.")}
{fi(3,"Kubah di atas: Ihsan","Puncak tingkatan agama, yang menaungi Islam dan Iman dari atas.")}
{fi(4,"Lengkung luar: Fikih Tahawwulat","Fikih Tahawwulat dan ilmu-ilmu yang sejalan menaungi dan menjaga ketiganya, laksana peta navigasi di tengah badai zaman.")}
{fi(5,"Kaki terbuka dan kitab terbuka: Open","Dua halaman yang terbuka berarti ilmu agama boleh dipelajari siapa saja. Kaki lengkung yang terbuka berarti tidak ada ambang yang menutup.")}
</div></div>''', "white", title="Filosofi Logo")

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

# ---------- 27 Citra ----------
arch = lambda w,h,extra="": f'<div class="arch" style="width:{w}mm;height:{h}mm;{extra}"></div>'
pg(f'''{sec("08","Citra")}<h2>Lengkung, garis halus, dan ruang kosong.</h2>
<div class="grid4" style="margin-top:4mm">
<div><div class="tile" style="height:56mm;background:#fff;border:.3mm solid var(--g3);align-items:flex-end">{arch(34,44)}</div><div class="cap"><b>Motif lengkung</b><br>Bingkai kartu kitab dan penanda bab, dipakai hemat. Bukan pola latar yang ramai.</div></div>
<div><div class="tile" style="height:56mm;background:#fff;border:.3mm solid var(--g3);flex-direction:column;gap:2.5mm;padding:8mm"><div style="width:100%;height:.3mm;background:#100F0E"></div><div style="width:100%;height:.3mm;background:#DADADA"></div><div style="width:100%;height:.3mm;background:#DADADA"></div><div style="width:60%;height:.3mm;background:#DADADA;align-self:flex-start"></div></div><div class="cap"><b>Garis halus</b><br>Garis 0,5 sampai 1 px menggantikan bayangan tebal.</div></div>
<div><div class="tile" style="height:56mm;background:#151515;border:.3mm solid var(--g3)"><div style="width:30mm;height:38mm;border:.35mm solid #F5F5F5;border-radius:50% 50% 0 0/20% 20% 0 0;display:flex;align-items:center;justify-content:center">{logo(14,"#F5F5F5")}</div></div><div class="cap"><b>Ilustrasi</b><br>Garis monokrom sederhana: buku, lengkung, lampu baca, rak kitab. Tanpa tokoh kartun dan tanpa efek 3D.</div></div>
<div><div class="tile" style="height:56mm;background:#fff;border:.3mm solid var(--g3);flex-direction:column;gap:3mm"><div style="display:flex;gap:4mm"><div style="width:9mm;height:9mm;border:.4mm solid #100F0E;border-radius:2mm"></div><div style="width:9mm;height:9mm;border:.4mm solid #100F0E;border-radius:50%"></div><div style="width:9mm;height:9mm;border:.4mm solid #100F0E;border-radius:2mm 2mm 50% 50%"></div></div><div class="small">Ikon garis, ujung bulat</div></div><div class="cap"><b>Ikon</b><br>Garis seragam, satu warna, sudut dan ujung membulat seirama.</div></div></div>
<div class="grid2" style="margin-top:5mm"><div class="card" style="padding:4mm 6mm"><b>Foto</b><p class="small" style="margin:1mm 0 0;color:var(--ink)">Dipakai jarang. Hitam putih atau netral, cahaya alami, tanpa filter dramatis. Subjek: kitab, tangan yang membaca, ruang belajar. Tidak memuat wajah tokoh tanpa izin tertulis.</p></div>
<div class="card" style="padding:4mm 6mm"><b>Gerak</b><p class="small" style="margin:1mm 0 0;color:var(--ink)">Pendek, halus, dan fungsional: pudar masuk dan geser kecil. Tanpa partikel, kilau, atau efek cahaya. Video memakai simbol apa adanya.</p></div></div>''', title="Citra")

# ---------- 28 Tata letak ----------
pg(f'''{sec("09","Tata Letak dan Komponen")}<div class="row" style="gap:10mm"><div class="col"><h2>Ritme jarak dan sudut.</h2>
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
scr1 = f'<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;gap:4mm;text-align:center">{logo(16)}<div class="wm" style="font-size:13pt">OpenTurath</div><div style="font-size:6.5pt;color:#606060;font-style:italic">Menjaga asal, membuka cakrawala.</div><div style="background:#171717;color:#fff;border-radius:3mm;padding:2.5mm 0;width:100%;font-size:7pt;font-weight:600;margin-top:4mm">Masuk dengan Google</div></div>'
scr2 = '<div style="font-size:6pt;letter-spacing:.14em;text-transform:uppercase;color:#606060;font-weight:600">Beranda</div><div class="serif" style="font-size:12pt;margin:1mm 0 3mm">Pilih bidang</div>' + "".join(f'<div style="background:#fff;border:.25mm solid #DADADA;border-radius:2.5mm;padding:2.5mm;margin-bottom:2mm"><div style="font-size:7.5pt;font-weight:600">{t}</div><div style="font-size:5.5pt;color:#606060">{d}</div></div>' for t,d in [("Fikih Syafi'i","Mazhab Imam Asy-Syafi'i"),("Hadis","Kitab induk hadis"),("Tafsir","Eksegesis Al-Qur'an"),("Fikih Tahawwulat","Lima cabang khusus")])
scr3 = '<div style="font-size:7pt;font-weight:600;margin-bottom:3mm">Fikih Syafi\'i</div><div style="background:#EDEDED;border-radius:2.5mm;padding:2.5mm;font-size:6pt;margin-bottom:2mm">Apa syarat sah wudhu?</div><div style="background:#fff;border:.25mm solid #DADADA;border-radius:2.5mm;padding:2.5mm;font-size:6pt;line-height:1.5">Pembahasan ditemukan pada bab thaharah.<div class="ar" style="font-size:9pt;margin-top:1.5mm">فُرُوضُ الْوُضُوءِ سِتَّةٌ</div><div style="color:#606060;margin-top:1.5mm">Buka kitab untuk membaca konteksnya.</div></div>'
pg(f'''{sec("10","Penerapan: Aplikasi")}<div class="row" style="gap:12mm;align-items:center"><div style="width:80mm"><h2>Aplikasi OpenTurath AI</h2><p>Satu logo per layar. Latar kanvas tenang, kartu putih bergaris halus, satu tombol utama berwarna Tinta.</p><p class="small">Ikon aplikasi memakai versi kotak membulat. Nama di toko aplikasi: <b>OpenTurath AI</b>.</p></div>
<div class="row" style="gap:8mm">{phone(scr1)}{phone(scr2)}{phone(scr3)}</div></div>''', title="Aplikasi")

# ---------- 30 Penerapan: website & sosial ----------
site = f'''<div style="width:150mm;border:.4mm solid #100F0E;border-radius:3mm;overflow:hidden;background:#F6F6F6"><div style="background:#fff;border-bottom:.3mm solid #DADADA;padding:3mm 5mm;display:flex;justify-content:space-between;align-items:center">{lockup(7)}<div style="font-size:7pt;display:flex;gap:5mm;color:#606060"><span>Asisten</span><span>Kitab rujukan</span><span>Harga</span><span style="background:#171717;color:#fff;border-radius:2mm;padding:1mm 3mm">Masuk</span></div></div>
<div style="padding:12mm 10mm 10mm"><div class="serif" style="font-size:25pt;line-height:1.05">Menjaga asal,<br>membuka cakrawala.</div><p style="font-size:8pt;color:#606060;margin:4mm 0;max-width:90mm">OpenTurath membantu penuntut ilmu memahami kitab dan menemukan rujukan ibarahnya, dengan tetap kembali kepada guru.</p><div style="display:flex;gap:3mm"><span style="background:#171717;color:#fff;border-radius:2.5mm;padding:2mm 5mm;font-size:8pt;font-weight:600">Jelajahi asisten</span><span style="border:.3mm solid #767676;border-radius:2.5mm;padding:2mm 5mm;font-size:8pt;font-weight:600;background:#fff">Lihat kitab rujukan</span></div></div></div>'''
post = f'<div style="width:50mm;height:62mm;background:#09090B;color:#FAFAFA;border-radius:2mm;padding:6mm;display:flex;flex-direction:column;justify-content:space-between"><div>{logo(8,"#FAFAFA")}</div><div class="serif" style="font-size:14pt;line-height:1.15">Menjaga asal, membuka cakrawala.</div><div style="font-size:5.5pt;letter-spacing:.14em;color:#999">OPENTURATH.ID</div></div>'
avatar = f'<div style="width:24mm;height:24mm;border-radius:50%;background:#F6F6F3;display:flex;align-items:center;justify-content:center;border:.3mm solid #ccc">{logo(11)}</div>'
pg(f'''{sec("10","Penerapan: Website dan Media Sosial")}<div class="row" style="gap:10mm;align-items:flex-start;margin-top:3mm"><div>{site}<div class="cap">Header memakai gabungan horizontal. Judul memakai tagline resmi.</div></div>
<div><div style="display:flex;gap:6mm;align-items:flex-end">{post}<div>{avatar}<div class="cap">Avatar: ikon aplikasi</div></div></div>
<div class="card" style="margin-top:5mm;padding:4mm 5mm;width:98mm"><div class="small">Biografi (di bawah 150 karakter)</div><p style="font-size:9pt;margin:1mm 0 0">Menjaga asal, membuka cakrawala. AI Islami berbasis kitab dan ulama. openturath.id</p></div></div></div>''', title="Website dan Sosial")

# ---------- 31 Penerapan: dokumen ----------
letter = f'<div style="width:78mm;height:104mm;background:#fff;border:.3mm solid #ccc;padding:7mm;position:relative">{lockup(8)}<div style="height:.3mm;background:#100F0E;margin:3mm 0 5mm"></div><div style="font-size:5.5pt;color:#606060;margin-bottom:3mm">22 Oktober 2026 &middot; No. OT-SRT-001</div><div style="font-size:6pt;line-height:1.7;color:#333">Yth. Bapak/Ibu,<br><br>Dengan hormat, kami menyampaikan...<br><div style="height:.25mm;background:#ddd;margin:2mm 0"></div><div style="height:.25mm;background:#ddd;margin:2mm 0"></div><div style="height:.25mm;background:#ddd;margin:2mm 0;width:70%"></div></div><div style="position:absolute;bottom:5mm;left:7mm;right:7mm;font-size:5pt;color:#606060;border-top:.25mm solid #ddd;padding-top:2mm;display:flex;justify-content:space-between"><span>openturath.id</span><span>Halaman 1</span></div></div>'
slide = f'<div style="width:96mm;height:54mm;background:#09090B;color:#FAFAFA;border-radius:1.5mm;padding:7mm;position:relative"><div style="position:absolute;top:6mm;right:7mm">{logo(7,"#FAFAFA")}</div><div class="kick" style="font-size:5.5pt;color:#999;margin-bottom:3mm">BAB 01</div><div class="serif" style="font-size:17pt;line-height:1.1;max-width:60mm">Mengapa belajar kitab terasa berat?</div></div>'
slide2 = f'<div style="width:96mm;height:54mm;background:#F6F6F3;border-radius:1.5mm;padding:7mm;border:.3mm solid #ccc"><div class="serif" style="font-size:12pt;margin-bottom:3mm">Tiga langkah memulai</div><div style="display:flex;gap:3mm">' + "".join(f'<div style="flex:1;background:#fff;border:.25mm solid #DADADA;border-radius:2mm;padding:3mm"><div class="num" style="font-size:12pt">{i}</div><div style="font-size:6pt">{t}</div></div>' for i,t in [(1,"Pilih bidang ilmu"),(2,"Ajukan pertanyaan"),(3,"Buka kitab rujukan")]) + '</div></div>'
pg(f'''{sec("10","Penerapan: Dokumen dan Presentasi")}<div class="row" style="gap:12mm;align-items:flex-start"><div>{letter}<div class="cap">Kop surat: gabungan horizontal, garis tipis, tanpa warna.</div></div>
<div><div style="display:flex;flex-direction:column;gap:5mm">{slide}{slide2}</div><div class="cap">Slide: judul Newsreader, latar Obsidian atau Kertas, logo di sudut.</div></div>
<div class="col"><div class="card"><h3>Penomoran dokumen</h3><p class="small" style="color:var(--ink)">Format <code>OT-JENIS-NNN</code>, contoh <code>OT-ID-001</code> untuk buku ini dan <code>OT-SRT-001</code> untuk surat.</p><h3 style="margin-top:4mm">Tanda tangan surel</h3><p class="small" style="color:var(--ink);margin:0">Nama, jabatan<br><b>OpenTurath</b><br>openturath.id</p></div></div></div>''', title="Dokumen")

# ---------- 32 Penggunaan bersama ----------
pg(f'''{sec("11","Penggunaan Bersama")}<div class="row" style="gap:10mm"><div class="col"><h2>Bagi pihak di luar OpenTurath.</h2>
<div class="card" style="margin-bottom:4mm"><span class="yes">Boleh tanpa izin</span><p style="font-size:9.5pt;margin:0">Menyebut nama OpenTurath secara wajar dalam berita, ulasan, dan tulisan. Menampilkan logo apa adanya untuk mengarahkan pembaca ke OpenTurath.</p></div>
<div class="card"><span class="no" style="color:var(--ink)">Perlu izin tertulis</span><p style="font-size:9.5pt;margin:0">Memakai nama atau logo pada produk atau layanan lain; menyiratkan kemitraan atau dukungan; membuat turunan logo, akun, atau domain yang tampak resmi; memakai logo untuk kegiatan komersial atau penggalangan dana. Izin diberikan hanya oleh Rafli Husen.</p></div></div>
<div class="col"><h2>Tata kelola.</h2><table>
<tr><td style="width:34mm"><b>Pemilik</b></td><td>Rafli Husen. Hanya Pemilik yang mengubah isi buku ini dan menyetujui pemakaian nama dan logo.</td></tr>
<tr><td><b>Kontak</b></td><td>support@openturath.id</td></tr>
<tr><td><b>Merek</b></td><td>Belum didaftarkan. Jangan memakai tanda &reg; pada logo atau nama.</td></tr>
<tr><td><b>Kerja sama</b></td><td>Belum ada kerja sama resmi. Jangan menyiratkan adanya kemitraan.</td></tr>
<tr><td><b>Versi</b></td><td>1.3, 23 Oktober 2026. Kecil (typo): 1.3.x. Isi: 1.x. Logo, nama, atau nilai: versi mayor.</td></tr>
<tr><td><b>Berkas</b></td><td>Aset logo di <code>aset_logo</code>. Buku dibangun dari <code>sumber_buku/build_buku.py</code>.</td></tr></table></div></div>''', title="Penggunaan Bersama")

# ---------- 33 Penutup ----------
pg(f'''<div style="height:100%;display:flex;flex-direction:column;justify-content:center;align-items:center;text-align:center;gap:10mm">{logo(26,"var(--bone)")}
<div class="serif" style="font-size:21pt;line-height:1.5;max-width:200mm;font-style:italic">Kami menjaga asal, dan membuka cakrawala. Setiap jawaban berpijak pada turath, dan alat ini tidak pernah menggantikan guru.</div>
<div style="font-size:8pt;letter-spacing:.2em;color:#9a9a9a">OPENTURATH &middot; MENJAGA ASAL, MEMBUKA CAKRAWALA &middot; OPENTURATH.ID</div></div>''', "dark", foot=False)

# ---------- rakit ----------
css = (HERE / "style.css").read_text().replace("FONTDIR", FONTDIR.as_posix())
html = f'<!doctype html><html lang="id"><head><meta charset="utf-8"><title>OpenTurath: Buku Identitas</title><style>{css}</style></head><body>{SYMBOL}{"".join(pages)}</body></html>'
out_html = HERE / "buku.html"; out_html.write_text(html, encoding="utf-8")
pdf = HERE.parent / "OpenTurath_Buku_Identitas.pdf"
chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
subprocess.run([chrome, "--headless", "--disable-gpu", "--no-pdf-header-footer", "--allow-file-access-from-files",
                f"--print-to-pdf={pdf}", f"file://{out_html}"], check=True, capture_output=True)
print("halaman:", len(pages), "->", pdf)
