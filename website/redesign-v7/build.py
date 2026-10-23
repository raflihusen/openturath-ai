#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""OpenTurath Website V7.1: prototipe statis tiga bahasa (ID, EN, AR) dari satu sumber.
Jalankan:  python3 build.py   ->  site/{id,en,ar}/*.html, site/index.html (pengalih), sitemap, robots, 404.
Fakta: data aplikasi (info_ai.json, pengantar_tahawwulat.json), website/content/{catalog,adab}.json, dan An-Nubdzah ash-Shughra.
Terjemahan Inggris dan Arab ditulis penyusun dan BELUM ditinjau penutur ahli; lihat BLUEPRINT_UX.md."""
import re, json, html, pathlib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
OUT = HERE / "site"
INFO = {x["id"]: x for x in json.load(open(ROOT / "openturath_ai/assets/data/info_ai.json", encoding="utf8"))}
PENG = json.load(open(ROOT / "openturath_ai/assets/data/pengantar_tahawwulat.json", encoding="utf8"))
ADAB = json.load(open(ROOT / "website/content/adab.json", encoding="utf8"))
CAT = {x["appAgentId"]: x for x in json.load(open(ROOT / "website/content/catalog.json", encoding="utf8"))}
SVG = (ROOT / "OpenTurath_logo_transparent.svg").read_text()
PATHS = re.findall(r'<path d="([^"]+)" fill="#100f0e"', SVG)  # 0 lengkung, 1 kubah, 2 halaman kiri, 3 halaman kanan
E = html.escape
LEGAL = json.load(open(HERE / "content" / "legal.json", encoding="utf8"))
LANG = "id"
LANGS = ("id", "en", "ar")
BASE = "https://openturath.id"

def L(i, e, a): return {"id": i, "en": e, "ar": a}[LANG]

SPRITE = ('<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>'
          '<symbol id="ot" viewBox="0 0 616 674">' + "".join(f'<path transform="translate(-204,-175)" d="{d}" fill="currentColor"/>' for d in PATHS) + '</symbol></defs></svg>')

def mark(h=30): return f'<svg style="height:{h}px;width:{h*615/673:.1f}px" viewBox="0 0 616 674" aria-hidden="true"><use href="#ot"/></svg>'

ICONS = {
  "arrow": '<path d="M5 12h14M13 6l6 6-6 6"/>', "download": '<path d="M12 4v11M7 11l5 5 5-5M5 20h14"/>',
  "sun": '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
  "moon": '<path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z"/>', "globe": '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>',
  "chev": '<path d="M6 9l6 6 6-6"/>', "menu": '<path d="M4 8h16M4 16h16"/>',
  "android": '<path d="M6 10h12v7a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2zM8 7l-1.5-2.5M16 7l1.5-2.5M6 10a6 6 0 0 1 12 0M9.5 14h.01M14.5 14h.01"/>',
  "laptop": '<rect x="4" y="5" width="16" height="11" rx="1.5"/><path d="M2 19h20"/>', "windows": '<path d="M3 5.5l7-1v7H3zM11 4.4L21 3v8.5H11zM3 12.5h7v7l-7-1zM11 12.5h10V21l-10-1.4z"/>',
  "layers": '<path d="M12 3l9 5-9 5-9-5zM3 13l9 5 9-5"/>', "scale": '<path d="M12 4v16M6 20h12M5 7h14M5 7l-3 7a3 3 0 0 0 6 0zM19 7l-3 7a3 3 0 0 0 6 0z"/>',
  "check": '<circle cx="12" cy="12" r="9"/><path d="M8 12.5l2.6 2.6L16 9.5"/>', "book": '<path d="M4 5.5C4 4.7 4.7 4 5.5 4H11v15H5.5C4.7 19 4 19.7 4 20.5zM20 5.5c0-.8-.7-1.5-1.5-1.5H13v15h5.5c.8 0 1.5.7 1.5 1.5z"/>',
  "library": '<rect x="4" y="5" width="4" height="15" rx="1"/><rect x="10" y="8" width="4" height="12" rx="1"/><path d="M16.5 20L19 6l3 .6L19.5 20.6zM2 22h20"/>',
  "scroll": '<path d="M7 3h11a2 2 0 0 1 2 2v13a3 3 0 0 1-3 3H8M7 3a2 2 0 0 0-2 2v13a3 3 0 0 0 3 3M9 8h7M9 12h7M9 16h4"/>',
  "cap": '<path d="M2 9l10-5 10 5-10 5zM6 11.5V16c0 1.5 3 3 6 3s6-1.5 6-3v-4.5M22 9v6"/>',
  "sparkle": '<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8zM19 16l.8 2.2L22 19l-2.2.8L19 22l-.8-2.2L16 19l2.2-.8z"/>', "plus": '<path d="M12 5v14M5 12h14"/>',
}
def ic(name, cls=""):
    return f'<svg class="ic {cls}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{ICONS[name]}</svg>'

# ---------- teks bersama ----------
def NAV(): return [("cara-kerja.html", L("Cara kerja", "How it works", "كيف يعمل")), ("pedoman.html", L("Pedoman keilmuan", "Scholarly guidelines", "الضوابط العلمية")),
                   ("ekosistem.html", L("Ekosistem", "Ecosystem", "المنظومة")), ("tentang.html", L("Tentang", "About", "عن OpenTurath"))]
G = {"tahaw": ["fiqh_tahawwulat"], "fikih": ["fiqh_syafii", "fiqh_hanafi", "fiqh_maliki", "fiqh_hanbali", "fiqh_muqaran"], "ushul": ["ushul_fiqh"],
     "hadis": ["hadits", "syarah_hadits", "musthalah_hadits", "thabaqat_tarajim"], "quran": ["tafsir", "tajwid_qiraat"],
     "akidah": ["aqidah", "tasawwuf"], "bahasa": ["nahwu_sharaf", "tarikh", "bibliografi_faharis"]}
def RUMPUN(): return {
    "tahaw": (L("Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات"), L("Lima asisten untuk rukun keempat agama", "Five assistants for the fourth pillar of religion", "خمسة مساعدين للركن الرابع من أركان الدين"), "layers"),
    "fikih": (L("Fikih", "Fiqh", "الفقه"), L("Empat mazhab, perbandingan, dan fatwa", "Four schools, comparison, and fatwa", "المذاهب الأربعة والمقارنة والفتاوى"), "scale"),
    "ushul": (L("Ushul dan kaidah", "Usul and legal maxims", "الأصول والقواعد"), L("Metode menggali hukum dari dalil", "How rulings are drawn from evidence", "منهج استنباط الأحكام من الأدلة"), "cap"),
    "hadis": (L("Hadis", "Hadith", "الحديث"), L("Matan, syarah, ilmu hadis, dan rijal", "Texts, commentaries, hadith sciences, narrators", "المتون والشروح ومصطلح الحديث والرجال"), "scroll"),
    "quran": (L("Al-Qur'an", "Qur'an", "القرآن"), L("Tafsir, tajwid, dan qira'at", "Tafsir, tajwid, and qira'at", "التفسير والتجويد والقراءات"), "book"),
    "akidah": (L("Akidah dan tasawuf", "Creed and Sufism", "العقيدة والتصوف"), L("Ushuluddin, kalam, dan tazkiyah", "Foundations of faith, kalam, and purification", "أصول الدين والكلام والتزكية"), "check"),
    "bahasa": (L("Bahasa, sejarah, bibliografi", "Language, history, bibliography", "اللغة والتاريخ والفهارس"), L("Nahwu, sharaf, sirah, dan faharis", "Grammar, morphology, sira, indexes", "النحو والصرف والسيرة والفهارس"), "library")}
def grp(i): return next(g for g, v in G.items() if i in v)
LEG = [("ketentuan.html", L("Ketentuan layanan", "Terms of service", "شروط الخدمة")), ("privasi.html", L("Kebijakan privasi", "Privacy policy", "سياسة الخصوصية")),
       ("pembayaran.html", L("Pembayaran dan pengembalian dana", "Payments and refunds", "الدفع واسترداد المبالغ")), ("hak-cipta.html", L("Sumber dan hak cipta", "Sources and copyright", "المصادر وحقوق النشر")),
       ("hapus-akun.html", L("Penghapusan akun dan data", "Account and data deletion", "حذف الحساب والبيانات")), ("panduan-ai.html", L("Panduan penggunaan AI dan rujukan", "Guide to using AI and references", "دليل استعمال الذكاء الاصطناعي والمراجع"))]
def legal_links(): return LEG

def shell(fname, title, desc, body, current=""):
    rtl = LANG == "ar"
    cur = ' aria-current="page"'
    links = "".join(f'<a href="{h}"{cur if h == current else ""}>{t}</a>' for h, t in NAV())
    bid = L("Bidang", "Fields", "المجالات")
    sheet = f'<a class="l" href="bidang.html">{L("Bidang ilmu","Fields of knowledge","المجالات العلمية")}</a>' + "".join(f'<a class="l" href="{h}">{t}</a>' for h, t in NAV())
    drop = "".join(f'<a href="bidang.html#{g}">{ic(i)}<span><b>{t}</b><span class="d">{d}</span></span></a>' for g, (t, d, i) in RUMPUN().items())
    names = {"id": "Bahasa Indonesia", "en": "English", "ar": "العربية"}
    cur2 = ' aria-current="true"'
    langrows = "".join(f'<a class="row" href="../{l}/{fname}" hreflang="{l}"{cur2 if l == LANG else ""}><span>{names[l]}</span><span class="soon">{"✓" if l == LANG else l.upper()}</span></a>' for l in LANGS)
    alts = "".join(f'<link rel="alternate" hreflang="{l}" href="{BASE}/{l}/{fname}">' for l in LANGS)
    anno = L("<b>Baru:</b> OpenTurath AI, rilis perdana 23 Oktober 2026", "<b>New:</b> OpenTurath AI, first public release on 23 October 2026", "<b>جديد:</b> OpenTurath AI، الإطلاق الأول في 23 أكتوبر 2026")
    ftag = L("Menjaga asal, membuka cakrawala.", "Rooted in origins. Open to new horizons.", "ذكاء اصطناعي إسلامي قائم على التراث")
    pil = L("Dibuat oleh pelajar, untuk para pelajar.", "Made by a student, for students.", "من طالب علم، لطلاب العلم.")
    colhd = lambda a, b, c: L(a, b, c)
    unduh = L("Unduh", "Download", "تحميل")
    legal_row = "".join(f'<a href="{h}">{t}</a>' for h, t in LEG)
    return f'''<!doctype html><html lang="{LANG}" dir="{"rtl" if rtl else "ltr"}" class="no-js"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{E(title)}</title><meta name="description" content="{E(desc)}"><meta name="theme-color" content="#FFFFFF">
<meta property="og:title" content="{E(title)}"><meta property="og:description" content="{E(desc)}"><meta property="og:type" content="website"><meta property="og:image" content="{BASE}/assets/og.png">
<meta name="twitter:card" content="summary_large_image"><link rel="canonical" href="{BASE}/{LANG}/{fname}">{alts}
<link rel="stylesheet" href="../assets/css/site.css"><link rel="icon" href="../assets/mark.svg" type="image/svg+xml">
<link rel="preload" href="../assets/fonts/googlesansflex.woff2" as="font" type="font/woff2" crossorigin>
<script src="../assets/js/boot.js"></script></head>
<body>{SPRITE}<a class="skip" href="#main">{L("Lewati ke konten","Skip to content","تخطَّ إلى المحتوى")}</a>
<div class="anno"><a href="unduh.html">{ic("sparkle")}<span>{anno}</span>{ic("arrow","arr")}</a></div>
<header class="site"><div class="hbar"><a class="wordmark" href="index.html" aria-label="OpenTurath">{mark(28)}<span>OpenTurath</span></a>
<nav class="main" aria-label="{L("Utama","Main","الرئيسية")}"><button class="navbtn" data-drop="fieldsDrop" aria-expanded="false" aria-controls="fieldsDrop">{bid}{ic("chev")}</button>{links}</nav>
<div class="hactions"><button class="langbtn" data-drop="langDrop" aria-expanded="false" aria-controls="langDrop" aria-label="{L("Pilih bahasa","Choose language","اختر اللغة")}">{ic("globe")}<span>{LANG.upper()}</span></button>
<button class="iconbtn theme-btn" aria-label="{L("Ganti tema terang atau gelap","Switch light or dark theme","تبديل المظهر الفاتح أو الداكن")}"><span class="sun">{ic("sun")}</span><span class="moon">{ic("moon")}</span></button>
<a class="btn primary sm hideS" href="unduh.html">{ic("download")}{unduh}</a>
<button class="iconbtn menu-btn" aria-label="{L("Buka menu","Open menu","افتح القائمة")}" aria-expanded="false">{ic("menu")}</button></div></div>
<div class="drop fields" id="fieldsDrop">{drop}<a href="bidang.html" class="alllink">{ic("arrow","arr")}<span><b>{L("Lihat semua bidang","See all fields","عرض كل المجالات")}</b></span></a></div>
<div class="drop lang" id="langDrop">{langrows}</div></header>
<div class="sheet" id="sheet">{sheet}<a class="btn primary" href="unduh.html">{ic("download")}{L("Unduh aplikasi","Download the app","تحميل التطبيق")}</a></div>
<main id="main">{body}</main>
<footer class="site"><div class="wrap"><div class="fgrid"><div class="fbrand"><a class="wordmark" href="index.html">{mark(34)}<span>OpenTurath</span></a></div>
<div><h4>{L("Produk","Product","المنتج")}</h4><ul><li><a href="bidang.html">OpenTurath AI</a></li><li><a href="bidang.html">{L("Bidang ilmu","Fields of knowledge","المجالات العلمية")}</a></li><li><a href="fikih-tahawwulat.html">{L("Fikih Tahawwulat","Fiqh al-Tahawwulat","فقه التحولات")}</a></li><li><a href="unduh.html">{unduh}</a></li></ul></div>
<div><h4>{L("Pelajari","Learn","تعرّف")}</h4><ul><li><a href="cara-kerja.html">{L("Cara kerja","How it works","كيف يعمل")}</a></li><li><a href="pedoman.html">{L("Pedoman keilmuan","Scholarly guidelines","الضوابط العلمية")}</a></li><li><a href="ekosistem.html">{L("Ekosistem","Ecosystem","المنظومة")}</a></li><li><a href="tentang.html">{L("Tentang","About","عن OpenTurath")}</a></li></ul></div>
<div><h4>{L("Bantuan","Help","المساعدة")}</h4><ul><li><a href="bantuan.html">{L("Bantuan dan FAQ","Help and FAQ","المساعدة والأسئلة الشائعة")}</a></li><li><a href="bantuan.html#lapor">{L("Laporkan kesalahan","Report an error","الإبلاغ عن خطأ")}</a></li><li><a href="mailto:support@openturath.id">support@openturath.id</a></li><li><a href="ketentuan.html">{L("Ketentuan dan privasi","Terms and privacy","الشروط والخصوصية")}</a></li></ul></div></div>
<div class="legal-links">{legal_row}</div>
<div class="fbar"><span>{L("OpenTurath adalah layanan mandiri dan memanfaatkan teknologi Google. Tidak berafiliasi dengan, didukung oleh, atau disahkan oleh Google.","OpenTurath is an independent service and uses Google technology. It is not affiliated with, supported by, or endorsed by Google.","OpenTurath خدمة مستقلة تستفيد من تقنية Google، وليست تابعة لـ Google ولا مدعومة منها ولا معتمدة لديها.")}</span><span>openturath.id</span></div></div></footer>
<script src="../assets/js/site.js" defer></script></body></html>'''

def write(name, title, desc, body, current=""):
    d = OUT / LANG; d.mkdir(parents=True, exist_ok=True)
    (d / name).write_text(shell(name, title, desc, body, current), encoding="utf8")

# ---------- komponen ----------
def head(kick, h1, lead, extra=""): return f'<section class="phead"><div class="wrap"><div class="kicker">{kick}</div><h1>{h1.replace("ﷺ", "<span class=salam>ﷺ</span>")}</h1><p class="lead">{lead}</p>{extra}</div></section>'
def sec(inner, cls="sec"): return f'<section class="{cls}"><div class="wrap">{inner}</div></section>'
def shead(kick, h2, lead="", center=False):
    return f'<div class="sec-head rv{" center" if center else ""}"><div class="kicker">{kick}</div><h2>{h2}</h2>' + (f'<p class="lead">{lead}</p>' if lead else '') + '</div>'

def bcard(i):
    """judul + nama Arab; data: ID dari info_ai.json, EN/AR dari katalog website."""
    if LANG == "id": title, ar = INFO[i]["judul"], INFO[i]["nama_arab"]
    elif LANG == "en": title, ar = CAT[i]["name"]["en"], CAT[i]["name"]["ar"]
    else: title, ar = CAT[i]["name"]["ar"], ""
    return title, ar

def explorer(default="fikih", with_all=False, search=False):
    R = RUMPUN()
    chips = (f'<button type="button" data-g="all" aria-pressed="{"true" if default == "all" else "false"}">{L("Semua","All","الكل")}</button>') if with_all else ""
    chips += "".join(f'<button type="button" data-g="{g}" aria-pressed="{"true" if g == default else "false"}">{R[g][0]}</button>' for g in G)
    cards, dets = "", ""
    for g in G:
        for i in G[g]:
            title, ar = bcard(i)
            desc = INFO[i]["tentang"] if LANG == "id" else CAT[i]["description"][LANG]
            q = (title + " " + ar + " " + desc).lower()
            arhtml = f'<span class="a">{E(ar)}</span>' if ar else ""
            cards += f'<button type="button" class="acard" data-id="{i}" data-g="{g}" data-q="{E(q)}" aria-pressed="false"><span class="t">{E(title)}</span>{arhtml}</button>'
            if LANG == "id":
                main, _, use = desc.partition("Gunakan AI ini untuk")
                use = use.strip(); use = use[:1].upper() + use[1:]
                body = f'<p>{E(main.strip())}</p>' + (f'<div class="use"><b>Gunakan untuk</b><p style="margin:0">{E(use)}</p></div>' if use else "")
                sub = ""
            else:
                body, sub = f'<p>{E(desc)}</p>', ""
            hd = f'<div class="ar">{E(ar)}</div>' if ar else ""
            gchip = f'<div class="group-chip"><span class="chip">{E(R[g][0])}</span></div>'
            dets += (f'<article class="detail" data-id="{i}" hidden>{hd}<h3>{E(title)}</h3>{gchip}{sub}{body}'
                     f'<a class="btn primary" href="unduh.html">{L("Buka di aplikasi","Open in the app","افتح في التطبيق")}{ic("arrow","arr")}</a></article>')
    s = ""
    if search:
        s = (f'<label class="sr" for="cari">{L("Cari bidang atau kitab","Search fields or books","ابحث عن مجال أو كتاب")}</label><input id="cari" type="search" '
             f'placeholder="{L("Cari bidang atau kitab, misalnya Minhajuth Thalibin","Search a field or a book, for example Minhaj al-Talibin","ابحث عن مجال أو كتاب، مثل منهاج الطالبين")}" class="searchbox">')
    return f'<div class="rumpun" role="group" aria-label="{L("Rumpun ilmu","Branches of knowledge","فروع العلم")}">{chips}</div>{s}<div class="explorer"><div class="alist">{cards}</div><div>{dets}</div></div>'

def gate_svg():
    names = ["p-arch", "p-dome", "p-left", "p-right"]
    ps = "".join(f'<path id="{n}" transform="translate(-204,-175)" d="{d}" fill="currentColor"/>' for n, d in zip(names, PATHS))
    return f'<svg viewBox="0 0 616 674" role="img" aria-label="{L("Logo OpenTurath: tiga bidang di bawah satu lengkung","OpenTurath logo: three shapes under one arch","شعار OpenTurath: ثلاثة أشكال تحت قوس واحد")}">{ps}</svg>'

SL = {s["id"]: s for s in PENG["slide"]}
KITAB = {"An-Nubdzah ash-Shughra": ("An-Nubdzah ash-Shughra", "An-Nubdhah al-Sughra", "النبذة الصغرى"), "Al-Ghirbal": ("Al-Ghirbal", "Al-Ghirbal", "الغربال")}
def src_label(s):
    name, _, pg = s.partition(", hlm. ")
    n = KITAB[name]
    return L(f"{n[0]}, hlm. {pg}", f"{n[1]}, p. {pg}", f"{n[2]}، ص {pg}")

def demo():
    qa = [
        (L("Berapa rukun agama menurut Fikih Tahawwulat?", "How many pillars of religion are there according to Fiqh al-Tahawwulat?", "كم عدد أركان الدين عند فقه التحولات؟"), "Al-Muhaqqiq",
         L("Menurut Fikih Tahawwulat, rukun agama ada empat. Islam bersambung dengan fikih, iman dengan akidah, ihsan dengan tasawuf, dan tanda kiamat dengan ilmu rukun keempat.",
           "According to Fiqh al-Tahawwulat, the pillars of religion are four. Islam connects to fiqh, iman to creed, ihsan to tasawwuf, and the signs of the Hour to the knowledge of the fourth pillar.",
           "أركان الدين عند فقه التحولات أربعة: الإسلام يتصل بالفقه، والإيمان بالعقيدة، والإحسان بالتصوف، وعلامات الساعة بعلم الركن الرابع."), SL["empat-rukun"]),
        (L("Jelaskan rukun keempat dengan perumpamaan sederhana.", "Explain the fourth pillar with a simple analogy.", "اشرح الركن الرابع بتشبيه بسيط."), "Al-Bayan",
         L("Bayangkan agama seperti mobil berpenggerak empat roda. Di jalan biasa, mode penggerak empat roda jarang dipakai; ia disiapkan untuk keadaan darurat. Orang yang tidak tahu fiturnya akan kebingungan, padahal jalan keluar ada di mobilnya sendiri. Fitur itu adalah rukun keempat agama.",
           "Imagine religion as a four-wheel-drive car. On ordinary roads the four-wheel mode is rarely used; it is kept for emergencies. Someone who does not know the feature is helpless, though the way out is in his own car. That feature is the fourth pillar of religion.",
           "تخيّل الدين سيارة بدفع رباعي. في الطريق المعتاد قلّما يُستعمل الدفع الرباعي، فهو معدّ للطوارئ. ومن جهل هذه الميزة ارتبك، مع أن مخرجه في سيارته نفسها. وتلك الميزة هي الركن الرابع من أركان الدين."), SL["mobil"]),
        (L("Apakah membahas tanda-tanda kiamat hanya membuat cemas?", "Does discussing the signs of the Hour only cause anxiety?", "هل الحديث عن علامات الساعة لا يورث إلا القلق؟"), "Al-Muhaqqiq",
         L("Banyak yang mengira begitu: membahas tanda kiamat hanya membuat cemas dan menjauh dari orang lain. Menurut beliau justru sebaliknya: ilmu tanda kiamat adalah pelindung yang menunjukkan sikap yang benar saat keadaan membingungkan.",
           "Many assume so: that discussing the signs of the Hour only brings anxiety and withdrawal. According to him it is the opposite: knowledge of these signs is a protection that shows the right stance when things are confusing.",
           "يظن كثيرون ذلك: أن الحديث عن علامات الساعة لا يورث إلا القلق والعزلة. وعنده الأمر بخلافه: فالعلم بعلامات الساعة وقاية تُبيّن الموقف الصحيح عند اشتباه الأمور."), SL["justru"])]
    who = lambda b: f'{L("AI Fikih Tahawwulat","AI Fiqh al-Tahawwulat","فقه التحولات")} · {b}'
    tabs = "".join(f'<button class="fx-item" role="tab" aria-selected="false" data-q="{E(q)}" data-who="{E(who(b))}" aria-controls="r{i}" id="t{i}"><span class="n">{i+1:02d}</span><span class="t">{E(q)}</span>{ic("plus")}</button>' for i, (q, b, a, s) in enumerate(qa))
    reps = "".join(
        f'<div class="reply" role="tabpanel" id="r{i}" aria-labelledby="t{i}" hidden><p>{E(a)}</p>'
        f'<div class="ibarah"><div class="lbl">{L("Ibarah","Passage","العبارة")}</div><div class="ar">{E(s["ibarah"].replace("…"," … "))}</div></div>'
        f'<div class="src"><span class="refchip">[1]</span><span><b>{E(src_label(s["sumber"]))}</b> &middot; {L("Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur (w. 1443 H)","Al-Habib Abu Bakr al-Adni ibn Ali al-Mashhur (d. 1443 AH)","الحبيب أبو بكر العدني بن علي المشهور (ت 1443 هـ)")}</span></div></div>'
        for i, (q, b, a, s) in enumerate(qa))
    note = L("Disusun dari materi Pengantar Fikih Tahawwulat di aplikasi. Jawaban sebenarnya bergantung pada pertanyaan dan kitab yang tersedia. Penjelasan AI perlu diverifikasi kepada guru.",
             "Composed from the Fiqh al-Tahawwulat introduction inside the app. Real answers depend on the question and the books available. AI explanations should be verified with a teacher.",
             "مأخوذ من مادة التعريف بفقه التحولات داخل التطبيق. تعتمد الإجابة الفعلية على السؤال والكتب المتاحة. ويجب التحقق من شرح الذكاء الاصطناعي لدى المعلم.")
    return (f'<div class="explorer-d"><div class="fx-list" role="tablist" aria-label="{L("Pertanyaan contoh","Sample questions","أسئلة توضيحية")}">{tabs}</div>'
            f'<div class="fx-stage"><div class="fx-card"><div class="fx-top"><span class="k" id="who">{E(who(qa[0][1]))}</span><span class="chip">{L("Contoh tampilan","Sample view","عرض توضيحي")}</span></div>'
            f'<div class="asked" id="asked">{E(qa[0][0])}</div>{reps}<p class="note">{note}</p></div></div></div>')

def FAQ_MAIN(): return [
    (L("Apakah OpenTurath AI mengeluarkan fatwa?", "Does OpenTurath AI issue fatwas?", "هل يصدر OpenTurath AI فتاوى؟"),
     L("Tidak. OpenTurath AI membantu menemukan pembahasan dan rujukan. Fatwa dan penerapan hukum pada keadaan tertentu tetap kepada ulama yang berkompeten.", "No. OpenTurath AI helps you find discussions and references. Fatwas and applying rulings to particular situations remain with qualified scholars.", "لا. يساعد OpenTurath AI على الوصول إلى المباحث والمراجع. أما الفتوى وتنزيل الأحكام على الوقائع فمرجعها العلماء المؤهلون.")),
    (L("Apakah ia menggantikan guru?", "Does it replace teachers?", "هل يحلّ محل المعلم؟"),
     L("Tidak. Ia alat bantu yang menghemat waktu mencari ibarah. Pemahaman dan adab tumbuh bersama guru, dan aplikasi selalu mengingatkan hal itu.", "No. It is a tool that saves time finding passages. Understanding and adab grow with a teacher, and the app keeps reminding you of that.", "لا. هو أداة توفّر وقت البحث عن العبارات. أما الفهم والأدب فينشآن مع المعلم، والتطبيق يذكّر بذلك دائمًا.")),
    (L("Dari mana jawabannya berasal?", "Where do the answers come from?", "من أين تأتي الإجابات؟"),
     L("Dari kumpulan kitab yang dikurasi pada bidang yang Anda pilih, bukan dari seluruh internet. Setiap bidang punya asisten dan metodologinya sendiri.", "From a curated set of books in the field you choose, not from the whole internet. Each field has its own assistant and method.", "من مجموعة كتب منتقاة في المجال الذي تختاره، لا من الإنترنت كله. ولكل مجال مساعده ومنهجه.")),
    (L("Apa bedanya dengan AI umum?", "How is it different from general AI?", "ما الفرق بينه وبين الذكاء الاصطناعي العام؟"),
     L("AI umum menjawab dari apa saja dan mudah mengarang ayat, kitab, atau ibarah. OpenTurath AI membatasi diri pada korpus yang dikurasi per bidang dan mengarahkan jawaban ke rujukan.", "General AI answers from anything and can easily invent verses, books, or passages. OpenTurath AI stays within a curated corpus per field and points answers to references.", "يجيب الذكاء الاصطناعي العام من أي مصدر وقد يختلق آيات وكتبًا وعبارات. أما OpenTurath AI فيلتزم بمدوّنة منتقاة لكل مجال ويوجّه الإجابة إلى المراجع.")),
    (L("Mengapa nomor halaman bisa berbeda dengan kitab cetakan saya?", "Why can page numbers differ from my printed book?", "لماذا قد يختلف رقم الصفحة عن نسختي المطبوعة؟"),
     L("Tata letak berbeda antar penerbit dan cetakan. Cocokkan judul kitab, edisi, jilid, dan halaman dengan edisi yang Anda pegang.", "Layouts differ between publishers and editions. Match the title, edition, volume, and page with the edition you hold.", "تختلف الصفحات باختلاف الناشرين والطبعات. طابق عنوان الكتاب والطبعة والجزء والصفحة مع الطبعة التي بين يديك.")),
    (L("Di perangkat apa dan bagaimana aksesnya?", "Which devices, and how does access work?", "على أي الأجهزة، وكيف يعمل الوصول؟"),
     L("Android, macOS, dan Windows. Masuk dengan akun Google, lalu pilih modul bidang yang ingin dibuka. Perpanjangan manual, tanpa auto-debit.", "Android, macOS, and Windows. Sign in with a Google account, then choose the field modules you want. Renewal is manual, with no auto-debit.", "أندرويد وماك ويندوز. سجّل الدخول بحساب Google ثم اختر وحدات المجالات التي تريدها. التجديد يدوي دون خصم تلقائي.")),
    (L("Bagaimana melaporkan kesalahan?", "How do I report an error?", "كيف أبلّغ عن خطأ؟"),
     L("Kirim kutipan, kitab dan edisi yang Anda pegang, serta alasannya ke support@openturath.id, atau pakai <a href='bantuan.html#lapor'>formulir laporan</a>.", "Send the quotation, the book and edition you hold, and your reason to support@openturath.id, or use the <a href='bantuan.html#lapor'>report form</a>.", "أرسل العبارة والكتاب والطبعة التي بين يديك وسبب اعتراضك إلى support@openturath.id، أو استخدم <a href='bantuan.html#lapor'>نموذج الإبلاغ</a>."))]
def faq(items): return '<div class="faq">' + "".join(f'<details><summary><span>{E(q)}</span><span class="pm" aria-hidden="true"></span></summary><div class="a">{a}</div></details>' for q, a in items) + '</div>'

# ---------- hero: lengkung bersarang ----------
KITAB_AR = ["الأم", "المجموع", "تحفة المحتاج", "نهاية المحتاج", "فتح الباري", "إحياء علوم الدين", "لسان العرب", "تفسير الطبري", "صحيح البخاري", "المستصفى"]
def arch_path(a, h, base=900, cx=720):
    f = lambda x, y: (cx + (x - 200) / 194 * a, base - (540 - y) / 540 * h)
    pts = [f(6, 540), f(6, 222), f(6, 132), f(60, 84), f(200, 6), f(340, 84), f(394, 132), f(394, 222), f(394, 540)]
    p = lambda t: f"{t[0]:.1f} {t[1]:.1f}"
    return f"M{p(pts[0])} L{p(pts[1])} C{p(pts[2])} {p(pts[3])} {p(pts[4])} C{p(pts[5])} {p(pts[6])} {p(pts[7])} L{p(pts[8])}"
def hero_arches():
    gs, defs = "", ""
    for i in range(6):
        a = 500 + i * 140; h = 680 + i * 110
        defs += f'<path id="ar{i}" d="{arch_path(a, h)}" pathLength="1"/>'
        op = [.30, .23, .18, .14, .10, .07][i]
        txt = ""
        T = lambda ks: "   ·   ".join(KITAB_AR[k % len(KITAB_AR)] for k in ks)
        if i == 1:
            txt = f'<text class="ktxt"><textPath href="#ar1" startOffset="50%" text-anchor="middle">{T(range(0, 5))}</textPath></text>'
        elif i == 3:
            txt = (f'<text class="ktxt"><textPath href="#ar3" startOffset="31%" text-anchor="middle">{T(range(5, 8))}</textPath></text>'
                   f'<text class="ktxt"><textPath href="#ar3" startOffset="69%" text-anchor="middle">{T(range(2, 5))}</textPath></text>')
        gs += f'<g class="ag" style="--i:{i};--d:{i+1}"><use href="#ar{i}" class="al" style="opacity:{op}"/>{txt}</g>'
    return f'<svg class="arches" viewBox="0 0 1440 900" preserveAspectRatio="xMidYMax slice" aria-hidden="true"><defs>{defs}</defs>{gs}</svg>'

# ---------- potongan Fikih Tahawwulat (dipakai beranda dan halaman khusus) ----------
def rukun_html():
    rows = [("islam", "01", L("Islam", "Islam", "الإسلام"), L("Fikih · rukun yang tetap", "Fiqh · a constant pillar", "الفقه · من الثوابت"), "الإسلام"),
            ("iman", "02", L("Iman", "Iman", "الإيمان"), L("Akidah · rukun yang tetap", "Creed · a constant pillar", "العقيدة · من الثوابت"), "الإيمان"),
            ("ihsan", "03", L("Ihsan", "Ihsan", "الإحسان"), L("Tasawuf · rukun yang tetap", "Tasawwuf · a constant pillar", "التصوف · من الثوابت"), "الإحسان"),
            ("tahaw", "04", L("Tanda-tanda zaman", "Signs of the times", "علامات الساعة"), L("Fikih Tahawwulat · membahas yang berubah dan menjaga tiga rukun di atas", "Fiqh al-Tahawwulat · studies what changes and guards the three pillars above", "فقه التحولات · يبحث في المتغيرات ويحفظ الأركان الثلاثة"), "علامات الساعة")]
    return '<div class="rukun" role="list">' + "".join(f'<button class="rk" data-hl="{h}" role="listitem"><span class="i">{n}</span><span class="tt">{t}<small>{s}</small></span><span class="ar">{a}</span></button>' for h, n, t, s, a in rows) + '</div>'

def tasks_html():
    t1 = (L("Memperbarui bahasa dakwah", "Renewing the language of da'wa", "تجديد لغة الدعوة"),
          L("Dakwah dengan hikmah dan nasihat yang baik, menjaga lisan dari mencela dan tangan dari menumpahkan darah, kecuali yang disyariatkan.",
            "Calling to God with wisdom and good counsel, guarding the tongue from reviling and the hand from bloodshed, except where the Law requires.",
            "الدعوة بالحكمة والموعظة الحسنة، مع حفظ اللسان من الذم واليد من الدم إلا فيما شرعه الله."))
    t2 = (L("Menjaga ilmu-ilmu yang tetap", "Safeguarding the constant sciences", "صيانة علوم الثوابت"),
          L("Memelihara kehormatan keadilan dan sanad dari kekacauan perubahan dan fitnah yang menyesatkan, dalam ilmu akidah, syariat, dan tingkatan suluk.",
            "Protecting the honour of integrity and chains of transmission from the disorder of change and misleading trials, in the sciences of creed, law, and spiritual conduct.",
            "حفظ شرف العدالة والأسانيد من عبث المتغيرات ومضلات الفتن في علوم العقيدة والشريعة ومراتب السلوك."))
    src = L("An-Nubdzah ash-Shughra, hlm. 13", "An-Nubdhah al-Sughra, p. 13", "النبذة الصغرى، ص ١٣")
    return (f'<div class="tasks"><div class="tasks-hd"><b>{L("Dua tugas rukun keempat","The two tasks of the fourth pillar","مهمتان للركن الرابع")}</b><span class="small">{src}</span></div>'
            f'<div class="tasks-g"><div><h4>{t1[0]}</h4><p>{t1[1]}</p></div><div><h4>{t2[0]}</h4><p>{t2[1]}</p></div></div></div>')

def branches_html():
    B = [("المحقق", "Al-Muhaqqiq", L("Sang pentahkik", "The verifier", "المحقِّق"), L("Mencari dan memeriksa ibarah asli beserta sumbernya.", "Finds and checks the original passage with its source.", "يبحث عن العبارة الأصلية ويتحقق منها مع مصدرها.")),
         ("البيان", "Al-Bayan", L("Penjelasan", "The explanation", "البيان"), L("Menyederhanakan konsep dan menerangkan istilah.", "Simplifies concepts and explains terms.", "يبسّط المفاهيم ويشرح المصطلحات.")),
         ("المختبر", "Al-Mukhtabir", L("Sang penguji", "The examiner", "المختبِر"), L("Menguji pemahaman Anda dan nalar atas persoalan kontemporer.", "Tests your understanding and reasoning on contemporary issues.", "يختبر فهمك ونظرك في النوازل المعاصرة.")),
         ("الحبيب", "Al-Habib", L("Arsip ceramah", "The lecture archive", "أرشيف المحاضرات"), L("Menemukan muhadharah Al-Habib Abu Bakar, lengkap dengan videonya.", "Finds the lectures of Al-Habib Abu Bakr, with the video.", "يجد محاضرات الحبيب أبي بكر مع مقاطعها المرئية.")),
         ("الخطيب", "Al-Khatib", L("Penyusun khutbah", "The sermon writer", "معدّ الخطب"), L("Menyusun khutbah dan materi dakwah.", "Drafts sermons and da'wa material.", "يُعدّ الخطب والمواد الدعوية."))]
    return '<div class="branches">' + "".join(f'<div class="br"><span class="ar">{a}</span><b>{n}</b><i>{m}</i><span>{d}</span></div>' for a, n, m, d in B) + '</div>'

# ======================= BERANDA =======================
def page_home():
    CHK = ic("check")
    h1 = L("Menjaga asal, membuka cakrawala.", "Rooted in origins. Open to new horizons.", "ذكاء اصطناعي إسلامي قائم على التراث")
    lede = L("OpenTurath AI menemani penuntut ilmu membaca kitab: memahami isinya, menemukan ibarahnya, dan menelusuri rujukannya, dari kitab dan ceramah para ulama.",
             "OpenTurath AI accompanies seekers of knowledge as they read: understanding the text, finding the passage, and tracing the reference, drawn from the books and lectures of the scholars.",
             "يرافق OpenTurath AI طالب العلم في قراءة الكتب: يفهم النص، ويصل إلى العبارة، ويتتبّع المرجع، من كتب العلماء ومحاضراتهم.")
    body = f'''
<section class="welcome" id="hero"><canvas id="ring" aria-hidden="true"></canvas>
<p class="eyebrow-brand rv in">{L("AI for Islamic Scholarship","AI for Islamic Scholarship","الذكاء الاصطناعي للعلوم الإسلامية")}</p>
<div class="hero-mark rv in">{mark(50)}</div>
<h1 class="hero rv in d1">{h1}</h1>
<p class="lede rv in d2">{lede}</p>
<div class="cta-row rv in d3"><a class="btn primary" href="unduh.html">{ic("download")}{L("Unduh aplikasi","Download the app","تحميل التطبيق")}</a><a class="btn tonal" href="cara-kerja.html">{L("Lihat cara kerja","See how it works","شاهد كيف يعمل")}</a></div>
<div class="meta-row rv in d3"><span>{CHK}{L("Ditinjau para ulama","Reviewed by scholars","مراجَع من العلماء")}</span><span>{CHK}{L("Dikurasi dengan wasathiyyah syar'iyyah","Curated by al-wasatiyya al-shar'iyya","مُنتقى وفق الوسطية الشرعية")}</span><span>{CHK}{L("Bukan pengganti guru","Not a replacement for teachers","ليس بديلًا عن المعلم")}</span></div>
<nav class="sr" aria-label="{L("Bidang ilmu","Fields of knowledge","المجالات العلمية")}">{"".join(f'<a href="bidang.html#{g}">{t[0]}</a>' for g, t in RUMPUN().items())}</nav></section>

<section class="sec"><div class="wrap">{shead(L("Masalah ilmiah dan akurasi","The scholarly problem: accuracy","المشكلة العلمية والدقة"), L("Jawaban AI mudah terdengar meyakinkan. Ilmu menuntut sumber yang bisa diperiksa.","AI answers sound convincing too easily. Scholarship demands sources you can check.","إجابات الذكاء الاصطناعي تبدو مقنعة بسهولة، والعلم يطلب مصادر يمكن التحقق منها."), L("Penelitian turats bertumpu pada ketepatan atribusi, redaksi ibarah, dan rujukan naskah. Satu sitasi yang keliru bisa meruntuhkan seluruh alur penelitian. Karena itu OpenTurath dibuat untuk membawa Anda kembali ke sumbernya, bukan memintanya percaya pada teks buatan AI.","Research on the turath rests on accurate attribution, exact wording, and manuscript references. A single wrong citation can bring down a whole line of research. OpenTurath is built to take you back to the source, not to ask you to trust text generated by AI.","يقوم بحث التراث على دقة النسبة وصحة نص العبارة والإحالة إلى النسخة. وقد تهدم إحالة خاطئة واحدة مسار البحث كله. لذلك بُني OpenTurath ليعيدك إلى المصدر، لا ليطلب منك تصديق نص ولّده الذكاء الاصطناعي.")) }
<div class="quad">
<div class="rv"><div class="n">01</div><h3>{L("Salah menyebut ulama dan mazhab","Misattributing scholars and schools","نسبة الأقوال إلى غير أصحابها")}</h3><p>{L("AI umum kerap menyandarkan pendapat kepada ulama yang keliru, mencampur posisi hukum, atau menggabungkan pendapat tanpa kaidah (talfiq).","General AI often pins an opinion on the wrong scholar, mixes legal positions, or combines opinions without method (talfiq).","كثيرًا ما ينسب الذكاء الاصطناعي العام رأيًا إلى غير قائله، أو يخلط بين الأقوال الفقهية، أو يلفّق بينها بلا ضابط.")}</p></div>
<div class="rv d1"><div class="n">02</div><h3>{L("Sitasi dan halaman karangan","Invented citations and pages","إحالات وصفحات مختلقة")}</h3><p>{L("Judul kitab, nomor jilid, dan halaman bisa tampak meyakinkan padahal tidak ada, dan mustahil dicocokkan dengan kitab cetak.","Titles, volumes, and page numbers can look convincing yet not exist, and cannot be matched with the printed book.","قد تبدو عناوين الكتب وأرقام الأجزاء والصفحات مقنعة وهي غير موجودة، ويستحيل مطابقتها بالكتاب المطبوع.")}</p></div>
<div class="rv d2"><div class="n">03</div><h3>{L("Teks terpotong dari konteksnya","Text cut from its context","نص مقتطع من سياقه")}</h3><p>{L("Pemotongan teks yang sembarangan memisahkan hukum dari pengecualian yang diterangkan pensyarah dan penulis hasyiyah.","Careless chunking separates a ruling from the exceptions explained by the commentator and the glossator.","التقطيع العشوائي للنص يفصل الحكم عن الاستثناءات التي بيّنها الشارح وصاحب الحاشية.")}</p></div>
<div class="rv d3 principle"><div class="n">04</div><h3>{L("Sumber lebih dulu","Source first","المصدر أولًا")}</h3><p>{L("OpenTurath tidak meminta Anda percaya begitu saja pada AI. Kami mempercepat penemuan ibarah aslinya supaya Anda bisa langsung memeriksa naskahnya.","OpenTurath does not ask you to simply trust the AI. We speed up finding the original passage so you can check the text yourself.","لا يطلب منك OpenTurath تصديق الذكاء الاصطناعي هكذا. نحن نسرّع الوصول إلى العبارة الأصلية لتتحقق بنفسك من النص.")}</p></div></div></div></section>

<section class="sec" id="demo"><div class="wrap">{shead(L("Contoh jawaban","Sample answers","نموذج إجابة"), L("Jawaban yang selalu menunjuk ke kitabnya.","Answers that always point to their book.","إجابات تشير دائمًا إلى كتابها."), L("Pilih satu pertanyaan, lalu lihat bagaimana penjelasan, ibarah Arab, dan rujukan datang bersama.","Pick a question and see how the explanation, the Arabic passage, and the reference arrive together.","اختر سؤالًا. تُظهر المعاينة كيف يجتمع الشرح والعبارة العربية والمرجع معًا."))}<div class="rv">{demo()}</div></div></section>

<section class="sec"><div class="wrap">{shead(L("Untuk siapa","Who it is for","لمن هو"), L("Untuk siapa OpenTurath?","Who is OpenTurath for?","لمن OpenTurath؟"))}
<div class="cases">
<div class="case rv">{ic("cap")}<h3>{L("Santri dan penuntut ilmu","Students and seekers of knowledge","الطلاب وطلاب العلم")}</h3><p>{L("Mulai memahami kitab tanpa harus lebih dulu menaklukkan bahasa dan istilahnya.","Start understanding the books without first conquering their language and terms.","ابدأ فهم الكتب دون أن تقهر لغتها ومصطلحاتها أولًا.")}</p><div class="q"><span><b>{L("Tanyakan:","Ask:","اسأل:")}</b> {L("Apa yang dimaksud rukun keempat?","What is meant by the fourth pillar?","ما المقصود بالركن الرابع؟")}</span></div></div>
<div class="case rv d1">{ic("library")}<h3>{L("Mahasiswa dan peneliti","University students and researchers","طلاب الجامعة والباحثون")}</h3><p>{L("Cari pembahasan lintas kitab, bandingkan keterangan, dan simpan rujukan untuk tulisan Anda.","Search discussions across books, compare accounts, and keep references for your writing.","ابحث في المباحث عبر الكتب، وقارن الأقوال، واحفظ المراجع لكتاباتك.")}</p><div class="q"><span><b>{L("Tanyakan:","Ask:","اسأل:")}</b> {L("Di kitab mana pembahasan ini dibahas paling rinci?","In which book is this discussed in most detail?","في أي كتاب يُبحث هذا الموضوع بأوسع تفصيل؟")}</span></div></div>
<div class="case rv d2">{ic("scroll")}<h3>{L("Pengajar, penceramah, khatib","Teachers, preachers, khatibs","المعلمون والدعاة والخطباء")}</h3><p>{L("Siapkan materi, periksa dalil dan ibarah, lalu sampaikan dengan lebih yakin.","Prepare material, check the evidence and passages, then deliver with more confidence.","أعدّ المادة، وتحقق من الدليل والعبارة، ثم ألقِها بثقة أكبر.")}</p><div class="q"><span><b>{L("Tanyakan:","Ask:","اسأل:")}</b> {L("Susun kerangka khutbah tentang sikap saat masa fitnah.","Outline a sermon on conduct in times of trial.","ضع هيكل خطبة عن الموقف زمن الفتن.")}</span></div></div></div></div></section>

<section class="sec" id="bidang"><div class="wrap">{shead(L("Bidang ilmu","Fields of knowledge","المجالات العلمية"), L("Satu ilmu, satu asisten.","One discipline, one assistant.","علم واحد، ومساعد واحد."), L("Tiap asisten hanya memegang kitab bidangnya dan memakai cara kerja bidang itu, jadi jawabannya tidak tercampur.","Each assistant holds only the books of its field and works the way that field works, so answers do not blend.","يلتزم كل مساعد بكتب مجاله وحده ويعمل بطريقة ذلك المجال، فلا تختلط إجاباته."))}<div class="rv">{explorer("fikih")}</div>
<p class="more"><a class="link" href="bidang.html">{L("Lihat semua bidang","See all fields","عرض كل المجالات")}{ic("arrow","arr")}</a></p></div></section>

<section class="sec band"><div class="wrap">{shead(L("Fikih Tahawwulat","Fiqh al-Tahawwulat","فقه التحولات"), L("Rukun keempat agama, penjaga tiga rukun yang lain.","The fourth pillar of religion, guardian of the other three.","الركن الرابع من أركان الدين، حارس الأركان الثلاثة الأخرى."), L("Dalam hadis Jibril, Nabi menjawab empat pertanyaan. Tiga yang pertama adalah ilmu yang tetap: fikih, akidah, tasawuf. Yang keempat membahas yang berubah, yaitu tanda-tanda zaman, dan bertugas menjaga ketiganya. Inilah yang tergambar pada logo OpenTurath: tiga bidang di dalam, satu lengkung yang menaungi.","In the hadith of Jibril, the Prophet answered four questions. The first three are the constant sciences: fiqh, creed, tasawwuf. The fourth studies what changes, the signs of the times, and guards the other three. This is what the OpenTurath logo shows: three shapes inside, one arch over them.","في حديث جبريل أجاب النبي عن أربعة أسئلة. الثلاثة الأولى علوم ثابتة: الفقه والعقيدة والتصوف. والرابع يبحث في المتغيرات، أي علامات الساعة، ويحفظ الثلاثة الأخرى. وهذا ما يصوّره شعار OpenTurath: ثلاثة أشكال في الداخل وقوس واحد يظلّلها."))}
<div class="tahaw rv"><div class="gate" data-hl="">{gate_svg()}</div>{rukun_html()}</div>
<div class="rv">{tasks_html()}</div>
<div class="branches-hd rv"><h3>{L("Lima cabang AI Fikih Tahawwulat","The five branches of AI Fiqh al-Tahawwulat","الفروع الخمسة لـ AI فقه التحولات")}</h3><p>{L("Satu bidang dengan lima asisten, masing-masing dengan tugasnya.","One field with five assistants, each with its own job.","مجال واحد وخمسة مساعدين، ولكل منهم مهمته.")}</p></div>
<div class="rv">{branches_html()}</div>
<p style="margin-top:40px;text-align:center"><a class="btn primary" href="fikih-tahawwulat.html">{L("Kenali Fikih Tahawwulat","Get to know Fiqh al-Tahawwulat","تعرّف على فقه التحولات")}{ic("arrow","arr")}</a></p></div></section>

<section class="sec"><div class="wrap">{shead(L("Cara kami menjaga","How we safeguard","كيف نحفظ"), L("Cara kami menjaga mutu jawaban.","How we keep answers sound.","كيف نحفظ سلامة الإجابات."))}
<div class="pillars">
<div class="pillar rv"><div class="bic">{ic("layers")}</div><h3>{L("Satu bidang, satu metodologi","One field, one method","مجال واحد، ومنهج واحد")}</h3><p>{L("Setiap asisten hanya berpegang pada kitab bidangnya. Fikih dan hadis punya cara kerja berbeda, dan tidak dicampur.","Each assistant keeps only to the books of its field. Fiqh and hadith work differently and are never mixed.","يلتزم كل مساعد بكتب مجاله وحدها. وللفقه والحديث طريقتان مختلفتان، فلا يُخلطان.")}</p></div>
<div class="pillar rv d1"><div class="bic">{ic("scale")}</div><h3>{L("Kurasi wasathiyyah syar'iyyah","Curation by al-wasatiyya al-shar'iyya","انتقاء وفق الوسطية الشرعية")}</h3><p>{L("Kitab dipilih satu per satu agar keilmuan tidak terpolitisasi dan tidak dipakai menjatuhkan kelompok lain.","Books are chosen one by one so scholarship is not politicised or used to bring other groups down.","تُنتقى الكتب واحدًا واحدًا حتى لا يُسيَّس العلم ولا يُستعمل لإسقاط الآخرين.")}</p></div>
<div class="pillar rv d2"><div class="bic">{ic("check")}</div><h3>{L("Ditinjau para ulama","Reviewed by scholars","مراجَع من العلماء")}</h3><p>{L("Para ulama diberi akses memeriksa isi di bidangnya, dan pakar mengarahkan metodologinya.","Scholars are given access to review the content of their fields, and experts guide the method.","يُتاح للعلماء مراجعة المحتوى في مجالاتهم، ويوجّه الخبراء المنهج.")}</p></div>
<div class="pillar rv d3"><div class="bic">{ic("book")}</div><h3>{L("Rujukan, dengan batas yang jujur","References, with honest limits","مراجع، وحدود صادقة")}</h3><p>{L("Jawaban diarahkan ke kitab, jilid, dan halaman bila tersedia. Penjelasan AI tetap diverifikasi kepada guru.","Answers point to the book, volume, and page where available. AI explanations are still verified with a teacher.","تُوجَّه الإجابة إلى الكتاب والجزء والصفحة إن توفرت. ويبقى شرح الذكاء الاصطناعي بحاجة إلى التحقق لدى المعلم.")}</p></div></div>
<div class="statement rv"><div><p>{L("AI hanyalah alat. Gurunya tetap guru.","AI is only a tool. The teacher remains the teacher.","الذكاء الاصطناعي مجرد أداة، والمعلم يبقى معلّمًا.")}</p></div><div><p class="small">{L("Penjelasan AI perlu diverifikasi kepada guru, terutama untuk amal dan fatwa.","AI explanations should be verified with a teacher, especially for practice and fatwa.","يجب التحقق من شرح الذكاء الاصطناعي لدى المعلم، خاصة في العمل والفتوى.")}</p><a class="btn inv-o sm" href="pedoman.html">{L("Baca pedoman keilmuan","Read the scholarly guidelines","اقرأ الضوابط العلمية")}</a></div></div></div></section>

<section class="sec"><div class="wrap">{shead(L("Ekosistem","Ecosystem","المنظومة"), L("OpenTurath lebih dari satu aplikasi.","OpenTurath is more than one app.","OpenTurath أكثر من تطبيق."), L("Satu nama, empat jalur yang saling melengkapi.","One name, four paths that complete each other.","اسم واحد وأربعة مسارات يكمّل بعضها بعضًا."))}{eco()}
<p class="more"><a class="link" href="ekosistem.html">{L("Tentang ekosistem OpenTurath","About the OpenTurath ecosystem","عن منظومة OpenTurath")}{ic("arrow","arr")}</a></p></div></section>

<section class="sec" style="border-top:0"><div class="wrap"><div class="founder"><div class="rv"><span class="pill">{L("Dibuat oleh pelajar, untuk para pelajar.","Made by a student, for students.","من طالب علم، لطلاب العلم.")}</span>
<blockquote>{L("Satu halaman kitab, satu jam, dan masih belum paham. Dari situlah OpenTurath bermula.","One page of a book, one hour, and still no understanding. That is where OpenTurath began.","صفحة من كتاب، وساعة كاملة، ولا فهم بعد. من هنا بدأ OpenTurath.")}</blockquote></div>
<div class="rv d1"><p class="lead" style="margin-bottom:20px">{L("Sang perintis adalah seorang santri. Ia pernah menerjemahkan sebuah kitab kata demi kata, menghabiskan sekitar satu jam untuk satu halaman, dan tetap belum paham. OpenTurath ia bangun seorang diri untuk menjawab kesulitan itu, dengan pemeriksaan dari para ulama.","The founder is a student of the sacred sciences. He once translated a book word by word, spent about an hour on a single page, and still did not understand. He built OpenTurath alone to answer that difficulty, with scholars checking the content.","المؤسس طالب علم. ترجم ذات يوم كتابًا كلمة كلمة، واستغرقت الصفحة الواحدة نحو ساعة، ولم يفهمها بعد. فبنى OpenTurath وحده ليجيب عن تلك الصعوبة، ويراجع العلماء المحتوى.")}</p>
<p class="chip-row"><span class="chip big">{L("Diumumkan di Universitas Al-Wasatiyah, Hadramaut, 7 Mei 2026, di hadapan para ulama","Announced at Al-Wasatiyah University, Hadramawt, on 7 May 2026, before scholars","أُعلن في جامعة الوسطية بحضرموت، 7 مايو 2026، بحضور العلماء")}</span></p>
<p><a class="link" href="tentang.html">{L("Baca ceritanya","Read the story","اقرأ القصة")}{ic("arrow","arr")}</a></p></div></div></div></section>

{download_band()}

<section class="sec"><div class="wrap">{shead(L("Pertanyaan","Questions","أسئلة"), L("Jawaban singkat.","Short answers.","إجابات موجزة."))}<div class="rv">{faq(FAQ_MAIN())}</div><p class="more"><a class="link" href="bantuan.html">{L("Semua bantuan","All help","كل المساعدة")}{ic("arrow","arr")}</a></p></div></section>'''
    body += '<script type="application/ld+json">' + json.dumps({"@context": "https://schema.org", "@type": "SoftwareApplication", "name": "OpenTurath AI", "applicationCategory": "EducationalApplication", "operatingSystem": "Android, macOS, Windows", "inLanguage": ["id", "en", "ar"], "url": BASE + "/" + LANG + "/index.html", "description": "AI Islami berbasis turath untuk penuntut ilmu."}, ensure_ascii=False) + '</script>'
    write("index.html", L("OpenTurath: Menjaga asal, membuka cakrawala", "OpenTurath: Rooted in origins. Open to new horizons.", "OpenTurath: ذكاء اصطناعي إسلامي قائم على التراث"),
          L("OpenTurath AI membantu penuntut ilmu memahami kitab dan menemukan rujukan ibarahnya, bidang demi bidang. AI Islami berbasis turath.",
            "OpenTurath AI helps seekers of knowledge understand books and find the passages they cite. An Islamic AI grounded in turath.",
            "يساعد OpenTurath AI طالب العلم على فهم الكتب والوصول إلى العبارات التي تستند إليها. ذكاء اصطناعي إسلامي قائم على التراث."), body)

def eco():
    cards = [
        ("first", mark(26), L("Rilis 23 Okt 2026", "Released 23 Oct 2026", "الإطلاق 23 أكتوبر 2026"), "OpenTurath AI",
         L("AI Islami berbasis turath yang mencakup semua bidang ilmu dan khazanah para ulama. Cita-citanya: menjadi garda terdepan AI Islami berbasis turath.", "An Islamic AI grounded in turath, covering all fields of knowledge and the heritage of the scholars. The aim: to be the frontier of turath-based Islamic AI.", "ذكاء اصطناعي إسلامي قائم على التراث يشمل كل العلوم وميراث العلماء. وغايته: أن يكون في طليعة الذكاء الاصطناعي الإسلامي القائم على التراث.")),
        ("", ic("library"), L("Dibangun", "In the making", "قيد البناء"), L("Maktabah OpenTurath", "OpenTurath Library", "مكتبة OpenTurath"),
         L("Pusat unduh kitab yang menyatukan semua cetakan dan banyak sumber unduh dalam satu halaman. Cita-citanya: menjadi pusat unduh kitab terbesar di dunia.", "A book download hub bringing every edition and many download sources onto one page. The aim: to be the largest book download hub in the world.", "مركز لتحميل الكتب يجمع كل الطبعات ومصادر التحميل الكثيرة في صفحة واحدة. وغايته: أن يكون أكبر مركز لتحميل الكتب في العالم.")),
        ("", ic("scroll"), L("Tahap uji", "In testing", "قيد الاختبار"), L("AI Manuskrip", "Manuscript AI", "ذكاء المخطوطات"),
         L("Membantu membaca dan menahkik manuskrip: makna bahasa, tokoh yang dimaksud, serta hadis dan ayat yang dikutip. Tujuannya: menjadi AI manuskrip paling akurat di dunia. Pada pengujian kami, akurasinya sangat tinggi.", "Helps read and critically edit manuscripts: word meanings, the figures mentioned, and the hadiths and verses cited. The aim: to be the most accurate manuscript AI in the world. In our tests its accuracy is very high.", "يساعد على قراءة المخطوطات وتحقيقها: معاني الألفاظ، والأعلام المقصودة، والأحاديث والآيات المنقولة. وغايته: أن يكون أدق ذكاء اصطناعي للمخطوطات في العالم. وقد أظهر في اختباراتنا دقة عالية جدًا.")),
        ("", ic("cap"), L("Rencana", "Planned", "مخطَّط"), L("Akademi OpenTurath", "OpenTurath Academy", "أكاديمية OpenTurath"),
         L("Belajar memakai AI bagi penuntut ilmu: dari percakapan, gambar dan video dakwah, hingga membuat aplikasi dan AI agent.", "Learning to use AI for seekers of knowledge: from conversation, images and da'wa video, to building apps and AI agents.", "تعلّم استعمال الذكاء الاصطناعي لطلاب العلم: من المحادثة وصور الدعوة ومقاطعها، إلى بناء التطبيقات ووكلاء الذكاء الاصطناعي."))]
    out = ""
    for k, (cls, icon, st, t, d) in enumerate(cards):
        if k == 0: out += f'<a class="first rv" href="bidang.html"><div class="top"><div class="eic">{icon}</div><span class="status">{st}</span></div><h3>{t}</h3><p>{d}</p><span class="go">{L("Jelajahi bidang","Explore the fields","استكشف المجالات")}{ic("arrow","arr")}</span></a>'
        else: out += f'<div class="e rv d{k}"><div class="top"><div class="eic">{icon}</div><span class="status">{st}</span></div><h3>{t}</h3><p>{d}</p></div>'
    return f'<div class="eco">{out}</div>'

def download_band(sub=True):
    P = [("android", "android", "Android", L("Android 8.0 ke atas", "Android 8.0 or later", "أندرويد 8.0 فأعلى")), ("macos", "laptop", "macOS", L("macOS 13 ke atas", "macOS 13 or later", "macOS 13 فأعلى")), ("windows", "windows", "Windows", L("Windows 10 ke atas", "Windows 10 or later", "ويندوز 10 فأعلى"))]
    cards = "".join(f'<div class="plat" data-os="{o}"><div class="p-ic">{ic(i)}</div><h3>{n}</h3><p class="req">{r}</p><a class="btn inv" href="unduh.html#{o}">{ic("download")}{L("Unduh untuk","Download for","تحميل لنظام")} {n}</a></div>' for o, i, n, r in P)
    return (f'<section class="sec band" id="unduh"><div class="wrap" style="text-align:center"><div class="sec-head center"><h2>{L("Bawa khazanahnya ke perangkat Anda.","Take the heritage to your devices.","احمل الكنوز إلى أجهزتك.")}</h2><p class="lead">{L("Satu akun untuk Android, macOS, dan Windows. Masuk dengan akun Google, lalu pilih bidang pertama Anda.","One account for Android, macOS, and Windows. Sign in with a Google account, then pick your first field.","حساب واحد لأندرويد وماك ويندوز. سجّل الدخول بحساب Google ثم اختر مجالك الأول.")}</p></div>'
            f'<div class="platforms rv">{cards}</div><div class="access" style="justify-content:center"><span>{L("Masuk dengan akun Google","Sign in with a Google account","الدخول بحساب Google")}</span><span>{L("Akses per modul bidang","Access per field module","الوصول لكل وحدة مجال")}</span><span>{L("Perpanjangan manual, tanpa auto-debit","Manual renewal, no auto-debit","تجديد يدوي دون خصم تلقائي")}</span></div></div></section>')

# ======================= BIDANG =======================
def page_bidang():
    write("bidang.html", L("Bidang ilmu: OpenTurath", "Fields of knowledge: OpenTurath", "المجالات العلمية: OpenTurath"),
          L("Peta bidang ilmu OpenTurath AI: fikih empat mazhab, hadis, tafsir, ushul, akidah, tasawuf, bahasa Arab, sejarah, bibliografi, dan Fikih Tahawwulat.", "Map of the fields of OpenTurath AI: fiqh across four schools, hadith, tafsir, usul, creed, tasawwuf, Arabic, history, bibliography, and Fiqh al-Tahawwulat.", "خريطة مجالات OpenTurath AI: الفقه في المذاهب الأربعة، والحديث، والتفسير، والأصول، والعقيدة، والتصوف، واللغة العربية، والتاريخ، والفهارس، وفقه التحولات."),
          head("OpenTurath AI", L("Bidang ilmu.", "Fields of knowledge.", "المجالات العلمية."), L("Setiap bidang punya asisten, kumpulan kitab, dan metodologinya sendiri. Pilih yang sesuai dengan ilmu yang Anda pelajari.", "Every field has its own assistant, set of books, and method. Pick the one that fits what you are studying.", "لكل مجال مساعده ومجموعة كتبه ومنهجه. اختر ما يوافق العلم الذي تدرسه.")) +
          sec(explorer("all", with_all=True, search=True), "sec-tight") +
          sec(f'<div class="statement" style="margin-top:0"><div><p>{L("Cakupan terus bertambah.","The scope keeps growing.","النطاق يتّسع باستمرار.")}</p></div><div><p class="small">{L("Dari Fikih Tahawwulat dan bidang yang ada, meluas ke seluruh ilmu Islam dan khazanah para ulama.","From Fiqh al-Tahawwulat and the existing fields, expanding to all the Islamic sciences and the heritage of the scholars.","من فقه التحولات والمجالات القائمة إلى سائر العلوم الإسلامية وتراث العلماء.")}</p><a class="btn inv-o sm" href="ekosistem.html">{L("Arah OpenTurath","Where OpenTurath is heading","وجهة OpenTurath")}</a></div></div>', "sec-tight"), "bidang.html")

# ======================= FIKIH TAHAWWULAT =======================
def page_tahaw():
    bab_ar = {"Pembuka": "المقدمة", "Perumpamaan": "التشبيه", "Dalil": "الدليل", "Keberatan": "الاعتراضات", "Tetap dan berubah": "الثوابت والمتغيرات", "Nama dan definisi": "الاسم والتعريف", "Tugasnya": "وظيفته", "Isinya": "مضمونه", "Waktunya": "زمانه", "Peta perjalanan": "خريطة المسير", "Rambu": "العلامات", "Sikap": "الموقف", "Tujuh langkah": "سبع خطوات", "Mulai belajar": "ابدأ التعلّم", "Penutup": "الخاتمة"}
    bab_en = {"Pembuka": "Opening", "Perumpamaan": "An analogy", "Dalil": "The evidence", "Keberatan": "Objections", "Tetap dan berubah": "The constant and the changing", "Nama dan definisi": "Name and definition", "Tugasnya": "Its task", "Isinya": "Its content", "Waktunya": "Its time", "Peta perjalanan": "The road map", "Rambu": "The signposts", "Sikap": "The right stance", "Tujuh langkah": "Seven steps", "Mulai belajar": "Start learning", "Penutup": "Closing"}
    bab = "".join(f'<li><b>{b["no"]:02d}</b> {E({"id": b["judul"], "en": bab_en[b["judul"]], "ar": bab_ar[b["judul"]]}[LANG])}</li>' for b in PENG["bab"])
    ib = SL["empat-rukun"]
    rows = [("Al-Muhaqqiq", "المحقق", L("Teks matan dan ibarah", "Texts and passages", "النصوص والعبارات"), L("Mencari, memeriksa, dan mengaitkan teks dengan sumbernya.", "Finds, checks, and links texts to their sources.", "يبحث ويتحقق ويربط النص بمصدره."), L("Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?", "What is meant by the Fourth Pillar in Fiqh al-Tahawwulat?", "ما المقصود بالركن الرابع في فقه التحولات؟")),
            ("Al-Bayan", "البيان", L("Penyederhanaan konsep", "Simplifying concepts", "تبسيط المفاهيم"), L("Menjelaskan konsep dan istilah dengan bahasa sederhana secara metodis.", "Explains concepts and terms in plain language, step by step.", "يشرح المفاهيم والمصطلحات بلغة بسيطة ومنهجية."), L("Bagaimana penjelasan al-ghutsa'iyyah dalam kitab?", "How do the books explain al-ghuthaiyya?", "كيف تشرح الكتب مفهوم الغثائية؟")),
            ("Al-Mukhtabir", "المختبر", L("Uji pemahaman dan nalar", "Testing understanding", "اختبار الفهم والنظر"), L("Menilai pemahaman dan menguji persoalan kontemporer.", "Assesses understanding and tests contemporary issues.", "يقيّم الفهم ويختبر النوازل المعاصرة."), L("Uji pemahaman saya tentang rukun agama yang empat.", "Test my understanding of the four pillars of religion.", "اختبر فهمي لأركان الدين الأربعة.")),
            ("Al-Habib", "الحبيب", L("Arsip muhadharah", "Lecture archive", "أرشيف المحاضرات"), L("Gudang ceramah dan rekaman Al-Habib Abu Bakar, dengan tautan video pada menit yang tepat.", "The store of Al-Habib Abu Bakr's lectures and recordings, linked to the exact minute.", "مستودع محاضرات الحبيب أبي بكر وتسجيلاته، مع رابط المقطع في الدقيقة المناسبة."), L("Muhadharah mana yang membahas sikap saat masa fitnah?", "Which lecture discusses conduct in times of trial?", "أي محاضرة تتناول الموقف زمن الفتن؟")),
            ("Al-Khatib", "الخطيب", L("Materi dakwah dan khutbah", "Da'wa and sermon material", "المواد الدعوية والخطب"), L("Menyusun khutbah dan materi ceramah serta mengarahkan persoalan dakwah.", "Drafts sermons and talks and guides da'wa questions.", "يُعدّ الخطب والمحاضرات ويوجّه المسائل الدعوية."), L("Susun kerangka khutbah tentang sikap saat masa fitnah.", "Outline a sermon on conduct in times of trial.", "ضع هيكل خطبة عن الموقف زمن الفتن."))]
    brt = "".join(f'<tr><td class="c"><b>{a}</b><div class="ar">{b}</div></td><td>{c}</td><td>{d}</td><td><span class="small">&ldquo;{e}&rdquo;</span></td></tr>' for a, b, c, d, e in rows)
    th = (L("Peran", "Role", "الدور"), L("Fungsi", "What it does", "الوظيفة"), L("Contoh pertanyaan", "Sample question", "سؤال توضيحي"), L("Asisten", "Assistant", "المساعد"))
    defn = L("Pemahaman syar'i atas ketetapan Allah dan sunnah-sunnah perubahan dalam kehidupan manusia dan alam, serta hal-hal baru dalam ilmu, budaya, peristiwa, dan fitnah sepanjang masa umat hingga kiamat.",
             "The legal-religious understanding of what God decrees and of the laws of change in human and cosmic life, together with the new developments in knowledge, culture, events, and trials across the life of the Ummah until the Hour.",
             "هو الفهم الشرعي لما يقضي الله ويدبّر، ولسنن التغيّرات في الحياة الإنسانية والكونية، وما يطرأ من مستجدات العلم والثقافة والحوادث والفتن في مراحل الأمة إلى قيام الساعة.")
    srcdef = L("An-Nubdzah ash-Shughra, hlm. 17", "An-Nubdhah al-Sughra, p. 17", "النبذة الصغرى، ص ١٧")
    body = (head(L("Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات"), L("Memahami perubahan zaman dengan petunjuk Nabi ﷺ.", "Understanding the changes of the age by the Prophet's guidance ﷺ.", "فهم تحولات العصر بهدي النبي ﷺ."), defn + f' <span class="small">({srcdef})</span>',
                 '<div class="ar bigname">فقه التحولات</div>') +
            sec(f'''<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">{L("Yang tetap dan yang berubah.","The constant and the changing.","الثوابت والمتغيرات.")}</h2><p class="lead">{L("Ilmu-ilmu agama terbagi dua. Yang tetap: Islam (syariat), iman (akidah), dan ihsan (suluk). Yang berubah: ilmu tentang tanda-tanda zaman, yang disebut Fikih Tahawwulat.","The religious sciences fall into two. The constant: Islam (law), iman (creed), and ihsan (spiritual conduct). The changing: the knowledge of the signs of the times, called Fiqh al-Tahawwulat.","علوم الدين قسمان: الثوابت، وهي الإسلام (الشريعة) والإيمان (العقيدة) والإحسان (السلوك)، والمتغيرات، وهي العلم بعلامات الساعة المسمى فقه التحولات.")}</p><p class="small">{L("An-Nubdzah ash-Shughra, hlm. 14","An-Nubdhah al-Sughra, p. 14","النبذة الصغرى، ص ١٤")}</p></div>
<div class="rv d1"><div class="ibarah"><div class="lbl">{L("Ibarah","Passage","العبارة")}</div><div class="ar" style="font-size:30px">{E(ib["ibarah"])}</div><p class="small" style="margin:6px 0 0">{E(src_label(ib["sumber"]))}</p></div>
<p>{L("Dari rangkaian empat pertanyaan dalam hadis Jibril, dan sabda Nabi bahwa Jibril datang mengajarkan agama kalian, dipahami bahwa rukun agama ada empat.","From the four questions in the hadith of Jibril, and the Prophet's words that Jibril came to teach you your religion, it is understood that the pillars of religion are four.","من سياق الأسئلة الأربعة في حديث جبريل، وقوله ﷺ إن جبريل أتاكم يعلّمكم أمر دينكم، يُعلم أن أركان الدين أربعة.")}</p></div></div>''') +
            f'<section class="sec band"><div class="wrap">{shead(L("Rukun keempat","The fourth pillar","الركن الرابع"), L("Penjaga tiga rukun yang lain.","Guardian of the other three.","حارس الأركان الثلاثة الأخرى."))}<div class="tahaw rv"><div class="gate" data-hl="">{gate_svg()}</div>{rukun_html()}</div><div class="rv">{tasks_html()}</div></div></section>' +
            f'<section class="sec band"><div class="wrap">{shead(L("Lima asisten","Five assistants","خمسة مساعدين"), L("Satu bidang, lima cara belajar.","One field, five ways to learn.","مجال واحد، وخمس طرق للتعلّم."), L("Korpusnya adalah kitab karya Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur dan arsip muhadharah beliau. Lima asisten membagi disiplin ini menurut kebutuhan pembelajar. Satu akses membuka kelimanya.","The corpus is the books of Al-Habib Abu Bakr al-Adni ibn Ali al-Mashhur and his lecture archive. Five assistants divide the discipline by the learner’s need. One access opens all five.","مدوّنتها كتب الحبيب أبي بكر العدني بن علي المشهور وأرشيف محاضراته. ويقسّم خمسة مساعدين هذا العلم بحسب حاجة المتعلّم. وبوصول واحد تُفتح الخمسة جميعًا."))}{branches_html()}'
            f'<table class="tbl rv" style="margin-top:48px"><thead><tr><th>{th[3]}</th><th>{th[0]}</th><th>{th[1]}</th><th>{th[2]}</th></tr></thead><tbody>{brt}</tbody></table></div></section>' +
            sec(shead(L("Pengantar", "Introduction", "مدخل"), L("Mulai dari video pengantar.", "Start with the introductory video.", "ابدأ بالفيديو التمهيدي."), L("Di dalam aplikasi, video pengantar sekitar dua belas menit menuntun Anda lewat lima belas bab, lengkap dengan ibarah dan sumbernya.", "Inside the app, an introductory video of about twelve minutes walks you through fifteen chapters, with passages and sources.", "داخل التطبيق فيديو تمهيدي مدته نحو اثنتي عشرة دقيقة يمرّ بك على خمسة عشر بابًا، مع العبارات ومصادرها.")) + f'<ul class="list-clean rv cols3">{bab}</ul><p style="margin-top:36px"><a class="btn primary" href="unduh.html">{ic("download")}{L("Unduh aplikasi","Download the app","تحميل التطبيق")}</a></p>'))
    write("fikih-tahawwulat.html", L("Fikih Tahawwulat: OpenTurath", "Fiqh al-Tahawwulat: OpenTurath", "فقه التحولات: OpenTurath"),
          L("Kenali Fikih Tahawwulat, rukun keempat agama, dan lima asisten OpenTurath AI untuk mempelajarinya.", "Get to know Fiqh al-Tahawwulat, the fourth pillar of religion, and the five OpenTurath AI assistants for studying it.", "تعرّف على فقه التحولات، الركن الرابع من أركان الدين، والمساعدين الخمسة في OpenTurath AI لدراسته."), body, "")

# ======================= CARA KERJA =======================
def page_cara():
    steps = [(L("Pilih bidang", "Choose a field", "اختر المجال"), L("Pilih asisten sesuai ilmu yang ditanyakan, dari fikih sampai hadis, tafsir, dan bahasa Arab.", "Pick the assistant for the discipline you are asking about, from fiqh to hadith, tafsir, and Arabic.", "اختر المساعد المناسب للعلم الذي تسأل عنه، من الفقه إلى الحديث والتفسير واللغة العربية.")),
             (L("Ajukan pertanyaan", "Ask a question", "اطرح سؤالك"), L("Tulis dengan bahasa sehari-hari, atau mulai dari pertanyaan contoh yang tersedia di tiap bidang.", "Write in everyday language, or start from the sample questions available in each field.", "اكتب بلغتك المعتادة، أو ابدأ من الأسئلة التوضيحية المتاحة في كل مجال.")),
             (L("Asisten menelusuri", "The assistant searches", "يبحث المساعد"), L("Penelusuran hanya dari kumpulan kitab bidang itu, bukan dari seluruh internet.", "It searches only the books of that field, not the whole internet.", "يبحث في كتب ذلك المجال وحدها، لا في الإنترنت كله.")),
             (L("Baca jawabannya", "Read the answer", "اقرأ الإجابة"), L("Penjelasan, ibarah Arab, dan nomor rujukan hadir bersama dalam satu jawaban.", "The explanation, the Arabic passage, and the reference number come together in one answer.", "يجتمع الشرح والعبارة العربية ورقم المرجع في إجابة واحدة.")),
             (L("Periksa kitabnya", "Check the book", "راجع الكتاب"), L("Buka keterangan kitab, cocokkan dengan edisi yang Anda pegang, dan baca konteksnya.", "Open the book details, match them with your edition, and read the context.", "افتح بيانات الكتاب وطابقها مع طبعتك واقرأ السياق.")),
             (L("Simpan dan bawa ke guru", "Save and bring it to your teacher", "احفظ وارجع إلى المعلم"), L("Simpan ke Catatan beserta rujukannya, lalu bawa ke majelis untuk dipastikan.", "Save it to Notes with its reference, then bring it to the majlis to be confirmed.", "احفظها في الملاحظات مع مرجعها، ثم اعرضها في المجلس للتثبّت."))]
    st = "".join(f'<div class="rv"><div class="n">{i+1:02d}</div><h3>{t}</h3><p>{d}</p></div>' for i, (t, d) in enumerate(steps))
    pr = [(L("Korpus per bidang", "A corpus per field", "مدوّنة لكل مجال"), L("Tiap asisten hanya berpegang pada kitab bidangnya, sehingga metodologi tiap ilmu tidak tercampur.", "Each assistant keeps only to the books of its field, so the method of each discipline stays distinct.", "يلتزم كل مساعد بكتب مجاله وحده، فلا تختلط مناهج العلوم.")),
          (L("Kurasi satu per satu", "Curated one by one", "انتقاء كتاب كتابًا"), L("Kitab dipilih dengan teliti. Jumlah kitab bukan ukuran; yang diukur adalah ketepatan jawaban.", "Books are chosen with care. The number of books is not the measure; the accuracy of answers is.", "تُختار الكتب بعناية. ليس العدد هو المعيار، بل دقة الإجابة.")),
          (L("Kitab utuh, bukan potongan acak", "Whole books, not random pieces", "كتب كاملة لا قصاصات"), L("Kitab ditaruh utuh dan dibagi hanya mengikuti sekat jilidnya.", "Books are kept whole and divided only along their volumes.", "تُحفظ الكتب كاملة ولا تُقسَّم إلا على حدود أجزائها.")),
          (L("Stempel rujukan", "A reference stamp", "ختم المرجع"), L("Setiap potongan teks bertanda: judul kitab, pengarang dan tahun wafat, penerbit atau pentahqiq, jilid, halaman.", "Every piece of text is marked: title, author and death year, publisher or editor, volume, page.", "كل مقطع موسوم: عنوان الكتاب، والمؤلف وسنة وفاته، والناشر أو المحقق، والجزء والصفحة.")),
          (L("Kurasi wasathiyyah syar'iyyah", "Curation by al-wasatiyya al-shar'iyya", "انتقاء وفق الوسطية الشرعية"), L("Kitab dipilih agar tidak terpolitisasi dan tidak dipakai menjatuhkan kelompok lain.", "Books are chosen so scholarship is not politicised or used to bring other groups down.", "تُنتقى الكتب حتى لا تُسيَّس ولا تُستعمل لإسقاط الآخرين.")),
          (L("Diperiksa sebelum masuk", "Checked before entering", "فحص قبل الإدخال"), L("Setiap penambahan diperiksa sebelum menjadi bagian korpus.", "Every addition is checked before becoming part of the corpus.", "تُفحص كل إضافة قبل أن تصبح جزءًا من المدوّنة."))]
    prh = "".join(f'<li><b>{t}.</b> {d}</li>' for t, d in pr)
    lim = [L("Jawaban AI dapat keliru atau kurang lengkap.", "AI answers can be wrong or incomplete.", "قد تخطئ إجابة الذكاء الاصطناعي أو تنقص."), L("Penjelasan AI perlu diverifikasi kepada guru, terutama untuk amal dan fatwa.", "AI explanations should be verified with a teacher, especially for practice and fatwa.", "يجب التحقق من شرح الذكاء الاصطناعي لدى المعلم، خاصة في العمل والفتوى."), L("Nomor halaman dapat berbeda antar edisi cetak.", "Page numbers can differ between printed editions.", "قد تختلف أرقام الصفحات بين الطبعات."), L("Tidak semua kitab ada di setiap bidang.", "Not every book is in every field.", "ليست كل الكتب موجودة في كل مجال."), L("OpenTurath AI bukan pemberi fatwa dan tidak menggantikan guru.", "OpenTurath AI is not a mufti and does not replace a teacher.", "OpenTurath AI ليس مفتيًا ولا يحل محل المعلم.")]
    body = (head(L("Cara kerja", "How it works", "كيف يعمل"), L("Dari pertanyaan sampai rujukan.", "From question to reference.", "من السؤال إلى المرجع."), L("Enam langkah sederhana, dan satu kebiasaan yang kami ajak Anda jaga: selalu kembali membuka kitabnya.", "Six simple steps, and one habit we invite you to keep: always go back and open the book.", "ست خطوات بسيطة، وعادة ندعوك إلى حفظها: أن تعود دائمًا إلى فتح الكتاب.")) +
            sec(f'<div class="steps6">{st}</div>', "sec-tight") +
            sec(f'<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">{L("Bagaimana korpusnya dijaga.","How the corpus is kept.","كيف تُحفظ المدوّنة.")}</h2><p class="lead">{L("Enam hal yang kami jaga agar korpus tiap asisten tetap rapi dan bisa ditelusuri.","Six things we do to keep each assistant’s corpus orderly and traceable.","ست قواعد تحفظ مدوّنة كل مساعد منظمة وقابلة للتتبّع.")}</p></div><ul class="list-clean rv d1">{prh}</ul></div>') +
            sec(f'<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">{L("Batas yang jujur.","Honest limits.","حدود صادقة.")}</h2><p class="lead">{L("Mengetahui batas alat adalah bagian dari adab menuntut ilmu.","Knowing the limits of a tool is part of the adab of seeking knowledge.","معرفة حدود الأداة من أدب طلب العلم.")}</p></div><ul class="list-clean rv d1">{"".join(f"<li>{x}</li>" for x in lim)}</ul></div>', "sec band"))
    write("cara-kerja.html", L("Cara kerja: OpenTurath", "How it works: OpenTurath", "كيف يعمل: OpenTurath"),
          L("Dari pertanyaan sampai rujukan: cara kerja OpenTurath AI dalam enam langkah, dan prinsip penyusunan korpus di baliknya.", "From question to reference: how OpenTurath AI works in six steps, and the corpus principles behind it.", "من السؤال إلى المرجع: كيف يعمل OpenTurath AI في ست خطوات، ومبادئ بناء المدوّنة خلفه."), body, "cara-kerja.html")

# ======================= PEDOMAN =======================
def page_pedoman():
    k = {"id": 0, "en": 1, "ar": 2}[LANG]
    def clean(t): return t.replace("hasil telaah itu", "hasil itu").replace("ditelaah kembali", "dibaca kembali").replace("bagi telaah Anda", "bagi proses belajar Anda") if LANG == "id" else t
    adab = "".join(f'<div class="pillar rv"><h3 style="font-size:22px">{E(clean(p["heading"][k]))}</h3><p>{E(clean(p["body"][k]))}</p></div>' for p in ADAB["principles"][:6])
    body = (head(L("Pedoman keilmuan", "Scholarly guidelines", "الضوابط العلمية"), L("Pegangan kami dalam memilih kitab dan memakai AI.", "How we choose books and how we use AI.", "ميزاننا في انتقاء الكتب واستعمال الذكاء الاصطناعي."), L("Cara kami memilih kitab, peran AI dibanding guru, dan adab yang kami ajak setiap pengguna menjaganya.", "How we choose books, the role of AI beside the teacher, and the adab we invite every user to keep.", "كيف ننتقي الكتب، ودور الذكاء الاصطناعي إلى جانب المعلم، والأدب الذي ندعو كل مستخدم إلى حفظه.")) +
            sec(f'''<div class="cols2"><div class="rv"><div class="ar bigname sm">الوسطية الشرعية والاعتدال الواعي</div><p class="small" style="margin-bottom:24px">Al-Wasathiyyah Asy-Syar'iyyah wal-I'tidal Al-Wa'i</p>
<p class="lead">{L("Ukuran kami memilih kitab. Wasathiyyah syar'iyyah bukan kompromi mekanis atau titik tengah politis. Ia bertumpu pada Al-Qur'an, sunnah, dan akhlak kenabian, dan menjaga dari dua jurang: berlebihan dan meremehkan.","Our measure for choosing books. Al-wasatiyya al-shar'iyya is not a mechanical compromise or a political middle. It rests on the Qur'an, the Sunna, and prophetic character, and guards against two pits: excess and neglect.","هي ميزاننا في انتقاء الكتب. والوسطية الشرعية ليست تسوية آلية ولا وسطًا سياسيًا، بل تقوم على القرآن والسنة وأخلاق النبوة، وتحفظ من هوّتين: الإفراط والتفريط.")}</p></div>
<ul class="list-clean rv d1"><li><b>{L("Inti.","Core.","الأصل.")}</b> {L("Kitab induk bersanad yang menjadi dasar jawaban: mazhab fikih empat, akidah Asy'ari dan Maturidi, tasawuf yang lurus, dan Fikih Tahawwulat.","Foundational books with chains of transmission that ground the answers: the four fiqh schools, Ash'ari and Maturidi creed, sound tasawwuf, and Fiqh al-Tahawwulat.","الكتب الأمهات المسندة التي تقوم عليها الإجابة: المذاهب الفقهية الأربعة، وعقيدة الأشاعرة والماتريدية، والتصوف المستقيم، وفقه التحولات.")}</li>
<li><b>{L("Pembanding terbatas.","Limited comparison.","مقارنة محدودة.")}</b> {L("Pandangan yang tajam atau diperselisihkan disimpan hanya sebagai pembanding, tidak menjadi dasar hukum atau jawaban otomatis.","Sharp or disputed views are kept only for comparison, never as a basis for rulings or automatic answers.","الآراء الحادة أو المختلف فيها تُحفظ للمقارنة فقط، ولا تكون أساس حكم ولا جوابًا آليًا.")}</li>
<li><b>{L("Dikecualikan.","Excluded.","مستبعد.")}</b> {L("Naskah propaganda kekerasan, adu domba antar muslim, dan tulisan yang dirancang merusak akidah serta kehormatan ulama.","Texts that propagate violence, set Muslims against each other, or are designed to damage creed and the honour of scholars.","نصوص الدعاية للعنف والتحريش بين المسلمين وما قُصد به الإضرار بالعقيدة وكرامة العلماء.")}</li>
<li><b>{L("Salamatul lisan.","Safety of the tongue.","سلامة اللسان.")}</b> {L("AI tidak mencela, mengkafirkan, atau menyesatkan sesama muslim.","The AI does not revile, declare takfir on, or label fellow Muslims as astray.","لا يذمّ الذكاء الاصطناعي المسلمين ولا يكفّرهم ولا يضلّلهم.")}</li>
<li><b>{L("Salamatul yad.","Safety of the hand.","سلامة اليد.")}</b> {L("AI tidak memprovokasi kekerasan atau pertumpahan darah.","The AI does not provoke violence or bloodshed.","لا يحرّض الذكاء الاصطناعي على العنف ولا سفك الدماء.")}</li></ul></div>''') +
            sec(shead(L("Adab", "Adab", "الآداب"), L("Panduan bagi pembaca.", "Guidance for the reader.", "إرشادات للقارئ.")) + f'<div class="pillars three">{adab}</div>') +
            sec(f'<div class="statement" style="margin-top:0"><div><p>{L("Menemukan kesalahan? Beri tahu kami.","Found a mistake? Tell us.","وجدت خطأ؟ أخبرنا.")}</p></div><div><p class="small">{L("Sertakan kutipan, kitab, dan edisi yang Anda pegang agar mudah diperiksa.","Include the quotation, the book, and the edition you hold so it can be checked easily.","أرفق العبارة والكتاب والطبعة التي بين يديك ليسهل فحصها.")}</p><a class="btn inv-o sm" href="bantuan.html#lapor">{L("Laporkan kesalahan","Report an error","الإبلاغ عن خطأ")}</a></div></div>', "sec-tight"))
    write("pedoman.html", L("Pedoman keilmuan: OpenTurath", "Scholarly guidelines: OpenTurath", "الضوابط العلمية: OpenTurath"),
          L("Wasathiyyah syar'iyyah sebagai ukuran kurasi kitab, peran AI dan guru, serta adab memakai OpenTurath AI.", "Al-wasatiyya al-shar'iyya as the measure for curating books, the role of AI and the teacher, and the adab of using OpenTurath AI.", "الوسطية الشرعية ميزانًا لانتقاء الكتب، ودور الذكاء الاصطناعي والمعلم، وآداب استعمال OpenTurath AI."), body, "pedoman.html")

# ======================= EKOSISTEM =======================
def page_eko():
    def lini(n, st, title, desc, pts):
        li = "".join(f"<li>{p}</li>" for p in pts)
        return (f'<div class="cols2 lini"><div class="rv"><div class="kicker">{L("Lini","Line","الخط")} {n}</div><h2 style="margin-bottom:16px">{title}</h2><span class="status">{st}</span></div><div class="rv d1"><p class="lead" style="margin-bottom:20px">{desc}</p><ul class="list-clean">{li}</ul></div></div>')
    body = (head(L("Ekosistem", "Ecosystem", "المنظومة"), L("OpenTurath lebih dari satu aplikasi.", "OpenTurath is more than one app.", "OpenTurath أكثر من تطبيق."), L("Tujuannya satu: menjadi rumah baru bagi seluruh penuntut ilmu. Empat lini yang saling menguatkan.", "One aim: to be a new home for all seekers of knowledge. Four lines that strengthen each other.", "غاية واحدة: أن يكون بيتًا جديدًا لكل طلاب العلم. أربعة خطوط يقوّي بعضها بعضًا.")) +
            sec(lini("01", L("Rilis 23 Okt 2026","Released 23 Oct 2026","الإطلاق 23 أكتوبر 2026"), "OpenTurath AI", L("AI Islami berbasis turath yang mencakup semua bidang ilmu dan khazanah para ulama. Cita-citanya: menjadi garda terdepan AI Islami berbasis turath.","An Islamic AI grounded in turath, covering all fields and the heritage of the scholars. The aim: to be the frontier of turath-based Islamic AI.","ذكاء اصطناعي إسلامي قائم على التراث يشمل كل العلوم وميراث العلماء. وغايته: أن يكون في طليعة الذكاء الاصطناعي الإسلامي القائم على التراث."), [L("Asisten per bidang, masing-masing dengan korpus dan metodologinya.","An assistant per field, each with its own corpus and method.","مساعد لكل مجال، ولكل منه مدوّنته ومنهجه."), L("Jawaban disertai ibarah dan rujukan.","Answers come with the passage and its reference.","تأتي الإجابة بالعبارة ومرجعها."), L("Pustaka, Catatan, dan multi-tab di Android, macOS, dan Windows.","Library, Notes, and multiple tabs on Android, macOS, and Windows.","مكتبة وملاحظات وتبويبات متعددة على أندرويد وماك وويندوز."), L("Dari Fikih Tahawwulat, meluas ke nahwu, sharaf, bahasa Arab, fikih, ushul fikih, dan seluruh ilmu Islam.","From Fiqh al-Tahawwulat, expanding to grammar, morphology, Arabic, fiqh, usul al-fiqh, and all the Islamic sciences.","من فقه التحولات إلى النحو والصرف واللغة العربية والفقه وأصول الفقه وسائر العلوم الإسلامية.")]) +
                lini("02", L("Dibangun","In the making","قيد البناء"), L("Maktabah OpenTurath","OpenTurath Library","مكتبة OpenTurath"), L("Pusat unduh kitab yang menyatukan semua cetakan dan banyak sumber unduh dalam satu halaman. Cita-citanya: menjadi pusat unduh kitab terbesar di dunia.","A book download hub that brings every edition and many download sources onto one page. The aim: to be the largest book download hub in the world.","مركز لتحميل الكتب يجمع كل الطبعات ومصادر التحميل الكثيرة في صفحة واحدة. وغايته: أن يكون أكبر مركز لتحميل الكتب في العالم."), [L("Satu kitab, semua cetakannya: edisi penerbit yang berbeda ditampilkan berdampingan.","One book, all its editions: different publishers' editions shown side by side.","كتاب واحد بكل طبعاته: تُعرض طبعات الناشرين المختلفة جنبًا إلى جنب."), L("Tombol unduh dari berbagai sumber dalam satu tempat.","Download buttons from different sources in one place.","أزرار التحميل من مصادر متعددة في مكان واحد."), L("Terhubung dengan OpenTurath AI untuk membuka kitab yang dirujuk.","Connected to OpenTurath AI to open the book being cited.","متصل بـ OpenTurath AI لفتح الكتاب المحال إليه.")]) +
                lini("03", L("Tahap uji","In testing","قيد الاختبار"), L("AI Manuskrip","Manuscript AI","ذكاء المخطوطات"), L("Membantu membaca dan menahkik manuskrip. Tujuannya: menjadi AI manuskrip paling akurat di dunia. Pada pengujian kami, akurasinya sangat tinggi.","Helps read and critically edit manuscripts. The aim: to be the most accurate manuscript AI in the world. In our tests its accuracy is very high.","يساعد على قراءة المخطوطات وتحقيقها. وغايته: أن يكون أدق ذكاء اصطناعي للمخطوطات في العالم. وقد أظهر في اختباراتنا دقة عالية جدًا."), [L("Memberi makna bahasa.","Gives word meanings.","يبيّن معاني الألفاظ."), L("Menjelaskan tokoh yang dimaksud dalam naskah.","Explains the figures mentioned in the text.","يوضح الأعلام المقصودة في النص."), L("Mengenali hadis dan ayat yang dikutip.","Recognises the hadiths and verses quoted.","يتعرّف على الأحاديث والآيات المنقولة.")]) +
                lini("04", L("Rencana","Planned","مخطَّط"), L("Akademi OpenTurath","OpenTurath Academy","أكاديمية OpenTurath"), L("Belajar memakai AI bagi penuntut ilmu, dalam empat tahap.","Learning to use AI for seekers of knowledge, in four stages.","تعلّم استعمال الذكاء الاصطناعي لطلاب العلم، في أربع مراحل."), [L("Percakapan dengan AI, sebagai dasar.","Conversing with AI, as the foundation.","المحادثة مع الذكاء الاصطناعي أساسًا."), L("Gambar dan video untuk dakwah.","Images and video for da'wa.","الصور والمقاطع للدعوة."), L("Membuat aplikasi yang Anda butuhkan.","Building the apps you need.","بناء التطبيقات التي تحتاجها."), L("Membuat AI agent.","Building AI agents.","بناء وكلاء الذكاء الاصطناعي.")])))
    write("ekosistem.html", L("Ekosistem: OpenTurath", "Ecosystem: OpenTurath", "المنظومة: OpenTurath"),
          L("OpenTurath lebih besar dari satu aplikasi: OpenTurath AI, Maktabah OpenTurath, AI Manuskrip, dan Akademi OpenTurath.", "OpenTurath is bigger than one app: OpenTurath AI, OpenTurath Library, Manuscript AI, and OpenTurath Academy.", "OpenTurath أكبر من تطبيق واحد: OpenTurath AI ومكتبة OpenTurath وذكاء المخطوطات وأكاديمية OpenTurath."), body, "ekosistem.html")

# ======================= TENTANG =======================
def page_tentang():
    tl = [("2023", L("Gagasan lahir","The idea is born","وُلدت الفكرة"), L("Saat AI mulai populer, muncul pertanyaan: bagaimana jika AI dapat menyebut rujukan dengan sangat akurat dan terhubung ke maktabah?","As AI became popular, a question arose: what if AI could cite references accurately and connect to the library?","حين شاع الذكاء الاصطناعي نشأ سؤال: ماذا لو استطاع أن يذكر المراجع بدقة بالغة ويتصل بالمكتبة؟")),
          (L("2023 sampai 2026","2023 to 2026","من 2023 إلى 2026"), L("Belajar dan membangun","Learning and building","التعلّم والبناء"), L("Tiga tahun mempelajari AI dan cara membuat aplikasi secara mendalam, serta semua yang dibutuhkan untuk mencapai tujuan ini.","Three years studying AI and app-building in depth, and everything needed to reach this goal.","ثلاث سنوات من التعمّق في الذكاء الاصطناعي وبناء التطبيقات، ومن كل ما يلزم لبلوغ هذه الغاية.")),
          (L("7 Mei 2026","7 May 2026","7 مايو 2026"), L("Diumumkan di Hadramaut","Announced in Hadramawt","الإعلان في حضرموت"), L("Di Universitas Al-Wasatiyah, Hadramaut, Yaman, di hadapan para ulama. Di sinilah visi OpenTurath dipaparkan untuk pertama kalinya.","At Al-Wasatiyah University, Hadramawt, Yemen, before scholars. The vision of OpenTurath was first presented here.","في جامعة الوسطية بحضرموت باليمن بحضور العلماء، وفيها عُرضت رؤية OpenTurath لأول مرة.")),
          (L("23 Oktober 2026","23 October 2026","23 أكتوبر 2026"), L("Rilis publik perdana","First public release","الإطلاق العام الأول"), L("OpenTurath AI dibuka untuk publik.","OpenTurath AI opens to the public.","يُفتح OpenTurath AI للجمهور."))]
    tlh = "".join(f'<div class="rv"><div class="d">{d}</div><div><h3 style="font-size:24px;margin-bottom:6px">{t}</h3><p>{x}</p></div></div>' for d, t, x in tl)
    vals = [(L("Kembali kepada sumber","Back to the source","الرجوع إلى المصدر"), L("Setiap jawaban berpijak pada kitab dan ceramah ulama.","Every answer rests on the books and lectures of the scholars.","كل إجابة تستند إلى كتب العلماء ومحاضراتهم.")), (L("Kembali berguru","Back to the teacher","الرجوع إلى المعلم"), L("AI hanyalah alat, dan tidak menggantikan guru.","AI is only a tool and does not replace a teacher.","الذكاء الاصطناعي أداة فقط ولا يحل محل المعلم.")),
            (L("Amanah","Trustworthiness","الأمانة"), L("Menjaga ketepatan ibarah dan jujur tentang batas.","Keeping passages accurate and honest about limits.","حفظ دقة العبارات والصدق في بيان الحدود.")), (L("Wasathiyyah syar'iyyah","Al-wasatiyya al-shar'iyya","الوسطية الشرعية"), L("Kurasi yang tidak berlebihan dan tidak meremehkan.","Curation without excess or neglect.","انتقاء لا إفراط فيه ولا تفريط.")),
            (L("Metodologi tiap ilmu dijaga","Each discipline's method is kept","منهج كل علم محفوظ"), L("Fikih dan hadis punya metodenya masing-masing.","Fiqh and hadith each have their own method.","للفقه والحديث منهجه الخاص لكل منهما.")), (L("Sarana baru, esensi terjaga","New means, essence preserved","وسائل جديدة، وجوهر محفوظ"), L("Memperbarui cara belajar tanpa merusak inti ajaran.","Renewing how we learn without damaging the core of the teaching.","تجديد طريقة التعلّم دون المساس بجوهر التعليم."))]
    vh = "".join(f'<div class="pillar rv"><h3 style="font-size:22px">{t}</h3><p>{d}</p></div>' for t, d in vals)
    body = (head(L("Tentang", "About", "عن OpenTurath"), L("Dibuat oleh pelajar, untuk para pelajar.", "Made by a student, for students.", "من طالب علم، لطلاب العلم."), L("OpenTurath adalah AI Islami berbasis turath: setiap jawabannya berpijak pada kitab dan ceramah para ulama.", "OpenTurath is an Islamic AI grounded in turath: every answer rests on the books and lectures of the scholars.", "OpenTurath ذكاء اصطناعي إسلامي قائم على التراث: كل إجابة فيه تستند إلى كتب العلماء ومحاضراتهم.")) +
            sec(f'''<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">{L("Awal ceritanya.","How it began.","كيف بدأ الأمر.")}</h2><span class="pill">{L("Sang perintis","The founder","المؤسس")}</span></div><div class="rv d1">
<p class="lead" style="margin-bottom:18px">{L("Sang perintis adalah seorang santri yang berguru kepada para ulama. Saat murajaah seorang diri, ia membaca salah satu kitab terbesar Fikih Tahawwulat dan menerjemahkannya kata demi kata. Satu halaman menghabiskan sekitar satu jam, dan ia tetap belum paham.","The founder is a student who studied under scholars. Reviewing alone, he read one of the largest books of Fiqh al-Tahawwulat and translated it word by word. One page took about an hour, and he still did not understand.","المؤسس طالب علم تلقّى عن العلماء. وبينما كان يراجع وحده قرأ أحد أكبر كتب فقه التحولات وترجمه كلمة كلمة. استغرقت الصفحة نحو ساعة، ولم يفهمها بعد.")}</p>
<p style="margin-bottom:16px">{L("Dari kesulitan itu lahir satu pertanyaan: bagaimana memudahkan penuntut ilmu menerjemahkan dan memahami kitab-kitab Fikih Tahawwulat, terutama istilah-istilahnya? Jawabannya ia cari lewat teknologi, dengan satu syarat: setiap jawaban harus punya rujukan.","From that difficulty came a question: how can we make it easier for seekers of knowledge to translate and understand the books of Fiqh al-Tahawwulat, especially its terms? He looked for the answer in technology, on one condition: every answer must have a reference.","ومن تلك الصعوبة وُلد سؤال: كيف نيسّر على طالب العلم ترجمة كتب فقه التحولات وفهمها، ولا سيما مصطلحاتها؟ فطلب الجواب في التقنية بشرط واحد: أن يكون لكل إجابة مرجع.")}</p>
<p>{L("OpenTurath dikerjakan seorang diri, dengan para ulama yang memeriksa isi keilmuannya. Kini sang perintis menempuh pendidikan pascasarjana di Yaman.","OpenTurath is built by one person, with scholars reviewing its content. The founder is now a postgraduate student in Yemen.","يبنيه شخص واحد، ويراجع العلماء محتواه العلمي. والمؤسس الآن طالب دراسات عليا في اليمن.")}</p></div></div>''') +
            sec(shead(L("Tonggak", "Milestones", "محطات"), L("Dari satu gagasan sampai rilis perdana.", "From one idea to the first release.", "من فكرة واحدة إلى الإطلاق الأول.")) + f'<div class="timeline">{tlh}</div>') +
            sec(shead(L("Nilai", "Values", "القيم"), L("Nilai yang kami pegang.", "The values we hold to.", "القيم التي نلتزم بها.")) + f'<div class="pillars three">{vh}</div>') +
            sec(f'<div class="statement" style="margin-top:0"><div><p>{L("Bicara dengan kami.","Talk to us.","تحدّث إلينا.")}</p></div><div><p class="small">support@openturath.id</p><a class="btn inv-o sm" href="bantuan.html">{L("Bantuan","Help","المساعدة")}</a></div></div>', "sec-tight"))
    write("tentang.html", L("Tentang: OpenTurath", "About: OpenTurath", "عن OpenTurath"),
          L("Cerita OpenTurath: dirintis seorang santri yang kesulitan memahami kitab, lalu mencari jalan agar penuntut ilmu lain tidak mengalaminya.", "The story of OpenTurath: started by a student who struggled to understand the books and looked for a way to spare other seekers of knowledge.", "قصة OpenTurath: أسسه طالب علم صعب عليه فهم الكتب، فبحث عن طريق يعفي غيره من طلاب العلم من هذه الصعوبة."), body, "tentang.html")

# ======================= UNDUH =======================
def page_unduh():
    def plat(osid, icn, name, req, steps_):
        li = "".join(f"<li>{s}</li>" for s in steps_)
        return (f'<div class="plat" id="{osid}" data-os="{osid}"><div class="plat-top"><div class="p-ic">{ic(icn)}</div><span class="status rec-badge" hidden>{L("Untuk perangkat Anda","For your device","لجهازك")}</span></div><h3>{name}</h3><p class="req">{req}</p>'
                f'<ul class="list-clean small-li">{li}</ul><a class="btn primary" href="{BASE}/{LANG}/download/">{ic("download")}{L("Unduh untuk","Download for","تحميل لنظام")} {name}</a></div>')
    body = (head(L("Unduh", "Download", "تحميل"), L("Mulai belajar hari ini.", "Start learning today.", "ابدأ التعلّم اليوم."), L("OpenTurath AI tersedia untuk ponsel dan komputer. Masuk dengan akun Google, lalu pilih bidang pertama Anda.", "OpenTurath AI is available for phone and computer. Sign in with a Google account, then pick your first field.", "OpenTurath AI متاح للهاتف والحاسوب. سجّل الدخول بحساب Google ثم اختر مجالك الأول.")) +
            sec(f'''<div class="platforms rv">{plat("android","android","Android",L("Android 8.0 ke atas","Android 8.0 or later","أندرويد 8.0 فأعلى"),[L("Unduh berkas pemasangan.","Download the install file.","نزّل ملف التثبيت."),L("Izinkan pemasangan dari sumber ini bila diminta.","Allow installing from this source if asked.","اسمح بالتثبيت من هذا المصدر إن طُلب منك."),L("Buka aplikasi dan masuk.","Open the app and sign in.","افتح التطبيق وسجّل الدخول.")])}
{plat("macos","laptop","macOS",L("macOS 13 ke atas","macOS 13 or later","macOS 13 فأعلى"),[L("Unduh berkas pemasangan.","Download the install file.","نزّل ملف التثبيت."),L("Seret aplikasi ke folder Aplikasi.","Drag the app into the Applications folder.","اسحب التطبيق إلى مجلد التطبيقات."),L("Buka dan masuk.","Open it and sign in.","افتحه وسجّل الدخول.")])}
{plat("windows","windows","Windows",L("Windows 10 ke atas","Windows 10 or later","ويندوز 10 فأعلى"),[L("Unduh berkas arsip.","Download the archive.","نزّل الملف المضغوط."),L("Ekstrak, lalu jalankan aplikasi.","Extract it, then run the app.","فُكّ الضغط ثم شغّل التطبيق."),L("Masuk dengan akun Google.","Sign in with a Google account.","سجّل الدخول بحساب Google.")])}</div>
<div class="access"><span>{L("Masuk dengan akun Google","Sign in with a Google account","الدخول بحساب Google")}</span><span>{L("Akses per modul bidang","Access per field module","الوصول لكل وحدة مجال")}</span><span>{L("Perpanjangan manual, tanpa auto-debit","Manual renewal, no auto-debit","تجديد يدوي دون خصم تلقائي")}</span></div>''', "sec-tight") +
            sec(shead(L("Setelah memasang", "After installing", "بعد التثبيت"), L("Tiga langkah pertama.", "Your first three steps.", "خطواتك الثلاث الأولى.")) + f'<div class="steps6 three"><div class="rv"><div class="n">01</div><h3>{L("Masuk","Sign in","سجّل الدخول")}</h3><p>{L("Gunakan akun Google Anda. Akun yang sama berlaku di semua perangkat.","Use your Google account. The same account works on every device.","استعمل حساب Google. الحساب نفسه يعمل على كل الأجهزة.")}</p></div><div class="rv d1"><div class="n">02</div><h3>{L("Pilih bidang","Pick a field","اختر المجال")}</h3><p>{L("Mulailah dari bidang yang sedang Anda pelajari, atau dari pengantar Fikih Tahawwulat.","Start from the field you are studying, or from the Fiqh al-Tahawwulat introduction.","ابدأ من المجال الذي تدرسه، أو من مدخل فقه التحولات.")}</p></div><div class="rv d2"><div class="n">03</div><h3>{L("Bertanya","Ask","اسأل")}</h3><p>{L("Tulis pertanyaan dengan bahasa sehari-hari, lalu buka kitab yang dirujuk.","Write your question in everyday language, then open the book it cites.","اكتب سؤالك بلغتك المعتادة ثم افتح الكتاب المحال إليه.")}</p></div></div>'))
    write("unduh.html", L("Unduh: OpenTurath", "Download: OpenTurath", "تحميل: OpenTurath"), L("Unduh OpenTurath AI untuk Android, macOS, dan Windows.", "Download OpenTurath AI for Android, macOS, and Windows.", "حمّل OpenTurath AI لأندرويد وماك وويندوز."), body, "")

# ======================= BANTUAN =======================
def page_bantuan():
    more = FAQ_MAIN() + [
        (L("Berapa percakapan yang bisa dibuka bersamaan?", "How many conversations can I open at once?", "كم محادثة يمكن فتحها معًا؟"), L("Lima tab di macOS dan tiga tab di perangkat lain.", "Five tabs on macOS and three on other devices.", "خمس تبويبات على ماك وثلاث على الأجهزة الأخرى.")),
        (L("Di mana catatan saya disimpan?", "Where are my notes kept?", "أين تُحفظ ملاحظاتي؟"), L("Catatan menyimpan jawaban beserta kutipan Arab, kitab, dan halamannya, sehingga tetap bisa ditelusuri. Rinciannya ada di kebijakan privasi.", "Notes keep the answer with its Arabic passage, book, and page, so it stays traceable. Details are in the privacy policy.", "تحفظ الملاحظات الإجابة مع العبارة العربية والكتاب والصفحة لتبقى قابلة للتتبّع. وتفاصيله في سياسة الخصوصية."))]
    leg = "".join(f'<li><a class="link" href="{u}">{t}</a></li>' for u, t in legal_links())
    f = (L("Bidang atau asisten", "Field or assistant", "المجال أو المساعد"), L("Contoh: AI Fikih Syafi'i", "For example: AI Shafi'i Fiqh", "مثال: AI الفقه الشافعي"), L("Kutipan yang dipertanyakan", "The quotation in question", "العبارة موضع السؤال"), L("Kitab dan edisi yang Anda pegang", "Book and edition you hold", "الكتاب والطبعة التي بين يديك"), L("Judul, penerbit, jilid, halaman", "Title, publisher, volume, page", "العنوان والناشر والجزء والصفحة"), L("Alasan", "Your reason", "السبب"), L("Kirim lewat surel", "Send by email", "أرسل بالبريد"))
    body = (head(L("Bantuan", "Help", "المساعدة"), L("Kami siap membantu.", "We are here to help.", "نحن هنا للمساعدة."), L("Jawaban singkat, formulir laporan kesalahan, dan cara menghubungi kami.", "Short answers, an error-report form, and how to reach us.", "إجابات موجزة ونموذج للإبلاغ عن الأخطاء وطريقة التواصل معنا.")) +
            sec(f'<div class="rv">{faq(more)}</div>', "sec-tight") +
            sec(f'''<div class="cols2" id="lapor"><div class="rv"><h2 style="margin-bottom:16px">{L("Laporkan kesalahan.","Report an error.","الإبلاغ عن خطأ.")}</h2><p class="lead">{L("Informasi dari pembaca membantu kami memeriksa bagian yang perlu diperbaiki. Sertakan kutipan, kitab, dan edisi yang Anda pegang.","Readers' information helps us check what needs correcting. Include the quotation, the book, and the edition you hold.","تساعدنا ملاحظات القرّاء على فحص ما يحتاج إلى تصحيح. أرفق العبارة والكتاب والطبعة التي بين يديك.")}</p></div>
<form class="form rv d1" id="report"><label>{f[0]}<input name="bidang" placeholder="{f[1]}" required></label><label>{f[2]}<textarea name="kutipan" required></textarea></label><label>{f[3]}<input name="kitab" placeholder="{f[4]}"></label><label>{f[5]}<textarea name="alasan"></textarea></label><button class="btn primary" type="submit">{f[6]}</button></form></div>''') +
            sec(shead(L("Layanan dan kontak","Service and contact","الخدمة والتواصل"), L("Jam layanan dan saluran resmi.","Service hours and official channels.","ساعات الخدمة والقنوات الرسمية.")) + contact_block(), "sec") +
            sec(f'<div class="cols2" id="legal"><div class="rv"><h2 style="margin-bottom:16px">{L("Kontak dan kebijakan.","Contact and policies.","التواصل والسياسات.")}</h2><p class="lead">support@openturath.id</p></div><ul class="list-clean rv d1">{leg}</ul></div>', "sec band"))
    write("bantuan.html", L("Bantuan: OpenTurath", "Help: OpenTurath", "المساعدة: OpenTurath"), L("Pertanyaan yang sering muncul, cara melaporkan kesalahan, dan kontak OpenTurath.", "Frequently asked questions, how to report an error, and OpenTurath contacts.", "الأسئلة الشائعة وطريقة الإبلاغ عن الأخطاء وسبل التواصل مع OpenTurath."), body, "")


# ======================= HUKUM =======================
def _fmt(x):
    x = E(x)
    x = re.sub(r"([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})", r'<a href="mailto:\1"><bdi class="ltr">\1</bdi></a>', x)
    return x
def md_html(text):
    out, ul = [], []
    def flush_ul():
        nonlocal ul
        if ul: out.append("<ul>" + "".join(f"<li>{_fmt(i)}</li>" for i in ul) + "</ul>"); ul = []
    for blk in re.split(r"\n\s*\n", text.strip()):
        para = []
        for l in [l.strip() for l in blk.split("\n") if l.strip()]:
            if l.startswith("•") or l.startswith("- "):
                if para: out.append("<p>" + "<br>".join(_fmt(x) for x in para) + "</p>"); para = []
                ul.append(l.lstrip("•- ").strip())
            else:
                flush_ul(); para.append(l)
        flush_ul()
        if para: out.append("<p>" + "<br>".join(_fmt(x) for x in para) + "</p>")
    return "".join(out)
def strip_no(t): return re.sub(r"^\s*[\d٠-٩]+\s*[\.\-\)]\s*", "", t)
def app_secs(key): return LEGAL["app"][LANG][key]
def site_secs(slug): return LEGAL["site"][LANG].get(slug, {}).get("sections", [])
def legal_page(fname, kick, title, lead, secs, desc):
    toc = "".join(f'<a href="#s{i+1}">{E(t)}</a>' for i, (t, c) in enumerate(secs))
    arts = "".join(f'<section id="s{i+1}"><h2>{E(t)}</h2>{md_html(c)}</section>' for i, (t, c) in enumerate(secs))
    date = L("13 September 2026", "13 September 2026", "13 سبتمبر 2026")
    meta = (f'<div class="legal-meta"><b>{L("Versi","Version","الإصدار")} 1.0</b> · {L("berlaku sejak","effective","ساريًا منذ")} {date}. '
            f'{L("Pertanyaan tentang dokumen ini dapat dikirim ke","Questions about this document can be sent to","يمكن إرسال الأسئلة عن هذه الوثيقة إلى")} <a href="mailto:support@openturath.id"><bdi class="ltr">support@openturath.id</bdi></a>.</div>')
    end = (f'<div class="legal-end"><a class="btn tonal" href="bantuan.html">{L("Kembali ke bantuan","Back to help","العودة إلى المساعدة")}</a>'
           f'<a class="btn tonal" href="bantuan.html#lapor">{L("Laporkan masalah","Report a problem","الإبلاغ عن مشكلة")}</a></div>')
    body = (head(kick, title, lead) +
            sec(f'<div class="legal"><nav class="toc" aria-label="{L("Isi dokumen","Contents","محتويات الوثيقة")}">{toc}</nav><article>{meta}{arts}{end}</article></div>', "sec-tight"))
    write(fname, f"{title}: OpenTurath", desc, body, "")

def page_legal_all():
    K = L("Kebijakan", "Policies", "السياسات")
    legal_page("ketentuan.html", K, L("Ketentuan Layanan", "Terms of Service", "شروط الخدمة"),
               L("Aturan memakai akun, asisten AI, katalog rujukan, Catatan, dan fitur berbayar OpenTurath.", "The rules for using OpenTurath accounts, AI assistants, reference catalogs, Notes, and paid features.", "قواعد استعمال حسابات OpenTurath ومساعدات الذكاء الاصطناعي وفهارس المراجع والملاحظات والميزات المدفوعة."),
               [(x["title"], x["content"]) for x in app_secs("terms")], L("Ketentuan layanan OpenTurath.", "OpenTurath terms of service.", "شروط خدمة OpenTurath."))
    legal_page("privasi.html", K, L("Kebijakan Privasi", "Privacy Policy", "سياسة الخصوصية"),
               L("Data apa yang kami proses, untuk apa, berapa lama disimpan, dan hak Anda atasnya.", "What data we process, why, how long we keep it, and your rights over it.", "ما البيانات التي نعالجها، ولماذا، ومدة حفظها، وحقوقك فيها."),
               [(x["title"], x["content"]) for x in app_secs("privacy")], L("Kebijakan privasi OpenTurath.", "OpenTurath privacy policy.", "سياسة خصوصية OpenTurath."))
    legal_page("pembayaran.html", K, L("Pembayaran dan Pengembalian Dana", "Payments and Refunds", "الدفع واسترداد المبالغ"),
               L("Informasi sebelum membeli, cara pembayaran dan aktivasi, perpanjangan manual, voucher, dan pengajuan refund.", "Information before you buy, how payment and activation work, manual renewal, vouchers, and refund requests.", "معلومات قبل الشراء، وكيفية الدفع والتفعيل، والتجديد اليدوي، والقسائم، وطلبات الاسترداد."),
               [(x["title"], x["content"]) for x in app_secs("refund")], L("Pembayaran dan pengembalian dana OpenTurath.", "OpenTurath payments and refunds.", "الدفع واسترداد المبالغ في OpenTurath."))
    legal_page("panduan-ai.html", K, L("Panduan Penggunaan AI dan Rujukan", "Guide to Using AI and References", "دليل استعمال الذكاء الاصطناعي والمراجع"),
               L("Cara memakai OpenTurath AI dengan adab: meneliti teks, menghormati mazhab, dan menjaga amanah ilmiah.", "How to use OpenTurath AI with adab: checking texts, respecting the schools, and keeping scholarly trust.", "كيف تستعمل OpenTurath AI بأدب: تفحص النصوص، وتحترم المذاهب، وتحفظ الأمانة العلمية."),
               [(x["title"], x["content"]) for x in app_secs("guideline")], L("Panduan penggunaan AI dan rujukan.", "Guide to using AI and references.", "دليل استعمال الذكاء الاصطناعي والمراجع."))
    t, pv = app_secs("terms"), app_secs("privacy")
    legal_page("hak-cipta.html", K, L("Sumber dan Hak Cipta", "Sources and Copyright", "المصادر وحقوق النشر"),
               L("Siapa memiliki apa: aplikasi, kitab, dan catatan Anda, serta cara meminta koreksi atau pencabutan materi.", "Who owns what: the app, the books, and your notes, and how to ask for a correction or removal.", "من يملك ماذا: التطبيق والكتب وملاحظاتك، وكيف تطلب التصحيح أو الإزالة."),
               [(strip_no(t[8]["title"]), t[8]["content"])] + [(x["title"], x["content"]) for x in site_secs("sources-and-rights")], L("Sumber dan hak cipta di OpenTurath.", "Sources and copyright at OpenTurath.", "المصادر وحقوق النشر في OpenTurath."))
    legal_page("hapus-akun.html", K, L("Penghapusan Akun dan Data", "Account and Data Deletion", "حذف الحساب والبيانات"),
               L("Cara menutup akun, data apa yang dihapus, dan apa yang disimpan sesuai ketentuan hukum.", "How to close your account, what is deleted, and what is kept under legal requirements.", "كيف تغلق حسابك، وما الذي يُحذف، وما الذي يُحفظ وفق الأحكام القانونية."),
               [(x["title"], x["content"]) for x in site_secs("account-deletion")] + [(strip_no(pv[8]["title"]), pv[8]["content"]), (strip_no(pv[10]["title"]), pv[10]["content"])], L("Penghapusan akun dan data OpenTurath.", "OpenTurath account and data deletion.", "حذف الحساب والبيانات في OpenTurath."))

def contact_block():
    cs = app_secs("contact")
    cards = "".join(f'<div class="rv"><h3>{E(strip_no(x["title"]))}</h3><div class="ctext">{md_html(x["content"])}</div></div>' for x in cs)
    return f'<div class="contact3">{cards}</div>'

# ======================= UTAMA =======================
PAGES = ["index", "bidang", "fikih-tahawwulat", "cara-kerja", "pedoman", "ekosistem", "tentang", "unduh", "bantuan", "ketentuan", "privasi", "pembayaran", "panduan-ai", "hak-cipta", "hapus-akun"]
for _l in LANGS:
    LANG = _l
    page_home(); page_bidang(); page_tahaw(); page_cara(); page_pedoman(); page_eko(); page_tentang(); page_unduh(); page_bantuan(); page_legal_all()

# pengalih bahasa di akar situs (tanpa halaman pilihan bahasa; skrip eksternal karena CSP)
(OUT / "index.html").write_text('''<!doctype html><html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>OpenTurath</title>
<link rel="alternate" hreflang="id" href="id/index.html"><link rel="alternate" hreflang="en" href="en/index.html"><link rel="alternate" hreflang="ar" href="ar/index.html"><link rel="alternate" hreflang="x-default" href="id/index.html">
<noscript><meta http-equiv="refresh" content="0;url=id/index.html"></noscript><script src="assets/js/lang.js"></script></head>
<body style="font-family:system-ui;padding:40px"><p><a href="id/index.html">Bahasa Indonesia</a> · <a href="en/index.html">English</a> · <a href="ar/index.html">العربية</a></p></body></html>''', encoding="utf8")
urls = "".join(f'<url><loc>{BASE}/{l}/{p}.html</loc>' + "".join(f'<xhtml:link rel="alternate" hreflang="{m}" href="{BASE}/{m}/{p}.html"/>' for m in LANGS) + '</url>' for l in LANGS for p in PAGES)
(OUT / "sitemap.xml").write_text(f'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">{urls}</urlset>', encoding="utf8")
(OUT / "robots.txt").write_text(f"User-agent: *\nAllow: /\nSitemap: {BASE}/sitemap.xml\n", encoding="utf8")
(OUT / "404.html").write_text('''<!doctype html><html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>404 · OpenTurath</title><meta name="robots" content="noindex"></head><body style="font-family:system-ui;text-align:center;padding:96px 24px"><h1 style="font-weight:450;font-size:48px;letter-spacing:-.03em">Halaman tidak ditemukan.</h1><p style="margin:24px 0"><a href="/id/index.html">Kembali ke beranda</a> · <a href="/en/index.html">Home</a> · <a href="/ar/index.html">الرئيسية</a></p></body></html>''', encoding="utf8")
(OUT / "assets" / "mark.svg").write_text('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 616 674"><g fill="#100F0E">' + "".join(f'<path transform="translate(-204,-175)" d="{d}"/>' for d in PATHS) + '</g></svg>')
(HERE / "og.html").write_text('<!doctype html><meta charset="utf-8"><body style="margin:0;width:1200px;height:630px;background:#121317;color:#F8F9FC;font-family:system-ui;display:flex;align-items:center;gap:56px;padding:0 90px;box-sizing:border-box"><svg style="height:260px;color:#F8F9FC" viewBox="0 0 616 674"><g fill="currentColor">' + "".join(f'<path transform="translate(-204,-175)" d="{d}"/>' for d in PATHS) + '</g></svg><div><div style="font-size:84px;font-weight:600;letter-spacing:-2px">OpenTurath</div><div style="font-size:40px;color:#B2BBC5;margin-top:14px;letter-spacing:-.5px">Menjaga asal, membuka cakrawala.</div></div></body>', encoding="utf8")
print("dibangun:", {l: sorted(p.name for p in (OUT / l).glob("*.html")) for l in LANGS}["id"], "x3 bahasa")
