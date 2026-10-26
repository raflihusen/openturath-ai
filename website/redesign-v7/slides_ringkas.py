#!/usr/bin/env python3
"""Menyusun deck ringkas "Mengenal Fikih Tahawwulat" untuk aplikasi.

Sumber : slides_mengenal_lengkap.json (84 slide, ID/EN/AR, dibuat slides_naskah.py).
Hasil  : openturath_ai/assets/data/slides_mengenal.json (32 slide, sekitar 7 menit).

Prinsip: "mengenal" berarti apa itu, dalilnya, dan mulai dari mana. Bab teknis
(dua kendali, rantai ikatan Islam, rincian lima cabang) tidak dimuat di sini.
Teks tiap slide diambil apa adanya dari sumber lengkap, termasuk terjemahan EN/AR.
Hanya tiga slide yang dirakit: gabungan dua slide, peta lima cabang (nama saja),
dan kartu lima asisten (nama saja). Adegan animasi dirujuk lewat kunci m01..m32
di lib/widgets/tahawwulat_scenes_mengenal.dart.
"""
import copy
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
SRC = HERE / "slides_mengenal_lengkap.json"
OUT = HERE.parent.parent / "openturath_ai" / "assets" / "data" / "slides_mengenal.json"

data = json.loads(SRC.read_text("utf8"))
S = data["slides"]  # indeks 0-based; nomor di bawah memakai nomor slide 1-based


def src(n):
    return copy.deepcopy(S[n - 1])


def blocks_of(slide, lang):
    return slide["blocks"] if lang == "id" else slide["i18n"][lang]["blocks"]


def merge(a, b):
    """Gabungkan dua slide isi: blok kedua mengikuti blok pertama di semua bahasa."""
    out = src(a)
    other = src(b)
    out["blocks"] = out["blocks"] + other["blocks"]
    for lang in ("en", "ar"):
        out["i18n"][lang]["blocks"] = out["i18n"][lang]["blocks"] + other["i18n"][lang]["blocks"]
    return out


HEAD = re.compile(r"^\*\*(.+?)\*\*", re.S)


def head_only(item):
    """'**Nama:** uraian' -> '**Nama**'."""
    m = HEAD.match(item)
    assert m, item
    return "**" + m.group(1).rstrip(":：").strip() + "**"


def five_branch_map():
    """Peta lima cabang tanpa istilah teknis: hanya nama tiap cabang."""
    out = src(59)
    for lang in ("id", "en", "ar"):
        for b in blocks_of(out, lang):
            if "ol" in b:
                b["ol"] = [head_only(x) for x in b["ol"]]
    return out


NUM = re.compile(r"^[0-9٠-٩]+\.\s*")


def five_assistants():
    """Satu slide untuk lima asisten: judul + daftar nama dan peran (tanpa uraian panjang)."""
    out = src(79)
    title = {
        "id": "**Lima asisten, lima cara membantu.**",
        "en": "**Five assistants, five ways to help.**",
        "ar": "**خمسة مساعدين، وخمس طرق للعون.**",
    }
    for lang in ("id", "en", "ar"):
        items = []
        for n in range(79, 84):
            first = blocks_of(S[n - 1], lang)[0]["p"]
            m = HEAD.match(first)
            assert m, (n, lang)
            items.append("**" + NUM.sub("", m.group(1)).strip() + "**")
        blocks = [{"p": title[lang]}, {"ol": items}]
        if lang == "id":
            out["blocks"] = blocks
        else:
            out["i18n"][lang]["blocks"] = blocks
    return out


# (nomor slide sumber atau fungsi perakit) berurutan sesuai deck baru.
PLAN = [
    # Bab 0: pembuka
    1, 2, 3,
    # Bab 1: Hadis Jibril
    4, lambda: merge(5, 6), 10, 13, 14, 18, 20,
    # Bab 2: satu kesatuan
    21, 25, 27, 35,
    # Bab 3: apa itu Fikih Tahawwulat
    40, 41, 46, 50, 52, 53,
    # Bab 4: lima cabang (nama saja)
    56, lambda: merge(57, 58), five_branch_map,
    # Bab 5: jalan selamat
    70, 71, 72, 73, 75,
    # Bab 6: mulai belajar
    77, 78, five_assistants, 84,
]

slides = []
for i, step in enumerate(PLAN, start=1):
    s = step() if callable(step) else src(step)
    s["scene"] = f"m{i:02d}"
    s["lvl"] = "full"
    slides.append(s)
slides[-1]["end"] = True

# Pemeriksaan: semua slide punya EN/AR dan jumlah blok sama dengan Indonesia.
for i, s in enumerate(slides, start=1):
    for lang in ("en", "ar"):
        tr = s["i18n"][lang]
        if s["kind"] == "title":
            assert {"kicker", "title"} <= set(tr), (i, lang)
        else:
            assert len(tr["blocks"]) == len(s["blocks"]), (i, lang)

used = sorted({s["bab"] for s in slides})
assert used == list(range(len(data["bab"]))), used

OUT.write_text(json.dumps({"bab": data["bab"], "slides": slides}, ensure_ascii=False, indent=1), "utf8")


def words(s):
    t = []
    for k in ("kicker", "title", "sub"):
        if s.get(k):
            t.append(s[k])
    for b in s.get("blocks", []) or []:
        for v in b.values():
            t.append(json.dumps(v, ensure_ascii=False) if not isinstance(v, str) else v)
    return len(re.findall(r"\w+", " ".join(t)))


total = sum(words(s) for s in slides)
print(f"{len(slides)} slide -> {OUT}")
print(f"{total} kata, sekitar {total / 200:.1f} menit baca")
for b, name in enumerate(data["bab"]):
    n = [s for s in slides if s["bab"] == b]
    print(f"  bab{b} {name['id']:<18} {len(n)} slide")
