"""Halaman "Mengenal Fikih Tahawwulat": naskah markdown per bahasa -> bagian dan tanya-jawab."""
import re
from pathlib import Path
HERE = Path(__file__).parent

# lima jalur bacaan: urutan bagian; bagian parsial: {huruf: nomor yang disertakan}
TRACKS = {
    1: ("A B I J L".split(), {}),
    2: ("A D F I J".split(), {"A": range(10, 15)}),
    3: ("B C E F G H".split(), {}),
    4: ("B C D G H J K".split(), {"G": range(10, 14)}),
    5: ("C D E H I".split(), {}),
}
def track_has(t, letter, no):
    order, part = TRACKS[t]
    if letter not in order: return False
    return no in part[letter] if letter in part else True

def _clean_ref(r):
    r = re.sub(r"\s*\(`ص [^`]*`(?::[^)]*)?\)", "", r)                # nomor halaman belum diverifikasi
    r = re.sub(r"\s*\*\(Catatan:.*?\)\.?\*", "", r)
    r = re.sub(r"`\[D(\d+)(?:,\s*D(\d+))*\]`", lambda m: m.group(0), r)
    return r

def _lessons(r, lang):
    """`[D20]` -> Pelajaran 20; `[Pengantar]` -> pengantar."""
    word = {"id": "Pelajaran", "en": "Lesson", "ar": "الدرس"}[lang]
    r = re.sub(r"`\[D(\d+)\]`", lambda m: f"{word} {m.group(1)}", r)
    r = r.replace("`[Pengantar]`", {"id": "Pengantar kitab", "en": "Introduction", "ar": "المقدمة"}[lang])
    return r

def parse(lang):
    txt = (HERE / "content" / f"mengenal_{lang}.md").read_text(encoding="utf8")
    secs, cur, ent = [], None, None
    for line in txt.split("\n"):
        m = re.match(r"^## (?:BAGIAN|SECTION|القسم) ([A-L])\s*[:：]\s*(.+)$", line)
        if m: cur = {"k": m.group(1), "title": m.group(2).strip(), "items": []}; secs.append(cur); ent = None; continue
        m = re.match(r"^### ([A-L])(\d+)\.\s*(.+?)(?:\s+`\[[^`]*\]`)?(?:\s+`\(\?\)`)?\s*$", line)
        if m and cur is not None:
            q = re.sub(r"\s*`[^`]*`", "", m.group(3)).strip()
            ent = {"k": m.group(1), "n": int(m.group(2)), "q": q, "a": [], "ref": ""}; cur["items"].append(ent); continue
        if ent is None: continue
        if line.startswith("* **") and re.match(r"^\* \*\*(?:Rujukan|Reference|المراجع|المرجع)", line):
            ent["ref"] = _lessons(_clean_ref(re.sub(r"^\* \*\*[^*]*\*\*\s*", "", line)), lang).strip(); continue
        if line.startswith("* **") and not ent["a"]:
            ent["a"].append(re.sub(r"^\* \*\*[^*]*\*\*\s*", "", line)); continue
        if line.strip() and not line.startswith("---") and not line.startswith("*Selesai"):
            ent["a"].append(line.rstrip())
    return secs

def inline(s):
    s = s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    s = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", s)
    s = re.sub(r"\*(.+?)\*", r"<i>\1</i>", s)
    s = re.sub(r"`([^`]*)`", r"\1", s)
    return s.strip()

def render_answer(lines):
    out, buf = [], []
    def flush():
        nonlocal buf
        if buf: out.append("<p>" + " ".join(inline(b) for b in buf) + "</p>"); buf = []
    items = []
    for l in lines:
        m = re.match(r"^\s{2,}(?:\d+\.|\*)\s+(.*)$", l)
        if m: flush(); items.append(inline(m.group(1)))
        else:
            if items: out.append("<ul>" + "".join(f"<li>{i}</li>" for i in items) + "</ul>"); items = []
            buf.append(l.strip())
    flush()
    if items: out.append("<ul>" + "".join(f"<li>{i}</li>" for i in items) + "</ul>")
    return "".join(out)
