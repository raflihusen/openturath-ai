#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""OpenTurath Website V7.1: prototipe statis tiga bahasa (ID, EN, AR) dari satu sumber.
Jalankan:  python3 build.py   ->  site/{id,en,ar}/*.html, site/index.html (pengalih), sitemap, robots, 404.
Fakta: data aplikasi (info_ai.json, pengantar_tahawwulat.json), website/content/{catalog,adab}.json, dan An-Nubdzah ash-Shughra.
Terjemahan Inggris dan Arab ditulis penyusun dan BELUM ditinjau penutur ahli; lihat BLUEPRINT_UX.md."""
import re, json, html, pathlib

HERE = pathlib.Path(__file__).resolve().parent
IG = "https://instagram.com/openturath.id"
ROOT = HERE.parent.parent
OUT = HERE / "site"
INFO = {x["id"]: x for x in json.load(open(ROOT / "openturath_ai/assets/data/info_ai.json", encoding="utf8"))}
_peng_src = ROOT / "website/content/pengantar_tahawwulat.json"
if not _peng_src.exists(): _peng_src = ROOT / "openturath_ai/assets/data/pengantar_tahawwulat.json"
PENG = json.load(open(_peng_src, encoding="utf8"))
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
  "sparkle": '<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8zM19 16l.8 2.2L22 19l-2.2.8L19 22l-.8-2.2L16 19l2.2-.8z"/>', "plus": '<path d="M12 5v14M5 12h14"/>', "mail": '<rect x="3" y="5" width="18" height="14" rx="3"/><path d="M4 7.5l8 6 8-6"/>', "instagram": '<rect x="3.5" y="3.5" width="17" height="17" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.2" cy="6.8" r=".6" fill="currentColor"/>', "mic": '<rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/>',
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
    "tahaw": (L("Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات"), L("Lima AI untuk rukun keempat agama", "Five AIs for the fourth pillar of religion", "خمسة ذكاءات اصطناعية للركن الرابع من أركان الدين"), "layers"),
    "fikih": (L("Fikih", "Fiqh", "الفقه"), L("Empat mazhab, perbandingan, dan fatwa", "Four schools, comparison, and fatwa", "المذاهب الأربعة والمقارنة والفتاوى"), "scale"),
    "ushul": (L("Ushul dan kaidah", "Usul and legal maxims", "الأصول والقواعد"), L("Metode menggali hukum dari dalil", "How rulings are drawn from evidence", "منهج استنباط الأحكام من الأدلة"), "cap"),
    "hadis": (L("Hadis", "Hadith", "الحديث"), L("Kitab hadis, ilmu hadis, dan biografi perawi", "Hadith books, hadith sciences, narrator biographies", "المتون والشروح ومصطلح الحديث والرجال"), "scroll"),
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
    sheet = "".join(f'<a class="l" href="{h}">{t}</a>' for h, t in NAV())
    drop = "".join(f'<a href="bidang.html#{g}">{ic(i)}<span><b>{t}</b><span class="d">{d}</span></span></a>' for g, (t, d, i) in RUMPUN().items())
    names = {"id": "Bahasa Indonesia", "en": "English", "ar": "العربية"}
    cur2 = ' aria-current="true"'
    clean_p = "" if fname == "index.html" else "/" + fname[:-5]
    canon = f"{BASE}/{LANG}{clean_p}"
    langrows = "".join(f'<a class="row" href="../{l}/{fname}" hreflang="{l}"{cur2 if l == LANG else ""}><span>{names[l]}</span><span class="soon">{"✓" if l == LANG else l.upper()}</span></a>' for l in LANGS)
    alts = "".join(f'<link rel="alternate" hreflang="{l}" href="{BASE}/{l}{clean_p}">' for l in LANGS)
    anno = L("<b>Baru:</b> OpenTurath AI, rilis perdana 26 Oktober 2026", "<b>New:</b> OpenTurath AI, first public release on 26 October 2026", "<b>جديد:</b> OpenTurath AI، الإطلاق الأول في 26 أكتوبر 2026")
    ftag = L("Menjaga warisan, membuka cakrawala.", "Rooted in heritage. Open to new horizons.", "ذكاء اصطناعي إسلامي قائم على التراث")
    pil = L("Dibuat oleh pelajar, untuk para pelajar.", "Made by a student, for students.", "من طالب علم، لطلاب العلم.")
    colhd = lambda a, b, c: L(a, b, c)
    unduh = L("Unduh", "Download", "تحميل")
    legal_row = "".join(f'<a href="{h}">{t}</a>' for h, t in LEG)
    return f'''<!doctype html><html lang="{LANG}" dir="{"rtl" if rtl else "ltr"}" class="no-js"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{E(title)}</title><meta name="description" content="{E(desc)}"><meta name="theme-color" content="#FFFFFF">
<meta property="og:title" content="{E(title)}"><meta property="og:description" content="{E(desc)}"><meta property="og:type" content="website"><meta property="og:image" content="{BASE}/assets/og.png">
<meta name="twitter:card" content="summary_large_image"><link rel="canonical" href="{canon}">{alts}
<link rel="stylesheet" href="../assets/css/site.css"><link rel="icon" href="../assets/mark.svg" type="image/svg+xml">
<link rel="preload" href="../assets/fonts/googlesansflex.woff2" as="font" type="font/woff2" crossorigin>
<script src="../assets/js/boot.js"></script></head>
<body>{SPRITE}<a class="skip" href="#main">{L("Lewati ke konten","Skip to content","تخطَّ إلى المحتوى")}</a>
<header class="site"><div class="hbar"><a class="wordmark" href="index.html" aria-label="OpenTurath"><span>OpenTurath</span></a>
<nav class="main" aria-label="{L("Utama","Main","الرئيسية")}">{links}</nav>
<div class="hactions"><button class="langbtn" data-drop="langDrop" aria-expanded="false" aria-controls="langDrop" aria-label="{L("Pilih bahasa","Choose language","اختر اللغة")}">{ic("globe")}<span>{LANG.upper()}</span></button>
<button class="iconbtn theme-btn" aria-label="{L("Ganti tema terang atau gelap","Switch light or dark theme","تبديل المظهر الفاتح أو الداكن")}"><span class="sun">{ic("sun")}</span><span class="moon">{ic("moon")}</span></button>
<a class="btn primary sm hideS" href="unduh.html">{ic("download")}{unduh}</a>
<button class="iconbtn menu-btn" aria-label="{L("Buka menu","Open menu","افتح القائمة")}" aria-expanded="false">{ic("menu")}</button></div></div>
<div class="drop lang" id="langDrop">{langrows}</div></header>
<div class="sheet" id="sheet">{sheet}<a class="btn primary" href="unduh.html">{ic("download")}{L("Unduh aplikasi","Download the app","تحميل التطبيق")}</a></div>
<main id="main">{body}</main>
<footer class="site"><div class="wrap"><div class="fgrid"><div class="fbrand"><a class="wordmark" href="index.html">{mark(34)}<span>OpenTurath</span></a></div>
<div><h4>{L("Produk","Product","المنتج")}</h4><ul><li><a href="bidang.html">OpenTurath AI</a></li><li><a href="bidang.html">{L("Bidang ilmu","Fields of knowledge","المجالات العلمية")}</a></li><li><a href="fikih-tahawwulat.html">{L("Fikih Tahawwulat","Fiqh al-Tahawwulat","فقه التحولات")}</a></li><li><a href="unduh.html">{unduh}</a></li></ul></div>
<div><h4>{L("Pelajari","Learn","تعرّف")}</h4><ul><li><a href="perbandingan.html">{L("Perbandingan AI","AI comparison","مقارنة الذكاءات")}</a></li><li><a href="mengenal-fikih-tahawwulat.html">{L("Mengenal Fikih Tahawwulat","Getting to know Fiqh al-Tahawwulat","التعرّف على فقه التحولات")}</a></li><li><a href="ai-manuskrip.html">{L("AI Manuskrip","Manuscript AI","ذكاء المخطوطات")}</a></li><li><a href="cara-kerja.html">{L("Cara kerja","How it works","كيف يعمل")}</a></li><li><a href="pedoman.html">{L("Pedoman keilmuan","Scholarly guidelines","الضوابط العلمية")}</a></li><li><a href="ekosistem.html">{L("Ekosistem","Ecosystem","المنظومة")}</a></li><li><a href="tentang.html">{L("Tentang","About","عن OpenTurath")}</a></li></ul></div>
<div><h4>{L("Bantuan","Help","المساعدة")}</h4><ul><li><a href="bantuan.html">{L("Bantuan dan FAQ","Help and FAQ","المساعدة والأسئلة الشائعة")}</a></li><li><a href="bantuan.html#lapor">{L("Laporkan kesalahan","Report an error","الإبلاغ عن خطأ")}</a></li><li><a href="ketentuan.html">{L("Ketentuan dan privasi","Terms and privacy","الشروط والخصوصية")}</a></li><li class="flink"><a href="mailto:support@openturath.id">{ic("mail")}<bdi class="ltr">support@openturath.id</bdi></a></li><li class="flink"><a href="https://instagram.com/openturath.id" target="_blank" rel="noopener">{ic("instagram")}<bdi class="ltr">@openturath.id</bdi></a></li></ul></div></div>
<div class="legal-links">{legal_row}</div>
<div class="fbar"><span>&copy; OpenTurath</span><span>openturath.id</span></div></div></footer>
<script src="../assets/js/site.js" defer></script></body></html>'''

def contact_pills():
    return (f'<a class="cpill" href="mailto:support@openturath.id">{ic("mail")}<bdi class="ltr">support@openturath.id</bdi></a>'
            f'<a class="cpill" href="{IG}" target="_blank" rel="noopener">{ic("instagram")}<bdi class="ltr">@openturath.id</bdi></a>')

def rewrite_links(html, lang):
    html = re.sub(r'(href|src)=["\']\.\./assets/', r'\1="/assets/', html)
    def _sub_lang(m):
        target_lang = m.group(1)
        target_file = m.group(2)
        if target_file == "index":
            return f'href="/{target_lang}"'
        return f'href="/{target_lang}/{target_file}"'
    html = re.sub(r'href=["\']\.\./(id|en|ar)/([a-zA-Z0-9_-]+)\.html["\']', _sub_lang, html)
    def _sub_page(m):
        page = m.group(1)
        frag = m.group(2) or ""
        if page == "index":
            return f'href="/{lang}{frag}"'
        return f'href="/{lang}/{page}{frag}"'
    html = re.sub(r'href=["\']([a-zA-Z0-9_-]+)\.html(#?[^"\']*)["\']', _sub_page, html)
    return html

def write(name, title, desc, body, current=""):
    d = OUT / LANG; d.mkdir(parents=True, exist_ok=True)
    html = shell(name, title, desc, body, current)
    html = rewrite_links(html, LANG)
    (d / name).write_text(html, encoding="utf8")

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

EVID = json.loads((HERE.parent / "content" / "evidence.json").read_text(encoding="utf8"))
def demo():
    asked = L("Bagaimana mazhab Syafi'i menjelaskan hukum bersentuhan kulit antara laki-laki dan perempuan non-mahram dalam kaitannya dengan wudhu? Jelaskan batasan dan pengecualiannya.",
              "How does the Shafi'i school explain the ruling on skin contact between a man and a non-mahram woman in relation to wudu? Explain its limits and exceptions.",
              "كيف يبيّن المذهب الشافعي حكم ملامسة البشرة بين الرجل والمرأة الأجنبية في الوضوء؟ بيّن ضوابطه ومستثنياته.")
    summ = L("<p>Menurut mazhab Syafi'i, bertemunya kulit laki-laki dengan perempuan non-mahram <b>membatalkan wudhu</b>, baik bagi yang menyentuh maupun yang disentuh, dengan syahwat maupun tanpa syahwat, sengaja maupun tidak. Dasarnya firman Allah &ldquo;aw lamastumun nisa'&rdquo; (An-Nisa': 43, Al-Ma'idah: 6).</p><h4>Lima syaratnya</h4><ul><li>Berbeda jenis kelamin</li><li>Keduanya sudah mencapai batas usia syahwat</li><li>Kulit bertemu kulit</li><li>Tanpa penghalang</li><li>Bukan mahram</li></ul><h4>Yang tidak membatalkan</h4><ul><li>Menyentuh mahram dan anak kecil</li><li>Menyentuh rambut, kuku, atau gigi</li><li>Ada penghalang, meski tipis</li><li>Ragu apakah yang tersentuh kulit</li></ul>",
             "<p>In the Shafi'i school, skin meeting skin between a man and a non-mahram woman <b>breaks wudu</b>, for the one who touches and the one touched, with or without desire, intended or not. The basis is the verse &ldquo;aw lamastumun nisa'&rdquo; (An-Nisa' 4:43, Al-Ma'idah 5:6).</p><h4>Five conditions</h4><ul><li>Different sexes</li><li>Both have reached the age of desire</li><li>Skin meets skin</li><li>No barrier</li><li>Not a mahram</li></ul><h4>What does not break it</h4><ul><li>Touching a mahram or a small child</li><li>Touching hair, nails, or teeth</li><li>A barrier, even a thin one</li><li>Doubt whether it was skin</li></ul>",
             "<p>عند الشافعية، التقاء بشرتي الرجل والمرأة الأجنبية <b>ينقض الوضوء</b> للامس والملموس، بشهوة وبغير شهوة، قصدًا وبغير قصد. ودليله قوله تعالى «أو لامستم النساء» (النساء: 43، المائدة: 6).</p><h4>شروطه الخمسة</h4><ul><li>اختلاف الجنس</li><li>بلوغ حدّ الشهوة</li><li>التقاء البشرتين</li><li>عدم الحائل</li><li>أن لا تكون محرمًا</li></ul><h4>ما لا ينقض</h4><ul><li>لمس المحرم والصغيرة</li><li>لمس الشعر والظفر والسن</li><li>وجود حائل ولو رقيقًا</li><li>الشك في كونه بشرة</li></ul>")
    rows = ""
    for e in EVID[:3]:
        rows += f'<div class="ref"><div class="rh"><span class="no">{e["number"]}</span><span class="loc">{E(e["locator"])}</span></div><div class="quote">{E(e["quote"])}</div></div>'
    return (f'<div class="q1"><div class="qbox"><span class="tag">{L("Pertanyaan","Question","السؤال")}</span><p class="asked">{E(asked)}</p><span class="tag">{L("Jawaban ringkas","Short answer","الجواب مختصرًا")}</span><div class="sum">{summ}</div></div>'
            f'<div class="refs"><h3>{L("Sebagian dari sepuluh rujukan","Some of the ten references","بعض المراجع العشرة")}</h3><p>{L("Tiga yang pertama, lengkap dengan nash Arabnya.","The first three, with their Arabic text.","الثلاثة الأولى مع نصها العربي.")}</p><div class="reflist">{rows}</div><div class="refmore"><span>{L("Masih ada " + str(len(EVID) - 3) + " rujukan lagi di jawaban lengkap.", "There are " + str(len(EVID) - 3) + " more references in the full answer.", "ثمة " + str(len(EVID) - 3) + " مراجع أخرى في الجواب الكامل.")}</span><a class="btn primary sm" href="perbandingan.html">{L("Lihat jawaban lengkap dan perbandingan dengan AI lain", "See the full answer and the comparison with other AIs", "اطّلع على الجواب الكامل والمقارنة مع غيره")}{ic("arrow","arr")}</a></div>'
            f'<div class="proof">{ic("check")}<span>{L("Kesepuluh rujukan ini dicek satu per satu oleh pendiri pada Maktabah Syamilah, dan semuanya dapat diverifikasi di sana.","The founder checked each of these ten references one by one in the Maktabah Shamila, and all can be verified there.","راجع المؤسس هذه المراجع العشرة واحدًا واحدًا في المكتبة الشاملة، وكلها يمكن التحقق منها هناك.")}</span></div></div></div>')

def FAQ_MAIN(): return [
    (L("Apakah OpenTurath AI mengeluarkan fatwa?", "Does OpenTurath AI issue fatwas?", "هل يصدر OpenTurath AI فتاوى؟"),
     L("Tidak. OpenTurath AI membantu menemukan pembahasan dan rujukan. Fatwa dan penerapan hukum pada keadaan tertentu tetap kepada ulama yang berkompeten.", "No. OpenTurath AI helps you find discussions and references. Fatwas and applying rulings to particular situations remain with qualified scholars.", "لا. يساعد OpenTurath AI على الوصول إلى المباحث والمراجع. أما الفتوى وتنزيل الأحكام على الوقائع فمرجعها العلماء المؤهلون.")),
    (L("Apakah ia menggantikan guru?", "Does it replace teachers?", "هل يحلّ محل المعلم؟"),
     L("Tidak. Ia alat bantu yang menghemat waktu mencari ibarah. Pemahaman dan adab tumbuh bersama guru, dan aplikasi selalu mengingatkan hal itu.", "No. It is a tool that saves time finding passages. Understanding and adab grow with a teacher, and the app keeps reminding you of that.", "لا. هو أداة توفّر وقت البحث عن العبارات. أما الفهم والأدب فينشآن مع المعلم، والتطبيق يذكّر بذلك دائمًا.")),
    (L("Dari mana jawabannya berasal?", "Where do the answers come from?", "من أين تأتي الإجابات؟"),
     L("Dari koleksi kitab pilihan pada bidang yang Anda pilih, bukan dari seluruh internet. Setiap bidang punya AI dan metodologinya sendiri.", "From a curated set of books in the field you choose, not from the whole internet. Each field has its own AI and method.", "من مجموعة كتب منتقاة في المجال الذي تختاره، لا من الإنترنت كله. ولكل مجال ذكاؤه الاصطناعي ومنهجه.")),
    (L("Apa bedanya dengan AI umum?", "How is it different from general AI?", "ما الفرق بينه وبين الذكاء الاصطناعي العام؟"),
     L("AI umum menjawab dari apa saja dan mudah mengarang ayat, kitab, atau ibarah. OpenTurath AI hanya memakai kitab pilihan untuk tiap bidang dan mengarahkan jawaban ke rujukan.", "General AI answers from anything and can easily invent verses, books, or passages. OpenTurath AI stays within a curated collection of books per field and points answers to references.", "يجيب الذكاء الاصطناعي العام من أي مصدر وقد يختلق آيات وكتبًا وعبارات. أما OpenTurath AI فيلتزم بمدوّنة منتقاة لكل مجال ويوجّه الإجابة إلى المراجع.")),
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
def sculpt():
    return (f'<figure class="sculpt"><img src="../assets/tahawwulat.webp" width="1254" height="1254" loading="lazy" decoding="async" alt="{L("Empat rukun agama dalam satu lingkaran: Islam, Iman, Ihsan, dan tanda-tanda zaman","The four pillars of religion in one circle: Islam, Iman, Ihsan, and the signs of the Hour","أركان الدين الأربعة في دائرة واحدة: الإسلام والإيمان والإحسان وعلامات الساعة")}"></figure>')

def exclusive():
    return (f'<div class="excl rv"><span class="xb">{L("AI Fikih Tahawwulat pertama di dunia","The world’s first Fiqh al-Tahawwulat AI","أول ذكاء اصطناعي لفقه التحولات في العالم")}</span>'
            f'<span class="xb alt">{L("Eksklusif di OpenTurath","Exclusive to OpenTurath","حصريًّا في OpenTurath")}</span></div>')

def philosophy_sec():
    return sec(shead(L("Filosofi logo","The logo's meaning","فلسفة الشعار"), L("Tiga bidang di bawah satu lengkung.","Three shapes under one arch.","ثلاثة أشكال تحت قوس واحد."),
                     L("Dalam hadis Jibril, Nabi menjawab empat pertanyaan. Tiga yang pertama adalah ilmu yang tetap: fikih, akidah, tasawuf. Yang keempat membahas yang berubah dan menjaga ketiganya. Itulah yang tergambar pada logo OpenTurath: tiga bidang di dalam, satu lengkung yang menaungi.",
                       "In the hadith of Jibril, the Prophet answered four questions. The first three are the constant sciences: fiqh, creed, tasawwuf. The fourth deals with what changes and guards the other three. That is what the OpenTurath logo draws: three shapes inside, one arch sheltering them.",
                       "في حديث جبريل أجاب النبي عن أربعة أسئلة. الثلاثة الأولى علوم الثوابت: الفقه والعقيدة والتصوف، والرابع يبحث في المتغيرات ويحفظ الثلاثة. وذلك ما يرسمه شعار OpenTurath: ثلاثة أشكال في الداخل وقوس واحد يظلّها.")) +
               f'<div class="tahaw rv"><div class="gate" data-hl="">{gate_svg()}</div>{rukun_html(True)}</div>')

def rukun_html(interactive=False):
    rows = [("islam", "01", L("Islam", "Islam", "الإسلام"), L("Fikih · rukun yang tetap", "Fiqh · a constant pillar", "الفقه · من الثوابت"), "الإسلام"),
            ("iman", "02", L("Iman", "Iman", "الإيمان"), L("Akidah · rukun yang tetap", "Creed · a constant pillar", "العقيدة · من الثوابت"), "الإيمان"),
            ("ihsan", "03", L("Ihsan", "Ihsan", "الإحسان"), L("Tasawuf · rukun yang tetap", "Tasawwuf · a constant pillar", "التصوف · من الثوابت"), "الإحسان"),
            ("tahaw", "04", L("Tanda-tanda zaman", "Signs of the times", "علامات الساعة"), L("Fikih Tahawwulat · membahas yang berubah dan menjaga tiga rukun di atas", "Fiqh al-Tahawwulat · studies what changes and guards the three pillars above", "فقه التحولات · يبحث في المتغيرات ويحفظ الأركان الثلاثة"), "علامات الساعة")]
    return '<div class="rukun" role="list">' + "".join(f'<{"button" if interactive else "div"} class="rk" data-hl="{h}" role="listitem"><span class="i">{n}</span><span class="tt">{t}<small>{s}</small></span><span class="ar">{a}</span></{"button" if interactive else "div"}>' for h, n, t, s, a in rows) + '</div>'

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
    cell = lambda n, icon, t: f'<div class="task"><h4>{t[0]}</h4><p>{t[1]}</p></div>'
    return (f'<div class="tasks"><div class="tasks-hd"><b>{L("Dua tugas rukun keempat","The two tasks of the fourth pillar","مهمتان للركن الرابع")}</b><span class="small">{src}</span></div>'
            f'<div class="tasks-g">{cell("1", "sparkle", t1)}{cell("2", "scale", t2)}</div></div>')

def branches_html():
    B = [("المحقق", "Al-Muhaqqiq", L("Peneliti teks", "The text researcher", "المحقِّق"), L("Mencari dan memeriksa ibarah asli beserta sumbernya.", "Finds and checks the original passage with its source.", "يبحث عن العبارة الأصلية ويتحقق منها مع مصدرها.")),
         ("البيان", "Al-Bayan", L("Penjelasan sederhana", "Simple explanations", "البيان"), L("Menjelaskan dengan bahasa mudah, cocok untuk pemula.", "Explains in easy language, ideal for beginners.", "يشرح بلغة سهلة، مناسب للمبتدئين.")),
         ("المختبر", "Al-Mukhtabir", L("Penguji pemahaman", "The understanding tester", "المختبِر"), L("Bertanya, menilai jawaban Anda, dan memberi jawaban ideal.", "Asks, judges your answer, and gives the ideal one.", "يسأل ويقيّم جوابك ويعطي الجواب المثالي.")),
         ("الحبيب", "Al-Habib", L("Ceramah Al-Habib", "Al-Habib's lectures", "محاضرات الحبيب"), L("Isi ceramah Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur, dengan diksi beliau sendiri.", "The content of the lectures of Al-Habib Abu Bakr al-Adni bin Ali al-Mashhur, in his own wording.", "مضمون محاضرات الحبيب أبي بكر العدني بن علي المشهور بألفاظه نفسها.")),
         ("الخطيب", "Al-Khatib", L("Penyusun khutbah", "The sermon writer", "معدّ الخطب"), L("Menyusun khutbah dan bahan ceramah.", "Drafts sermons and talk material.", "يُعدّ الخطب ومواد المحاضرات."))]
    return '<div class="branches">' + "".join(f'<div class="br"><span class="ar">{a}</span><b>{n}</b><i>{m}</i><span>{d}</span></div>' for a, n, m, d in B) + '</div>'

# ======================= BERANDA =======================
def page_home():
    CHK = ic("check")
    h1 = L('<span class="tl">Waktu Anda untuk memahami,</span> <span class="tl">bukan untuk mencari.</span><span class="hero-sub">Pencarian, serahkan kepada kami.</span>',
           '<span class="tl">Your time is for understanding,</span> <span class="tl">not for searching.</span><span class="hero-sub">Leave the searching to us.</span>',
           '<span class="tl">وقتك للفهم، لا للبحث.</span><span class="hero-sub">اترك البحث لنا.</span>')
    lede = L("OpenTurath AI menemani penuntut ilmu membaca kitab. Anda bertanya, ia menjelaskan, lalu menunjukkan ibarah dan rujukannya dari kitab serta ceramah para ulama.",
             "OpenTurath AI keeps seekers of knowledge company as they read. You ask, it explains, then points you to the passage and its source in the books and lectures of the scholars.",
             "يرافق OpenTurath AI طالب العلم في قراءة الكتب: تسأل فيشرح، ثم يدلّك على العبارة ومرجعها في كتب العلماء ومحاضراتهم.")
    body = f'''
<section class="welcome" id="hero"><canvas id="ring" aria-hidden="true"></canvas>
<p class="eyebrow-brand rv">{L("AI Islami nomor 1 di dunia","The world’s No. 1 Islamic AI","الذكاء الاصطناعي الإسلامي الأول عالميًا")}<a class="star" href="#klaim" aria-label="{L("Lihat dasar klaim","See the basis of this claim","اطّلع على أساس هذا الادعاء")}">*</a></p>
<div class="hero-mark rv">{mark(50)}</div>
<h1 class="hero hero-wide rv d1">{h1}</h1>
<p class="lede rv d2">{lede}</p>
<div class="cta-row rv d3"><a class="btn primary" href="unduh.html">{ic("download")}{L("Unduh aplikasi","Download the app","تحميل التطبيق")}</a><a class="btn tonal" href="cara-kerja.html">{L("Lihat cara kerja","See how it works","شاهد كيف يعمل")}</a></div>
<div class="meta-row rv d3"><span>{CHK}{L("Dikonsultasikan dengan ulama","Built in consultation with scholars","بُني بالتشاور مع العلماء")}</span><span>{CHK}{L("Dipilih dengan manhaj wasathiyyah syar'iyyah","Curated by the manhaj of al-wasatiyya al-shar'iyya","مُنتقى وفق منهج الوسطية الشرعية")}</span><span>{CHK}{L("Rujukan bisa dicek ke kitabnya","References you can check in the book","مراجع يمكن التحقق منها في الكتاب")}</span></div>
<p class="claim-note rv d3" id="klaim"><span class="star">*</span> {L("Berdasarkan kajian empiris: perbandingan langsung keluaran OpenTurath AI dengan AI Islami kelas dunia lainnya. Metodologi khusus pada tiap ilmu menjaga jawabannya relevan dan rujukannya nyata. ","Based on empirical study: a direct comparison of OpenTurath AI’s output with other world-class Islamic AIs. A dedicated method for each science keeps answers relevant and references real. ","استنادًا إلى دراسة تجريبية: مقارنة مباشرة بين مخرجات OpenTurath AI وغيره من أنظمة الذكاء الاصطناعي الإسلامية العالمية. ومنهج خاص لكل علم يحفظ صلة الإجابة وحقيقة المراجع. ")}<a class="link" href="perbandingan.html">{L("Lihat perbandingannya","See the comparison","اطّلع على المقارنة")}</a></p>
<nav class="sr" aria-label="{L("Bidang ilmu","Fields of knowledge","المجالات العلمية")}">{"".join(f'<a href="bidang.html#{g}">{t[0]}</a>' for g, t in RUMPUN().items())}</nav></section>

<section class="sec"><div class="wrap">{shead(L("Masalahnya","The problem","المشكلة"), L("AI sering terdengar yakin, padahal rujukannya belum tentu ada.","AI often sounds certain when its reference may not exist.","يبدو الذكاء الاصطناعي واثقًا، وقد لا يكون لمرجعه وجود."), L("Dalam ilmu turats, satu nisbah yang keliru atau satu ibarah yang diubah bisa membuat seluruh pembahasan goyah. Tiga hal ini paling sering terjadi pada AI umum.","In the sciences of the turath, one wrong attribution or one altered passage can unsettle an entire discussion. These three things happen most often with general-purpose AI.","في علوم التراث قد تزعزع نسبة خاطئة واحدة أو عبارة محرّفة واحدة البحث كله. وهذه ثلاثة أمور تقع كثيرًا في الذكاء الاصطناعي العام.")) }
<p class="sublabel rv">{L("Yang sering keliru pada AI umum","Where general AI often goes wrong","أين يخطئ الذكاء الاصطناعي العام")}</p>
<div class="trio3">
<div class="rv"><div class="n">01</div><h3>{L("Tanpa metodologi tiap disiplin ilmu","No method for each discipline","بلا منهج خاص لكل علم")}</h3><p>{L("AI umum menjawab fikih, hadis, dan tafsir dengan cara yang sama. Kaidah tiap ilmu dan mazhab tidak dipakai, sehingga jawabannya bercampur dan kurang relevan.","General AI answers fiqh, hadith, and tafsir the same way. The rules of each discipline and school are not applied, so answers blend together and fit the question poorly.","يجيب الذكاء الاصطناعي العام عن الفقه والحديث والتفسير بطريقة واحدة. لا تُراعى قواعد كل علم ومذهب، فتختلط الإجابات وتقلّ صلتها بالسؤال.")}</p></div>
<div class="rv d1"><div class="n">02</div><h3>{L("Halusinasi pada ibarah dan referensi","Hallucinated passages and references","هلوسة في العبارات والمراجع")}</h3><p>{L("Ibarah Arab, judul kitab, jilid, dan halaman tampak meyakinkan, tetapi dikarang sendiri oleh AI dan tidak ada di kitab aslinya.","Arabic passages, book titles, volumes, and pages look convincing, but the AI made them up and they are not in the original book.","تبدو العبارات العربية وعناوين الكتب والأجزاء والصفحات مقنعة، لكن الذكاء الاصطناعي اخترعها وليست في الكتاب الأصلي.")}</p></div>
<div class="rv d2"><div class="n">03</div><h3>{L("Kalimat dipotong dari konteksnya","Sentences cut from their context","جمل مقتطعة من سياقها")}</h3><p>{L("Hukum dikutip tanpa pengecualiannya, sehingga maksud penulis dan pensyarah ikut berubah.","A ruling is quoted without its exceptions, and the author's and commentator's meaning changes with it.","يُنقل الحكم دون استثناءاته فيتغيّر مقصود المؤلف والشارح.")}</p></div></div>
<div class="answer rv"><div><p class="sublabel" style="color:inherit;opacity:.7">{L("Cara OpenTurath menjawabnya","How OpenTurath answers it","كيف يجيب OpenTurath")}</p><h3>{L("Kami mulai dari kitabnya, bukan dari tebakan.","We start from the book, not from a guess.","نبدأ من الكتاب، لا من التخمين.")}</h3><p class="lead2">{L("OpenTurath tidak meminta Anda percaya begitu saja. Tujuannya mempercepat Anda sampai ke ibarah aslinya, supaya Anda sendiri yang memeriksa naskahnya.","OpenTurath does not ask for your blind trust. It helps you reach the original passage faster, so you can check the text yourself.","لا يطلب منك OpenTurath التصديق وحسب، بل يسرّع وصولك إلى العبارة الأصلية لتتحقق من النص بنفسك.")}</p></div>
<ul><li>{ic("check")}<span><b>{L("Satu bidang, satu AI","One field, one AI","مجال واحد، وذكاء اصطناعي واحد")}</b>{L("Setiap AI hanya memegang kitab di bidangnya, sehingga metodologi tiap disiplin ilmu tidak tercampur dan jawabannya sesuai dengan ilmu yang ditanyakan.","Each AI holds only the books of its own field, so the method of each discipline never blends and the answer fits the science you asked about.","كل ذكاء اصطناعي يلتزم بكتب مجاله وحدها، فلا تختلط مناهج العلوم، وتأتي الإجابة موافقة للعلم المسؤول عنه.")}</span></li>
<li>{ic("check")}<span><b>{L("Ibarah dan rujukan di samping jawaban","The passage and reference beside the answer","العبارة والمرجع بجانب الجواب")}</b>{L("Anda melihat teks Arabnya dan tahu dari kitab mana ia diambil.","You see the Arabic text and know which book it comes from.","ترى النص العربي وتعرف من أي كتاب أُخذ.")}</span></li>
<li>{ic("check")}<span><b>{L("Dikonsultasikan dengan ulama","Built in consultation with scholars","بُني بالتشاور مع العلماء")}</b>{L("Pembuatan AI ini dikonsultasikan dengan para ulama, mulai dari pemilihan kitab dan metodologi tiap ilmu sampai isi di bidangnya. Kitab dipilih satu per satu dengan manhaj wasathiyyah syar'iyyah.","The making of this AI was done in consultation with scholars, from the choice of books and the method of each science to the content in its field. Books are chosen one by one by the manhaj of al-wasatiyya al-shar'iyya.","صُنع هذا الذكاء الاصطناعي بالتشاور مع العلماء، من اختيار الكتب ومنهج كل علم إلى المحتوى في مجاله. وتُنتقى الكتب واحدًا واحدًا وفق منهج الوسطية الشرعية.")}</span></li></ul></div></div></section>

<section class="sec" id="demo"><div class="wrap">{shead(L("Contoh nyata","A real example","مثال حقيقي"), L("Satu pertanyaan, sepuluh rujukan.","One question, ten references.","سؤال واحد، وعشرة مراجع."), L("Ini jawaban asli OpenTurath untuk satu pertanyaan fikih, lengkap dengan kutipan dari kitab-kitab mazhab Syafi'i.","This is an original OpenTurath answer to a fiqh question, with quotations from the books of the Shafi'i school.","هذا جواب أصلي من OpenTurath عن سؤال فقهي، مع نصوص منقولة من كتب المذهب الشافعي."))}<div class="rv">{demo()}</div></div></section>

<section class="sec"><div class="wrap">{shead(L("Pembaca","Readers","القرّاء"), L("Untuk siapa OpenTurath?","Who is OpenTurath for?","لمن OpenTurath؟"))}
<div class="cases">
<div class="case rv">{ic("cap")}<h3>{L("Santri dan penuntut ilmu","Students and seekers of knowledge","الطلاب وطلاب العلم")}</h3><p>{L("Mulai memahami kitab tanpa harus lebih dulu menaklukkan bahasa dan istilahnya.","Start understanding the books without first conquering their language and terms.","ابدأ فهم الكتب دون أن تقهر لغتها ومصطلحاتها أولًا.")}</p></div>
<div class="case rv d1">{ic("library")}<h3>{L("Mahasiswa dan peneliti","University students and researchers","طلاب الجامعة والباحثون")}</h3><p>{L("Cari pembahasan lintas kitab, bandingkan keterangan, dan simpan rujukan untuk tulisan Anda.","Search discussions across books, compare accounts, and keep references for your writing.","ابحث في المباحث عبر الكتب، وقارن الأقوال، واحفظ المراجع لكتاباتك.")}</p></div>
<div class="case rv d2">{ic("scroll")}<h3>{L("Pengajar, penceramah, khatib","Teachers, preachers, khatibs","المعلمون والدعاة والخطباء")}</h3><p>{L("OpenTurath AI membantu menyusun materi pengajaran, ceramah, dan khutbah: mencari dalil dan ibarah, menyusun kerangka, lalu menyiapkan bahan yang siap Anda sampaikan.","OpenTurath AI helps you prepare teaching, lecture, and sermon material: finding the evidence and passages, outlining, then preparing content ready for you to deliver.","يساعدك OpenTurath AI في إعداد مواد التدريس والمحاضرات والخطب: بالبحث عن الدليل والعبارة، وصياغة الهيكل، ثم تجهيز مادة جاهزة للإلقاء.")}</p></div></div></div></section>

<section class="sec" id="angka"><div class="wrap">{shead(L("Dalam angka","In numbers","بالأرقام"), L("Fondasinya dibangun dari kitab dan khazanah para ulama.","Its foundation is built from books and the heritage of the scholars.","أساسه مبني من الكتب وتراث العلماء."), L("Sebagian angka dirilis berkala, sehingga yang tampil di aplikasi terus bertambah.","Part of these figures is released in stages, so what appears in the app keeps growing.","تُصدَر هذه المواد على دفعات، فيزداد ما يظهر في التطبيق باستمرار."))}
<div class="stats rv"><div class="stat big"><svg class="bk" viewBox="0 0 380 270" preserveAspectRatio="xMaxYMid slice" fill="none" stroke="currentColor" stroke-width="1.3" aria-hidden="true"><g><rect x="14" y="70" width="34" height="170" rx="4"/><path d="M14 88h34M14 218h34" opacity=".6"/><path d="M31.0 104v26" opacity=".6"/><rect x="52" y="40" width="26" height="200" rx="4"/><path d="M52 58h26M52 218h26" opacity=".6"/><rect x="82" y="92" width="38" height="148" rx="4"/><path d="M82 110h38M82 218h38" opacity=".6"/><rect x="124" y="56" width="30" height="184" rx="4"/><path d="M124 74h30M124 218h30" opacity=".6"/><path d="M139.0 90v26" opacity=".6"/><rect x="158" y="30" width="34" height="214" rx="4"/><path d="M158 48h34M158 222h34" opacity=".6"/><rect x="196" y="78" width="28" height="156" rx="4"/><path d="M196 96h28M196 212h28" opacity=".6"/><rect x="228" y="46" width="36" height="196" rx="4"/><path d="M228 64h36M228 220h36" opacity=".6"/><path d="M246.0 80v26" opacity=".6"/><rect x="268" y="64" width="30" height="164" rx="4"/><path d="M268 82h30M268 206h30" opacity=".6"/><rect x="302" y="34" width="32" height="206" rx="4"/><path d="M302 52h32M302 218h32" opacity=".6"/><rect x="338" y="84" width="34" height="152" rx="4"/><path d="M338 102h34M338 214h34" opacity=".6"/><path d="M355.0 118v26" opacity=".6"/><g transform="rotate(14 360 250)"><rect x="332" y="96" width="30" height="156" rx="4"/><path d="M332 114h30M332 230h30" opacity=".6"/></g><path d="M0 270h380" opacity=".9"/><path d="M60 40c30-24 70-24 100 0M200 30c36-26 84-26 120 0" opacity=".45"/></g></svg><div class="sic">{ic("library")}</div><div><div class="num">5.300+</div><div class="lab">{L("Kitab turats","Turath books","كتاب تراثي")}</div></div></div>
<div class="stat"><div class="sic">{ic("scroll")}</div><div class="num">800.000.000+</div><div><div class="lab">{L("Kata teks kitab","Words of book text","كلمة من نصوص الكتب")}</div></div></div>
<div class="stat"><div class="sic">{ic("mic")}</div><div class="num">30.000+</div><div><div class="lab">{L("Arsip ceramah dan daurah","Lectures and daurah archive","أرشيف المحاضرات والدورات")}</div></div></div>
<div class="stat"><div class="sic">{ic("layers")}</div><div class="num">18</div><div><div class="lab">{L("AI spesialis","Specialist AIs","ذكاءً اصطناعيًا متخصصًا")}</div></div></div></div></div></section>

<section class="sec" id="bidang"><div class="wrap">{shead(L("Bidang ilmu","Fields of knowledge","المجالات العلمية"), L("Satu ilmu, satu AI.","One discipline, one AI.","علم واحد، وذكاء اصطناعي واحد."), L("Tiap AI hanya memegang kitab bidangnya dan berpegang pada manhaj dan kaidah bidang itu, jadi jawabannya tidak tercampur.","Each AI holds only the books of its field and works the way that field works, so answers do not blend.","يلتزم كل ذكاء اصطناعي بكتب مجاله وحده ويعمل بطريقة ذلك المجال، فلا تختلط إجاباته."))}<div class="rv">{explorer("fikih")}</div>
<p class="more"><a class="link" href="bidang.html">{L("Lihat semua bidang","See all fields","عرض كل المجالات")}{ic("arrow","arr")}</a></p></div></section>

<section class="sec band"><div class="wrap">{exclusive()}{shead(L("Fikih Tahawwulat","Fiqh al-Tahawwulat","فقه التحولات"), L("Rukun keempat agama, penjaga tiga rukun yang lain.","The fourth pillar of religion, guardian of the other three.","الركن الرابع من أركان الدين، حارس الأركان الثلاثة الأخرى."), L("Dalam hadis Jibril, Nabi menjawab empat pertanyaan. Tiga yang pertama adalah ilmu yang tetap: fikih, akidah, tasawuf. Yang keempat membahas yang berubah, yaitu tanda-tanda zaman, dan bertugas menjaga ketiganya.","In the hadith of Jibril, the Prophet answered four questions. The first three are the constant sciences: fiqh, creed, tasawwuf. The fourth studies what changes, the signs of the times, and guards the other three.","في حديث جبريل أجاب النبي عن أربعة أسئلة. الثلاثة الأولى علوم ثابتة: الفقه والعقيدة والتصوف. والرابع يبحث في المتغيرات، أي علامات الساعة، ويحفظ الثلاثة الأخرى."))}
<div class="tahaw tsc rv">{sculpt()}{rukun_html()}</div>
<div class="rv">{tasks_html()}</div>
<div class="branches-hd rv"><h3>{L("Lima cabang AI Fikih Tahawwulat","The five branches of AI Fiqh al-Tahawwulat","الفروع الخمسة لـ AI فقه التحولات")}</h3><p>{L("Satu bidang dengan lima AI, masing-masing dengan tugasnya.","One field with five AIs, each with its own job.","مجال واحد وخمسة ذكاءات اصطناعية، ولكل منهم مهمته.")}</p></div>
<div class="rv">{branches_html()}</div>
<p style="margin-top:40px;display:flex;flex-wrap:wrap;gap:12px;justify-content:center"><a class="btn primary" href="mengenal-fikih-tahawwulat.html">{L("Mengenal Fikih Tahawwulat","Getting to know Fiqh al-Tahawwulat","التعرّف على فقه التحولات")}{ic("arrow","arr")}</a><a class="btn inv-o" href="fikih-tahawwulat.html">{L("Tentang ilmunya","About the science","عن هذا العلم")}</a></p></div></section>

<section class="sec"><div class="wrap">{shead(L("Cara kami menjaga","How we safeguard","كيف نحفظ"), L("Cara kami menjaga mutu jawaban.","How we keep answers sound.","كيف نحفظ سلامة الإجابات."))}
<div class="pillars">
<div class="pillar rv"><div class="bic">{ic("layers")}</div><h3>{L("Satu bidang, satu metodologi","One field, one method","مجال واحد، ومنهج واحد")}</h3><p>{L("Setiap AI hanya berpegang pada kitab bidangnya. Fikih dan hadis punya manhaj dan kaidah yang berbeda, dan tidak dicampur.","Each AI keeps only to the books of its field. Fiqh and hadith work differently and are never mixed.","يلتزم كل ذكاء اصطناعي بكتب مجاله وحدها. وللفقه والحديث طريقتان مختلفتان، فلا يُخلطان.")}</p></div>
<div class="pillar rv d1"><div class="bic">{ic("scale")}</div><h3>{L("Dipilih dengan manhaj wasathiyyah","Curation by al-wasatiyya al-shar'iyya","انتقاء وفق الوسطية الشرعية")}</h3><p>{L("Kitab dipilih satu per satu agar keilmuan tidak terpolitisasi dan tidak dipakai menjatuhkan kelompok lain.","Books are chosen one by one so scholarship is not politicised or used to bring other groups down.","تُنتقى الكتب واحدًا واحدًا حتى لا يُسيَّس العلم ولا يُستعمل لإسقاط الآخرين.")}</p></div>
<div class="pillar rv d2"><div class="bic">{ic("check")}</div><h3>{L("Dikonsultasikan dengan ulama","Built in consultation with scholars","بُني بالتشاور مع العلماء")}</h3><p>{L("Pembuatan AI ini dikonsultasikan dengan para ulama: kitab yang dipakai, metodologi tiap ilmu, dan isi di bidangnya.","The making of this AI is done in consultation with scholars: the books used, the method of each science, and the content in its field.","يُصنع هذا الذكاء الاصطناعي بالتشاور مع العلماء: في الكتب المعتمدة، ومنهج كل علم، والمحتوى في مجاله.")}</p></div>
<div class="pillar rv d3"><div class="bic">{ic("book")}</div><h3>{L("Rujukan, dengan batas yang jujur","References, with honest limits","مراجع، وحدود صادقة")}</h3><p>{L("Jawaban diarahkan ke kitab, jilid, dan halaman bila tersedia. Penjelasan AI tetap diverifikasi kepada guru.","Answers point to the book, volume, and page where available. AI explanations are still verified with a teacher.","تُوجَّه الإجابة إلى الكتاب والجزء والصفحة إن توفرت. ويبقى شرح الذكاء الاصطناعي بحاجة إلى التحقق لدى المعلم.")}</p></div></div>
<div class="statement rv"><div><p>{L("Setiap jawaban ada kitabnya.","Every answer points to its book.","لكل جواب كتابه.")}</p></div><div><p class="small">{L("OpenTurath menunjukkan ibarah dan nomor halamannya, jadi Anda bisa mengeceknya sendiri. Untuk amal dan fatwa, tetap tanyakan kepada guru.","OpenTurath shows the passage and its page number, so you can check it yourself. For practice and fatwa, still ask your teacher.","يعرض OpenTurath العبارة ورقم الصفحة لتتحقق بنفسك. أما في العمل والفتوى فاسأل معلمك.")}</p><a class="btn inv-o sm" href="pedoman.html">{L("Baca pedoman keilmuan","Read the scholarly guidelines","اقرأ الضوابط العلمية")}</a></div></div></div></section>

<section class="sec"><div class="wrap">{shead(L("Ekosistem","Ecosystem","المنظومة"), L("OpenTurath lebih dari satu aplikasi.","OpenTurath is more than one app.","OpenTurath أكثر من تطبيق."), L("Satu nama, empat jalur yang saling melengkapi.","One name, four paths that complete each other.","اسم واحد وأربعة مسارات يكمّل بعضها بعضًا."))}{eco()}
<p class="more"><a class="link" href="ekosistem.html">{L("Tentang ekosistem OpenTurath","About the OpenTurath ecosystem","عن منظومة OpenTurath")}{ic("arrow","arr")}</a></p></div></section>

<section class="sec" style="border-top:0"><div class="wrap"><div class="founder"><div class="fcol rv"><span class="pill">{L("Dibuat oleh pelajar, untuk para pelajar.","Made by a student, for students.","من طالب علم، لطلاب العلم.")}</span><blockquote>{L("Satu halaman kitab, satu jam, dan masih belum paham. Dari situlah OpenTurath bermula.","One page of a book, one hour, and still no understanding. That is where OpenTurath began.","صفحة من كتاب، وساعة كاملة، ولا فهم بعد. من هنا بدأ OpenTurath.")}</blockquote></div><div class="fcol rv d1"><p class="lead">{L("Sang perintis adalah seorang santri. Ia pernah menerjemahkan sebuah kitab kata demi kata, menghabiskan sekitar satu jam untuk satu halaman, dan tetap belum paham. OpenTurath ia bangun seorang diri untuk menjawab kesulitan itu, dengan pemeriksaan dari para ulama.","The founder is a student of the sacred sciences. He once translated a book word by word, spent about an hour on a single page, and still did not understand. He built OpenTurath alone to answer that difficulty, with scholars checking the content.","المؤسس طالب علم. ترجم ذات يوم كتابًا كلمة كلمة، واستغرقت الصفحة الواحدة نحو ساعة، ولم يفهمها بعد. فبنى OpenTurath وحده ليجيب عن تلك الصعوبة، ويراجع العلماء المحتوى.")}</p><p class="chip-row"><span class="chip big">{L("Diumumkan di Universitas Al-Wasatiyah, Hadramaut, 7 Mei 2026, di hadapan para ulama","Announced at Al-Wasatiyah University, Hadramawt, on 7 May 2026, before scholars","أُعلن في جامعة الوسطية بحضرموت، 7 مايو 2026، بحضور العلماء")}</span></p></div><div class="fbottom rv"><a class="link" href="tentang.html">{L("Baca ceritanya","Read the story","اقرأ القصة")}{ic("arrow","arr")}</a><div class="cpills">{contact_pills()}</div></div></div></div></section>

{download_band()}

<section class="sec"><div class="wrap">{shead(L("Pertanyaan","Questions","أسئلة"), L("Jawaban singkat.","Short answers.","إجابات موجزة."))}<div class="rv">{faq(FAQ_MAIN())}</div><p class="more"><a class="link" href="bantuan.html">{L("Semua bantuan","All help","كل المساعدة")}{ic("arrow","arr")}</a></p></div></section>'''
    body += '<script type="application/ld+json">' + json.dumps({"@context": "https://schema.org", "@type": "SoftwareApplication", "name": "OpenTurath AI", "applicationCategory": "EducationalApplication", "operatingSystem": "Android, macOS, Windows", "inLanguage": ["id", "en", "ar"], "url": BASE + "/" + LANG + "/index.html", "description": "AI Islami berbasis turath untuk penuntut ilmu."}, ensure_ascii=False) + '</script>'
    write("index.html", L("OpenTurath", "OpenTurath", "OpenTurath"),
          L("OpenTurath AI membantu penuntut ilmu memahami kitab dan menemukan rujukan ibarahnya, bidang demi bidang. AI Islami berbasis turath.",
            "OpenTurath AI helps seekers of knowledge understand books and find the passages they cite. An Islamic AI grounded in turath.",
            "يساعد OpenTurath AI طالب العلم على فهم الكتب والوصول إلى العبارات التي تستند إليها. ذكاء اصطناعي إسلامي قائم على التراث."), body)

def eco():
    cards = [
        ("first", mark(26), L("Rilis 26 Okt 2026", "Released 26 Oct 2026", "الإطلاق 26 أكتوبر 2026"), "OpenTurath AI",
         L("AI Islami berbasis turath yang mencakup semua bidang ilmu dan khazanah para ulama. Cita-citanya: menjadi garda terdepan AI Islami berbasis turath.", "An Islamic AI grounded in turath, covering all fields of knowledge and the heritage of the scholars. The aim: to be the frontier of turath-based Islamic AI.", "ذكاء اصطناعي إسلامي قائم على التراث يشمل كل العلوم وميراث العلماء. وغايته: أن يكون في طليعة الذكاء الاصطناعي الإسلامي القائم على التراث.")),
        ("", ic("library"), L("Dibangun", "In the making", "قيد البناء"), L("Maktabah OpenTurath", "OpenTurath Library", "مكتبة OpenTurath"),
         L("Pusat unduh kitab yang menyatukan semua cetakan dan banyak sumber unduh dalam satu halaman. Cita-citanya: menjadi pusat unduh kitab terbesar di dunia.", "A book download hub bringing every edition and many download sources onto one page. The aim: to be the largest book download hub in the world.", "مركز لتحميل الكتب يجمع كل الطبعات ومصادر التحميل الكثيرة في صفحة واحدة. وغايته: أن يكون أكبر مركز لتحميل الكتب في العالم.")),
        ("", ic("scroll"), L("Segera hadir", "Coming soon", "قريبًا"), L("AI Manuskrip", "Manuscript AI", "ذكاء المخطوطات"),
         L("Menuliskan ulang naskah Arab kuno menjadi teks digital yang bisa dicari dan disunting, lalu merapikannya bila diminta. Tahqiq dan pemeriksaan isi tetap pekerjaan pemilik naskah.", "Rewrites old Arabic manuscripts as searchable, editable digital text, and tidies the layout on request. Critical editing and checking the content remain the owner’s work.", "يعيد كتابة المخطوطات العربية القديمة نصًّا رقميًّا قابلًا للبحث والتحرير، وينسّقه عند الطلب. ويبقى التحقيق والتثبّت من المضمون على صاحب المخطوط.")),
        ("", ic("cap"), L("Rencana", "Planned", "مخطَّط"), L("Daurah OpenTurath", "OpenTurath Daurah", "دورات OpenTurath"),
         L("Daurah belajar memakai AI bagi penuntut ilmu: dari percakapan, gambar dan video dakwah, hingga membuat aplikasi dan AI agent.", "Courses on using AI for seekers of knowledge: from conversation, images and da'wa video, to building apps and AI agents.", "دورات في استعمال الذكاء الاصطناعي لطلاب العلم: من المحادثة وصور الدعوة ومقاطعها، إلى بناء التطبيقات ووكلاء الذكاء الاصطناعي."))]
    out = ""
    for k, (cls, icon, st, t, d) in enumerate(cards):
        if k == 0: out += f'<a class="first rv" href="bidang.html"><div class="top"><div class="eic">{icon}</div><span class="status">{st}</span></div><h3>{t}</h3><p>{d}</p><span class="go">{L("Jelajahi bidang","Explore the fields","استكشف المجالات")}{ic("arrow","arr")}</span></a>'
        else: out += f'<div class="e rv d{k}"><div class="top"><div class="eic">{icon}</div><span class="status">{st}</span></div><h3>{t}</h3><p>{d}</p></div>'
    return f'<div class="eco">{out}</div>'

def download_band(sub=True):
    """Isyarat saja: unduhan lengkap ada di halaman Unduh."""
    chips = "".join(f'<span class="pchip">{n}</span>' for n in ("Android", "Windows", "macOS"))
    return (f'<section class="sec band" id="unduh"><div class="wrap" style="text-align:center"><div class="sec-head center"><h2>{L("Bawa khazanahnya ke perangkat Anda.","Take the heritage to your devices.","احمل الكنوز إلى أجهزتك.")}</h2><p class="lead">{L("Tersedia untuk Android, Windows, dan macOS. Satu akun Google untuk semua perangkat.","Available for Android, Windows, and macOS. One Google account for every device.","متوفر لأندرويد وويندوز وماك. حساب Google واحد لجميع الأجهزة.")}</p></div>'
            f'<div class="pchips rv">{chips}</div>'
            f'<p class="rv" style="margin-top:28px"><a class="btn inv" href="unduh.html">{ic("download")}{L("Pilih perangkat dan unduh","Choose your device and download","اختر جهازك وحمّل التطبيق")}</a></p></div></section>')

# ======================= BIDANG =======================
def page_bidang():
    write("bidang.html", L("Bidang ilmu: OpenTurath", "Fields of knowledge: OpenTurath", "المجالات العلمية: OpenTurath"),
          L("Peta bidang ilmu OpenTurath AI: fikih empat mazhab, hadis, tafsir, ushul, akidah, tasawuf, bahasa Arab, sejarah, bibliografi, dan Fikih Tahawwulat.", "Map of the fields of OpenTurath AI: fiqh across four schools, hadith, tafsir, usul, creed, tasawwuf, Arabic, history, bibliography, and Fiqh al-Tahawwulat.", "خريطة مجالات OpenTurath AI: الفقه في المذاهب الأربعة، والحديث، والتفسير، والأصول، والعقيدة، والتصوف، واللغة العربية، والتاريخ، والفهارس، وفقه التحولات."),
          head("OpenTurath AI", L("Bidang ilmu.", "Fields of knowledge.", "المجالات العلمية."), L("Setiap bidang punya AI, koleksi kitab, dan metodologinya sendiri. Pilih yang sesuai dengan ilmu yang Anda pelajari.", "Every field has its own AI, set of books, and method. Pick the one that fits what you are studying.", "لكل مجال ذكاؤه الاصطناعي ومجموعة كتبه ومنهجه. اختر ما يوافق العلم الذي تدرسه.")) +
          sec(explorer("all", with_all=True, search=True), "sec-tight") +
          sec(f'<div class="statement" style="margin-top:0"><div><p>{L("Cakupan terus bertambah.","The scope keeps growing.","النطاق يتّسع باستمرار.")}</p></div><div><p class="small">{L("Dari Fikih Tahawwulat dan bidang yang ada, meluas ke seluruh ilmu Islam dan khazanah para ulama.","From Fiqh al-Tahawwulat and the existing fields, expanding to all the Islamic sciences and the heritage of the scholars.","من فقه التحولات والمجالات القائمة إلى سائر العلوم الإسلامية وتراث العلماء.")}</p><a class="btn inv-o sm" href="ekosistem.html">{L("Arah OpenTurath","Where OpenTurath is heading","وجهة OpenTurath")}</a></div></div>', "sec-tight"), "bidang.html")

# ======================= FIKIH TAHAWWULAT =======================
def tahaw_story():
    Q = lambda ar, src: f'<p class="quote-ar">{ar}</p><p class="quote-src">{src}</p>'
    NUB = lambda p: L(f"An-Nubdzah ash-Shughra, hlm. {p.translate(str.maketrans('٠١٢٣٤٥٦٧٨٩', '0123456789'))}", f"An-Nubdhah al-Sughra, p. {p.translate(str.maketrans('٠١٢٣٤٥٦٧٨٩', '0123456789'))}", f"النبذة الصغرى، ص {p}")
    s1 = (shead(L("Mulai dari sini","Start here","ابدأ من هنا"), L("Membahas tanda kiamat, bukankah menakutkan?","Isn't talking about the signs of the Hour frightening?","أليس الحديث عن علامات الساعة مخيفًا؟"),
                L("Pertanyaan itu wajar. Di sinilah Al-Habib Abu Bakar Al-Adni memulai.","It is a fair question. This is where Al-Habib Abu Bakr al-Adni begins.","السؤال مشروع، ومنه يبدأ الحبيب أبو بكر العدني.")) +
          f'<div class="two rv"><div class="ol"><span class="k">{L("Anggapan umum","A common belief","ظن شائع")}</span><h3>{L("Ilmu ini hanya menebar takut dan membuat orang menjauh.","This knowledge only spreads fear and makes people withdraw.","هذا العلم لا يورث إلا الخوف والعزلة.")}</h3>{Q("«يعتقد البعض… بأن علامات الساعة سبب لإثارة الخوف من المستقبل… وسبيل إلى الإحباط والعزلة»", NUB("٥٥"))}</div>'
          f'<div class="dark"><span class="k">{L("Kata Al-Habib","In Al-Habib’s words","قول الحبيب")}</span><h3>{L("Justru sebaliknya: ia pelindung yang menunjukkan sikap yang benar.","Quite the opposite: it is a protection that shows the right stance.","بل على العكس: هو وقاية تبيّن الموقف الصحيح.")}</h3>{Q("«أن العلم بعلامات الساعة تحصين ووقاية شرعية للمسلم… وتبين له الموقف المتخذ شرعا»", NUB("٥٥"))}</div></div>')
    s2 = (shead(L("Perumpamaan","An analogy","تشبيه"), L("Penggerak keempat yang terlupakan.","The fourth drive that was forgotten.","المحرّك الرابع المنسي."),
                L("Al-Habib mengibaratkan agama seperti mobil yang punya mode penggerak empat roda.","Al-Habib likens religion to a car with a four-wheel-drive mode.","شبّه الحبيب الدين بسيارة لها نظام الدفع الرباعي.")) +
          f'<div class="carbox rv"><div><span class="st">01 · {L("Jalan biasa","The ordinary road","الطريق المعتاد")}</span><h3>{L("Jarang dipakai","Rarely used","قلّما يُستعمل")}</h3><p>{L("Di jalan mulus, tombol penggerak empat roda hampir tak tersentuh. Ia disiapkan untuk keadaan darurat.","On a smooth road the four-wheel-drive button is hardly touched. It is kept for emergencies.","في الطريق الممهّد لا يكاد يُلمس زر الدفع الرباعي، فهو معدّ للطوارئ.")}</p></div>'
          f'<div><span class="st">02 · {L("Jalan berlumpur","The muddy road","الطريق الموحل")}</span><h3>{L("Pemiliknya bingung","The owner is lost","يحار صاحبها")}</h3><p>{L("Yang tidak tahu fiturnya terjebak, padahal jalan keluarnya ada di mobilnya sendiri.","Whoever does not know the feature is stuck, though the way out is in his own car.","من جهل الميزة علق، ومخرجه في سيارته نفسها.")}</p></div>'
          f'<div class="em"><span class="st">03 · {L("Rukun keempat","The fourth pillar","الركن الرابع")}</span><h3>{L("Itulah rukun keempat agama","That is the fourth pillar of religion","ذلكم هو الركن الرابع")}</h3><p>{L("Ilmu yang disiapkan untuk saat jalan sulit, dan yang paling mudah dilupakan.","The knowledge kept for hard roads, and the easiest to forget.","علم أُعدّ لساعة الشدّة، وأيسره نسيانًا.")}</p></div></div>'
          f'<p class="quote-src rv" style="margin-top:14px">{Q("«ليس دائم الاستخدام، وإنما يتخذ للطوارئ»", L("Al-Ghirbal, hlm. 6","Al-Ghirbal, p. 6","الغربال، ص ٦"))}</p>')
    qs = [("01", L("Islam","Islam","الإسلام"), L("Rukun Islam dan syariat","The pillars of Islam and the law","أركان الإسلام والشريعة"), "الإسلام", ""),
          ("02", L("Iman","Iman","الإيمان"), L("Rukun iman dan akidah","The pillars of faith and creed","أركان الإيمان والعقيدة"), "الإيمان", ""),
          ("03", L("Ihsan","Ihsan","الإحسان"), L("Tazkiyah dan suluk","Purification and spiritual conduct","التزكية والسلوك"), "الإحسان", ""),
          ("04", L("Tanda-tandanya","Its signs","أماراتها"), L("Tanda-tanda kiamat","The signs of the Hour","علامات الساعة"), "علامات الساعة", "last")]
    qh = "".join(f'<li class="{c}"><span class="no">{n}</span><h3>{t}</h3><p>{d}</p><div class="ar">{a}</div></li>' for n, t, d, a, c in qs)
    s3 = (shead(L("Dalilnya","The evidence","الدليل"), L("Empat pertanyaan dalam hadis Jibril.","Four questions in the hadith of Jibril.","أربعة أسئلة في حديث جبريل."),
                L("Seorang lelaki berpakaian sangat putih duduk di hadapan Nabi ﷺ dan bertanya empat hal berurutan. Setelah ia pergi, Nabi ﷺ bersabda bahwa ia Jibril, datang mengajarkan agama kalian. Karena keempat pertanyaan itu disebut agama, rukun agama ada empat.",
                  "A man in brilliant white clothes sat before the Prophet ﷺ and asked four things in turn. After he left, the Prophet ﷺ said he was Jibril, come to teach you your religion. Since all four questions are called religion, the pillars of religion are four.",
                  "جلس رجل شديد بياض الثياب بين يدي النبي ﷺ وسأل أربعة أسئلة متتابعة. فلما انصرف قال النبي ﷺ إنه جبريل أتاكم يعلّمكم أمر دينكم. ولما سُمّيت الأسئلة الأربعة دينًا كانت أركان الدين أربعة.")) +
          f'<ol class="qs rv">{qh}</ol><p class="quote-ar rv" style="margin-top:22px">«فإنه جبريل أتاكم يعلمكم أمر دينكم»</p><p class="quote-src rv">{NUB("١٠")}</p>')
    s4 = (shead(L("Yang tetap dan yang berubah","The constant and the changing","الثوابت والمتغيرات"), L("Agama tetap. Zamanlah yang ditimbang.","Religion stays. The age is what gets weighed.","الدين ثابت، والزمان هو الذي يوزن.")) +
          f'<div class="two rv"><div class="ol"><span class="k">{L("Yang tetap","The constant","الثوابت")}</span><h3>{L("Islam, iman, dan ihsan","Islam, iman, and ihsan","الإسلام والإيمان والإحسان")}</h3><p>{L("Tiga rukun ini tidak berubah sampai kiamat: syariat, akidah, dan suluk.","These three pillars do not change until the Hour: law, creed, and spiritual conduct.","هذه الأركان الثلاثة لا تتغير إلى قيام الساعة: الشريعة والعقيدة والسلوك.")}</p>{Q("«الثوابت: ما يترتب عليه معرفة علم الشريعة والعقيدة ومراتب السلوك»", NUB("١٤"))}</div>'
          f'<div class="dark"><span class="k">{L("Yang berubah","The changing","المتغيرات")}</span><h3>{L("Keadaan manusia dan zamannya","The condition of people and their age","أحوال الناس وزمانهم")}</h3><p>{L("Rukun keempat membaca perubahan yang sebab-sebabnya sudah disebut wahyu. Ia tidak mengubah agama; ia membaca zaman dengan agama yang tetap.","The fourth pillar reads the changes whose causes revelation has already named. It does not change religion; it reads the age by an unchanging religion.","يقرأ الركن الرابع التغيرات التي نصّ الوحي على أسبابها. وهو لا يغيّر الدين، بل يقرأ الزمان بدين ثابت.")}</p></div></div>')
    s5 = (shead(L("Namanya","Its name","اسمه"), L("Satu ilmu, tiga nama.","One knowledge, three names.","علم واحد وثلاثة أسماء."),
                L("Fikih berarti paham sampai ke dasarnya. Tahawwulat berarti perubahan-perubahan. Jadi Fikih Tahawwulat adalah memahami perubahan zaman dengan petunjuk Nabi ﷺ.","Fiqh means understanding down to the root. Tahawwulat means the changes. So Fiqh al-Tahawwulat is understanding the changes of the age by the Prophet’s guidance ﷺ.","الفقه هو الفهم إلى الأعماق، والتحولات هي التغيرات. ففقه التحولات فهم تحولات العصر بهدي النبي ﷺ.")) +
          f'<div class="names rv"><div class="ol"><h3>{L("Ilmu akhir zaman","Knowledge of the end times","علم آخر الزمان")}</h3><p>{L("Nama yang paling dikenal orang.","The name most people know.","الاسم الأشهر بين الناس.")}</p></div><div class="ol"><h3>{L("Ilmu tanda-tanda kiamat","Knowledge of the signs of the Hour","العلم بعلامات الساعة")}</h3><p>{L("Nama yang dipakai dalam hadis Jibril.","The name used in the hadith of Jibril.","الاسم الوارد في حديث جبريل.")}</p></div><div class="ol"><h3>{L("Fikih Tahawwulat","Fiqh al-Tahawwulat","فقه التحولات")}</h3><p>{L("Istilah Al-Habib sendiri, untuk ilmu yang sama.","Al-Habib’s own term for the same knowledge.","مصطلح الحبيب نفسه لهذا العلم.")}</p></div></div>')
    s6 = (shead(L("Isinya","Its content","مضمونه"), L("Dua tanda, dua kendali.","Two signs, two controls.","علامتان وقراران."),
                L("Ketika ditanya tentang tanda kiamat, Nabi ﷺ menyebut dua hal. Al-Habib menyimpulkan bahwa kedua tanda itu menunjuk dua kendali penentu (qarar), dan semua tanda lain bermuara ke dua kendali ini.","Asked about the signs of the Hour, the Prophet ﷺ named two things. Al-Habib concludes that they point to two deciding controls (qarar), and that all other signs lead back to them.","لما سُئل النبي ﷺ عن علامات الساعة ذكر أمرين. ويرى الحبيب أنهما يشيران إلى قرارين، وأن سائر العلامات تعود إليهما.")) +
          f'<div class="two rv"><div class="ol"><span class="k">{L("Kendali pertama","First control","القرار الأول")}</span><h3>{L("Ilmu dan keyakinan","Knowledge and belief","العلم والاعتقاد")}</h3><p>{L("Yang semestinya diarahkan justru mengarahkan, sehingga arah ilmu dan keyakinan bergeser.","Those who should be guided end up guiding, and the direction of knowledge and belief shifts.","يتصدّر للتوجيه من كان حقه أن يُوجَّه، فيختلّ اتجاه العلم والاعتقاد.")}</p>{Q("«قرار العلم والاعتقاد»", NUB("١٥"))}</div>'
          f'<div class="ol"><span class="k">{L("Kendali kedua","Second control","القرار الثاني")}</span><h3>{L("Kekuasaan dan harta","Authority and wealth","الحكم والاقتصاد")}</h3><p>{L("Urusan diserahkan kepada yang bukan ahlinya, dan kemuliaan diukur dari megahnya bangunan.","Affairs are handed to those who are not fit for them, and honour is measured by grand buildings.","يُسند الأمر إلى غير أهله، ويُقاس الشرف بفخامة البنيان.")}</p>{Q("«قرار الحكم والاقتصاد»", NUB("١٥"))}</div></div>')
    s7 = (shead(L("Waktunya","Its timing","زمانه"), L("Tiga garis waktu yang berjalan bersamaan.","Three timelines running together.","ثلاثة خطوط زمنية متداخلة."),
                L("Tanda kiamat dibagi tiga menurut kapan terjadinya, bukan menurut seberapa penting. Ketiganya berjalan saling tumpang-tindih sepanjang zaman.","The signs of the Hour are divided in three by when they occur, not by how important they are. The three overlap along the ages.","تنقسم علامات الساعة ثلاثًا بحسب زمن وقوعها لا بحسب أهميتها، وهي تجري متداخلة عبر الأزمنة.")) +
          f'<div class="road rv"><span>{L("Kecil","Small","الصغرى")}</span><span>{L("Tengah","Middle","الوسطى")}</span><span>{L("Besar","Major","الكبرى")}</span></div>'
          f'<div class="tl3 rv"><div class="ol"><span class="k">{L("Tanda kecil","Minor signs","العلامات الصغرى")}</span><h3>{L("Garis terpanjang","The longest line","أطول الخطوط")}</h3><p>{L("Dimulai sebelum Nabi ﷺ lahir dan berlanjut sampai tiupan sangkakala. Banyak ragamnya dan berulang.","It begins before the Prophet ﷺ was born and runs until the trumpet. Varied, and recurring.","تبدأ قبل مولد النبي ﷺ وتستمر إلى النفخ في الصور، وهي متنوعة ومتكررة.")}</p></div>'
          f'<div class="ol"><span class="k">{L("Tanda tengah","Middle signs","العلامات الوسطى")}</span><h3>{L("Peristiwa besar yang terjadi sekali","Great events that happen once","أحداث كبرى تقع مرة")}</h3><p>{L("Dari diutusnya Nabi ﷺ sampai munculnya Imam Mahdi.","From the sending of the Prophet ﷺ until the appearance of the Mahdi.","من بعثة النبي ﷺ إلى ظهور المهدي.")}</p></div>'
          f'<div class="ol"><span class="k">{L("Tanda besar","Major signs","العلامات الكبرى")}</span><h3>{L("Sepuluh tanda penutup","Ten closing signs","عشر علامات ختامية")}</h3><p>{L("Dimulai dari munculnya Imam Mahdi sampai tiupan sangkakala.","Beginning with the Mahdi and ending with the sounding of the trumpet.","تبدأ بظهور المهدي وتنتهي بالنفخ في الصور.")}</p></div></div>'
          f'<p class="quote-ar rv" style="margin-top:22px">«وكلها تجري متداخلة في مسيرة الأزمنة والأمكنة»</p><p class="quote-src rv">{NUB("٤٣")}</p>')
    return s1, s2, s3, s4, s5, s6, s7

def page_tahaw():
    bab_ar = {"Pembuka": "المقدمة", "Perumpamaan": "التشبيه", "Dalil": "الدليل", "Keberatan": "الاعتراضات", "Tetap dan berubah": "الثوابت والمتغيرات", "Nama dan definisi": "الاسم والتعريف", "Tugasnya": "وظيفته", "Isinya": "مضمونه", "Waktunya": "زمانه", "Peta perjalanan": "خريطة المسير", "Rambu": "العلامات", "Sikap": "الموقف", "Tujuh langkah": "سبع خطوات", "Mulai belajar": "ابدأ التعلّم", "Penutup": "الخاتمة"}
    bab_en = {"Pembuka": "Opening", "Perumpamaan": "An analogy", "Dalil": "The evidence", "Keberatan": "Objections", "Tetap dan berubah": "The constant and the changing", "Nama dan definisi": "Name and definition", "Tugasnya": "Its task", "Isinya": "Its content", "Waktunya": "Its time", "Peta perjalanan": "The road map", "Rambu": "The signposts", "Sikap": "The right stance", "Tujuh langkah": "Seven steps", "Mulai belajar": "Start learning", "Penutup": "Closing"}
    bab = "".join(f'<li><b>{b["no"]:02d}</b> {E({"id": b["judul"], "en": bab_en[b["judul"]], "ar": bab_ar[b["judul"]]}[LANG])}</li>' for b in PENG["bab"])
    ib = SL["empat-rukun"]
    rows = [("Al-Muhaqqiq", "المحقق", L("Teks matan dan ibarah", "Texts and passages", "النصوص والعبارات"), L("Mencari, memeriksa, dan mengaitkan teks dengan sumbernya.", "Finds, checks, and links texts to their sources.", "يبحث ويتحقق ويربط النص بمصدره."), L("Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?", "What is meant by the Fourth Pillar in Fiqh al-Tahawwulat?", "ما المقصود بالركن الرابع في فقه التحولات؟")),
            ("Al-Bayan", "البيان", L("Penyederhanaan konsep", "Simplifying concepts", "تبسيط المفاهيم"), L("Menjelaskan dengan bahasa yang sederhana dan mudah dipahami, cocok untuk pemula.", "Explains in simple, easy language, well suited to beginners.", "يشرح بلغة مبسّطة سهلة الفهم، مناسبة للمبتدئين."), L("Jelaskan al-ghutsa'iyyah dengan bahasa sederhana.", "Explain al-ghuthaiyya in simple words.", "اشرح الغثائية بعبارة مبسّطة.")),
            ("Al-Mukhtabir", "المختبر", L("Uji pemahaman", "Testing understanding", "اختبار الفهم"), L("AI bertanya, Anda menjawab, lalu ia menilai di mana jawaban Anda sudah baik dan di mana lemah, dan memberi jawaban idealnya.", "The AI asks, you answer, then it judges where your answer is strong and where weak, and gives the ideal answer.", "يسألك الذكاء الاصطناعي فتجيب، ثم يقيّم جوابك: مواطن الإحسان ومواطن الضعف، ويعطيك الجواب المثالي."), L("Uji saya: apa itu al-ghutsa'iyyah?", "Test me: what is al-ghuthaiyya?", "اختبرني: ما الغثائية؟")),
            ("Al-Habib", "الحبيب", L("Ceramah Al-Habib", "Al-Habib's lectures", "محاضرات الحبيب"), L("Isi ceramah Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur, dijawab dengan diksi beliau sendiri.", "The content of the lectures of Al-Habib Abu Bakr al-Adni bin Ali al-Mashhur, answered in his own wording.", "مضمون محاضرات الحبيب أبي بكر العدني بن علي المشهور، بعبارته وألفاظه."), L("Bagaimana Al-Habib menjelaskan sikap saat masa fitnah?", "How does Al-Habib explain conduct in times of trial?", "كيف يشرح الحبيب الموقف زمن الفتن؟")),
            ("Al-Khatib", "الخطيب", L("Materi dakwah dan khutbah", "Da'wa and sermon material", "المواد الدعوية والخطب"), L("Menyusun khutbah, bahan ceramah, dan materi dakwah lainnya.", "Drafts sermons, talk material, and other da'wa content.", "يُعدّ الخطب والمواد الوعظية وسائر المواد الدعوية."), L("Susun kerangka khutbah tentang sikap saat masa fitnah.", "Outline a sermon on conduct in times of trial.", "ضع هيكل خطبة عن الموقف زمن الفتن."))]
    brt = "".join(f'<tr><td class="c"><b>{a}</b><div class="ar">{b}</div></td><td>{c}</td><td>{d}</td><td><span class="small">&ldquo;{e}&rdquo;</span></td></tr>' for a, b, c, d, e in rows)
    th = (L("Peran", "Role", "الدور"), L("Fungsi", "What it does", "الوظيفة"), L("Contoh pertanyaan", "Sample question", "سؤال توضيحي"), L("AI", "AI", "الذكاء الاصطناعي"))
    defn = L("Pemahaman syar'i atas ketetapan Allah dan sunnah-sunnah perubahan dalam kehidupan manusia dan alam, serta hal-hal baru dalam ilmu, budaya, peristiwa, dan fitnah sepanjang masa umat hingga kiamat.",
             "The legal-religious understanding of what God decrees and of the laws of change in human and cosmic life, together with the new developments in knowledge, culture, events, and trials across the life of the Ummah until the Hour.",
             "هو الفهم الشرعي لما يقضي الله ويدبّر، ولسنن التغيّرات في الحياة الإنسانية والكونية، وما يطرأ من مستجدات العلم والثقافة والحوادث والفتن في مراحل الأمة إلى قيام الساعة.")
    srcdef = L("An-Nubdzah ash-Shughra, hlm. 17", "An-Nubdhah al-Sughra, p. 17", "النبذة الصغرى، ص ١٧")
    S1, S2, S3, S4, S5, S6, S7 = tahaw_story()
    body = (head(L("Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات"), L("Memahami perubahan zaman dengan petunjuk Nabi ﷺ.", "Understanding the changes of the age by the Prophet's guidance ﷺ.", "فهم تحولات العصر بهدي النبي ﷺ."), defn + f' <span class="small">({srcdef})</span>',
                 '<div class="ar bigname">فقه التحولات</div>') +
            sec(S1) + sec(S2) + sec(S3) +
            f'<section class="sec band"><div class="wrap">{exclusive()}{shead(L("Rukun keempat","The fourth pillar","الركن الرابع"), L("Penjaga tiga rukun yang lain.","Guardian of the other three.","حارس الأركان الثلاثة الأخرى."))}<div class="tahaw tsc rv">{sculpt()}{rukun_html()}</div><div class="rv">{tasks_html()}</div></div></section>' +
            sec(S4) + sec(S5) + sec(S6) + sec(S7) +
            sec(f'<div class="rv" style="display:flex;flex-wrap:wrap;gap:16px;align-items:center;justify-content:space-between"><p class="lead" style="margin:0;max-width:640px">{L("Punya pertanyaan yang lebih sederhana? Seratus tiga puluh tiga jawaban singkat menunggu Anda.","Have simpler questions? One hundred and thirty-three short answers are waiting.","هل لديك أسئلة أبسط؟ ثلاث وثلاثون ومئة إجابة موجزة في انتظارك.")}</p><a class="btn primary" href="mengenal-fikih-tahawwulat.html">{L("Mengenal Fikih Tahawwulat","Getting to know Fiqh al-Tahawwulat","التعرّف على فقه التحولات")}{ic("arrow","arr")}</a></div>', "sec-tight") +
            f'<section class="sec band"><div class="wrap">{shead(L("Lima AI","Five AIs","خمسة ذكاءات اصطناعية"), L("Satu bidang, lima cara belajar.","One field, five ways to learn.","مجال واحد، وخمس طرق للتعلّم."), L("Isinya adalah kitab karya Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur dan arsip ceramah beliau. Lima AI membagi disiplin ini menurut kebutuhan pembelajar. Satu akses membuka kelimanya.","The collection is made up of the books of Al-Habib Abu Bakr al-Adni ibn Ali al-Mashhur and his lecture archive. Five AIs divide the discipline by the learner’s need. One access opens all five.","مدوّنتها كتب الحبيب أبي بكر العدني بن علي المشهور وأرشيف محاضراته. ويقسّم خمسة ذكاءات اصطناعية هذا العلم بحسب حاجة المتعلّم. وبوصول واحد تُفتح الخمسة جميعًا."))}{branches_html()}'
            f'<table class="tbl rv" style="margin-top:48px"><thead><tr><th>{th[3]}</th><th>{th[0]}</th><th>{th[1]}</th><th>{th[2]}</th></tr></thead><tbody>{brt}</tbody></table></div></section>' +
            sec(shead(L("Pengantar", "Introduction", "مدخل"), L("Mulai dari video pengantar.", "Start with the introductory video.", "ابدأ بالفيديو التمهيدي."), L("Di dalam aplikasi, video pengantar sekitar dua belas menit menuntun Anda lewat lima belas bab, lengkap dengan ibarah dan sumbernya.", "Inside the app, an introductory video of about twelve minutes walks you through fifteen chapters, with passages and sources.", "داخل التطبيق فيديو تمهيدي مدته نحو اثنتي عشرة دقيقة يمرّ بك على خمسة عشر بابًا، مع العبارات ومصادرها.")) + f'<ul class="list-clean rv cols3">{bab}</ul><p style="margin-top:36px"><a class="btn primary" href="unduh.html">{ic("download")}{L("Unduh aplikasi","Download the app","تحميل التطبيق")}</a></p>'))
    write("fikih-tahawwulat.html", L("Fikih Tahawwulat: OpenTurath", "Fiqh al-Tahawwulat: OpenTurath", "فقه التحولات: OpenTurath"),
          L("Kenali Fikih Tahawwulat, rukun keempat agama, dan lima AI OpenTurath untuk mempelajarinya.", "Get to know Fiqh al-Tahawwulat, the fourth pillar of religion, and the five OpenTurath AIs for studying it.", "تعرّف على فقه التحولات، الركن الرابع من أركان الدين، والذكاءات الاصطناعية الخمسة في OpenTurath AI لدراسته."), body, "")

# ======================= CARA KERJA =======================
def page_cara():
    steps = [(L("Pilih bidang", "Choose a field", "اختر المجال"), L("Pilih AI sesuai ilmu yang ditanyakan, dari fikih sampai hadis, tafsir, dan bahasa Arab.", "Pick the AI for the discipline you are asking about, from fiqh to hadith, tafsir, and Arabic.", "اختر الذكاء الاصطناعي المناسب للعلم الذي تسأل عنه، من الفقه إلى الحديث والتفسير واللغة العربية.")),
             (L("Ajukan pertanyaan", "Ask a question", "اطرح سؤالك"), L("Tulis dengan bahasa sehari-hari, atau mulai dari pertanyaan contoh yang tersedia di tiap bidang.", "Write in everyday language, or start from the sample questions available in each field.", "اكتب بلغتك المعتادة، أو ابدأ من الأسئلة التوضيحية المتاحة في كل مجال.")),
             (L("AI menelusuri", "The AI searches", "يبحث الذكاء الاصطناعي"), L("Penelusuran hanya dari koleksi kitab bidang itu, bukan dari seluruh internet.", "It searches only the books of that field, not the whole internet.", "يبحث في كتب ذلك المجال وحدها، لا في الإنترنت كله.")),
             (L("Baca jawabannya", "Read the answer", "اقرأ الإجابة"), L("Penjelasan, ibarah Arab, dan nomor rujukan hadir bersama dalam satu jawaban.", "The explanation, the Arabic passage, and the reference number come together in one answer.", "يجتمع الشرح والعبارة العربية ورقم المرجع في إجابة واحدة.")),
             (L("Periksa kitabnya", "Check the book", "راجع الكتاب"), L("Buka keterangan kitab, cocokkan dengan edisi yang Anda pegang, dan baca konteksnya.", "Open the book details, match them with your edition, and read the context.", "افتح بيانات الكتاب وطابقها مع طبعتك واقرأ السياق.")),
             (L("Simpan dan bawa ke guru", "Save and bring it to your teacher", "احفظ وارجع إلى المعلم"), L("Simpan ke Catatan beserta rujukannya, lalu bawa ke majelis untuk dipastikan.", "Save it to Notes with its reference, then bring it to the majlis to be confirmed.", "احفظها في الملاحظات مع مرجعها، ثم اعرضها في المجلس للتثبّت."))]
    st = "".join(f'<div class="rv"><div class="n">{i+1:02d}</div><h3>{t}</h3><p>{d}</p></div>' for i, (t, d) in enumerate(steps))
    pr = [(L("Kitab per bidang", "Books per field", "مدوّنة لكل مجال"), L("Tiap AI hanya berpegang pada kitab bidangnya, sehingga metodologi tiap ilmu tidak tercampur.", "Each AI keeps only to the books of its field, so the method of each discipline stays distinct.", "يلتزم كل ذكاء اصطناعي بكتب مجاله وحده، فلا تختلط مناهج العلوم.")),
          (L("Dipilih satu per satu", "Curated one by one", "انتقاء كتاب كتابًا"), L("Kitab dipilih dengan teliti. Jumlah kitab bukan ukuran; yang diukur adalah ketepatan jawaban.", "Books are chosen with care. The number of books is not the measure; the accuracy of answers is.", "تُختار الكتب بعناية. ليس العدد هو المعيار، بل دقة الإجابة.")),
          (L("Kitab utuh, bukan potongan acak", "Whole books, not random pieces", "كتب كاملة لا قصاصات"), L("Kitab ditaruh utuh dan dibagi hanya mengikuti sekat jilidnya.", "Books are kept whole and divided only along their volumes.", "تُحفظ الكتب كاملة ولا تُقسَّم إلا على حدود أجزائها.")),
          (L("Stempel rujukan", "A reference stamp", "ختم المرجع"), L("Setiap potongan teks bertanda: judul kitab, pengarang dan tahun wafat, penerbit atau pentahqiq, jilid, halaman.", "Every piece of text is marked: title, author and death year, publisher or editor, volume, page.", "كل مقطع موسوم: عنوان الكتاب، والمؤلف وسنة وفاته، والناشر أو المحقق، والجزء والصفحة.")),
          (L("Dipilih dengan manhaj wasathiyyah", "Curation by al-wasatiyya al-shar'iyya", "انتقاء وفق الوسطية الشرعية"), L("Kitab dipilih agar tidak terpolitisasi dan tidak dipakai menjatuhkan kelompok lain.", "Books are chosen so scholarship is not politicised or used to bring other groups down.", "تُنتقى الكتب حتى لا تُسيَّس ولا تُستعمل لإسقاط الآخرين.")),
          (L("Diperiksa sebelum masuk", "Checked before entering", "فحص قبل الإدخال"), L("Setiap kitab yang ditambahkan diperiksa dulu sebelum dipakai.", "Every book added is checked before it is used.", "تُفحص كل إضافة قبل أن تصبح جزءًا من المدوّنة."))]
    prh = "".join(f'<li><b>{t}.</b> {d}</li>' for t, d in pr)
    lim = [L("Jawaban AI dapat keliru atau kurang lengkap.", "AI answers can be wrong or incomplete.", "قد تخطئ إجابة الذكاء الاصطناعي أو تنقص."), L("Penjelasan AI perlu diverifikasi kepada guru, terutama untuk amal dan fatwa.", "AI explanations should be verified with a teacher, especially for practice and fatwa.", "يجب التحقق من شرح الذكاء الاصطناعي لدى المعلم، خاصة في العمل والفتوى."), L("Nomor halaman dapat berbeda antar edisi cetak.", "Page numbers can differ between printed editions.", "قد تختلف أرقام الصفحات بين الطبعات."), L("Tidak semua kitab ada di setiap bidang.", "Not every book is in every field.", "ليست كل الكتب موجودة في كل مجال."), L("OpenTurath AI bukan pemberi fatwa dan tidak menggantikan guru.", "OpenTurath AI is not a mufti and does not replace a teacher.", "OpenTurath AI ليس مفتيًا ولا يحل محل المعلم.")]
    body = (head(L("Cara kerja", "How it works", "كيف يعمل"), L("Dari pertanyaan sampai rujukan.", "From question to reference.", "من السؤال إلى المرجع."), L("Enam langkah sederhana, dan satu kebiasaan yang kami ajak Anda jaga: selalu kembali membuka kitabnya.", "Six simple steps, and one habit we invite you to keep: always go back and open the book.", "ست خطوات بسيطة، وعادة ندعوك إلى حفظها: أن تعود دائمًا إلى فتح الكتاب.")) +
            sec(f'<div class="steps6">{st}</div>', "sec-tight") +
            sec(f'<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">{L("Bagaimana koleksi kitabnya dijaga.","How the book collection is kept.","كيف تُحفظ المدوّنة.")}</h2><p class="lead">{L("Enam hal yang kami jaga agar koleksi kitab tiap AI tetap rapi dan bisa ditelusuri.","Six things we do to keep each AI’s book collection orderly and traceable.","ست قواعد تحفظ مدوّنة كل ذكاء اصطناعي منظمة وقابلة للتتبّع.")}</p></div><ul class="list-clean rv d1">{prh}</ul></div>') +
            sec(f'<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">{L("Batas yang jujur.","Honest limits.","حدود صادقة.")}</h2><p class="lead">{L("Mengetahui batas alat adalah bagian dari adab menuntut ilmu.","Knowing the limits of a tool is part of the adab of seeking knowledge.","معرفة حدود الأداة من أدب طلب العلم.")}</p></div><ul class="list-clean rv d1">{"".join(f"<li>{x}</li>" for x in lim)}</ul></div>', "sec band"))
    write("cara-kerja.html", L("Cara kerja: OpenTurath", "How it works: OpenTurath", "كيف يعمل: OpenTurath"),
          L("Dari pertanyaan sampai rujukan: cara kerja OpenTurath AI dalam enam langkah, dan cara kami menjaga koleksi kitabnya.", "From question to reference: how OpenTurath AI works in six steps, and how we keep its book collection.", "من السؤال إلى المرجع: كيف يعمل OpenTurath AI في ست خطوات، ومبادئ بناء المدوّنة خلفه."), body, "cara-kerja.html")

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
          L("Wasathiyyah syar'iyyah sebagai ukuran memilih kitab, peran AI dan guru, serta adab memakai OpenTurath AI.", "Al-wasatiyya al-shar'iyya as the measure for curating books, the role of AI and the teacher, and the adab of using OpenTurath AI.", "الوسطية الشرعية ميزانًا لانتقاء الكتب، ودور الذكاء الاصطناعي والمعلم، وآداب استعمال OpenTurath AI."), body, "pedoman.html")

# ======================= EKOSISTEM =======================
def page_eko():
    CHK = ic("check")
    lines = [
      ("big", mark(30), L("Rilis 26 Okt 2026", "Released 26 Oct 2026", "الإطلاق 26 أكتوبر 2026"), "OpenTurath AI",
       L("Teman membaca kitab. Anda bertanya, ia menjelaskan, lalu menunjukkan ibarah dan rujukannya dari kitab dan ceramah para ulama.", "A companion for reading books. You ask, it explains, then shows you the passage and its reference from the books and lectures of the scholars.", "رفيق في قراءة الكتب. تسأل فيشرح، ثم يريك العبارة ومرجعها من كتب العلماء ومحاضراتهم."),
       [L("AI per bidang, masing-masing dengan kitab, manhaj, dan kaidahnya","One AI per field, each with its own books and method","ذكاء اصطناعي لكل مجال، بكتبه ومنهجه"), L("Catatan, pustaka, dan banyak tab di Android, macOS, Windows","Notes, library, and multiple tabs on Android, macOS, Windows","ملاحظات ومكتبة وتبويبات متعددة على أندرويد وماك وويندوز"), L("Dimulai dari Fikih Tahawwulat, lalu meluas ke seluruh ilmu Islam","Starting with Fiqh al-Tahawwulat, then widening to all the Islamic sciences","تبدأ من فقه التحولات ثم تتسع لسائر العلوم الإسلامية")],
       L("Harapan kami, setiap jawaban berujung di kitab: Anda membaca penjelasannya, membuka ibarahnya, dan menutupnya dengan bertanya kepada guru. AI mempercepat jalan, bukan menggantikan perjalanan.", "Our hope is that every answer ends in the book: you read the explanation, open the passage, and finish by asking a teacher. AI shortens the road; it does not replace the journey.", "نرجو أن تنتهي كل إجابة في الكتاب: تقرأ الشرح، وتفتح العبارة، وتختم بسؤال المعلم. الذكاء الاصطناعي يختصر الطريق ولا يغني عن الرحلة.")),
      ("", ic("library"), L("Dibangun", "In the making", "قيد البناء"), L("Maktabah OpenTurath", "OpenTurath Library", "مكتبة OpenTurath"),
       L("Pusat unduh kitab yang menyatukan banyak sumber unduh dan semua cetakan dalam satu halaman.", "A book download hub that brings many download sources and every edition onto one page.", "مركز لتحميل الكتب يجمع مصادر التحميل الكثيرة وكل الطبعات في صفحة واحدة."),
       [L("Satu kitab, semua cetakannya berdampingan","One book, all its editions side by side","كتاب واحد وكل طبعاته جنبًا إلى جنب"), L("Tombol unduh dari berbagai sumber","Download buttons from different sources","أزرار تحميل من مصادر متعددة"), L("Tersambung ke OpenTurath AI","Connected to OpenTurath AI","متصل بـ OpenTurath AI")],
       L("Nantinya, Anda tidak perlu lagi berkeliling mencari kitab. Cukup satu tempat untuk menemukan cetakan yang tepat, lalu membukanya dari rujukan yang disebut AI.", "In time, you will no longer need to wander around looking for a book. One place is enough to find the right edition and open it from the reference the AI names.", "وفي المستقبل لن تحتاج إلى الدوران بحثًا عن الكتاب، بل يكفيك مكان واحد لتجد الطبعة المناسبة وتفتحها من المرجع الذي يذكره الذكاء الاصطناعي.")),
      ("", ic("scroll"), L("Segera hadir", "Coming soon", "قريبًا"), L("AI Manuskrip", "Manuscript AI", "ذكاء المخطوطات"),
       L("Menuliskan ulang naskah Arab kuno menjadi teks digital yang bisa dicari dan disunting, lalu merapikannya bila diminta.", "Rewrites old Arabic manuscripts as searchable, editable digital text, and tidies the layout on request.", "يعيد كتابة المخطوطات العربية القديمة نصًّا رقميًّا قابلًا للبحث والتحرير، وينسّقه عند الطلب."),
       [L("Menyalin naskah apa adanya","Copies the manuscript as it is","ينسخ المخطوط كما هو"), L("Menandai bagian yang tidak terbaca","Marks what cannot be read","يعلّم المواضع غير المقروءة"), L("Merapikan tata letak","Tidies the layout","ينسّق الصفحات")],
       L("Peneliti dapat menghemat jam-jam pertama yang paling melelahkan, sementara tahqiq dan pemeriksaan isi tetap di tangan pemilik naskah yang berilmu.", "Researchers can save the first and most tiring hours, while critical editing and checking the content stay in the hands of the knowledgeable owner of the manuscript.", "يوفّر الباحث الساعات الأولى المرهقة، ويبقى التحقيق والتثبّت من المضمون بيد صاحب المخطوط من أهل العلم.")),
      ("", ic("cap"), L("Rencana", "Planned", "مخطَّط"), L("Daurah OpenTurath", "OpenTurath Daurah", "دورات OpenTurath"),
       L("Daurah memakai AI dengan benar bagi penuntut ilmu, dalam empat tahap.", "Daurah on using AI well, for seekers of knowledge, in four stages.", "دورة في استعمال الذكاء الاصطناعي بصورة صحيحة لطلاب العلم، في أربع مراحل."),
       [L("Bercakap dengan AI","Conversing with AI","المحادثة مع الذكاء الاصطناعي"), L("Gambar dan video dakwah","Images and video for da'wa","الصور والمقاطع للدعوة"), L("Membuat aplikasi sendiri","Building your own apps","بناء تطبيقاتك"), L("Membuat AI agent","Building AI agents","بناء وكلاء الذكاء الاصطناعي")],
       L("Kami berharap penuntut ilmu tidak hanya memakai teknologi, tetapi mampu membuat alat yang ia butuhkan untuk berkhidmah kepada ilmu.", "We hope seekers of knowledge will not only use technology but can build the tools they need to serve knowledge.", "ونرجو ألا يكتفي طالب العلم باستعمال التقنية، بل يقدر على صنع الأدوات التي يحتاجها لخدمة العلم.")),
    ]
    cards = ""
    LBL = [L("Yang kami harapkan","What we hope for","ما نرجوه"), L("Gambaran ke depan","The picture ahead","الصورة المأمولة"), L("Manfaat yang dituju","The benefit we aim for","الفائدة المقصودة"), L("Hasil yang diharapkan","The outcome we hope for","الثمرة المرجوة")]
    for k, (cls, icon, st, t, d, pts, ideal) in enumerate(lines):
        lbl = LBL[k]
        li = "".join(f"<li>{CHK}<span>{p}</span></li>" for p in pts)
        cards += (f'<article class="eline {cls} rv d{k % 3}"><div class="top"><div class="eic">{icon}</div><span class="status">{st}</span></div>'
                  f'<h3>{t}</h3><p class="ed">{d}</p><ul>{li}</ul><div class="ideal"><b>{lbl}</b><p>{ideal}</p></div></article>')
    flow = [
      (L("Belajar","Learn","التعلّم"), L("Daurah mengajarkan cara bertanya dan memeriksa dengan benar.","The Daurah teaches how to ask and check properly.","تعلّمك الدورات كيف تسأل وتتحقق كما ينبغي.")),
      (L("Membaca dan bertanya","Read and ask","القراءة والسؤال"), L("OpenTurath AI menjelaskan, lalu menunjukkan ibarah dan rujukannya.","OpenTurath AI explains, then shows the passage and its reference.","يشرح OpenTurath AI ثم يريك العبارة ومرجعها.")),
      (L("Menemukan kitabnya","Find the book","العثور على الكتاب"), L("Maktabah mengantar Anda ke cetakan yang tepat.","The Library takes you to the right edition.","توصلك المكتبة إلى الطبعة المناسبة.")),
      (L("Menuliskan naskah","Rewrite the manuscript","إعادة كتابة المخطوط"), L("AI Manuskrip menuliskan ulang naskah yang sulit dibaca.","Manuscript AI rewrites manuscripts that are hard to read.","يعيد ذكاء المخطوطات كتابة المخطوطات العسيرة القراءة.")),
    ]
    steps = "".join(f'<li class="rv d{i}"><span class="num">0{i+1}</span><h3>{t}</h3><p>{d}</p></li>' for i, (t, d) in enumerate(flow))
    body = (head(L("Ekosistem", "Ecosystem", "المنظومة"), L("OpenTurath lebih dari satu aplikasi.", "OpenTurath is more than one app.", "OpenTurath أكثر من تطبيق."), L("Cita-citanya satu: menjadi rumah baru bagi seluruh penuntut ilmu. Empat lini ini disusun supaya saling menguatkan.", "One aim: to be a new home for all seekers of knowledge. These four lines are built to strengthen each other.", "غاية واحدة: أن يكون بيتًا جديدًا لكل طلاب العلم. وقد صُمّمت هذه الخطوط الأربعة ليقوّي بعضها بعضًا.")) +
            sec(f'<div class="bento">{cards}</div>') +
            sec(shead(L("Saat bekerja bersama", "Working together", "حين تعمل معًا"), L("Perjalanan satu penuntut ilmu.", "One seeker's journey.", "رحلة طالب علم واحد."), L("Ini gambaran yang kami tuju. Sebagian lini masih dibangun, jadi urutan ini adalah arah, bukan layanan yang sudah seluruhnya tersedia.", "This is the picture we are aiming for. Some lines are still being built, so this sequence is a direction, not a fully available service.", "هذه الصورة التي نقصدها. وبعض الخطوط ما زال قيد البناء، فهذا الترتيب اتجاه لا خدمة مكتملة.")) + f'<ol class="journey">{steps}</ol>', "sec band") +
            sec(f'<div class="statement" style="margin-top:0"><div><p>{L("Mulai dari yang sudah ada hari ini.","Start with what is here today.","ابدأ بما هو متاح اليوم.")}</p></div><div><p class="small">{L("OpenTurath AI sudah dapat diunduh. Lini lain akan diumumkan di sini ketika siap.","OpenTurath AI can already be downloaded. The other lines will be announced here when ready.","يمكن تحميل OpenTurath AI الآن. وستُعلن الخطوط الأخرى هنا حين تجهز.")}</p><a class="btn inv-o sm" href="unduh.html">{L("Unduh OpenTurath AI","Download OpenTurath AI","حمّل OpenTurath AI")}</a></div></div>', "sec-tight"))
    write("ekosistem.html", L("Ekosistem: OpenTurath", "Ecosystem: OpenTurath", "المنظومة: OpenTurath"),
          L("OpenTurath lebih besar dari satu aplikasi: OpenTurath AI, Maktabah OpenTurath, AI Manuskrip, dan Daurah OpenTurath.", "OpenTurath is bigger than one app: OpenTurath AI, OpenTurath Library, Manuscript AI, and OpenTurath Daurah.", "OpenTurath أكبر من تطبيق واحد: OpenTurath AI ومكتبة OpenTurath وذكاء المخطوطات ودورات OpenTurath."), body, "ekosistem.html")

# ======================= TENTANG =======================
def page_tentang():
    tl = [("2023", L("Gagasan lahir","The idea is born","وُلدت الفكرة"), L("Saat AI mulai populer, muncul pertanyaan: bagaimana jika AI dapat menyebut rujukan dengan sangat akurat dan terhubung ke maktabah?","As AI became popular, a question arose: what if AI could cite references accurately and connect to the library?","حين شاع الذكاء الاصطناعي نشأ سؤال: ماذا لو استطاع أن يذكر المراجع بدقة بالغة ويتصل بالمكتبة؟")),
          (L("2023 sampai 2026","2023 to 2026","من 2023 إلى 2026"), L("Belajar dan membangun","Learning and building","التعلّم والبناء"), L("Tiga tahun mendalami AI dan cara membuat aplikasi, sampai alatnya cukup matang untuk dirilis.","Three years studying AI and how to build apps, until the tool was mature enough to release.","ثلاث سنوات في التعمق في الذكاء الاصطناعي وبناء التطبيقات حتى نضجت الأداة بما يكفي للإطلاق.")),
          (L("7 Mei 2026","7 May 2026","7 مايو 2026"), L("Diumumkan di Hadramaut","Announced in Hadramawt","الإعلان في حضرموت"), L("Di Universitas Al-Wasatiyah, Hadramaut, Yaman, di hadapan para ulama. Di sinilah visi OpenTurath dipaparkan untuk pertama kalinya.","At Al-Wasatiyah University, Hadramawt, Yemen, before scholars. The vision of OpenTurath was first presented here.","في جامعة الوسطية بحضرموت باليمن بحضور العلماء، وفيها عُرضت رؤية OpenTurath لأول مرة.")),
          (L("26 Oktober 2026","26 October 2026","26 أكتوبر 2026"), L("Rilis publik perdana","First public release","الإطلاق العام الأول"), L("OpenTurath AI dibuka untuk publik.","OpenTurath AI opens to the public.","يُفتح OpenTurath AI للجمهور."))]
    tlh = "".join(f'<div class="rv"><div class="d">{d}</div><div><h3 style="font-size:24px;margin-bottom:6px">{t}</h3><p>{x}</p></div></div>' for d, t, x in tl)
    vals = [(L("Kembali kepada sumber","Back to the source","الرجوع إلى المصدر"), L("Setiap jawaban berpijak pada kitab dan ceramah ulama.","Every answer rests on the books and lectures of the scholars.","كل إجابة تستند إلى كتب العلماء ومحاضراتهم.")), (L("Kembali berguru","Back to the teacher","الرجوع إلى المعلم"), L("AI hanyalah alat, dan tidak menggantikan guru.","AI is only a tool and does not replace a teacher.","الذكاء الاصطناعي أداة فقط ولا يحل محل المعلم.")),
            (L("Amanah","Trustworthiness","الأمانة"), L("Menjaga ketepatan ibarah dan jujur tentang batas.","Keeping passages accurate and honest about limits.","حفظ دقة العبارات والصدق في بيان الحدود.")), (L("Wasathiyyah syar'iyyah","Al-wasatiyya al-shar'iyya","الوسطية الشرعية"), L("Pemilihan kitab yang tidak berlebihan dan tidak meremehkan.","Curation without excess or neglect.","انتقاء لا إفراط فيه ولا تفريط.")),
            (L("Metodologi tiap ilmu dijaga","Each discipline's method is kept","منهج كل علم محفوظ"), L("Fikih dan hadis punya metodenya masing-masing.","Fiqh and hadith each have their own method.","للفقه والحديث منهجه الخاص لكل منهما.")), (L("Sarana baru, esensi terjaga","New means, essence preserved","وسائل جديدة، وجوهر محفوظ"), L("Memperbarui cara belajar tanpa merusak inti ajaran.","Renewing how we learn without damaging the core of the teaching.","تجديد طريقة التعلّم دون المساس بجوهر التعليم."))]
    vh = "".join(f'<div class="pillar rv"><h3 style="font-size:22px">{t}</h3><p>{d}</p></div>' for t, d in vals)
    body = (head(L("Tentang", "About", "عن OpenTurath"), L("Dibuat oleh pelajar, untuk para pelajar.", "Made by a student, for students.", "من طالب علم، لطلاب العلم."), L("OpenTurath adalah AI Islami berbasis turath: setiap jawabannya berpijak pada kitab dan ceramah para ulama.", "OpenTurath is an Islamic AI grounded in turath: every answer rests on the books and lectures of the scholars.", "OpenTurath ذكاء اصطناعي إسلامي قائم على التراث: كل إجابة فيه تستند إلى كتب العلماء ومحاضراتهم.")) +
            sec(f'''<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">{L("Awal ceritanya.","How it began.","كيف بدأ الأمر.")}</h2><span class="pill">{L("Sang perintis","The founder","المؤسس")}</span></div><div class="rv d1">
<p class="lead" style="margin-bottom:18px">{L("Sang perintis adalah seorang santri yang berguru kepada para ulama. Saat murajaah seorang diri, ia membaca salah satu kitab terbesar Fikih Tahawwulat dan menerjemahkannya kata demi kata. Satu halaman menghabiskan sekitar satu jam, dan ia tetap belum paham.","The founder is a student who studied under scholars. Reviewing alone, he read one of the largest books of Fiqh al-Tahawwulat and translated it word by word. One page took about an hour, and he still did not understand.","المؤسس طالب علم تلقّى عن العلماء. وبينما كان يراجع وحده قرأ أحد أكبر كتب فقه التحولات وترجمه كلمة كلمة. استغرقت الصفحة نحو ساعة، ولم يفهمها بعد.")}</p>
<p style="margin-bottom:16px">{L("Dari kesulitan itu lahir satu pertanyaan: bagaimana memudahkan penuntut ilmu menerjemahkan dan memahami kitab-kitab Fikih Tahawwulat, terutama istilah-istilahnya? Jawabannya ia cari lewat teknologi, dengan satu syarat: setiap jawaban harus punya rujukan.","From that difficulty came a question: how can we make it easier for seekers of knowledge to translate and understand the books of Fiqh al-Tahawwulat, especially its terms? He looked for the answer in technology, on one condition: every answer must have a reference.","ومن تلك الصعوبة وُلد سؤال: كيف نيسّر على طالب العلم ترجمة كتب فقه التحولات وفهمها، ولا سيما مصطلحاتها؟ فطلب الجواب في التقنية بشرط واحد: أن يكون لكل إجابة مرجع.")}</p>
<p>{L("OpenTurath dikerjakan seorang diri, dengan para ulama yang memeriksa isi keilmuannya. Kini sang perintis menempuh pendidikan pascasarjana di Yaman.","OpenTurath is built by one person, with scholars reviewing its content. The founder is now a postgraduate student in Yemen.","يبنيه شخص واحد، ويراجع العلماء محتواه العلمي. والمؤسس الآن طالب دراسات عليا في اليمن.")}</p></div></div>''') +
            philosophy_sec() +
            sec(shead(L("Tonggak", "Milestones", "محطات"), L("Dari satu gagasan sampai rilis perdana.", "From one idea to the first release.", "من فكرة واحدة إلى الإطلاق الأول.")) + f'<div class="timeline">{tlh}</div>') +
            sec(shead(L("Nilai", "Values", "القيم"), L("Nilai yang kami pegang.", "The values we hold to.", "القيم التي نلتزم بها.")) + f'<div class="pillars three">{vh}</div>') +
            sec(f'<div class="statement" style="margin-top:0"><div><p>{L("Bicara dengan kami.","Talk to us.","تحدّث إلينا.")}</p></div><div class="stk"><a class="btn inv-o sm" href="bantuan.html">{L("Bantuan","Help","المساعدة")}</a><div class="cpills">{contact_pills()}</div></div></div>', "sec-tight"))
    write("tentang.html", L("Tentang: OpenTurath", "About: OpenTurath", "عن OpenTurath"),
          L("Cerita OpenTurath: dirintis seorang santri yang kesulitan memahami kitab, lalu mencari jalan agar penuntut ilmu lain tidak mengalaminya.", "The story of OpenTurath: started by a student who struggled to understand the books and looked for a way to spare other seekers of knowledge.", "قصة OpenTurath: أسسه طالب علم صعب عليه فهم الكتب، فبحث عن طريق يعفي غيره من طلاب العلم من هذه الصعوبة."), body, "tentang.html")

# ======================= UNDUH =======================
def page_unduh():
    def plat(osid, icn, name, req, steps_, href, cta, dl=False, meta_info="", badge=""):
        li = "".join(f"<li>{s}</li>" for s in steps_)
        dl_attr = ' download' if dl else ''
        meta_html = f'<p class="fine-print" style="margin-top:12px;font-size:12px;opacity:0.8">{meta_info}</p>' if meta_info else ''
        return (f'<div class="plat" id="{osid}" data-os="{osid}"><div class="plat-top">{badge}<span class="status rec-badge" hidden>{L("Untuk perangkat Anda","For your device","لجهازك")}</span></div><h3>{name}</h3><p class="req">{req}</p>'
                f'<ul class="list-clean small-li">{li}</ul><a class="btn primary" href="{href}"{dl_attr}>{ic("download")}{cta}</a>{meta_html}</div>')
    body = (head(L("Unduh", "Download", "تحميل"), L("Mulai belajar hari ini.", "Start learning today.", "ابدأ التعلّم اليوم."), L("OpenTurath AI tersedia untuk ponsel dan komputer. Masuk dengan akun Google, lalu pilih bidang pertama Anda.", "OpenTurath AI is available for phone and computer. Sign in with a Google account, then pick your first field.", "OpenTurath AI متاح للهاتف والحاسوب. سجّل الدخول بحساب Google ثم اختر مجالك الأول.")) +
            sec(f'''<div class="platforms rv">{plat("android","android","Android",L("Android 8.0 ke atas","Android 8.0 or later","أندرويد 8.0 فأعلى"),[L("Unduh berkas pemasangan APK.","Download the APK install file.","نزّل ملف تثبيت APK."),L("Izinkan pemasangan dari sumber ini bila diminta.","Allow installing from this source if asked.","اسمح بالتثبيت من هذا المصدر إن طُلب منك."),L("Bila muncul peringatan Google Play Protect (<b>Pemindaian aplikasi disarankan</b>), pilih <b>Instal tanpa memindai</b>. Di sebagian ponsel tulisannya <b>Install anyway</b>.","If a Google Play Protect warning appears (<b>App scan recommended</b>), choose <b>Install without scanning</b>. On some phones it reads <b>Install anyway</b>.","إن ظهر تحذير Google Play Protect (<b>يوصى بفحص التطبيق</b>) فاختر <b>التثبيت دون فحص</b>. وفي بعض الهواتف يظهر <b>Install anyway</b>."),L("Buka aplikasi dan masuk.","Open the app and sign in.","افتح التطبيق وسجّل الدخول.")], href="/openturath.apk", cta=L("Unduh APK (27 MB)","Download APK (27 MB)","تحميل APK (27 ميغابايت)"), dl=True, meta_info=L("Versi rilis 1.0.85 (build 86) · APK resmi langsung","Release version 1.0.85 (build 86) · Official direct APK","الإصدار 1.0.85 (بناء 86) · ملف APK الرسمي المباشر"))}
{plat("macos","laptop","macOS",L("macOS 13 ke atas","macOS 13 or later","macOS 13 فأعلى"),[L("Unduh berkas pemasangan DMG.","Download the DMG install file.","نزّل ملف تثبيت DMG."),L("Seret aplikasi ke folder Aplikasi.","Drag the app into the Applications folder.","اسحب التطبيق إلى مجلد التطبيقات."),L("Saat pertama dibuka, macOS meminta kata sandi untuk <b>Keychain</b>. Isi kata sandi (PIN) login Mac Anda, lalu pilih <b>Always Allow</b> (Selalu Izinkan).","The first time you open it, macOS asks for your <b>Keychain</b> password. Enter your Mac login password (PIN), then choose <b>Always Allow</b>.","عند الفتح لأول مرة يطلب macOS كلمة مرور <b>سلسلة المفاتيح</b>. أدخل كلمة مرور الدخول إلى جهازك ثم اختر <b>Always Allow</b> (السماح دائمًا)."),L("Buka dan masuk.","Open it and sign in.","افتحه وسجّل الدخول.")], href="/openturath.dmg", cta=L("Unduh DMG (49 MB)","Download DMG (49 MB)","تحميل DMG (49 ميغابايت)"), dl=True, meta_info=L("Versi rilis 1.0.85 (build 86) · Berkas pemasangan macOS resmi","Release version 1.0.85 (build 86) · Official macOS installer","الإصدار 1.0.85 (بناء 86) · مثبت نظام ماك الرسمي"))}
{plat("windows","windows","Windows",L("Windows 10 ke atas (x64 / ARM64)","Windows 10 or later (x64 / ARM64)","Windows 10 فأعلى (x64 / ARM64)"),[L("Unduh berkas pemasangan (Setup.exe).","Download the installer (Setup.exe).","نزّل مثبت التطبيق (Setup.exe)."),L("Buka penginstal, lalu ikuti langkah pemasangan.","Open the installer and follow the setup steps.","افتح المثبّت واتّبع خطوات التثبيت."),L("Masuk dengan akun Google.","Sign in with a Google account.","سجّل الدخول بحساب Google.")], href="/OpenTurath_AI_Windows_Setup.exe", cta=L("Unduh Penginstal (18 MB)","Download Installer (18 MB)","تحميل المثبّت (18 ميغابايت)"), dl=True, meta_info=L("Versi rilis 1.0.85 (build 86) · Penginstal resmi Windows (x64 & ARM64)","Release version 1.0.85 (build 86) · Official Windows installer (x64 & ARM64)","الإصدار 1.0.85 (بناء 86) · مثبت نظام ويندوز الرسمي"))}</div>
<div class="access"><span>{L("Masuk dengan akun Google","Sign in with a Google account","الدخول بحساب Google")}</span><span>{L("Akses per modul bidang","Access per field module","الوصول لكل وحدة مجال")}</span><span>{L("Perpanjangan manual, tanpa auto-debit","Manual renewal, no auto-debit","تجديد يدوي دون خصم تلقائي")}</span></div>''', "sec-tight") +
            sec(shead(L("Setelah memasang", "After installing", "بعد التثبيت"), L("Tiga langkah pertama.", "Your first three steps.", "خطواتك الثلاث الأولى.")) + f'<div class="steps6 three"><div class="rv"><div class="n">01</div><h3>{L("Masuk","Sign in","سجّل الدخول")}</h3><p>{L("Gunakan akun Google Anda. Akun yang sama berlaku di semua perangkat.","Use your Google account. The same account works on every device.","استعمل حساب Google. الحساب نفسه يعمل على كل الأجهزة.")}</p></div><div class="rv d1"><div class="n">02</div><h3>{L("Pilih bidang","Pick a field","اختر المجال")}</h3><p>{L("Mulailah dari bidang yang sedang Anda pelajari, atau dari pengantar Fikih Tahawwulat.","Start from the field you are studying, or from the Fiqh al-Tahawwulat introduction.","ابدأ من المجال الذي تدرسه، أو من مدخل فقه التحولات.")}</p></div><div class="rv d2"><div class="n">03</div><h3>{L("Bertanya","Ask","اسأل")}</h3><p>{L("Tulis pertanyaan dengan bahasa sehari-hari, lalu buka kitab yang dirujuk.","Write your question in everyday language, then open the book it cites.","اكتب سؤالك بلغتك المعتادة ثم افتح الكتاب المحال إليه.")}</p></div></div>'))
    write("unduh.html", L("Unduh: OpenTurath", "Download: OpenTurath", "تحميل: OpenTurath"), L("Unduh OpenTurath AI untuk Android, macOS, dan Windows.", "Download OpenTurath AI for Android, macOS, and Windows.", "حمّل OpenTurath AI لأندرويد وماك وويندوز."), body, "")

# ======================= BANTUAN =======================
def page_bantuan():
    more = FAQ_MAIN() + [
        (L("Mengapa macOS meminta kata sandi Keychain?", "Why does macOS ask for my Keychain password?", "لماذا يطلب macOS كلمة مرور سلسلة المفاتيح؟"), L("OpenTurath menyimpan sesi masuk Anda dengan aman di Keychain, supaya Anda tidak perlu masuk berulang. Isi kata sandi login Mac Anda dan pilih Always Allow; setelah itu pertanyaan ini tidak muncul lagi.", "OpenTurath stores your sign-in session securely in the Keychain so you do not have to sign in again and again. Enter your Mac login password and choose Always Allow; the prompt will not return.", "يحفظ OpenTurath جلسة دخولك بأمان في سلسلة المفاتيح حتى لا تعيد الدخول كل مرة. أدخل كلمة مرور الدخول إلى جهازك واختر Always Allow ولن يظهر الطلب مجددًا.")),
        (L("Mengapa Android menampilkan peringatan Play Protect?", "Why does Android show a Play Protect warning?", "لماذا يعرض أندرويد تحذير Play Protect؟"), L("Aplikasi dipasang dari berkas, bukan dari toko aplikasi, dan Play Protect belum pernah memindainya. Pilih Instal tanpa memindai (atau Install anyway) untuk melanjutkan. Anda juga bisa memilih Pindai aplikasi bila ingin Google memeriksanya dulu.", "The app is installed from a file, not from an app store, and Play Protect has not scanned it before. Choose Install without scanning (or Install anyway) to continue. You can also choose Scan app if you want Google to check it first.", "يُثبَّت التطبيق من ملف لا من متجر، ولم يفحصه Play Protect من قبل. اختر التثبيت دون فحص (أو Install anyway) للمتابعة. ويمكنك اختيار فحص التطبيق إن أردت أن تفحصه Google أولًا.")),

        (L("Berapa percakapan yang bisa dibuka bersamaan?", "How many conversations can I open at once?", "كم محادثة يمكن فتحها معًا؟"), L("Lima tab di macOS dan tiga tab di perangkat lain.", "Five tabs on macOS and three on other devices.", "خمس تبويبات على ماك وثلاث على الأجهزة الأخرى.")),
        (L("Di mana catatan saya disimpan?", "Where are my notes kept?", "أين تُحفظ ملاحظاتي؟"), L("Catatan menyimpan jawaban beserta kutipan Arab, kitab, dan halamannya, sehingga tetap bisa ditelusuri. Rinciannya ada di kebijakan privasi.", "Notes keep the answer with its Arabic passage, book, and page, so it stays traceable. Details are in the privacy policy.", "تحفظ الملاحظات الإجابة مع العبارة العربية والكتاب والصفحة لتبقى قابلة للتتبّع. وتفاصيله في سياسة الخصوصية."))]
    leg = "".join(f'<li><a class="link" href="{u}">{t}</a></li>' for u, t in legal_links())
    f = (L("Bidang atau AI", "Field or AI", "المجال أو الذكاء الاصطناعي"), L("Contoh: AI Fikih Syafi'i", "For example: AI Shafi'i Fiqh", "مثال: AI الفقه الشافعي"), L("Kutipan yang dipertanyakan", "The quotation in question", "العبارة موضع السؤال"), L("Kitab dan edisi yang Anda pegang", "Book and edition you hold", "الكتاب والطبعة التي بين يديك"), L("Judul, penerbit, jilid, halaman", "Title, publisher, volume, page", "العنوان والناشر والجزء والصفحة"), L("Alasan", "Your reason", "السبب"), L("Kirim lewat surel", "Send by email", "أرسل بالبريد"))
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
from legal_plus import PLUS
def plus(doc, base, numbered=True):
    return [((f'{len(base)+i+1}. ' if numbered else '') + t, c) for i, (t, c) in enumerate(PLUS[doc][LANG])]
def app_secs(key): return LEGAL["app"][LANG][key]
def site_secs(slug): return LEGAL["site"][LANG].get(slug, {}).get("sections", [])
def legal_page(fname, kick, title, lead, secs, desc):
    toc = "".join(f'<a href="#s{i+1}">{E(t)}</a>' for i, (t, c) in enumerate(secs))
    arts = "".join(f'<section id="s{i+1}"><h2>{E(t)}</h2>{md_html(c)}</section>' for i, (t, c) in enumerate(secs))
    date = L("26 Oktober 2026", "26 October 2026", "26 أكتوبر 2026")
    meta = (f'<div class="legal-meta"><b>{L("Versi","Version","الإصدار")} 1.1</b> · {L("diperbarui","updated","حُدّثت في")} {date}. '
            f'{L("OpenTurath adalah layanan mandiri dan memanfaatkan teknologi Google. Tidak berafiliasi dengan, didukung oleh, atau disahkan oleh Google.","OpenTurath is an independent service and uses Google technology. It is not affiliated with, supported by, or endorsed by Google.","OpenTurath خدمة مستقلة تستفيد من تقنية Google، وليست تابعة لـ Google ولا مدعومة منها ولا معتمدة لديها.")} '
            f'{L("Pertanyaan tentang dokumen ini dapat dikirim ke","Questions about this document can be sent to","يمكن إرسال الأسئلة عن هذه الوثيقة إلى")} <a href="mailto:support@openturath.id"><bdi class="ltr">support@openturath.id</bdi></a>.</div>')
    end = (f'<div class="legal-end"><a class="btn tonal" href="bantuan.html">{L("Kembali ke bantuan","Back to help","العودة إلى المساعدة")}</a>'
           f'<a class="btn tonal" href="bantuan.html#lapor">{L("Laporkan masalah","Report a problem","الإبلاغ عن مشكلة")}</a></div>')
    body = (head(kick, title, lead) +
            sec(f'<div class="legal"><nav class="toc" aria-label="{L("Isi dokumen","Contents","محتويات الوثيقة")}">{toc}</nav><article>{meta}{arts}{end}</article></div>', "sec-tight"))
    write(fname, f"{title}: OpenTurath", desc, body, "")

def page_panduan():
    g = app_secs("guideline"); intro = g[0]["content"].split("\n")[0]
    steps = [
      (L("Baca jawabannya","Read the answer","اقرأ الجواب"), L("Anggap sebagai penjelasan awal, bukan putusan.","Treat it as a first explanation, not a ruling.","عدّه شرحًا أوليًا لا حكمًا.")),
      (L("Buka ibarahnya","Open the passage","افتح العبارة"), L("Baca teks Arabnya, termasuk kalimat sebelum dan sesudahnya.","Read the Arabic text, including the sentences before and after.","اقرأ النص العربي بما قبله وما بعده.")),
      (L("Cocokkan dengan kitab","Match with the book","طابقها بالكتاب"), L("Periksa pada edisi yang Anda pegang. Nomor halaman bisa berbeda.","Check it in the edition you hold. Page numbers may differ.","تحقق منها في الطبعة التي بين يديك. فقد تختلف أرقام الصفحات.")),
      (L("Tanyakan kepada guru","Ask a teacher","اسأل المعلم"), L("Terutama untuk amal, fatwa, dan perkara yang berakibat nyata.","Especially for practice, fatwa, and matters with real consequences.","خاصة في العمل والفتوى والأمور ذات الأثر الفعلي.")),
    ]
    st = "".join(f'<li class="rv d{i}"><div class="num">0{i+1}</div><h3>{t}</h3><p>{d}</p></li>' for i, (t, d) in enumerate(steps))
    cards = ""
    for i, x in enumerate(g[1:]):
        t = re.sub(r"^[^·]*·\s*", "", x["title"]).strip()
        cards += f'<div class="rv d{i % 2}"><div class="no">{i+1}</div><div class="ab"><h3>{E(t)}</h3>{md_html(x["content"])}</div></div>'
    lim = PLUS["panduan-ai"][LANG]
    items = "".join(f'<li>{ic("check")}<span><b>{E(t)}</b>{E(c.split(chr(10)+chr(10))[0])}</span></li>' for t, c in lim)
    body = (head(L("Panduan", "Guide", "دليل"), L("Memakai AI dengan adab.", "Using AI with adab.", "استعمال الذكاء الاصطناعي بأدب."), L("Delapan pegangan agar OpenTurath AI menolong Anda memahami kitab, tanpa menggeser guru dan tanpa mengurangi amanah ilmiah.", "Eight principles so OpenTurath AI helps you understand books without displacing the teacher or weakening scholarly trust.", "ثمانية مبادئ ليعينك OpenTurath AI على فهم الكتب دون أن يزاحم المعلم أو ينقص الأمانة العلمية.")) +
            sec(f'<p class="panduan-intro rv">{E(intro)}</p>', "sec-tight") +
            sec(shead(L("Sebelum memakai jawaban", "Before you use an answer", "قبل أن تعتمد الجواب"), L("Empat langkah singkat.", "Four short steps.", "أربع خطوات موجزة.")) + f'<ol class="steps4">{st}</ol>') +
            sec(shead(L("Delapan adab", "Eight principles of adab", "ثمانية آداب"), L("Pegangan setiap pengguna.", "A guide for every user.", "مرجع لكل مستخدم.")) + f'<div class="adab8">{cards}</div>', "sec band") +
            sec(f'<div class="answer rv"><div><p class="sublabel" style="color:inherit;opacity:.7">{L("Batas","Limits","الحدود")}</p><h3>{L("Di mana AI berhenti, di situ guru mulai.","Where the AI stops, the teacher begins.","حيث يقف الذكاء الاصطناعي يبدأ المعلم.")}</h3><p class="lead2">{L("Layanan ini membantu membaca dan menelusuri. Ia tidak berfatwa, dan tidak menggantikan majelis ilmu.","This service helps you read and trace. It does not issue fatwas and does not replace the circle of knowledge.","تعين هذه الخدمة على القراءة والتتبع. وهي لا تُفتي ولا تغني عن مجالس العلم.")}</p></div><ul>{items}</ul></div>') +
            sec(f'<div class="statement" style="margin-top:0"><div><p>{L("Menemukan kekeliruan? Beri tahu kami.","Found a mistake? Tell us.","وجدت خطأ؟ أخبرنا.")}</p></div><div><p class="small">{L("Sertakan kutipan, nama kitab, dan edisi yang Anda pegang agar mudah kami periksa.","Include the quotation, the book, and the edition you hold so we can check it easily.","أرفق العبارة واسم الكتاب والطبعة التي بين يديك ليسهل علينا فحصها.")}</p><a class="btn inv-o sm" href="bantuan.html#lapor">{L("Laporkan kesalahan","Report an error","الإبلاغ عن خطأ")}</a></div></div>', "sec-tight"))
    write("panduan-ai.html", L("Panduan penggunaan AI dan rujukan: OpenTurath", "Guide to using AI and references: OpenTurath", "دليل استعمال الذكاء الاصطناعي والمراجع: OpenTurath"),
          L("Delapan adab dan empat langkah memeriksa jawaban OpenTurath AI.", "Eight principles of adab and four steps to check an OpenTurath AI answer.", "ثمانية آداب وأربع خطوات للتحقق من إجابة OpenTurath AI."), body, "")

def page_legal_all():
    K = L("Kebijakan", "Policies", "السياسات")
    legal_page("ketentuan.html", K, L("Ketentuan Layanan", "Terms of Service", "شروط الخدمة"),
               L("Aturan memakai akun, AI, katalog rujukan, Catatan, dan fitur berbayar OpenTurath.", "The rules for using OpenTurath accounts, AIs, reference catalogs, Notes, and paid features.", "قواعد استعمال حسابات OpenTurath ومساعدات الذكاء الاصطناعي وفهارس المراجع والملاحظات والميزات المدفوعة."),
               [(x["title"], x["content"]) for x in app_secs("terms")] + plus("ketentuan", app_secs("terms")), L("Ketentuan layanan OpenTurath.", "OpenTurath terms of service.", "شروط خدمة OpenTurath."))
    legal_page("privasi.html", K, L("Kebijakan Privasi", "Privacy Policy", "سياسة الخصوصية"),
               L("Data apa yang kami proses, untuk apa, berapa lama disimpan, dan hak Anda atasnya.", "What data we process, why, how long we keep it, and your rights over it.", "ما البيانات التي نعالجها، ولماذا، ومدة حفظها، وحقوقك فيها."),
               [(x["title"], x["content"]) for x in app_secs("privacy")] + plus("privasi", app_secs("privacy")), L("Kebijakan privasi OpenTurath.", "OpenTurath privacy policy.", "سياسة خصوصية OpenTurath."))
    legal_page("pembayaran.html", K, L("Pembayaran dan Pengembalian Dana", "Payments and Refunds", "الدفع واسترداد المبالغ"),
               L("Informasi sebelum membeli, cara pembayaran dan aktivasi, perpanjangan manual, voucher, dan pengajuan refund.", "Information before you buy, how payment and activation work, manual renewal, vouchers, and refund requests.", "معلومات قبل الشراء، وكيفية الدفع والتفعيل، والتجديد اليدوي، والقسائم، وطلبات الاسترداد."),
               [(x["title"], x["content"]) for x in app_secs("refund")] + plus("pembayaran", app_secs("refund")), L("Pembayaran dan pengembalian dana OpenTurath.", "OpenTurath payments and refunds.", "الدفع واسترداد المبالغ في OpenTurath."))
    page_panduan()
    t, pv = app_secs("terms"), app_secs("privacy")
    legal_page("hak-cipta.html", K, L("Sumber dan Hak Cipta", "Sources and Copyright", "المصادر وحقوق النشر"),
               L("Siapa memiliki apa: aplikasi, kitab, dan catatan Anda, serta cara meminta koreksi atau pencabutan materi.", "Who owns what: the app, the books, and your notes, and how to ask for a correction or removal.", "من يملك ماذا: التطبيق والكتب وملاحظاتك، وكيف تطلب التصحيح أو الإزالة."),
               [(strip_no(t[8]["title"]), t[8]["content"])] + [(x["title"], x["content"]) for x in site_secs("sources-and-rights")] + plus("hak-cipta", [], False), L("Sumber dan hak cipta di OpenTurath.", "Sources and copyright at OpenTurath.", "المصادر وحقوق النشر في OpenTurath."))
    legal_page("hapus-akun.html", K, L("Penghapusan Akun dan Data", "Account and Data Deletion", "حذف الحساب والبيانات"),
               L("Cara menutup akun, data apa yang dihapus, dan apa yang disimpan sesuai ketentuan hukum.", "How to close your account, what is deleted, and what is kept under legal requirements.", "كيف تغلق حسابك، وما الذي يُحذف، وما الذي يُحفظ وفق الأحكام القانونية."),
               [(x["title"], x["content"]) for x in site_secs("account-deletion")] + [(strip_no(pv[8]["title"]), pv[8]["content"]), (strip_no(pv[10]["title"]), pv[10]["content"])], L("Penghapusan akun dan data OpenTurath.", "OpenTurath account and data deletion.", "حذف الحساب والبيانات في OpenTurath."))

def contact_block():
    cs = app_secs("contact")
    cards = "".join(f'<div class="rv"><h3>{E(strip_no(x["title"]))}</h3><div class="ctext">{md_html(x["content"])}</div></div>' for x in cs)
    cards += f'<div class="rv"><h3>{L("Media sosial","Social media","وسائل التواصل")}</h3><div class="ctext"><p class="cline">'+ic("instagram")+'<a href="'+IG+'" target="_blank" rel="noopener"><bdi class="ltr">@openturath.id</bdi></a></p></div></div>'
    return f'<div class="contact3">{cards}</div>'


# ======================= MENGENAL FIKIH TAHAWWULAT =======================
M_SECT = {
 "id": {"A": "Kegelisahan sehari-hari", "B": "Apa itu Fikih Tahawwulat?", "C": "Tempatnya dalam agama", "D": "Yang tetap dan yang berubah", "E": "Dua tugas rukun keempat", "F": "Dua tanda dan dua kendali",
        "G": "Tanda-tanda kiamat", "H": "Perjalanan zaman dan keadaan umat", "I": "Fitnah dan sikap yang selamat", "J": "Penerapan dalam hidup modern", "K": "Keraguan dan keberatan yang wajar", "L": "Cara belajar dan memakai AI"},
 "en": {"A": "Everyday unease", "B": "What is Fiqh al-Tahawwulat?", "C": "Its place in the religion", "D": "What stays and what changes", "E": "The two tasks of the fourth pillar", "F": "Two signs and two controls",
        "G": "Signs of the Hour", "H": "The journey of the ages and the state of the Ummah", "I": "Fitna and the safe way through", "J": "Living it in the modern world", "K": "Honest doubts and objections", "L": "How to study and use the AI"},
 "ar": {"A": "قلق الحياة اليومية", "B": "ما هو فقه التحولات؟", "C": "موضعه من الدين", "D": "الثوابت والمتغيرات", "E": "مهمتا الركن الرابع", "F": "علامتان وقراران",
        "G": "أشراط الساعة", "H": "مراحل الزمان وأحوال الأمة", "I": "الفتن ومنهج السلامة", "J": "التطبيق في الحياة المعاصرة", "K": "الشبهات والاعتراضات المشروعة", "L": "كيفية التعلّم واستعمال الذكاء الاصطناعي"},
}
def M_TRACKS(): return {
 1: (L("Orang awam", "General reader", "عامة القرّاء"), L("Ketenangan hati, jawaban atas kegelisahan, dan langkah amal nyata.", "Peace of heart, answers to everyday unease, and practical steps.", "طمأنينة القلب وأجوبة القلق وخطوات عملية.")),
 2: (L("Keluarga", "Family", "الأسرة"), L("Menjaga iman anak, adab media sosial, dan rumah yang rukun saat berbeda pendapat.", "Protecting children's faith, social-media adab, and a peaceful home when views differ.", "حفظ إيمان الأبناء وآداب وسائل التواصل وسكينة البيت عند الاختلاف.")),
 3: (L("Santri", "Student of knowledge", "طالب العلم"), L("Hadis Jibril, empat rukun agama, sanad, dan pembagian tanda kiamat.", "The Hadith of Jibril, the four pillars, chains of transmission, and the division of the signs.", "حديث جبريل وأركان الدين الأربعة والإسناد وأقسام الأشراط.")),
 4: (L("Mahasiswa dan akademisi", "Students and academics", "الطلبة والباحثون"), L("Cara membaca sejarah, sains dan AI, nash yang mendahului, dan keberatan kritis.", "How to read history, science and AI, forward-looking texts, and critical objections.", "قراءة التاريخ والعلم والذكاء الاصطناعي والنصوص الاستباقية والاعتراضات النقدية.")),
 5: (L("Pengajar dan dai", "Teachers and preachers", "المعلمون والدعاة"), L("Berdakwah dengan hikmah, memperbarui cara, dan meredam provokasi.", "Calling with wisdom, renewing the means, and calming provocation.", "الدعوة بالحكمة وتجديد الوسائل وتهدئة التحريش.")),
}
import modul as MOD
def page_mengenal():
    M = MOD.MODUL
    g = lambda t: t[LANG]
    h = M["head"]
    body = head(g(h["kicker"]), g(h["title"]), g(h["lead"]))
    # 1 pertanyaan
    q = M["q"]
    groups = "".join(f'<div class="qg rv"><h3>{E(g(t))}</h3><ul>' + "".join(f'<li>{E(g(x))}</li>' for x in qs) + '</ul></div>' for t, qs in q["groups"])
    body += sec(shead(g(q["kicker"]), g(q["title"]), g(q["lead"])) + f'<div class="qgroups">{groups}</div>')
    # 2 apa itu
    w = M["what"]; c = w["contrast"]
    pts = "".join(f'<div class="wp rv"><div class="n">0{i+1}</div><div><h3>{E(g(t))}</h3><p>{E(g(d))}</p></div></div>' for i, (t, d) in enumerate(w["points"]))
    body += sec(shead(g(w["kicker"]), g(w["title"]), g(w["lead"])) +
                f'<div class="contrast rv"><div><span>{E(g(c[0]))}</span><p>{E(g(c[1]))}</p></div><div class="on"><span>{E(g(c[2]))}</span><p>{E(g(c[3]))}</p></div></div>'
                f'<div class="whatgrid">{sculpt()}<div class="wpts">{pts}</div></div>')
    # 3 faedah
    bf = M["benefit"]
    cards = "".join(f'<div class="bcard rv"><div class="n">{i+1:02d}</div><h3>{E(g(t))}</h3><p>{E(g(d))}</p></div>' for i, (t, d) in enumerate(bf["items"]))
    body += sec(shead(g(bf["kicker"]), g(bf["title"]), g(bf["lead"])) + f'<div class="bgrid">{cards}</div>', "sec")
    # 4 cabang
    br = M["branch"]
    rows = ""
    for i, (t, d, qs) in enumerate(br["items"]):
        chips = "".join(f'<li>{E(g(x))}</li>' for x in qs)
        barn = ''
        rows += f'<div class="brow rv"><div class="n">{i+1}</div><div class="bt"><h3>{E(g(t))}</h3>{barn}<p>{E(g(d))}</p></div><div class="bq"><span>{L("Bisa menjawab","Can answer","يجيب عن")}</span><ul>{chips}</ul></div></div>'
    body += sec(shead(g(br["kicker"]), g(br["title"]), g(br["lead"])) + f'<div class="brows">{rows}</div>')
    # 5 beda
    d = M["diff"]
    c0, c1 = g(d["cols"][0]), g(d["cols"][1])
    vs = (f'<div class="vs rv"><div class="vs-h"><span></span><b>{E(c0)}</b><b class="on">{E(c1)}</b></div>' +
          "".join(f'<div class="vs-r"><span class="vs-l">{E(g(a))}</span><p data-t="{E(c0)}">{E(g(x))}</p><p class="on" data-t="{E(c1)}">{E(g(y))}</p></div>' for a, x, y in d["rows"]) + '</div>')
    uniq = "".join(f'<li>{ic("check")}<span>{E(g(u))}</span></li>' for u in d["unique"])
    body += sec(shead(g(d["kicker"]), g(d["title"]), g(d["lead"])) +
                vs)
    body += (f'<section class="sec band"><div class="wrap">{shead(L("Keunikan","Distinctive","التميّز"), g(d["unique_title"]))}<ul class="uniq rv">{uniq}</ul></div></section>')
    # 6 mulai
    s = M["start"]
    st = "".join(f'<li class="rv d{i}"><div class="num">0{i+1}</div><h3>{E(g(t))}</h3><p>{E(g(x))}</p></li>' for i, (t, x) in enumerate(s["steps"]))
    body += sec(shead(g(s["kicker"]), g(s["title"])) + f'<ol class="steps4">{st}</ol>'
                f'<div class="cta-row" style="margin-top:36px"><a class="btn primary" href="unduh.html">{ic("download")}{E(g(s["cta"]))}</a><a class="btn tonal" href="fikih-tahawwulat.html">{E(g(s["cta2"]))}</a><a class="btn tonal" href="perbandingan.html">{L("Lihat perbandingan AI","See the AI comparison","اطّلع على مقارنة الذكاءات")}</a></div>', "sec")
    write("mengenal-fikih-tahawwulat.html", L("Mengenal Fikih Tahawwulat: OpenTurath", "Getting to know Fiqh al-Tahawwulat: OpenTurath", "التعرّف على فقه التحولات: OpenTurath"),
          L("Panduan singkat untuk orang awam: pertanyaan yang dijawabnya, manfaat nyata, lima cabang ilmunya, dan bedanya dengan pembahasan akhir zaman yang beredar.", "A short guide for everyone: the questions it answers, real benefits, its five branches, and how it differs from circulating end-times talk.", "دليل موجز لعامة القرّاء: الأسئلة التي يجيب عنها، وفوائده الملموسة، وفروعه الخمسة، وبماذا يختلف عن حديث آخر الزمان المتداول."), body, "")

import compare as CMP
def page_perbandingan():
    q, runs = CMP.load()
    names = [r["name"] for r in runs]
    tabs = "".join(f'<button type="button" class="ctab" role="tab" data-c="{r["id"]}" aria-selected="{"true" if i == 0 else "false"}">{E(r["name"])}</button>' for i, r in enumerate(runs))
    panels = ""
    for i, r in enumerate(runs):
        panels += (f'<article class="cpanel" role="tabpanel" id="c-{r["id"]}" data-c="{r["id"]}">'
                   f'<header><h3>{E(r["name"])}</h3><span class="small">{L("Jawaban asli, tidak diubah", "Original answer, unchanged", "الجواب الأصلي دون تعديل")}</span></header>'
                   f'<div class="cbody">{CMP.md_full(r["text"])}</div></article>')
    body = head(L("Perbandingan", "Comparison", "المقارنة"), L("Satu pertanyaan, enam AI.", "One question, six AIs.", "سؤال واحد، وستة ذكاءات اصطناعية."),
                L("Pertanyaan fikih yang sama diajukan ke OpenTurath dan lima AI Islam lain. Jawaban asli ditampilkan apa adanya, tanpa diubah.", "The same fiqh question was put to OpenTurath and five other Islamic AIs. Each original answer is shown as it was, unchanged.", "طُرح سؤال فقهي واحد على OpenTurath وخمسة ذكاءات اصطناعية إسلامية أخرى. وتُعرض الإجابات الأصلية كما هي دون تعديل."))
    body += sec(f'<div class="qcard rv"><span class="tag">{L("Pertanyaan", "Question", "السؤال")}</span><p>{E(q)}</p></div>'
                f'<div class="cnote rv">{L("Hasil ini tidak mewakili seluruh kemampuan setiap produk, dan belum diperiksa oleh pemeriksa independen. Jawaban pembanding dipertahankan dalam bahasa aslinya (Indonesia).", "These results do not represent every product’s full ability and have not been checked by an independent reviewer. The answers are kept in their original language (Indonesian).", "لا تمثّل هذه النتائج كامل قدرات كل منتج، ولم يراجعها مراجع مستقل. وتبقى الإجابات بلغتها الأصلية (الإندونيسية).")}</div>', "sec-tight")
    body += sec(f'<div class="ctabs" role="tablist" aria-label="{L("Pilih jawaban", "Choose an answer", "اختر جوابًا")}">{tabs}</div>{panels}', "sec-tight")
    body += sec(f'<div class="cta-row"><a class="btn primary" href="unduh.html">{ic("download")}{L("Unduh aplikasi", "Download the app", "تحميل التطبيق")}</a><a class="btn tonal" href="panduan-ai.html">{L("Cara memeriksa kutipan", "How to check a quotation", "كيف تتحقق من النص")}</a></div>', "sec-tight")
    write("perbandingan.html", L("Perbandingan: OpenTurath", "Comparison: OpenTurath", "المقارنة: OpenTurath"),
          L("Satu pertanyaan fikih, enam AI: jawaban asli OpenTurath dan lima AI Islam lain, berdampingan.", "One fiqh question, six AIs: the original answers of OpenTurath and five other Islamic AIs, side by side.", "سؤال فقهي واحد وستة ذكاءات اصطناعية: الإجابات الأصلية لـ OpenTurath وخمسة غيره."), body, "")

# ======================= AI MANUSKRIP =======================
def page_manuskrip():
    do = [L("Menuliskan ulang naskah sebagaimana tampak, tanpa memperbaiki atau menebak isinya.", "Rewriting the manuscript as it appears, without correcting or guessing its content.", "إعادة كتابة المخطوط كما يظهر، دون تصحيح أو تخمين لمضمونه."),
          L("Menandai bagian yang tidak terbaca, bukan mengarangnya.", "Marking the parts that cannot be read, rather than inventing them.", "الإشارة إلى المواضع غير المقروءة بدل اختلاقها."),
          L("Merapikan tata letak bila Anda mau: paragraf, catatan pinggir, dan dokumen yang enak dibaca.", "Tidying the layout if you wish: paragraphs, marginal notes, and a document that reads well.", "تنسيق الصفحات إن شئت: الفقرات والحواشي ومستند مريح للقراءة.")]
    mine = [L("Tahqiq, muqabalah, dan pemeriksaan isi naskah.", "Critical editing, collation, and checking the content.", "التحقيق والمقابلة والتثبّت من مضمون النص."),
            L("Memastikan Anda berhak memproses naskah itu dan memutuskan penerbitannya.", "Making sure you have the right to process the manuscript and deciding on its publication.", "التأكد من أن لك حق معالجة المخطوط والبتّ في نشره.")]
    prices = [(L("Transkripsi naskah cetak", "Transcription, printed text", "نسخ النص المطبوع"), L("Rp 5.000", "Rp 5,000", "5.000 روبية"), L("per halaman standar", "per standard page", "للصفحة القياسية")),
              (L("Transkripsi tulisan tangan", "Transcription, handwriting", "نسخ الخط اليدوي"), L("Rp 7.500", "Rp 7,500", "7.500 روبية"), L("per halaman standar", "per standard page", "للصفحة القياسية")),
              (L("Formatting rapi (tambahan)", "Tidy formatting (optional)", "التنسيق (اختياري)"), L("Rp 3.000", "Rp 3,000", "3.000 روبية"), L("per halaman standar", "per standard page", "للصفحة القياسية"))]
    ph = "".join(f'<div class="pillar rv"><h3 style="font-size:22px">{t}</h3><p style="font-size:28px;margin:8px 0 2px"><b>{p}</b></p><p class="small">{u}</p></div>' for t, p, u in prices)
    fair = [L("Yang dihitung adalah kata pada teks hasil. Harakat tidak menambah hitungan, sehingga Anda dapat mencocokkannya sendiri dengan hitung kata di Word.", "What is counted is the words in the finished text. Diacritics add nothing to the count, so you can check it yourself with the word count in Word.", "المحسوب هو كلمات النص الناتج. والحركات لا تزيد العدد، فيمكنك مطابقته بنفسك بعدّاد الكلمات في وورد."),
            L("Nomor halaman, header, dan footer berulang tidak dihitung. Catatan pinggir dihitung.", "Page numbers and repeated headers and footers are not counted. Marginal notes are.", "لا تُحسب أرقام الصفحات ولا الترويسات والتذييلات المتكررة، وتُحسب الحواشي."),
            L("Halaman kosong, sampul, dan halaman tanpa teks tidak dihitung.", "Blank pages, covers, and pages without text are not counted.", "لا تُحسب الصفحات الفارغة والأغلفة والصفحات الخالية من النص."),
            L("Perkiraan harga dibuat dari tiga halaman contoh. Tagihan akhir mengikuti jumlah kata sebenarnya dan tidak melebihi perkiraan lebih dari 10%.", "The estimate is made from three sample pages. The final bill follows the actual word count and does not exceed the estimate by more than 10%.", "يُقدَّر السعر من ثلاث صفحات نموذجية. والفاتورة النهائية تتبع عدد الكلمات الفعلي ولا تتجاوز التقدير بأكثر من 10%."),
            L("Bagian yang tidak terbaca ditandai dan tidak ditagih.", "Parts that cannot be read are marked and not charged.", "المواضع غير المقروءة تُعلَّم ولا تُحاسَب."),
            L("Tiga halaman pertama gratis untuk dicoba.", "The first three pages are free to try.", "أول ثلاث صفحات مجانًا للتجربة."),
            L("Salah tulis dari pihak kami diperbaiki tanpa biaya.", "Our own transcription errors are fixed at no charge.", "الأخطاء الناشئة من جهتنا نصححها دون مقابل.")]
    calc = [L("Kitab 400 halaman, rata-rata 250 kata per halaman: 100.000 kata, yaitu 400 halaman standar.", "A 400-page book at 250 words a page on average: 100,000 words, i.e. 400 standard pages.", "كتاب من 400 صفحة بمتوسط 250 كلمة للصفحة: 100.000 كلمة، أي 400 صفحة قياسية."),
            L("Transkripsi naskah cetak: 400 × Rp 5.000 = Rp 2.000.000.", "Transcription of printed text: 400 × Rp 5,000 = Rp 2,000,000.", "نسخ النص المطبوع: 400 × 5.000 = 2.000.000 روبية."),
            L("Dengan formatting rapi: ditambah 400 × Rp 3.000 = Rp 1.200.000, jadi total Rp 3.200.000.", "With tidy formatting: add 400 × Rp 3,000 = Rp 1,200,000, for a total of Rp 3,200,000.", "مع التنسيق: تضاف 400 × 3.000 = 1.200.000، فيكون المجموع 3.200.000 روبية.")]
    li = lambda xs: "".join(f"<li>{x}</li>" for x in xs)
    st = [(L("Kirim contoh", "Send a sample", "أرسل نموذجًا"), L("Kirim tiga halaman dari naskah Anda lewat email atau Instagram.", "Send three pages of your manuscript by email or Instagram.", "أرسل ثلاث صفحات من مخطوطك بالبريد أو إنستغرام.")),
          (L("Terima perkiraan", "Get an estimate", "استلم التقدير"), L("Kami hitung rata-rata kata dan memberi perkiraan harga.", "We work out the average word count and give a price estimate.", "نحسب متوسط الكلمات ونعطيك تقدير السعر.")),
          (L("Naskah dikerjakan", "We do the work", "يُنجَز العمل"), L("Teks hasil dikirim kembali dalam berkas yang bisa Anda sunting.", "The finished text is returned in a file you can edit.", "يُرسل إليك النص الناتج في ملف قابل للتحرير."))]
    sh = "".join(f'<div class="rv d{i}"><div class="n">0{i+1}</div><h3>{t}</h3><p>{d}</p></div>' for i, (t, d) in enumerate(st))
    body = (head(L("AI Manuskrip", "Manuscript AI", "ذكاء المخطوطات"), L("Naskah Arab kuno, ditulis ulang dalam hitungan jam.", "Old Arabic manuscripts, rewritten in hours.", "مخطوطات عربية قديمة تُعاد كتابتها في ساعات."),
                 L("Kirim foto atau pindaian naskah Anda. Kami menuliskannya kembali sebagai teks Arab digital yang bisa dicari dan disunting, lalu merapikannya bila Anda mau.", "Send photos or scans of your manuscript. We rewrite it as digital Arabic text you can search and edit, and tidy it up if you wish.", "أرسل صور مخطوطك أو مسحه الضوئي. نعيد كتابته نصًّا عربيًّا رقميًّا قابلًا للبحث والتحرير، ثم ننسّقه إن شئت."),
                 f'<p class="small" style="margin-top:16px">{L("Dalam percobaan kami, satu kitab 400 halaman selesai dituliskan ulang dalam sekitar dua jam. Waktu sebenarnya bergantung pada kondisi naskah.", "In our trial, a 400-page book was rewritten in about two hours. The actual time depends on the condition of the manuscript.", "في تجربتنا أُعيدت كتابة كتاب من 400 صفحة في نحو ساعتين. ويتوقف الزمن الفعلي على حال المخطوط.")}</p>') +
            sec(f'<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">{L("Batas pekerjaan kami.", "Where our work ends.", "حدود عملنا.")}</h2><p class="lead">{L("Kami berhenti di tulisan ulang dan tata letak. Penelitian dan penelaahan isi tetap pekerjaan pemilik naskah.", "We stop at the rewriting and the layout. Research and checking the content remain the owner’s work.", "نتوقف عند إعادة الكتابة والتنسيق، أما البحث والتثبّت من المضمون فيبقيان على صاحب المخطوط.")}</p></div><div class="rv d1"><h3 style="margin-bottom:10px">{L("Yang kami kerjakan", "What we do", "ما نقوم به")}</h3><ul class="list-clean">{li(do)}</ul><h3 style="margin:24px 0 10px">{L("Tanggung jawab pemilik naskah", "The owner’s responsibility", "مسؤولية صاحب المخطوط")}</h3><ul class="list-clean">{li(mine)}</ul></div></div>') +
            sec(shead(L("Tarif", "Pricing", "الأسعار"), L("Dihitung dari kata, bukan dari ukuran halaman.", "Counted by words, not by page size.", "تُحسب بالكلمات لا بحجم الصفحة."), L("Satu halaman standar adalah 250 kata. Halaman yang renggang dan halaman yang padat tidak dihargai sama. Tarif ini masih awal dan dapat berubah.", "One standard page is 250 words. A sparse page and a dense page are not priced the same. These rates are initial and may change.", "الصفحة القياسية 250 كلمة. فلا تُسعَّر الصفحة المتفرقة كالصفحة الكثيفة. وهذه الأسعار أولية وقابلة للتغيير.")) + f'<div class="pillars three">{ph}</div>') +
            sec(f'<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">{L("Cara kami menghitung.", "How we count.", "كيف نحسب.")}</h2><p class="lead">{L("Aturannya kami tulis terbuka supaya tidak ada yang dirugikan.", "The rules are written openly so that no one is wronged.", "قواعد الحساب معلنة حتى لا يُظلم أحد.")}</p></div><ul class="list-clean rv d1">{li(fair)}</ul></div>', "sec band") +
            sec(f'<div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">{L("Contoh hitungan.", "A worked example.", "مثال حسابي.")}</h2></div><ul class="list-clean rv d1">{li(calc)}</ul></div>') +
            sec(shead(L("Cara memesan", "How to order", "طريقة الطلب"), L("Tiga langkah.", "Three steps.", "ثلاث خطوات.")) + f'<div class="steps6 three">{sh}</div>', "sec-tight") +
            sec(f'<p class="small rv">{L("Naskah Anda tetap milik Anda dan tidak kami publikasikan. Pastikan Anda berhak memproses naskah yang dikirim. Ketentuan lengkap ada di halaman", "Your manuscript stays yours and we do not publish it. Please make sure you have the right to process what you send. The full terms are on the page", "يبقى مخطوطك ملكًا لك ولا ننشره. تأكد من أن لك حق معالجة ما ترسله. والشروط كاملة في صفحة")} <a href="hak-cipta.html">{L("Sumber dan hak cipta", "Sources and copyright", "المصادر وحقوق النشر")}</a>.</p>', "sec-tight") +
            sec(f'<div class="statement" style="margin-top:0"><div><p>{L("Punya naskah untuk dicoba?", "Have a manuscript to try?", "هل لديك مخطوط للتجربة؟")}</p></div><div class="stk"><div class="cpills">{contact_pills()}</div></div></div>', "sec-tight"))
    write("ai-manuskrip.html", L("AI Manuskrip: OpenTurath", "Manuscript AI: OpenTurath", "ذكاء المخطوطات: OpenTurath"),
          L("Penulisan ulang naskah Arab kuno ke teks digital yang bisa dicari dan disunting, dengan tarif per 250 kata yang terbuka.", "Rewriting old Arabic manuscripts into searchable, editable digital text, with open per-250-word pricing.", "إعادة كتابة المخطوطات العربية القديمة نصًّا رقميًّا قابلًا للبحث والتحرير، بتسعير معلن لكل 250 كلمة."), body, "")

# ======================= UTAMA =======================
PAGES = ["index", "bidang", "fikih-tahawwulat", "cara-kerja", "pedoman", "ekosistem", "tentang", "unduh", "bantuan", "ketentuan", "privasi", "pembayaran", "panduan-ai", "hak-cipta", "hapus-akun", "mengenal-fikih-tahawwulat", "perbandingan", "ai-manuskrip"]
for _l in LANGS:
    LANG = _l
    page_home(); page_bidang(); page_tahaw(); page_cara(); page_pedoman(); page_eko(); page_tentang(); page_unduh(); page_bantuan(); page_legal_all(); page_mengenal(); page_perbandingan(); page_manuskrip()

# pengalih bahasa di akar situs (tanpa halaman pilihan bahasa; skrip eksternal karena CSP)
(OUT / "index.html").write_text('''<!doctype html><html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>OpenTurath</title>
<link rel="alternate" hreflang="id" href="id"><link rel="alternate" hreflang="en" href="en"><link rel="alternate" hreflang="ar" href="ar"><link rel="alternate" hreflang="x-default" href="id">
<noscript><meta http-equiv="refresh" content="0;url=/id"></noscript><script src="/assets/js/lang.js"></script></head>
<body style="font-family:system-ui;padding:40px"><p><a href="/id">Bahasa Indonesia</a> · <a href="/en">English</a> · <a href="/ar">العربية</a></p></body></html>''', encoding="utf8")
urls = "".join(f'<url><loc>{BASE}/{l}{"" if p == "index" else "/" + p}</loc>' + "".join(f'<xhtml:link rel="alternate" hreflang="{m}" href="{BASE}/{m}{"" if m == "index" else "/" + p}"/>' for m in LANGS) + '</url>' for l in LANGS for p in PAGES)
(OUT / "sitemap.xml").write_text(f'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">{urls}</urlset>', encoding="utf8")
(OUT / "robots.txt").write_text(f"User-agent: *\nAllow: /\nSitemap: {BASE}/sitemap.xml\n", encoding="utf8")
(OUT / "404.html").write_text('''<!doctype html><html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>404 · OpenTurath</title><meta name="robots" content="noindex"></head><body style="font-family:system-ui;text-align:center;padding:96px 24px"><h1 style="font-weight:450;font-size:48px;letter-spacing:-.03em">Halaman tidak ditemukan.</h1><p style="margin:24px 0"><a href="/id">Kembali ke beranda</a> · <a href="/en">Home</a> · <a href="/ar">الرئيسية</a></p></body></html>''', encoding="utf8")
(OUT / "assets" / "mark.svg").write_text('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 616 674"><g fill="#100F0E">' + "".join(f'<path transform="translate(-204,-175)" d="{d}"/>' for d in PATHS) + '</g></svg>')
(HERE / "og.html").write_text('<!doctype html><meta charset="utf-8"><body style="margin:0;width:1200px;height:630px;background:#121317;color:#F8F9FC;font-family:system-ui;display:flex;align-items:center;gap:56px;padding:0 90px;box-sizing:border-box"><svg style="height:260px;color:#F8F9FC" viewBox="0 0 616 674"><g fill="currentColor">' + "".join(f'<path transform="translate(-204,-175)" d="{d}"/>' for d in PATHS) + '</g></svg><div><div style="font-size:84px;font-weight:600;letter-spacing:-2px">OpenTurath</div><div style="font-size:40px;color:#B2BBC5;margin-top:14px;letter-spacing:-.5px">Menjaga warisan, membuka cakrawala.</div></div></body>', encoding="utf8")
print("dibangun:", {l: sorted(p.name for p in (OUT / l).glob("*.html")) for l in LANGS}["id"], "x3 bahasa")
