#!/usr/bin/env python3
"""OpenTurath Website V7 — prototipe statis dari satu sumber data.
Jalankan:  python3 build.py   ->  site/*.html
Fakta berasal dari data aplikasi (info_ai.json, pengantar_tahawwulat.json) dan website/content/adab.json.
Tidak ada angka korpus, harga, atau klaim ketepatan di sini (lihat BLUEPRINT_UX.md)."""
import re, json, html, pathlib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
OUT = HERE / "site"
INFO = json.load(open(ROOT / "openturath_ai/assets/data/info_ai.json", encoding="utf8"))
PENG = json.load(open(ROOT / "openturath_ai/assets/data/pengantar_tahawwulat.json", encoding="utf8"))
ADAB = json.load(open(ROOT / "website/content/adab.json", encoding="utf8"))
SVG = (ROOT / "OpenTurath_logo_transparent.svg").read_text()
PATHS = re.findall(r'<path d="([^"]+)" fill="#100f0e"', SVG)  # 0 lengkung, 1 kubah, 2 halaman kiri, 3 halaman kanan
E = html.escape

SPRITE = ('<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>'
          '<symbol id="ot" viewBox="0 0 616 674">' + "".join(f'<path transform="translate(-204,-175)" d="{d}" fill="currentColor"/>' for d in PATHS) + '</symbol>'
          '<clipPath id="archClip" clipPathUnits="objectBoundingBox"><path d="M0.075,1 V0.4185 C0.075,0.2704 0.195,0.1889 0.5,0.063 C0.805,0.1889 0.925,0.2704 0.925,0.4185 V1 Z"/></clipPath>'
          '</defs></svg>')

def mark(h=30): return f'<svg style="height:{h}px;width:{h*615/673:.1f}px" viewBox="0 0 616 674" aria-hidden="true"><use href="#ot"/></svg>'

def ic(name, cls=""):
    P = {
      "arrow": '<path d="M5 12h14M13 6l6 6-6 6"/>',
      "download": '<path d="M12 4v11M7 11l5 5 5-5M5 20h14"/>',
      "sun": '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
      "moon": '<path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z"/>',
      "globe": '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>',
      "chev": '<path d="M6 9l6 6 6-6"/>',
      "menu": '<path d="M4 8h16M4 16h16"/>',
      "close": '<path d="M6 6l12 12M18 6L6 18"/>',
      "android": '<path d="M6 10h12v7a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2zM8 7l-1.5-2.5M16 7l1.5-2.5M6 10a6 6 0 0 1 12 0M9.5 14h.01M14.5 14h.01"/>',
      "laptop": '<rect x="4" y="5" width="16" height="11" rx="1.5"/><path d="M2 19h20"/>',
      "windows": '<path d="M3 5.5l7-1v7H3zM11 4.4L21 3v8.5H11zM3 12.5h7v7l-7-1zM11 12.5h10V21l-10-1.4z"/>',
      "layers": '<path d="M12 3l9 5-9 5-9-5zM3 13l9 5 9-5"/>',
      "scale": '<path d="M12 4v16M6 20h12M5 7h14M5 7l-3 7a3 3 0 0 0 6 0zM19 7l-3 7a3 3 0 0 0 6 0z"/>',
      "check": '<circle cx="12" cy="12" r="9"/><path d="M8 12.5l2.6 2.6L16 9.5"/>',
      "book": '<path d="M4 5.5C4 4.7 4.7 4 5.5 4H11v15H5.5C4.7 19 4 19.7 4 20.5zM20 5.5c0-.8-.7-1.5-1.5-1.5H13v15h5.5c.8 0 1.5.7 1.5 1.5z"/>',
      "library": '<rect x="4" y="5" width="4" height="15" rx="1"/><rect x="10" y="8" width="4" height="12" rx="1"/><path d="M16.5 20L19 6l3 .6L19.5 20.6zM2 22h20"/>',
      "scroll": '<path d="M7 3h11a2 2 0 0 1 2 2v13a3 3 0 0 1-3 3H8M7 3a2 2 0 0 0-2 2v13a3 3 0 0 0 3 3M9 8h7M9 12h7M9 16h4"/>',
      "cap": '<path d="M2 9l10-5 10 5-10 5zM6 11.5V16c0 1.5 3 3 6 3s6-1.5 6-3v-4.5M22 9v6"/>',
      "sparkle": '<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8zM19 16l.8 2.2L22 19l-2.2.8L19 22l-.8-2.2L16 19l2.2-.8z"/>',
      "plus": '<path d="M12 5v14M5 12h14"/>',
      "send": '<path d="M5 12h13M12 6l6 6-6 6"/>',
    }[name]
    return f'<svg class="ic {cls}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{P}</svg>'

NAV = [("cara-kerja.html", "Cara kerja"), ("pedoman.html", "Pedoman keilmuan"), ("ekosistem.html", "Ekosistem"), ("tentang.html", "Tentang")]
RK = {'tahaw': ('layers', 'Fikih Tahawwulat', 'Lima asisten untuk rukun keempat agama'), 'fikih': ('scale', 'Fikih', 'Empat mazhab, perbandingan, dan fatwa'), 'ushul': ('cap', 'Ushul dan kaidah', 'Metode menggali hukum dari dalil'), 'hadis': ('scroll', 'Hadis', 'Matan, syarah, ilmu hadis, dan rijal'), 'quran': ('book', "Al-Qur'an", "Tafsir, tajwid, dan qira'at"), 'akidah': ('check', 'Akidah dan tasawuf', 'Ushuluddin, kalam, dan tazkiyah'), 'bahasa': ('library', 'Bahasa, sejarah, bibliografi', 'Nahwu, sharaf, sirah, dan faharis')}

def shell(fname, title, desc, body, current=""):
    cur = ' aria-current="page"'
    links = "".join(f'<a href="{h}"{cur if h == current else ""}>{t}</a>' for h, t in NAV)
    sheet = '<a class="l" href="bidang.html">Bidang ilmu</a>' + "".join(f'<a class="l" href="{h}">{t}</a>' for h, t in NAV)
    drop = "".join(f'<a href="bidang.html#{g}">{ic(i)}<span><b>{t}</b><span class="d">{d}</span></span></a>' for g, (i, t, d) in RK.items())
    return f'''<!doctype html><html lang="id" dir="ltr" class="no-js"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{E(title)}</title><meta name="description" content="{E(desc)}"><meta name="theme-color" content="#FFFFFF">
<meta property="og:title" content="{E(title)}"><meta property="og:description" content="{E(desc)}"><meta property="og:type" content="website">
<link rel="stylesheet" href="assets/css/site.css"><link rel="icon" href="assets/mark.svg" type="image/svg+xml">
<link rel="preload" href="assets/fonts/googlesansflex.woff2" as="font" type="font/woff2" crossorigin>
<script>try{{var u=new URLSearchParams(location.search);if(u.get('nofx'))document.documentElement.classList.add('nofx');var q=u.get('theme');var t=q||localStorage.getItem('ot-theme');if(t)document.documentElement.setAttribute('data-theme',t)}}catch(e){{}}</script></head>
<body>{SPRITE}<a class="skip" href="#main">Lewati ke konten</a>
<div class="anno"><a href="unduh.html">{ic("sparkle")}<span><b>Baru:</b> OpenTurath AI, rilis perdana 23 Oktober 2026</span>{ic("arrow","arr")}</a></div>
<header class="site"><div class="hbar"><a class="wordmark" href="index.html" aria-label="OpenTurath, beranda">{mark(28)}<span>OpenTurath</span></a>
<nav class="main" aria-label="Utama"><button class="navbtn" data-drop="fieldsDrop" aria-expanded="false" aria-controls="fieldsDrop">Bidang{ic("chev")}</button>{links}</nav>
<div class="hactions"><button class="langbtn" data-drop="langDrop" aria-expanded="false" aria-controls="langDrop" aria-label="Pilih bahasa">{ic("globe")}<span>ID</span></button>
<button class="iconbtn theme-btn" aria-label="Ganti tema terang atau gelap"><span class="sun">{ic("sun")}</span><span class="moon">{ic("moon")}</span></button>
<a class="btn primary sm hideS" href="unduh.html">{ic("download")}Unduh</a>
<button class="iconbtn menu-btn" aria-label="Buka menu" aria-expanded="false">{ic("menu")}</button></div></div>
<div class="drop fields" id="fieldsDrop">{drop}<a href="bidang.html" style="border-top:1px solid var(--outline-variant);border-radius:0 0 16px 16px;margin-top:6px;padding-top:16px">{ic("arrow","arr")}<span><b>Lihat semua bidang</b></span></a></div>
<div class="drop lang" id="langDrop"><div class="row"><b>Bahasa Indonesia</b><span class="soon">ID</span></div><div class="row soon"><span>English</span><span>Segera</span></div><div class="row soon"><span>العربية</span><span>Segera</span></div></div></header>
<div class="sheet" id="sheet">{sheet}<a class="btn primary" href="unduh.html">{ic("download")}Unduh aplikasi</a></div>
<main id="main">{body}</main>
<footer class="site"><div class="wrap"><div class="fgrid"><div><a class="wordmark" href="index.html">{mark(30)}<span>OpenTurath</span></a>
<p class="ftag">Menjaga asal, membuka cakrawala.</p><span class="pill">Dibuat oleh pelajar, untuk para pelajar.</span></div>
<div><h4>Produk</h4><ul><li><a href="bidang.html">OpenTurath AI</a></li><li><a href="bidang.html">Bidang ilmu</a></li><li><a href="fikih-tahawwulat.html">Fikih Tahawwulat</a></li><li><a href="unduh.html">Unduh</a></li></ul></div>
<div><h4>Pelajari</h4><ul><li><a href="cara-kerja.html">Cara kerja</a></li><li><a href="pedoman.html">Pedoman keilmuan</a></li><li><a href="ekosistem.html">Ekosistem</a></li><li><a href="tentang.html">Tentang</a></li></ul></div>
<div><h4>Bantuan</h4><ul><li><a href="bantuan.html">Bantuan dan FAQ</a></li><li><a href="bantuan.html#lapor">Laporkan kesalahan</a></li><li><a href="mailto:support@openturath.id">support@openturath.id</a></li><li><a href="bantuan.html#legal">Ketentuan dan privasi</a></li></ul></div></div>
<div class="fbar"><span>OpenTurath adalah layanan mandiri dan memanfaatkan teknologi Google. Tidak berafiliasi dengan, didukung oleh, atau disahkan oleh Google.</span><span>openturath.id</span></div></div></footer>
<script src="assets/js/site.js" defer></script></body></html>'''

def write(name, title, desc, body, current=""):
    (OUT / name).write_text(shell(name, title, desc, body, current), encoding="utf8")

# ---------- data bidang ----------
G = {"tahaw": ["fiqh_tahawwulat"], "fikih": ["fiqh_syafii", "fiqh_hanafi", "fiqh_maliki", "fiqh_hanbali", "fiqh_muqaran"], "ushul": ["ushul_fiqh"],
     "hadis": ["hadits", "syarah_hadits", "musthalah_hadits", "thabaqat_tarajim"], "quran": ["tafsir", "tajwid_qiraat"],
     "akidah": ["aqidah", "tasawwuf"], "bahasa": ["nahwu_sharaf", "tarikh", "bibliografi_faharis"]}
GL = {"tahaw": "Fikih Tahawwulat", "fikih": "Fikih", "ushul": "Ushul dan kaidah", "hadis": "Hadis", "quran": "Al-Qur'an", "akidah": "Akidah dan tasawuf", "bahasa": "Bahasa, sejarah, bibliografi"}
byid = {x["id"]: x for x in INFO}
def grp(i): return next(g for g, v in G.items() if i in v)

def explorer(default="fikih", with_all=False, search=False):
    chips = ('<button type="button" data-g="all" aria-pressed="%s">Semua</button>' % ("true" if default == "all" else "false")) if with_all else ""
    chips += "".join(f'<button type="button" data-g="{g}" aria-pressed="{"true" if g == default else "false"}">{l}</button>' for g, l in GL.items())
    order = [i for g in G for i in G[g]]
    cards, dets = "", ""
    for i in order:
        x = byid[i]; g = grp(i)
        cards += f'<button type="button" class="acard" data-id="{i}" data-g="{g}" data-q="{E((x["judul"]+" "+x["tentang"]).lower())}" aria-pressed="false"><span class="t">{E(x["judul"])}</span><span class="a">{E(x["nama_arab"])}</span></button>'
        main, _, use = x["tentang"].partition("Gunakan AI ini untuk")
        usehtml = f'<div class="use"><b>Gunakan untuk</b><p style="margin:0">{E(use.strip()[:1].upper() + use.strip()[1:])}</p></div>' if use else ""
        dets += (f'<article class="detail" data-id="{i}" hidden><div class="ar">{E(x["nama_arab"])}</div><h3>{E(x["judul"])}</h3><div class="sub">{E(x["subjudul"])}</div>'
                 f'<p>{E(main.strip())}</p>{usehtml}<a class="btn primary" href="unduh.html" style="margin-top:22px">Buka di aplikasi{ic("arrow","arr")}</a></article>')
    s = ""
    if search:
        s = '<label class="sr" for="cari">Cari bidang atau kitab</label><input id="cari" type="search" placeholder="Cari bidang atau kitab, misalnya Minhajuth Thalibin" style="width:100%;min-height:52px;padding:0 18px;border:1px solid var(--line-strong);border-radius:10px;background:var(--surface);color:var(--text);font:inherit;margin-bottom:16px">'
    return f'<div class="rumpun" role="group" aria-label="Rumpun ilmu">{chips}</div>{s}<div class="explorer"><div class="alist">{cards}</div><div>{dets}</div></div>'

# ---------- potongan umum ----------
def gate_svg():
    names = ["p-arch", "p-dome", "p-left", "p-right"]
    ps = "".join(f'<path id="{n}" transform="translate(-204,-175)" d="{d}" fill="currentColor"/>' for n, d in zip(names, PATHS))
    return f'<svg viewBox="0 0 616 674" role="img" aria-label="Logo OpenTurath: tiga bidang di bawah satu lengkung">{ps}</svg>'

SL = {s["id"]: s for s in PENG["slide"]}
def demo():
    qa = [
        ("AI Fikih Tahawwulat · Al-Muhaqqiq", "Berapa rukun agama menurut Fikih Tahawwulat?",
         "Menurut Fikih Tahawwulat, rukun agama ada empat. " + SL["empat-rukun"]["kunci"], SL["empat-rukun"]["ibarah"], SL["empat-rukun"]["sumber"]),
        ("AI Fikih Tahawwulat · Al-Bayan", "Jelaskan rukun keempat dengan perumpamaan sederhana.",
         "Bayangkan agama seperti mobil berpenggerak empat roda. " + SL["mobil"]["kunci"] + " " + SL["lumpur"]["kunci"], SL["mobil"]["ibarah"], SL["mobil"]["sumber"]),
        ("AI Fikih Tahawwulat · Al-Muhaqqiq", "Apakah membahas tanda-tanda kiamat hanya membuat cemas?",
         "Banyak yang mengira begitu. " + SL["takut"]["kunci"] + " Menurut beliau justru sebaliknya: " + SL["justru"]["kunci"][0].lower() + SL["justru"]["kunci"][1:], SL["justru"]["ibarah"], SL["justru"]["sumber"])]
    tabs = "".join(f'<button class="fx-item" role="tab" aria-selected="false" data-q="{E(q)}" data-who="{E(w)}" aria-controls="r{i}" id="t{i}"><span class="n">{i+1:02d}</span><span class="t">{E(q)}</span>{ic("plus")}</button>' for i, (w, q, a, b, c) in enumerate(qa))
    reps = "".join(
        f'<div class="reply" role="tabpanel" id="r{i}" aria-labelledby="t{i}" hidden><p>{E(a)}</p>'
        f'<div class="ibarah"><div class="lbl">Ibarah</div><div class="ar">{E(b.replace("…"," … "))}</div></div>'
        f'<div class="src"><span class="refchip">[1]</span><span><b>{E(c.split(",")[0])}</b>, {E(c.split(",",1)[1].strip())} &middot; Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur (w. 1443 H)</span></div></div>'
        for i, (w, q, a, b, c) in enumerate(qa))
    return (f'<div class="explorer-d"><div class="fx-list" role="tablist" aria-label="Pertanyaan contoh">{tabs}</div>'
            f'<div class="fx-stage"><div class="fx-card"><div class="fx-top"><span class="k" id="who">{E(qa[0][0])}</span><span class="chip">Contoh tampilan</span></div>'
            f'<div class="asked" id="asked">{E(qa[0][1])}</div>{reps}'
            f'<p class="note">Disusun dari materi Pengantar Fikih Tahawwulat di aplikasi. Jawaban sebenarnya bergantung pada pertanyaan dan kitab yang tersedia. Penjelasan AI perlu diverifikasi kepada guru.</p></div></div></div>')

def faq(items):
    return '<div class="faq">' + "".join(f'<details><summary><span>{E(q)}</span><span class="pm" aria-hidden="true"></span></summary><div class="a">{a}</div></details>' for q, a in items) + '</div>'

FAQ_MAIN = [
    ("Apakah OpenTurath AI mengeluarkan fatwa?", "Tidak. OpenTurath AI membantu menemukan pembahasan dan rujukan. Fatwa dan penerapan hukum pada keadaan tertentu tetap kepada ulama yang berkompeten."),
    ("Apakah ia menggantikan guru?", "Tidak. Ia alat bantu yang menghemat waktu mencari ibarah. Pemahaman dan adab tumbuh bersama guru, dan aplikasi selalu mengingatkan hal itu."),
    ("Dari mana jawabannya berasal?", "Dari kumpulan kitab yang dikurasi pada bidang yang Anda pilih, bukan dari seluruh internet. Setiap bidang punya asisten dan metodologinya sendiri."),
    ("Apa bedanya dengan AI umum?", "AI umum menjawab dari apa saja dan mudah mengarang ayat, kitab, atau ibarah. OpenTurath AI membatasi diri pada korpus yang dikurasi per bidang dan mengarahkan jawaban ke rujukan."),
    ("Mengapa nomor halaman bisa berbeda dengan kitab cetakan saya?", "Tata letak berbeda antar penerbit dan cetakan. Cocokkan judul kitab, edisi, jilid, dan halaman dengan edisi yang Anda pegang."),
    ("Di perangkat apa dan bagaimana aksesnya?", "Android, macOS, dan Windows. Masuk dengan akun Google, lalu pilih modul bidang yang ingin dibuka. Perpanjangan manual, tanpa auto-debit."),
    ("Bagaimana melaporkan kesalahan?", "Kirim kutipan, kitab dan edisi yang Anda pegang, serta alasannya ke support@openturath.id, atau pakai <a href='bantuan.html#lapor'>formulir laporan</a>."),
]

def head(kick, h1, lead, extra=""):
    return f'<section class="phead"><div class="wrap"><div class="kicker">{kick}</div><h1>{h1}</h1><p class="lead">{lead}</p>{extra}</div></section>'

def sec(inner, cls="sec", band=False): return f'<section class="{cls}{" band" if band else ""}"><div class="wrap">{inner}</div></section>'
def shead(kick, h2, lead=""): return f'<div class="sec-head rv"><div class="kicker">{kick}</div><h2>{h2}</h2>' + (f'<p class="lead">{lead}</p>' if lead else '') + '</div>'

# ======================= BERANDA =======================
CHK = ic("check")
home = f'''
<section class="welcome"><canvas id="ring" aria-hidden="true"></canvas>
<div class="hero-mark rv in">{mark(50)}</div>
<h1 class="hero rv in">Menjaga asal, membuka cakrawala.</h1>
<p class="lede rv in d1">OpenTurath AI membantu penuntut ilmu memahami kitab dan menemukan rujukan ibarahnya, bidang demi bidang, dari kitab dan ceramah para ulama.</p>
<div class="cta-row rv in d2"><a class="btn primary" href="unduh.html">{ic("download")}Unduh aplikasi</a><a class="btn tonal" href="cara-kerja.html">Lihat cara kerja</a></div>
<div class="meta-row rv in d3"><span>{CHK}Ditinjau para ulama</span><span>{CHK}Dikurasi dengan wasathiyyah syar'iyyah</span><span>{CHK}Bukan pengganti guru</span></div></section>

<section class="sec"><div class="wrap">{shead("Mengapa OpenTurath","Kitabnya agung. Pintunya sering terasa terlalu tinggi.","Tiga kesulitan yang dialami hampir setiap penuntut ilmu, dan jawaban kami untuk masing-masing.")}
<div class="trio">
<div class="rv"><div class="n">01</div><h3>Bahasa dan istilah</h3><p>Kitab klasik berbahasa Arab tinggi. Satu halaman bisa menghabiskan satu jam, dan istilahnya tetap membingungkan.</p><span class="fix">Penjelasan sederhana, teks Arab asli tetap tampil.</span></div>
<div class="rv d1"><div class="n">02</div><h3>Mencari ibarah</h3><p>Menemukan satu nas memakan waktu lama, apalagi bila kata kuncinya tidak diketahui.</p><span class="fix">Bertanya dengan bahasa sehari-hari, ibarah dan rujukannya ditunjukkan.</span></div>
<div class="rv d2"><div class="n">03</div><h3>AI tanpa sandaran</h3><p>AI umum sering mengarang ayat, kitab, bahkan ibarah, padahal banyak orang bertanya perkara agama kepadanya.</p><span class="fix">Dibatasi pada kitab bidangnya yang dikurasi.</span></div></div></div></section>

<section class="sec" id="demo"><div class="wrap">{shead("Satu pertanyaan, langsung ke ibarahnya","Jawaban yang selalu menunjuk ke kitabnya.","Pilih satu pertanyaan di kiri. Pratinjau menunjukkan bagaimana penjelasan, ibarah Arab, dan rujukan hadir bersama.")}<div class="rv">{demo()}</div></div></section>

<section class="sec"><div class="wrap">{shead("Untuk siapa","Dibangun untuk para pembaca kitab.")}
<div class="cases">
<div class="case rv">{ic("cap")}<h3>Santri dan penuntut ilmu</h3><p>Mulai memahami kitab tanpa harus lebih dulu menaklukkan bahasa dan istilahnya.</p><div class="q"><span><b>Tanyakan:</b> Apa yang dimaksud rukun keempat?</span></div></div>
<div class="case rv d1">{ic("library")}<h3>Mahasiswa dan peneliti</h3><p>Cari pembahasan lintas kitab, bandingkan keterangan, dan simpan rujukan untuk tulisan Anda.</p><div class="q"><span><b>Tanyakan:</b> Di kitab mana pembahasan ini dibahas paling rinci?</span></div></div>
<div class="case rv d2">{ic("scroll")}<h3>Pengajar, penceramah, khatib</h3><p>Siapkan materi, periksa dalil dan ibarah, lalu sampaikan dengan lebih yakin.</p><div class="q"><span><b>Tanyakan:</b> Susun kerangka khutbah tentang sikap saat masa fitnah.</span></div></div></div></div></section>

<section class="sec" id="bidang"><div class="wrap">{shead("Bidang ilmu","Satu ilmu, satu asisten.","Setiap asisten berpegang pada kitab bidangnya dan metodologinya sendiri, supaya jawaban tidak bercampur.")}<div class="rv">{explorer("fikih")}</div>
<p style="margin-top:32px"><a class="link" href="bidang.html">Lihat semua bidang{ic("arrow","arr")}</a></p></div></section>

<section class="sec band"><div class="wrap">{shead("Fikih Tahawwulat","Rukun keempat agama, peta navigasi di tengah badai zaman.","Dalam hadis Jibril, Nabi menjawab empat pertanyaan. Tiga yang pertama berpadu dengan fikih, akidah, dan tasawuf. Yang keempat menjaga ketiganya. Inilah yang tergambar pada logo OpenTurath.")}
<div class="tahaw rv"><div class="gate" data-hl="">{gate_svg()}</div>
<div class="rukun" role="list">
<button class="rk" data-hl="islam" role="listitem"><span class="i">01</span><span class="tt">Islam<small>bersambung dengan Fikih</small></span><span class="ar">الإسلام</span></button>
<button class="rk" data-hl="iman" role="listitem"><span class="i">02</span><span class="tt">Iman<small>bersambung dengan Akidah</small></span><span class="ar">الإيمان</span></button>
<button class="rk" data-hl="ihsan" role="listitem"><span class="i">03</span><span class="tt">Ihsan<small>bersambung dengan Tasawuf</small></span><span class="ar">الإحسان</span></button>
<button class="rk" data-hl="tahaw" role="listitem"><span class="i">04</span><span class="tt">Tanda-tanda zaman<small>Ilmu rukun keempat: Fikih Tahawwulat</small></span><span class="ar">علامات الساعة</span></button></div></div>
<div class="branches rv">
<div class="br"><span class="ar">المحقق</span><b>Al-Muhaqqiq</b><span>Teks matan dan ibarah</span></div>
<div class="br"><span class="ar">البيان</span><b>Al-Bayan</b><span>Penyederhanaan konsep dan istilah</span></div>
<div class="br"><span class="ar">المختبر</span><b>Al-Mukhtabir</b><span>Uji pemahaman dan nalar</span></div>
<div class="br"><span class="ar">الحبيب</span><b>Al-Habib</b><span>Arsip muhadharah Al-Habib Abu Bakar</span></div>
<div class="br"><span class="ar">الخطيب</span><b>Al-Khatib</b><span>Materi dakwah dan khutbah</span></div></div>
<p style="margin-top:40px"><a class="btn primary" href="fikih-tahawwulat.html">Kenali Fikih Tahawwulat{ic("arrow","arr")}</a></p></div></section>

<section class="sec"><div class="wrap">{shead("Cara kami menjaga","Pagar keilmuan di balik setiap jawaban.")}
<div class="pillars">
<div class="pillar rv"><div class="bic">{ic("layers")}</div><h3>Satu bidang, satu metodologi</h3><p>Setiap asisten hanya berpegang pada kitab bidangnya. Fikih dan hadis punya cara kerja berbeda, dan tidak dicampur.</p></div>
<div class="pillar rv d1"><div class="bic">{ic("scale")}</div><h3>Kurasi wasathiyyah syar'iyyah</h3><p>Kitab dipilih satu per satu agar keilmuan tidak terpolitisasi dan tidak dipakai menjatuhkan kelompok lain.</p></div>
<div class="pillar rv d2"><div class="bic">{ic("check")}</div><h3>Ditinjau para ulama</h3><p>Para ulama diberi akses memeriksa isi di bidangnya, dan pakar mengarahkan metodologinya.</p></div>
<div class="pillar rv d3"><div class="bic">{ic("book")}</div><h3>Rujukan, dengan batas yang jujur</h3><p>Jawaban diarahkan ke kitab, jilid, dan halaman bila tersedia. Penjelasan AI tetap diverifikasi kepada guru.</p></div></div>
<div class="statement rv"><div><p>AI hanyalah alat. Gurunya tetap guru.</p></div><div><p class="small">Penjelasan AI perlu diverifikasi kepada guru, terutama untuk amal dan fatwa.</p><a class="btn inv-o sm" href="pedoman.html">Baca pedoman keilmuan</a></div></div></div></section>

<section class="sec"><div class="wrap">{shead("Ekosistem","OpenTurath lebih besar dari satu aplikasi.","Satu merek, empat lini yang saling menguatkan.")}
<div class="eco">
<a class="first rv" href="bidang.html"><div class="top"><div class="eic">{mark(26)}</div><span class="status">Rilis 23 Okt 2026</span></div><h3>OpenTurath AI</h3><p>AI Islami berbasis turath yang mencakup semua bidang ilmu dan khazanah para ulama. Tiap bidang punya asisten dan metodologinya sendiri.</p><span class="go">Jelajahi bidang{ic("arrow","arr")}</span></a>
<div class="e rv d1"><div class="top"><div class="eic">{ic("library")}</div><span class="status">Dibangun</span></div><h3>Maktabah OpenTurath</h3><p>Pusat unduh kitab yang menyatukan semua cetakan dan banyak sumber unduh dalam satu halaman.</p></div>
<div class="e rv d2"><div class="top"><div class="eic">{ic("scroll")}</div><span class="status">Tahap uji</span></div><h3>AI Manuskrip</h3><p>Membantu membaca dan menahkik manuskrip: makna bahasa, tokoh yang dimaksud, serta hadis dan ayat yang dikutip.</p></div>
<div class="e rv d3"><div class="top"><div class="eic">{ic("cap")}</div><span class="status">Rencana</span></div><h3>Akademi OpenTurath</h3><p>Belajar memakai AI bagi penuntut ilmu: dari percakapan, gambar dan video dakwah, hingga membuat aplikasi dan AI agent.</p></div></div>
<p style="margin-top:28px"><a class="link" href="ekosistem.html">Tentang ekosistem OpenTurath{ic("arrow","arr")}</a></p></div></section>

<section class="sec" style="border-top:0"><div class="wrap"><div class="founder"><div class="rv"><span class="pill">Dibuat oleh pelajar, untuk para pelajar.</span>
<blockquote>Satu halaman kitab, satu jam, dan masih belum paham. Dari kesulitan itu lahir OpenTurath.</blockquote></div>
<div class="rv d1"><p class="lead" style="margin-bottom:20px">Rafli Husen adalah santri yang berguru langsung kepada Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur dan para ulama Hadramaut. Ia membangun OpenTurath seorang diri, dengan para ulama yang memeriksa isi keilmuannya.</p>
<p><a class="link" href="tentang.html">Baca ceritanya{ic("arrow","arr")}</a></p></div></div></div></section>

<section class="sec band" id="unduh"><div class="wrap" style="text-align:center">
<div class="sec-head" style="margin-inline:auto;margin-bottom:40px"><h2>Bawa khazanahnya ke perangkat Anda.</h2><p class="lead" style="margin:20px auto 0">Satu akun untuk Android, macOS, dan Windows. Masuk dengan akun Google, lalu pilih bidang pertama Anda.</p></div>
<div class="platforms rv" style="text-align:start">
<div class="plat" data-os="android"><div class="p-ic">{ic("android")}</div><h3>Android</h3><p class="req">Android 8.0 ke atas</p><a class="btn inv" href="unduh.html#android">{ic("download")}Unduh untuk Android</a></div>
<div class="plat" data-os="macos"><div class="p-ic">{ic("laptop")}</div><h3>macOS</h3><p class="req">macOS 13 ke atas</p><a class="btn inv" href="unduh.html#macos">{ic("download")}Unduh untuk macOS</a></div>
<div class="plat" data-os="windows"><div class="p-ic">{ic("windows")}</div><h3>Windows</h3><p class="req">Windows 10 ke atas</p><a class="btn inv" href="unduh.html#windows">{ic("download")}Unduh untuk Windows</a></div></div>
<div class="access" style="justify-content:center"><span>Masuk dengan akun Google</span><span>Akses per modul bidang</span><span>Perpanjangan manual, tanpa auto-debit</span></div></div></section>

<section class="sec"><div class="wrap">{shead("Pertanyaan","Jawaban singkat.")}<div class="rv">{faq(FAQ_MAIN)}</div><p style="margin-top:32px"><a class="link" href="bantuan.html">Semua bantuan{ic("arrow","arr")}</a></p></div></section>'''
write("index.html", "OpenTurath: Menjaga asal, membuka cakrawala", "OpenTurath AI membantu penuntut ilmu memahami kitab dan menemukan rujukan ibarahnya, bidang demi bidang. AI Islami berbasis turath.", home)

# ======================= BIDANG =======================
write("bidang.html", "OpenTurath AI: Bidang ilmu — OpenTurath", "Peta bidang ilmu OpenTurath AI: fikih empat mazhab, hadis, tafsir, ushul, akidah, tasawuf, bahasa Arab, sejarah, bibliografi, dan Fikih Tahawwulat.",
      head("OpenTurath AI", "Bidang ilmu.", "Setiap bidang punya asisten, kumpulan kitab, dan metodologinya sendiri. Pilih yang sesuai dengan ilmu yang Anda pelajari.") +
      sec(explorer("all", with_all=True, search=True), "sec-tight") +
      sec('<div class="statement" style="margin-top:0"><div><p>Cakupan terus bertambah.</p></div><div><p class="small">Dari Fikih Tahawwulat dan bidang yang ada, meluas ke seluruh ilmu Islam dan khazanah para ulama.</p><a class="btn inv-o sm" href="ekosistem.html">Arah OpenTurath</a></div></div>', "sec-tight"), "bidang.html")

# ======================= FIKIH TAHAWWULAT =======================
bab = "".join(f'<li><b>{b["no"]:02d}</b> {E(b["judul"])}</li>' for b in PENG["bab"])
br_rows = [("Al-Muhaqqiq", "المحقق", "Teks matan dan ibarah", "Mencari, memeriksa, dan mengaitkan teks dengan sumbernya.", "Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?"),
           ("Al-Bayan", "البيان", "Penyederhanaan konsep", "Menjelaskan konsep dan istilah dengan bahasa sederhana secara metodis.", "Bagaimana penjelasan al-ghutsa'iyyah dalam kitab?"),
           ("Al-Mukhtabir", "المختبر", "Uji pemahaman dan nalar", "Menilai pemahaman dan menguji persoalan kontemporer.", "Uji pemahaman saya tentang rukun agama yang empat."),
           ("Al-Habib", "الحبيب", "Arsip muhadharah", "Gudang ceramah dan rekaman Al-Habib Abu Bakar, dengan tautan video pada menit yang tepat.", "Muhadharah mana yang membahas sikap saat masa fitnah?"),
           ("Al-Khatib", "الخطيب", "Materi dakwah dan khutbah", "Menyusun khutbah dan materi ceramah serta mengarahkan persoalan dakwah.", "Susun kerangka khutbah tentang sikap saat masa fitnah.")]
brt = "".join(f'<tr><td><b>{a}</b><div class="ar" style="font-size:22px;color:var(--muted)">{b}</div></td><td>{c}</td><td>{d}</td><td style="font-style:normal"><span class="small">&ldquo;{e}&rdquo;</span></td></tr>' for a, b, c, d, e in br_rows)
tstyle = "<style>.tbl{width:100%;border-collapse:collapse}.tbl th{text-align:start;font-size:12px;letter-spacing:.16em;text-transform:uppercase;color:var(--muted);font-weight:500;padding:12px 16px 12px 0;border-bottom:1px solid var(--line-strong)}.tbl td{padding:22px 16px 22px 0;border-bottom:1px solid var(--line);vertical-align:top;font-size:16px}@media(max-width:760px){.tbl,.tbl tbody,.tbl tr,.tbl td{display:block}.tbl thead{display:none}.tbl td{padding:6px 0;border:0}.tbl tr{padding:20px 0;border-bottom:1px solid var(--line)}}</style>"
ibr = SL["empat-rukun"]
write("fikih-tahawwulat.html", "Fikih Tahawwulat — OpenTurath", "Kenali Fikih Tahawwulat, rukun keempat agama, dan lima asisten OpenTurath AI untuk mempelajarinya.",
      head("Fikih Tahawwulat", "Memahami perubahan zaman dengan petunjuk Nabi ﷺ.", "Fikih Tahawwulat membaca perubahan zaman dengan kacamata hadis-hadis tanda zaman, lalu menurunkannya menjadi sikap dan langkah. Korpusnya adalah kitab karya Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur dan arsip muhadharah beliau.",
           '<div class="ar" style="font-size:clamp(44px,6vw,80px);margin-top:8px">فِقْهُ التَّحَوُّلَاتِ</div>') +
      sec(f'''<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">Empat rukun agama.</h2><p class="lead" style="margin-bottom:20px">Dalam hadis Jibril, Nabi menjawab empat pertanyaan: Islam, iman, ihsan, dan tanda-tanda kiamat. Menurut Fikih Tahawwulat, keempatnya adalah rukun agama.</p>
<div class="ibarah" style="margin-top:24px"><div class="lbl">Ibarah</div><div class="ar" style="font-size:30px">{E(ibr["ibarah"])}</div><p class="small" style="margin:6px 0 0">{E(ibr["sumber"])}</p></div></div>
<div class="rv d1"><ul class="list-clean"><li><b>Islam</b> bersambung dengan fikih.</li><li><b>Iman</b> bersambung dengan akidah.</li><li><b>Ihsan</b> bersambung dengan tasawuf.</li><li><b>Tanda-tanda zaman</b> bersambung dengan ilmu rukun keempat: Fikih Tahawwulat, yang menjaga ketiganya saat keadaan membingungkan.</li></ul></div></div>''') +
      sec(shead("Lima asisten", "Satu bidang, lima cara belajar.", "Lima asisten membagi disiplin ini menurut kebutuhan pembelajar. Satu akses membuka kelimanya.") + tstyle + f'<table class="tbl rv"><thead><tr><th>Asisten</th><th>Peran</th><th>Fungsi</th><th>Contoh pertanyaan</th></tr></thead><tbody>{brt}</tbody></table>', "sec band") +
      sec(shead("Pengantar", "Mulai dari video pengantar.", "Di dalam aplikasi, video pengantar sekitar dua belas menit menuntun Anda lewat lima belas bab, lengkap dengan ibarah dan sumbernya.") + f'<ul class="list-clean rv" style="columns:3 240px;column-gap:40px">{bab}</ul><p style="margin-top:36px"><a class="btn primary" href="unduh.html">{ic("download")}Unduh aplikasi</a></p>'), "fikih-tahawwulat.html")

# ======================= CARA KERJA =======================
steps = [("Pilih bidang", "Pilih asisten sesuai ilmu yang ditanyakan, dari fikih sampai hadis, tafsir, dan bahasa Arab."), ("Ajukan pertanyaan", "Tulis dengan bahasa sehari-hari, atau mulai dari pertanyaan contoh yang tersedia di tiap bidang."),
         ("Asisten menelusuri", "Penelusuran hanya dari kumpulan kitab bidang itu, bukan dari seluruh internet."), ("Baca jawabannya", "Penjelasan, ibarah Arab, dan nomor rujukan hadir bersama dalam satu jawaban."),
         ("Periksa kitabnya", "Buka keterangan kitab, cocokkan dengan edisi yang Anda pegang, dan baca konteksnya."), ("Simpan dan bawa ke guru", "Simpan ke Catatan beserta rujukannya, lalu bawa ke majelis untuk dipastikan.")]
st = "".join(f'<div class="rv"><div class="n">{i+1:02d}</div><h3>{t}</h3><p>{d}</p></div>' for i, (t, d) in enumerate(steps))
pr = [("Satu bidang, satu korpus", "Tiap asisten hanya berpegang pada kitab bidangnya, sehingga metodologi tiap ilmu tidak tercampur."), ("Sumber yang bersih", "Teks diambil dari basis data kitab resmi, bukan salinan sembarang."),
      ("Kitab tidak dipotong sembarang", "Kitab ditaruh utuh. Kitab besar dibagi hanya mengikuti sekat jilid yang resmi."), ("Stempel rujukan", "Setiap potongan teks bertanda: judul kitab, pengarang dan tahun wafat, penerbit atau pentahqiq, jilid, halaman."),
      ("Kurasi wasathiyyah syar'iyyah", "Kitab dipilih satu per satu agar tidak terpolitisasi dan tidak dipakai menjatuhkan kelompok lain."), ("Diperiksa sebelum masuk", "Berkas melewati pemeriksaan otomatis sebelum menjadi bagian korpus.")]
prh = "".join(f'<li><b>{t}.</b> {d}</li>' for t, d in pr)
write("cara-kerja.html", "Cara kerja — OpenTurath", "Dari pertanyaan sampai rujukan: cara kerja OpenTurath AI dalam enam langkah, dan prinsip penyusunan korpus di baliknya.",
      head("Cara kerja", "Dari pertanyaan sampai rujukan.", "Enam langkah sederhana, dan satu kebiasaan yang kami ajak Anda jaga: selalu kembali membuka kitabnya.") +
      sec(f'<div class="steps6">{st}</div>', "sec-tight") +
      sec(f'''<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">Di balik layar.</h2><p class="lead">Enam prinsip yang menjaga korpus tiap asisten tetap rapi dan dapat ditelusuri.</p></div><ul class="list-clean rv d1">{prh}</ul></div>''') +
      sec(f'''<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">Batas yang jujur.</h2><p class="lead">Mengetahui batas alat adalah bagian dari adab menuntut ilmu.</p></div>
<ul class="list-clean rv d1"><li>Jawaban AI dapat keliru atau kurang lengkap.</li><li>Penjelasan AI perlu diverifikasi kepada guru, terutama untuk amal dan fatwa.</li><li>Nomor halaman dapat berbeda antar edisi cetak.</li><li>Tidak semua kitab ada di setiap bidang.</li><li>OpenTurath AI bukan pemberi fatwa dan tidak menggantikan guru.</li></ul></div>''', "sec band") , "cara-kerja.html")

# ======================= PEDOMAN =======================
adab = "".join(f'<div class="pillar rv"><h3 style="font-size:22px">{E(p["heading"][0])}</h3><p>{E(p["body"][0])}</p></div>' for p in ADAB["principles"][:6])
write("pedoman.html", "Pedoman keilmuan — OpenTurath", "Wasathiyyah syar'iyyah sebagai ukuran kurasi kitab, peran AI dan guru, serta adab memakai OpenTurath AI.",
      head("Pedoman keilmuan", "Alat yang rendah hati di hadapan ilmu.", "Cara kami memilih kitab, peran AI dibanding guru, dan adab yang kami ajak setiap pengguna menjaganya.") +
      sec(f'''<div class="cols2"><div class="rv"><div class="ar" style="font-size:clamp(40px,5vw,64px);margin-bottom:8px">الوسطية الشرعية والاعتدال الواعي</div><p class="small" style="margin-bottom:24px">Al-Wasathiyyah Asy-Syar'iyyah wal-I'tidal Al-Wa'i</p>
<p class="lead">Ukuran kami memilih kitab. Wasathiyyah syar'iyyah bukan kompromi mekanis atau titik tengah politis. Ia bertumpu pada Al-Qur'an, sunnah, dan akhlak kenabian, dan menjaga dari dua jurang: berlebihan dan meremehkan.</p></div>
<ul class="list-clean rv d1"><li><b>Inti.</b> Kitab induk bersanad yang menjadi dasar jawaban: mazhab fikih empat, akidah Asy'ari dan Maturidi, tasawuf yang lurus, dan Fikih Tahawwulat.</li>
<li><b>Pembanding terbatas.</b> Pandangan yang tajam atau diperselisihkan disimpan hanya sebagai pembanding, tidak menjadi dasar hukum atau jawaban otomatis.</li>
<li><b>Dikecualikan.</b> Naskah propaganda kekerasan, adu domba antar muslim, dan tulisan yang dirancang merusak akidah serta kehormatan ulama.</li>
<li><b>Salamatul lisan.</b> AI tidak mencela, mengkafirkan, atau menyesatkan sesama muslim.</li><li><b>Salamatul yad.</b> AI tidak memprovokasi kekerasan atau pertumpahan darah.</li></ul></div>''') +
      sec(shead("Adab", "Panduan bagi pembaca.") + f'<div class="pillars" style="grid-template-columns:repeat(3,1fr)">{adab}</div><style>@media(max-width:900px){{.pillars{{grid-template-columns:1fr 1fr!important}}}}@media(max-width:560px){{.pillars{{grid-template-columns:1fr!important}}}}</style>', "sec", False) +
      sec('<div class="statement" style="margin-top:0"><div><p>Menemukan kesalahan? Beri tahu kami.</p></div><div><p class="small">Sertakan kutipan, kitab, dan edisi yang Anda pegang agar mudah diperiksa.</p><a class="btn inv-o sm" href="bantuan.html#lapor">Laporkan kesalahan</a></div></div>', "sec-tight"), "pedoman.html")

# ======================= EKOSISTEM =======================
def lini(n, ico, st, title, desc, pts, first=False):
    li = "".join(f"<li>{p}</li>" for p in pts)
    return (f'<div class="cols2" style="padding-block:clamp(40px,5vw,72px);border-top:1px solid var(--line-strong)"><div class="rv"><div class="kicker">Lini {n}</div><h2 style="margin-bottom:16px">{title}</h2><span class="status">{st}</span></div>'
            f'<div class="rv d1"><p class="lead" style="margin-bottom:20px">{desc}</p><ul class="list-clean">{li}</ul></div></div>')
write("ekosistem.html", "Ekosistem — OpenTurath", "OpenTurath lebih besar dari satu aplikasi: OpenTurath AI, Maktabah OpenTurath, AI Manuskrip, dan Akademi OpenTurath.",
      head("Ekosistem", "OpenTurath lebih besar dari satu aplikasi.", "Tujuannya satu: menjadi rumah baru bagi seluruh penuntut ilmu. Empat lini yang saling menguatkan.") +
      sec(lini("01", "", "Rilis 23 Okt 2026", "OpenTurath AI", "AI Islami berbasis turath yang mencakup semua bidang ilmu dan khazanah para ulama.", ["Asisten per bidang, masing-masing dengan korpus dan metodologinya.", "Jawaban disertai ibarah dan rujukan.", "Pustaka, Catatan, dan multi-tab di Android, macOS, dan Windows.", "Dari Fikih Tahawwulat, meluas ke nahwu, sharaf, bahasa Arab, fikih, ushul fikih, dan seluruh ilmu Islam."]) +
          lini("02", "", "Dibangun", "Maktabah OpenTurath", "Pusat unduh kitab yang menyatukan semua cetakan dan banyak sumber unduh dalam satu halaman.", ["Satu kitab, semua cetakannya: edisi penerbit yang berbeda ditampilkan berdampingan.", "Tombol unduh dari berbagai sumber dalam satu tempat.", "Terhubung dengan OpenTurath AI untuk membuka kitab yang dirujuk."]) +
          lini("03", "", "Tahap uji", "AI Manuskrip", "Membantu membaca dan menahkik manuskrip.", ["Memberi makna bahasa.", "Menjelaskan tokoh yang dimaksud dalam naskah.", "Mengenali hadis dan ayat yang dikutip."]) +
          lini("04", "", "Rencana", "Akademi OpenTurath", "Belajar memakai AI bagi penuntut ilmu, dalam empat tahap.", ["Percakapan dengan AI, sebagai dasar.", "Gambar dan video untuk dakwah.", "Membuat aplikasi yang Anda butuhkan.", "Membuat AI agent."]) , "sec") , "ekosistem.html")

# ======================= TENTANG =======================
tl = [("2023", "Gagasan lahir", "Saat AI mulai populer, muncul pertanyaan: bagaimana jika AI dapat menyebut rujukan dengan sangat akurat dan terhubung ke maktabah?"),
      ("2023 sampai 2026", "Belajar dan membangun", "Tiga tahun mempelajari AI dan cara membuat aplikasi secara mendalam, serta semua yang dibutuhkan untuk mencapai tujuan ini."),
      ("7 Mei 2026", "Diumumkan di Hadramaut", "Di Universitas Al-Wasatiyah, Hadramaut, Yaman, di hadapan para ulama. Di sinilah visi OpenTurath dipaparkan untuk pertama kalinya."),
      ("23 Oktober 2026", "Rilis publik perdana", "OpenTurath AI dibuka untuk publik.")]
tlh = "".join(f'<div class="rv"><div class="d">{d}</div><div><h3 style="font-size:24px;margin-bottom:6px">{t}</h3><p>{x}</p></div></div>' for d, t, x in tl)
vals = [("Kembali kepada sumber", "Setiap jawaban berpijak pada kitab dan ceramah ulama."), ("Kembali berguru", "AI hanyalah alat, dan tidak menggantikan guru."), ("Amanah", "Menjaga ketepatan ibarah dan jujur tentang batas."),
        ("Wasathiyyah syar'iyyah", "Kurasi yang tidak berlebihan dan tidak meremehkan."), ("Metodologi tiap ilmu dijaga", "Fikih dan hadis punya metodenya masing-masing."), ("Sarana baru, esensi terjaga", "Memperbarui cara belajar tanpa merusak inti ajaran.")]
vh = "".join(f'<div class="pillar rv"><h3 style="font-size:22px">{t}</h3><p>{d}</p></div>' for t, d in vals)
write("tentang.html", "Tentang — OpenTurath", "Cerita OpenTurath: dirintis Rafli Husen, santri yang berguru kepada Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur. Dibuat oleh pelajar, untuk para pelajar.",
      head("Tentang", "Dibuat oleh pelajar, untuk para pelajar.", "OpenTurath adalah AI Islami berbasis turath: setiap jawabannya berpijak pada kitab dan ceramah para ulama.") +
      sec('''<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">Satu halaman, satu jam.</h2><span class="pill">Rafli Husen</span></div><div class="rv d1">
<p class="lead" style="margin-bottom:18px">Rafli adalah santri yang berguru langsung kepada Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur dan para ulama Hadramaut. Saat murajaah seorang diri, ia membaca salah satu kitab terbesar Fikih Tahawwulat dan menerjemahkannya kata demi kata. Satu halaman menghabiskan sekitar satu jam, dan ia tetap belum paham.</p>
<p style="margin-bottom:16px">Dari kesulitan itu lahir satu pertanyaan: bagaimana memudahkan penuntut ilmu menerjemahkan dan memahami kitab-kitab Fikih Tahawwulat, terutama istilah-istilahnya? Jawabannya ia cari lewat teknologi, dengan satu syarat: setiap jawaban harus punya rujukan.</p>
<p>OpenTurath dikerjakan seorang diri, dengan para ulama yang memeriksa isi keilmuannya. Kini ia menempuh pascasarjana di Yaman.</p></div></div>''') +
      sec(shead("Tonggak", "Dari satu gagasan sampai rilis perdana.") + f'<div class="timeline">{tlh}</div>', "sec", False) +
      sec(shead("Nilai", "Enam nilai yang memandu keputusan.") + f'<div class="pillars" style="grid-template-columns:repeat(3,1fr)">{vh}</div><style>@media(max-width:900px){{.pillars{{grid-template-columns:1fr 1fr!important}}}}@media(max-width:560px){{.pillars{{grid-template-columns:1fr!important}}}}</style>') +
      sec('<div class="statement" style="margin-top:0"><div><p>Bicara dengan kami.</p></div><div><p class="small">support@openturath.id</p><a class="btn inv-o sm" href="bantuan.html">Bantuan</a></div></div>', "sec-tight"), "tentang.html")

# ======================= UNDUH =======================
def plat(osid, icn, name, req, steps_):
    li = "".join(f"<li>{s}</li>" for s in steps_)
    return (f'<div class="plat" id="{osid}" data-os="{osid}"><div style="display:flex;justify-content:space-between;align-items:center"><div class="p-ic">{ic(icn)}</div><span class="status rec-badge" hidden>Untuk perangkat Anda</span></div><h3>{name}</h3><p class="req">{req}</p>'
            f'<ul class="list-clean" style="font-size:15px">{li}</ul><a class="btn primary" href="https://openturath.id/id/download/">{ic("download")}Unduh untuk {name}</a></div>')
write("unduh.html", "Unduh — OpenTurath", "Unduh OpenTurath AI untuk Android, macOS, dan Windows.",
      head("Unduh", "Mulai belajar hari ini.", "OpenTurath AI tersedia untuk ponsel dan komputer. Masuk dengan akun Google, lalu pilih bidang pertama Anda.") +
      sec(f'''<div class="platforms rv">{plat("android","android","Android","Android 8.0 ke atas",["Unduh berkas pemasangan.","Izinkan pemasangan dari sumber ini bila diminta.","Buka aplikasi dan masuk."])}
{plat("macos","laptop","macOS","macOS 13 ke atas",["Unduh berkas pemasangan.","Seret aplikasi ke folder Aplikasi.","Buka dan masuk."])}
{plat("windows","windows","Windows","Windows 10 ke atas",["Unduh berkas arsip.","Ekstrak, lalu jalankan aplikasi.","Masuk dengan akun Google."])}</div>
<div class="access"><span>Masuk dengan akun Google</span><span>Akses per modul bidang</span><span>Perpanjangan manual, tanpa auto-debit</span></div>''', "sec-tight") +
      sec(shead("Setelah memasang", "Tiga langkah pertama.") + '<div class="steps6" style="grid-template-columns:repeat(3,1fr)"><div class="rv"><div class="n">01</div><h3>Masuk</h3><p>Gunakan akun Google Anda. Akun yang sama berlaku di semua perangkat.</p></div><div class="rv d1"><div class="n">02</div><h3>Pilih bidang</h3><p>Mulailah dari bidang yang sedang Anda pelajari, atau dari pengantar Fikih Tahawwulat.</p></div><div class="rv d2"><div class="n">03</div><h3>Bertanya</h3><p>Tulis pertanyaan dengan bahasa sehari-hari, lalu buka kitab yang dirujuk.</p></div></div>'), "unduh.html")

# ======================= BANTUAN =======================
FAQ_MORE = FAQ_MAIN + [
    ("Berapa percakapan yang bisa dibuka bersamaan?", "Lima tab di macOS dan tiga tab di perangkat lain."),
    ("Di mana catatan saya disimpan?", "Catatan menyimpan jawaban beserta kutipan Arab, kitab, dan halamannya, sehingga tetap bisa ditelusuri. Rinciannya ada di kebijakan privasi."),
    ("Bagaimana dengan pengembalian dana?", "Ketentuan langganan dan pengembalian dana dijelaskan pada halaman kebijakan. Hubungi support@openturath.id untuk bantuan.")]
write("bantuan.html", "Bantuan — OpenTurath", "Pertanyaan yang sering muncul, cara melaporkan kesalahan, dan kontak OpenTurath.",
      head("Bantuan", "Kami siap membantu.", "Jawaban singkat, formulir laporan kesalahan, dan cara menghubungi kami.") +
      sec(f'<div class="rv">{faq(FAQ_MORE)}</div>', "sec-tight") +
      sec('''<div class="cols2" id="lapor"><div class="rv"><h2 style="margin-bottom:16px">Laporkan kesalahan.</h2><p class="lead">Informasi dari pembaca membantu kami memeriksa bagian yang perlu diperbaiki. Sertakan kutipan, kitab, dan edisi yang Anda pegang.</p></div>
<form class="form rv d1" id="report"><label>Bidang atau asisten<input name="bidang" placeholder="Contoh: AI Fikih Syafi'i" required></label><label>Kutipan yang dipertanyakan<textarea name="kutipan" required></textarea></label>
<label>Kitab dan edisi yang Anda pegang<input name="kitab" placeholder="Judul, penerbit, jilid, halaman"></label><label>Alasan<textarea name="alasan"></textarea></label><button class="btn primary" type="submit" style="justify-self:start">Kirim lewat surel</button></form></div>''', "sec", False) +
      sec('''<div class="cols2" id="legal"><div class="rv"><h2 style="margin-bottom:16px">Kontak dan kebijakan.</h2><p class="lead">support@openturath.id</p></div><ul class="list-clean rv d1"><li>Ketentuan layanan</li><li>Kebijakan privasi</li><li>Langganan dan pengembalian dana</li><li>Hak cipta dan pelaporan materi</li></ul></div>''', "sec band"), "bantuan.html")

(OUT / "assets" / "mark.svg").write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 616 674"><rect width="616" height="674" fill="none"/><g fill="#100F0E">' + "".join(f'<path transform="translate(-204,-175)" d="{d}"/>' for d in PATHS) + '</g></svg>')
print("dibangun:", sorted(p.name for p in OUT.glob("*.html")))
