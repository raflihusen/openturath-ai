#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mengekstrak naskah hukum kanonik OpenTurath menjadi content/legal.json (tiga bahasa).
Sumber utama: openturath_ai/lib/core/legal_copy{,_en,_ar}.dart (terms, privacy, refund, guideline, contact).
Sumber tambahan (tidak ada di aplikasi): halaman website yang tayang di website/dist/{id,en,ar}/{sources-and-rights,account-deletion,security,accessibility}."""
import re, json, html, pathlib
HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
CORE = ROOT / "openturath_ai/lib/core"
DIST = ROOT / "website/dist"

def lit(expr):
    out, i, n = [], 0, len(expr)
    while i < n:
        c = expr[i]
        if c in "'\"":
            q, j, buf = c, i + 1, []
            while j < n and expr[j] != q:
                if expr[j] == "\\" and j + 1 < n:
                    buf.append({"n": "\n", "t": "\t"}.get(expr[j + 1], expr[j + 1])); j += 2
                else: buf.append(expr[j]); j += 1
            out.append("".join(buf)); i = j + 1
        else: i += 1
    return "".join(out)

def parse_id():
    s = (CORE / "legal_copy.dart").read_text(encoding="utf8")
    res, titles = {}, {}
    for m in re.finditer(r"static const List<LegalSection> (\w+)\s*=\s*\[", s):
        i = m.end(); depth = 1; j = i
        while depth and j < len(s):
            depth += (s[j] == "[") - (s[j] == "]"); j += 1
        block = s[i:j - 1]; secs = []
        for sm in re.finditer(r"LegalSection\(", block):
            k = sm.end(); d = 1; e = k
            while d and e < len(block):
                ch = block[e]
                if ch in "'\"":
                    q = ch; e += 1
                    while e < len(block) and block[e] != q:
                        if block[e] == "\\": e += 1
                        e += 1
                elif ch == "(": d += 1
                elif ch == ")": d -= 1
                e += 1
            body = block[k:e - 1]
            t = re.search(r"title:\s*(.*?),\s*\n\s*content:", body, re.S); c = re.search(r"content:\s*(.*)$", body, re.S)
            secs.append({"title": lit(t.group(1)) if t else "", "content": lit(c.group(1)) if c else ""})
        res[m.group(1)] = secs
    for m in re.finditer(r"static const (\w*Title)\s*=\s*([^;]+);", s): titles[m.group(1)] = lit(m.group(2))
    consts = {k: v for k, v in re.findall(r"static const (?:String )?(\w+)\s*=\s*'([^']*)';", s)}
    # selesaikan interpolasi $documentVersion / $effectiveDate
    for lst in res.values():
        for it in lst:
            for f in ("title", "content"):
                it[f] = it[f].replace("$documentVersion", consts.get("documentVersion", "1.0")).replace("$effectiveDate", consts.get("effectiveDate", ""))
    # selesaikan semua interpolasi Dart ($nama atau ${nama}) dengan konstanta kanonik
    def resolve(t):
        return re.sub(r"\$\{?(\w+)\}?", lambda m: consts.get(m.group(1), m.group(0)), t)
    for lst in res.values():
        for it in lst:
            it["title"], it["content"] = resolve(it["title"]), resolve(it["content"])
    mapping = {"terms": "termsSections", "privacy": "privacySections", "refund": "refundSections", "guideline": "aiGuidelineSections", "contact": "contactSections"}
    return {k: res[v] for k, v in mapping.items()}, consts

def parse_dart_map(fname):
    s = (CORE / fname).read_text(encoding="utf8")
    keys = [(m.group(1), m.start()) for m in re.finditer(r"'(\w+)':\s*\[", s)] + [("_end", len(s))]
    res = {}
    un = lambda t: t.replace("\\'", "'").replace('\\"', '"').replace("\\n", "\n")
    for (k, a), (_, b) in zip(keys, keys[1:]):
        items = re.findall(r"\(\s*(?:'((?:[^'\\]|\\.)*)'|\"((?:[^\"\\]|\\.)*)\")\s*,\s*'''(.*?)'''\s*,?\s*\)", s[a:b], re.S)
        res[k] = [{"title": un(t1 or t2), "content": c.strip()} for t1, t2, c in items]
    return res

def parse_dist(lang, slug):
    p = DIST / lang / slug / "index.html"
    if not p.exists(): return None
    s = p.read_text(encoding="utf8")
    h1 = re.search(r"<h1[^>]*>(.*?)</h1>", s, re.S); art = re.search(r'<article class="reading-content">(.*?)</article>', s, re.S)
    if not art: return None
    secs = []
    for m in re.finditer(r'<section id="section-\d+">\s*<h2>(.*?)</h2>(.*?)</section>', art.group(1), re.S):
        body = m.group(2)
        body = re.sub(r"<svg.*?</svg>", "", body, flags=re.S)
        body = re.sub(r"<a [^>]*>(.*?)</a>", r"\1", body, flags=re.S)
        body = re.sub(r"<br\s*/?>", "\n", body)
        body = re.sub(r"</p>\s*<p>", "\n\n", body); body = re.sub(r"</?p>", "", body)
        body = re.sub(r"<li>(.*?)</li>", r"• \1\n", body, flags=re.S); body = re.sub(r"</?(ul|ol)>", "\n", body)
        body = re.sub(r"<[^>]+>", "", body)
        secs.append({"title": html.unescape(re.sub(r"<[^>]+>", "", m.group(1))).strip(), "content": re.sub(r"\n{3,}", "\n\n", html.unescape(body)).strip()})
    return {"title": html.unescape(re.sub(r"<[^>]+>", "", h1.group(1))).strip() if h1 else slug, "sections": secs}

if __name__ == "__main__":
    idd, consts = parse_id()
    out = {"meta": {"version": consts.get("documentVersion"), "effective": consts.get("effectiveDate"), "email": consts.get("contactSupportEmail"),
                    "hours": consts.get("serviceHours"), "support_sla": consts.get("supportSla"), "refund_sla": consts.get("refundSla")},
           "app": {"id": idd, "en": parse_dart_map("legal_copy_en.dart"), "ar": parse_dart_map("legal_copy_ar.dart")}, "site": {}}
    for lang in ("id", "en", "ar"):
        out["site"][lang] = {}
        for slug in ("sources-and-rights", "account-deletion", "security", "accessibility"):
            d = parse_dist(lang, slug)
            if d: out["site"][lang][slug] = d
    (HERE / "content").mkdir(exist_ok=True)
    (HERE / "content" / "legal.json").write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf8")
    print({l: {k: len(v) for k, v in out["app"][l].items()} for l in ("id", "en", "ar")})
    print({l: {k: len(v["sections"]) for k, v in out["site"][l].items()} for l in ("id", "en", "ar")})
    print(out["meta"])
