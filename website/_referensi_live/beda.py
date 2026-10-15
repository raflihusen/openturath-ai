import os,re,html,difflib,sys
L='/Volumes/Husen/AKSARAMAH DEV/06_WEBSITE_OPENTURATH_V7/'
def teks(p):
    s=open(p,encoding='utf-8',errors='replace').read()
    m=re.search(r'<main.*?</main>',s,re.S); s=m.group(0) if m else s
    s=re.sub(r'<(script|style)[^>]*>.*?</\1>','',s,flags=re.S); s=re.sub(r'<[^>]+>','\n',s)
    return [x.strip() for x in html.unescape(s).split('\n') if x.strip()]
r=sys.argv[1]
a=teks(L+'dist'+r+'index.html'); b=teks(L+'_referensi_live/halaman'+r+'index.html')
for x in difflib.unified_diff(a,b,lineterm='',n=0):
    if not x.startswith(('+++','---')): print(x[:300])
