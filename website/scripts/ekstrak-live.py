#!/usr/bin/env python3
"""V7: simpan isi <main> setiap halaman openturath.id (versi live) ke content/live/<lokal>/<rute>.json.
Email yang disamarkan Cloudflare (data-cfemail) didekode kembali; skrip Cloudflare dibuang."""
import os, re, json, html
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + '/'
SRC = R + '_referensi_live/halaman'; OUT = R + 'content/live/'
def cf(hexs):
    k = int(hexs[:2], 16); return ''.join(chr(int(hexs[i:i + 2], 16) ^ k) for i in range(2, len(hexs), 2))
def bersih(s):
    s = re.sub(r'<a href="/cdn-cgi/l/email-protection#([0-9a-f]+)"', lambda m: '<a href="mailto:%s"' % cf(m.group(1)), s)
    s = re.sub(r'<(?:span|a)[^>]*class="__cf_email__"[^>]*data-cfemail="([0-9a-f]+)"[^>]*>\[email&#160;protected\]</(?:span|a)>', lambda m: cf(m.group(1)), s)
    s = re.sub(r'<script[^>]*cloudflare[^>]*>\s*</script>', '', s)
    return s
n = 0
for dp, _, fs in os.walk(SRC):
    if 'index.html' not in fs: continue
    route = dp[len(SRC):].strip('/')
    loc, _, rest = route.partition('/')
    s = open(dp + '/index.html', encoding='utf-8').read()
    m = re.search(r'<main[^>]*>(.*)</main>', s, re.S)
    if not m: continue
    title = html.unescape(re.search(r'<title>(.*?)</title>', s, re.S).group(1)).replace(' — OpenTurath', '')
    desc = re.search(r'<meta name="description" content="([^"]*)"', s)
    out = OUT + loc + '/' + (rest or '_beranda') + '.json'
    os.makedirs(os.path.dirname(out), exist_ok=True)
    json.dump({'title': title, 'description': html.unescape(desc.group(1)) if desc else '', 'main': bersih(m.group(1))}, open(out, 'w', encoding='utf-8'), ensure_ascii=False)
    n += 1
print('halaman live disimpan:', n)
