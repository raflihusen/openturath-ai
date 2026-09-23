"""Generate six OpenTurath folio UI illustrations from the existing design tokens.

These are reviewable concept boards, not Flutter screens or product screenshots.
Requires Pillow and macOS PyObjC for correctly shaped Arabic specimen text.
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = Path(__file__).resolve().parent
FONT_DIR = ROOT / "openturath_ai/assets/native_fonts"
S = 2
W, H = 1450, 1090
INK = "#171717"
MUTED = "#656560"
FAINT = "#91918b"
PAPER = "#F6F6F3"
WHITE = "#FFFFFF"
LINE = "#DDDDD8"
SOFT = "#EEEEEB"
BOARD = "#E9E9E5"
OLIVE = "#3D4A3E"


def font(name: str, size: float) -> ImageFont.FreeTypeFont:
    file = {
        "display": "NativeNewsreader.ttf",
        "ui": "NativeOutfit.ttf",
        "strong": "NativeInter.ttf",
    }[name]
    return ImageFont.truetype(str(FONT_DIR / file), round(size * S))


def box(draw, x, y, w, h, fill, radius=0, outline=None, width=1):
    rect = (round(x*S), round(y*S), round((x+w)*S), round((y+h)*S))
    if radius:
        draw.rounded_rectangle(rect, radius=round(radius*S), fill=fill,
                               outline=outline, width=round(width*S))
    else:
        draw.rectangle(rect, fill=fill, outline=outline, width=round(width*S))


def rule(draw, x1, y1, x2, y2, color=LINE, width=1):
    draw.line((round(x1*S), round(y1*S), round(x2*S), round(y2*S)),
              fill=color, width=max(1, round(width*S)))


def tx(draw, x, y, value, size=14, face="ui", color=INK, anchor=None):
    draw.text((round(x*S), round(y*S)), value, font=font(face, size),
              fill=color, anchor=anchor, stroke_width=0)


def right(draw, x, y, value, size=14, face="ui", color=INK):
    tx(draw, x, y, value, size, face, color, anchor="ra")


def wrapped(draw, x, y, value, width, size=13, face="ui", color=MUTED,
            leading=1.35, max_lines=None):
    words = value.split()
    lines, current = [], ""
    f = font(face, size)
    for word in words:
        candidate = (current + " " + word).strip()
        if draw.textlength(candidate, font=f) <= width*S:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    if max_lines:
        lines = lines[:max_lines]
    for i, line in enumerate(lines):
        tx(draw, x, y + i*size*leading, line, size, face, color)
    return y + len(lines)*size*leading


def circle(draw, x, y, r, fill, outline=None, width=1):
    draw.ellipse((round((x-r)*S), round((y-r)*S), round((x+r)*S),
                  round((y+r)*S)), fill=fill, outline=outline,
                 width=round(width*S))


def chevron(draw, x, y, color=INK):
    rule(draw, x-3, y-4, x+1, y, color, 1.5)
    rule(draw, x+1, y, x-3, y+4, color, 1.5)


def arrow(draw, x, y, color=INK):
    rule(draw, x-6, y, x+5, y, color, 1.4)
    rule(draw, x+1, y-4, x+5, y, color, 1.4)
    rule(draw, x+5, y, x+1, y+4, color, 1.4)


def search_icon(draw, x, y):
    circle(draw, x, y, 5, None, MUTED, 1.4)
    rule(draw, x+4, y+4, x+8, y+8, MUTED, 1.4)


def nav(draw, x, y, active):
    rule(draw, x, y, x+380, y, LINE)
    labels = ["Beranda", "Asisten", "Catatan", "Pengaturan"]
    for i, label in enumerate(labels):
        cx = x + 47 + i*95
        is_active = label == active
        c = INK if is_active else FAINT
        if i == 0:
            rule(draw, cx-7, y+24, cx, y+18, c, 1.5)
            rule(draw, cx, y+18, cx+7, y+24, c, 1.5)
            rule(draw, cx-5, y+24, cx-5, y+33, c, 1.5)
            rule(draw, cx+5, y+24, cx+5, y+33, c, 1.5)
        elif i == 1:
            tx(draw, cx, y+12, "✦", 21, "ui", c, anchor="mt")
        elif i == 2:
            for q, ww in enumerate((12, 9, 11)):
                rule(draw, cx-6, y+20+q*5, cx-6+ww, y+20+q*5, c, 1.4)
        else:
            circle(draw, cx, y+26, 6, None, c, 1.4)
            circle(draw, cx, y+26, 2, c)
        tx(draw, cx, y+41, label, 10.5, "ui", c, anchor="mt")
        if is_active:
            box(draw, cx-11, y+61, 22, 2, INK, 1)


def phone(draw, x, y, label, active=None):
    # A single paper surface is intentional: most content uses editorial rules,
    # while rounded panels are reserved for controls and a focal action.
    box(draw, x+3, y+10, 380, 830, "#D5D5D0", 36)
    box(draw, x, y, 380, 830, PAPER, 36, "#CACAC4", 1)
    box(draw, x+1, y+1, 378, 36, PAPER, 35)
    tx(draw, x+24, y+17, "9:41", 12, "strong", INK)
    for k, hh in enumerate((5, 7, 10, 12)):
        box(draw, x+315+k*5, y+29-hh, 3, hh, INK, 1)
    box(draw, x+348, y+19, 16, 9, INK, 3)
    tx(draw, x+22, y-35, label, 11, "strong", MUTED)
    if active:
        nav(draw, x, y+746, active)


def board(title, subtitle, labels):
    im = Image.new("RGB", (W*S, H*S), BOARD)
    d = ImageDraw.Draw(im)
    box(d, 0, 0, W, 8, INK)
    tx(d, 75, 38, title, 33, "display", INK)
    tx(d, 76, 88, subtitle, 14, "ui", MUTED)
    right(d, 1375, 50, "OPENTURATH / DESIGN STUDY 01", 11, "strong", MUTED)
    rule(d, 75, 120, 1375, 120, "#CBCBC5")
    for i, label in enumerate(labels):
        x = 75+i*455
        tx(d, x, 1025, label, 12, "strong", MUTED)
        if i < 2:
            rule(d, x+385, 1040, x+420, 1040, FAINT)
            arrow(d, x+425, 1040, FAINT)
    return im, d


def context_tabs(draw, x, y, selected):
    labels = ["Asisten", "Pustaka", "Catatan"]
    rule(draw, x, y+41, x+332, y+41, LINE)
    for i, label in enumerate(labels):
        xx = x+i*111
        is_active = label == selected
        tx(draw, xx+55, y+12, label, 12, "strong" if is_active else "ui",
           INK if is_active else MUTED, anchor="mt")
        if is_active:
            box(draw, xx+34, y+40, 43, 2, INK, 1)


def screen_dashboard(draw, x, y):
    phone(draw, x, y, "01 / BERANDA", "Beranda")
    ox, oy = x+24, y+55
    tx(draw, ox, oy, "OpenTurath", 24, "display", INK)
    right(draw, x+356, oy+2, "23 SEP 2026", 10, "strong", MUTED)
    rule(draw, ox, oy+39, x+356, oy+39, INK, 1.3)
    tx(draw, ox, oy+58, "Selamat kembali, M Fulan", 11, "ui", MUTED)
    tx(draw, ox, oy+78, "Lanjutkan apa yang", 29, "display", INK)
    tx(draw, ox, oy+109, "sedang Anda telaah.", 29, "display", INK)
    # Session presented like an open folio, not another generic dashboard card.
    box(draw, ox, oy+155, 332, 152, WHITE, 16, LINE)
    box(draw, ox, oy+155, 5, 152, INK, 2)
    tx(draw, ox+20, oy+171, "RUANG KAJIAN TERAKHIR", 9, "strong", MUTED)
    tx(draw, ox+20, oy+195, "Fikih Syafi'i", 25, "display", INK)
    tx(draw, ox+20, oy+230, "Matan · Syarah · Hasyiyah", 12, "ui", MUTED)
    rule(draw, ox+20, oy+267, ox+312, oy+267, LINE)
    tx(draw, ox+20, oy+278, "Buka kembali ruang AI", 12, "strong", INK)
    arrow(draw, ox+295, oy+283)
    tx(draw, ox, oy+331, "INDEKS KEILMUAN", 10, "strong", MUTED)
    right(draw, x+356, oy+331, "10 bidang  ↗", 11, "ui", MUTED)
    rule(draw, ox, oy+355, x+356, oy+355, INK)
    rows = [
        ("01", "Fikih Tahawwulat", "01 asisten"),
        ("02", "Fikih & Fatwa", "06 asisten"),
        ("03", "Hadis & Ulumul Hadis", "03 asisten"),
        ("04", "Tafsir & Qiraat", "02 asisten"),
    ]
    for i, (no, title, meta) in enumerate(rows):
        yy = oy+371+i*58
        tx(draw, ox, yy, no, 11, "strong", FAINT)
        tx(draw, ox+35, yy-3, title, 18, "display", INK)
        right(draw, x+348, yy+2, meta, 10, "ui", MUTED)
        rule(draw, ox+35, yy+41, x+356, yy+41, LINE)
    box(draw, ox, oy+630, 332, 47, WHITE, 14, LINE)
    search_icon(draw, ox+20, oy+650)
    tx(draw, ox+39, oy+642, "Cari asisten atau bidang ilmu", 12, "ui", FAINT)


def screen_field(draw, x, y):
    phone(draw, x, y, "02 / BIDANG", "Asisten")
    ox, oy = x+24, y+56
    tx(draw, ox, oy, "‹", 25, "ui")
    tx(draw, ox+25, oy+5, "BIDANG 02 / 10", 10, "strong", MUTED)
    tx(draw, ox, oy+45, "Fikih & Fatwa", 31, "display")
    wrapped(draw, ox, oy+88, "Ibadah, muamalah, fatwa kontemporer, dan mazhab mu'tabar.", 325, 12, "ui", MUTED, 1.4)
    context_tabs(draw, ox, oy+145, "Asisten")
    tx(draw, ox, oy+211, "PILIH CARA MENELAAH", 10, "strong", MUTED)
    # An assistant is a dossier with a real scope and corpus, not a repeated row.
    box(draw, ox, oy+239, 332, 197, INK, 16)
    tx(draw, ox+19, oy+257, "01 / 06   ·   MAZHAB", 10, "strong", "#B2B2AA")
    right(draw, ox+309, oy+258, "✦", 21, "ui", WHITE)
    tx(draw, ox+19, oy+286, "Fikih Syafi'i", 27, "display", WHITE)
    tx(draw, ox+19, oy+323, "Matan · Syarah · Hasyiyah Mu'tabarah", 11, "ui", "#C8C8C0")
    rule(draw, ox+19, oy+354, ox+313, oy+354, "#4B4B47")
    tx(draw, ox+19, oy+369, "Rujukan: Al-Umm, Al-Majmu'", 11, "ui", "#C8C8C0")
    tx(draw, ox+19, oy+400, "Kenali asisten", 12, "strong", WHITE)
    arrow(draw, ox+296, oy+405, WHITE)
    tx(draw, ox, oy+461, "SPESIALIS LAIN", 10, "strong", MUTED)
    others = [
        ("02", "Fikih Hanafi", "Zhahir ar-Riwayah"),
        ("03", "Fikih Maliki", "Amal ahl al-Madinah"),
        ("04", "Fikih Hanbali", "Nash & riwayat"),
    ]
    for i, (no, name, desc) in enumerate(others):
        yy = oy+488+i*57
        rule(draw, ox, yy-8, x+356, yy-8, LINE)
        tx(draw, ox, yy+3, no, 10, "strong", FAINT)
        tx(draw, ox+36, yy-4, name, 18, "display")
        tx(draw, ox+36, yy+19, desc, 10, "ui", MUTED)
        chevron(draw, x+349, yy+12, MUTED)


def screen_assistant(draw, x, y):
    phone(draw, x, y, "03 / IDENTITAS ASISTEN", "Asisten")
    ox, oy = x+24, y+56
    tx(draw, ox, oy, "‹", 25, "ui")
    tx(draw, ox+25, oy+5, "ASISTEN / FIKIH TAHAWWULAT", 10, "strong", MUTED)
    tx(draw, ox, oy+45, "Fikih Tahawwulat", 30, "display")
    tx(draw, ox, oy+86, "Manhaj Abu Bakr al-Masyhur", 12, "ui", MUTED)
    rule(draw, ox, oy+119, x+356, oy+119, INK)
    tx(draw, ox, oy+135, "58", 31, "display")
    tx(draw, ox+46, oy+149, "kitab", 11, "ui", MUTED)
    rule(draw, ox+117, oy+136, ox+117, oy+176, LINE)
    tx(draw, ox+135, oy+135, "1.099", 31, "display")
    tx(draw, ox+228, oy+149, "transkrip", 11, "ui", MUTED)
    tx(draw, ox, oy+194, "LIMA PERAN, SATU BIDANG", 10, "strong", MUTED)
    role_rows = [
        ("01", "Al-Muhaqqiq", "Telusur matan & ibarah"),
        ("02", "Al-Bayan", "Uraikan konsep & istilah"),
        ("03", "Al-Mukhtabir", "Uji pemahaman interaktif"),
        ("04", "Al-Habib", "Khazanah muhadharah"),
        ("05", "Al-Khatib", "Susun materi dakwah"),
    ]
    for i, (no, name, desc) in enumerate(role_rows):
        yy = oy+225+i*64
        if i == 0:
            box(draw, ox, yy-5, 332, 59, WHITE, 14, LINE)
        else:
            rule(draw, ox, yy+56, x+356, yy+56, LINE)
        tx(draw, ox+12, yy+3, no, 10, "strong", FAINT)
        tx(draw, ox+46, yy-2, name, 18, "display")
        tx(draw, ox+46, yy+25, desc, 11, "ui", MUTED)
        chevron(draw, x+345, yy+18, MUTED)
    box(draw, ox, oy+566, 332, 72, SOFT, 14)
    tx(draw, ox+15, oy+578, "COBA PERTANYAAN", 9, "strong", MUTED)
    wrapped(draw, ox+15, oy+600, "Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?", 298, 12, "ui", INK, 1.25, 2)
    box(draw, ox, oy+650, 332, 45, INK, 999)
    tx(draw, ox+166, oy+662, "Buka ruang asisten   →", 12, "strong", WHITE, "mt")


def screen_library(draw, x, y, arabic):
    phone(draw, x, y, "04 / PUSTAKA", "Asisten")
    ox, oy = x+24, y+56
    tx(draw, ox, oy, "‹", 25, "ui")
    tx(draw, ox+25, oy+5, "FIKIH & FATWA", 10, "strong", MUTED)
    tx(draw, ox, oy+45, "Pustaka Syafi'i", 30, "display")
    tx(draw, ox, oy+87, "87 kitab dalam katalog ini", 12, "ui", MUTED)
    context_tabs(draw, ox, oy+122, "Pustaka")
    box(draw, ox, oy+187, 332, 45, WHITE, 14, LINE)
    search_icon(draw, ox+19, oy+205)
    tx(draw, ox+39, oy+196, "Cari judul, pengarang, atau istilah", 11, "ui", FAINT)
    tx(draw, ox, oy+254, "URUTAN: TAHUN WAFAT", 10, "strong", MUTED)
    right(draw, x+356, oy+254, "Saring  ≡", 11, "strong")
    rule(draw, ox, oy+278, x+356, oy+278, INK)
    entries = [
        ("01", "الأم", "Imam asy-Syafi'i · w. 204 H", "8 jilid   /   2.267 hlm."),
        ("02", "الأمر والنهي", "Imam al-Muzani · w. 264 H", "1 jilid   /   384 hlm."),
        ("03", "مختصر المزني", "Imam al-Muzani · w. 264 H", "3 jilid   /   2.107 hlm."),
    ]
    for i, (no, title, meta, count) in enumerate(entries):
        yy = oy+292+i*124
        tx(draw, ox, yy+4, no, 10, "strong", FAINT)
        arabic.append((x+350, yy+4, title, 27))
        tx(draw, ox+36, yy+53, meta, 12, "ui", MUTED)
        tx(draw, ox+36, yy+77, count, 10, "ui", FAINT)
        rule(draw, ox, yy+111, x+356, yy+111, LINE)
    box(draw, ox, oy+679, 332, 1, LINE)
    tx(draw, ox, oy+689, "Tampilkan 84 kitab lainnya", 11, "strong")
    arrow(draw, x+347, oy+696)


def screen_book(draw, x, y, arabic):
    phone(draw, x, y, "05 / REKAM KITAB", "Asisten")
    ox, oy = x+24, y+56
    tx(draw, ox, oy, "‹", 25, "ui")
    tx(draw, ox+25, oy+5, "PUSTAKA SYAFI'I / 01 DARI 87", 10, "strong", MUTED)
    box(draw, ox, oy+48, 332, 157, WHITE, 16, LINE)
    box(draw, ox, oy+48, 5, 157, INK, 2)
    tx(draw, ox+19, oy+63, "KITAB INDUK / ABAD 2 H", 9, "strong", MUTED)
    arabic.append((x+336, oy+90, "الأم", 51))
    tx(draw, ox+19, oy+159, "Imam Muhammad bin Idris asy-Syafi'i", 12, "ui", MUTED)
    tx(draw, ox, oy+229, "Naskah & edisi", 25, "display")
    tx(draw, ox, oy+267, "Data bibliografi untuk menilai sumber", 11, "ui", MUTED)
    rule(draw, ox, oy+298, x+356, oy+298, INK)
    rows = [
        ("PENGARANG", "Imam asy-Syafi'i  ·  w. 204 H"),
        ("PENERBIT", "Dar al-Fikr, Beirut"),
        ("CETAKAN", "Kedua  ·  1403 H / 1983 M"),
        ("KETEBALAN", "8 jilid  ·  2.267 halaman"),
    ]
    for i, (label, value) in enumerate(rows):
        yy = oy+310+i*73
        tx(draw, ox, yy, label, 9, "strong", MUTED)
        tx(draw, ox, yy+23, value, 13, "ui", INK)
        rule(draw, ox, yy+62, x+356, yy+62, LINE)
    box(draw, ox, oy+624, 332, 47, INK, 999)
    tx(draw, ox+166, oy+636, "Salin sitasi lengkap", 12, "strong", WHITE, "mt")
    box(draw, ox, oy+681, 332, 41, WHITE, 999, LINE)
    tx(draw, ox+166, oy+691, "Simpan sebagai rujukan", 11, "strong", INK, "mt")


def screen_notes(draw, x, y):
    phone(draw, x, y, "06 / CATATAN", "Catatan")
    ox, oy = x+24, y+56
    tx(draw, ox, oy, "Catatan", 31, "display")
    right(draw, x+355, oy+10, "+ Baru", 11, "strong")
    tx(draw, ox, oy+50, "Jejak telaah yang bisa ditinjau kembali.", 12, "ui", MUTED)
    box(draw, ox, oy+86, 332, 45, WHITE, 14, LINE)
    search_icon(draw, ox+19, oy+104)
    tx(draw, ox+39, oy+95, "Cari isi catatan atau rujukan", 11, "ui", FAINT)
    tx(draw, ox, oy+158, "SEMUA BIDANG", 10, "strong", MUTED)
    right(draw, x+356, oy+158, "Fikih & Fatwa   ⌄", 11, "ui", INK)
    rule(draw, ox, oy+184, x+356, oy+184, INK)
    # Mixed document types map to the existing BookmarkDocumentKind model.
    tx(draw, ox, oy+204, "01 / RUJUKAN KITAB", 9, "strong", MUTED)
    tx(draw, ox, oy+229, "Al-Umm", 22, "display")
    tx(draw, ox, oy+263, "Imam asy-Syafi'i · Pustaka Syafi'i", 11, "ui", MUTED)
    box(draw, ox, oy+294, 115, 24, SOFT, 999)
    tx(draw, ox+57, oy+299, "Tersimpan", 10, "ui", INK, "mt")
    rule(draw, ox, oy+340, x+356, oy+340, LINE)
    tx(draw, ox, oy+357, "02 / JAWABAN ASISTEN", 9, "strong", MUTED)
    tx(draw, ox, oy+382, "Rukun wudu", 22, "display")
    wrapped(draw, ox, oy+419, "Jawaban dari ruang Fikih Syafi'i. Tandai poin yang perlu diperiksa kembali pada kitab.", 305, 11, "ui", MUTED, 1.38, 3)
    box(draw, ox, oy+480, 133, 24, SOFT, 999)
    tx(draw, ox+66, oy+485, "Perlu verifikasi", 10, "ui", INK, "mt")
    rule(draw, ox, oy+526, x+356, oy+526, LINE)
    tx(draw, ox, oy+544, "03 / CATATAN PRIBADI", 9, "strong", MUTED)
    tx(draw, ox, oy+570, "Titik telaah berikutnya", 21, "display")
    wrapped(draw, ox, oy+606, "Bandingkan uraian dalam Al-Umm dengan syarah yang tersedia di katalog.", 305, 11, "ui", MUTED, 1.38, 2)
    rule(draw, ox, oy+670, x+356, oy+670, LINE)
    tx(draw, ox, oy+680, "Semua dokumen tersimpan", 11, "strong")
    arrow(draw, x+346, oy+687)


def add_arabic(im, items):
    """Shape short Arabic titles with Cocoa on a transparent bitmap layer."""
    if not items:
        return im
    import Cocoa
    rep = Cocoa.NSBitmapImageRep.alloc().initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel_(
        None, W*S, H*S, 8, 4, True, False, Cocoa.NSCalibratedRGBColorSpace, 0, 0)
    context = Cocoa.NSGraphicsContext.graphicsContextWithBitmapImageRep_(rep)
    Cocoa.NSGraphicsContext.saveGraphicsState()
    Cocoa.NSGraphicsContext.setCurrentContext_(context)
    for x_right, top, value, size in items:
        f = Cocoa.NSFont.fontWithName_size_("GeezaPro", size*S)
        attributes = {Cocoa.NSFontAttributeName: f,
                      Cocoa.NSForegroundColorAttributeName: Cocoa.NSColor.colorWithCalibratedRed_green_blue_alpha_(.09, .09, .09, 1)}
        ns = Cocoa.NSString.stringWithString_(value)
        width = ns.sizeWithAttributes_(attributes).width
        ns.drawAtPoint_withAttributes_((x_right*S-width, H*S-(top+size*1.13)*S), attributes)
    Cocoa.NSGraphicsContext.restoreGraphicsState()
    import io
    blob = bytes(rep.representationUsingType_properties_(Cocoa.NSPNGFileType, {}))
    overlay = Image.open(io.BytesIO(blob)).convert("RGBA")
    return Image.alpha_composite(im.convert("RGBA"), overlay).convert("RGB")


def main():
    a, da = board("Satu bidang, tiga pintu", "Beranda → bidang → identitas asisten. Monokrom hangat, folio bernomor, permukaan yang tenang.",
                  ["LANJUTKAN KAJIAN", "PILIH BIDANG & SPESIALIS", "KENALI KEAHLIAN ASISTEN"])
    for i, fn in enumerate((screen_dashboard, screen_field, screen_assistant)):
        fn(da, 75+i*455, 165)
    a.save(OUT / "open_turath_folio_01.png", optimize=True)

    b, db = board("Jejak telaah yang utuh", "Pustaka → rekam kitab → catatan. Rujukan bibliografis dan status verifikasi hadir dalam satu bahasa visual.",
                  ["INDEKS PUSTAKA", "REKAM BIBLIOGRAFI", "JEJAK CATATAN"])
    ar = []
    screen_library(db, 75, 165, ar)
    screen_book(db, 530, 165, ar)
    screen_notes(db, 985, 165)
    b = add_arabic(b, ar)
    b.save(OUT / "open_turath_folio_02.png", optimize=True)


if __name__ == "__main__":
    main()
