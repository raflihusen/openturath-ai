#!/usr/bin/env python3
"""Membuat lib/core/notebook_fonts.dart: font aplikasi (subset, woff2, base64)
untuk disuntikkan ke WebView NotebookLM. Jalankan dari folder openturath_ai.

  python3 tool/make_notebook_fonts.py

Outfit dan Scheherazade New berlisensi OFL (lihat assets/native_fonts/OFL-*.txt).
"""
import base64, io, pathlib
from fontTools import subset
from fontTools.ttLib import TTFont

FONTS = pathlib.Path("assets/native_fonts")
LATIN = "U+0020-007E,U+00A0-024F,U+2000-206F,U+2190-2193"
ARABIC = ("U+0020-007E,U+00A0,U+00AB,U+00BB,U+0600-06FF,U+0750-077F,U+08A0-08FF,"
          "U+FB50-FDFF,U+FE70-FEFF,U+2000-206F,U+25CC")
SOURCES = [
    ("OT Outfit", 400, "NativeOutfit.ttf", LATIN),
    ("OT Outfit", 600, "NativeOutfit-600.ttf", LATIN),
    ("OT Scheherazade", 400, "NativeArabic.ttf", ARABIC),
]

def woff2_b64(path, unicodes):
    opts = subset.Options()
    opts.flavor = "woff2"
    opts.layout_features = ["*"]
    opts.notdef_outline = True
    font = TTFont(str(FONTS / path))
    sub = subset.Subsetter(opts)
    sub.populate(unicodes=subset.parse_unicodes(unicodes))
    sub.subset(font)
    font.flavor = "woff2"
    buf = io.BytesIO()
    font.save(buf)
    return base64.b64encode(buf.getvalue()).decode()

faces = []
for family, weight, path, unicodes in SOURCES:
    faces.append(
        f'@font-face{{font-family:"{family}";font-weight:{weight};font-style:normal;'
        f'font-display:swap;src:url(data:font/woff2;base64,{woff2_b64(path, unicodes)}) format("woff2");}}')
css = "".join(faces)
dart = f"""// GENERATED oleh tool/make_notebook_fonts.py. Jangan diubah tangan.
//
// Font aplikasi (Outfit 400/600 dan Scheherazade New) sebagai @font-face
// berisi data URI, disuntikkan ke halaman NotebookLM agar jawaban memakai
// huruf yang sama dengan aplikasi.
const notebookFontsScript = r'''
(function () {{
  if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;
  if (document.getElementById('ot-fonts')) return;
  var style = document.createElement('style');
  style.id = 'ot-fonts';
  style.textContent = `{css}`;
  (document.head || document.documentElement).appendChild(style);
}})();
''';
"""
pathlib.Path("lib/core/notebook_fonts.dart").write_text(dart, encoding="utf8")
print("ok", len(dart))
