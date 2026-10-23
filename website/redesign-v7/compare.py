"""Perbandingan satu pertanyaan, enam AI: arsip jawaban asli (Q001)."""
import json, re
from pathlib import Path
HERE = Path(__file__).parent

def _inl(s):
    s = s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    s = re.sub(r"\[(\d+)\]", r"<sup>\1</sup>", s)
    s = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", s)
    s = re.sub(r"(?<![\*\w])\*(?!\s)(.+?)(?<!\s)\*(?!\*)", r"<i>\1</i>", s)
    s = re.sub(r"`([^`]*)`", r"\1", s)
    s = re.sub(r"«(.+?)»", r'<span class="arq">«\1»</span>', s)
    s = re.sub(r"[﴿{]([^}﴾]+)[﴾}]", lambda m: f'<span class="arq">﴿{m.group(1)}﴾</span>' if re.search(r"[؀-ۿ]", m.group(1)) else m.group(0), s)
    return s

def md_full(text):
    out, buf, stack = [], [], []  # stack: open list tags with indent
    def flush():
        nonlocal buf
        if buf: out.append("<p>" + "<br>".join(_inl(x) for x in buf) + "</p>"); buf = []
    def close_to(ind):
        while stack and stack[-1][1] >= ind:
            out.append("</li></" + stack.pop()[0] + ">")
    for raw in text.split("\n"):
        line = raw.rstrip()
        if not line.strip(): flush(); continue
        m = re.match(r"^(#{1,6})\s+(.*)$", line)
        if m:
            flush(); close_to(0); lvl = min(6, max(3, len(m.group(1)) + 1)); out.append(f"<h{lvl}>{_inl(m.group(2))}</h{lvl}>"); continue
        if re.match(r"^-{3,}$", line.strip()): flush(); close_to(0); out.append("<hr>"); continue
        m = re.match(r"^(\s*)([-*•]|\d+\.)\s+(.*)$", line)
        if m:
            flush(); ind = len(m.group(1)); tag = "ol" if m.group(2)[0].isdigit() else "ul"
            if stack and stack[-1][1] == ind and stack[-1][0] == tag: out.append("</li><li>")
            elif stack and stack[-1][1] < ind: out.append(f"<{tag}><li>"); stack.append((tag, ind))
            else:
                close_to(ind + 1) if stack else None
                if stack and stack[-1][1] == ind and stack[-1][0] == tag: out.append("</li><li>")
                else: out.append(f"<{tag}><li>"); stack.append((tag, ind))
            out.append(_inl(m.group(3))); continue
        if stack and re.match(r"^\s+\S", line): out.append("<br>" + _inl(line.strip())); continue
        close_to(0); buf.append(line.strip())
    flush(); close_to(0)
    return "".join(out)

def load():
    ev = json.loads((HERE.parent / "content" / "evaluation.json").read_text(encoding="utf8"))
    runs = [{"id": r["id"], "name": "OpenTurath" if r["id"] == "openturath" else r["name"], "url": (r.get("url") or ""), "text": r["text"]} for r in ev["runs"]]
    runs.sort(key=lambda r: r["id"] != "openturath")
    for r in runs:
        if r["id"] == "openturath":
            t = r["text"].split("📊")[0].rstrip().rstrip("-").rstrip()
            r["text"] = re.sub(r"^▸.*\n", "", t).lstrip()
        r["words"] = len(re.findall(r"\S+", re.sub(r"[#*`>|-]", " ", r["text"])))
        r["arq"] = len(re.findall(r"«[^»]+»|\{[^}]*[؀-ۿ][^}]*\}|﴿[^﴾]+﴾", r["text"]))
    return ev["question"], runs
