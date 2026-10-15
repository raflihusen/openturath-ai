import os,re,html,difflib,collections,sys
L='/Volumes/Husen/AKSARAMAH DEV/06_WEBSITE_OPENTURATH_V7/'
def teks(p,tag):
    s=open(p,encoding='utf-8',errors='replace').read()
    m=re.search(r'<%s\b.*?</%s>'%(tag,tag),s,re.S); s=m.group(0) if m else ''
    s=re.sub(r'<(script|style)[^>]*>.*?</\1>','',s,flags=re.S); s=re.sub(r'<[^>]+>','\n',s)
    s=s.replace('[email\xa0protected]','EMAIL').replace('[email protected]','EMAIL').replace('openturath@gmail.com','EMAIL')
    t=' '.join(x.strip() for x in html.unescape(s).split('\n') if x.strip()); t=t.replace('[email\xa0protected]','EMAIL'); t=re.sub(r'\s*EMAIL\s*',' EMAIL ',t); t=re.sub(r'\s+([.,،:])',r'\1',t)
    return [x.strip() for x in re.split(r'(?<=[.!?؟:])\s+',t) if x.strip()]
ulang=lambda r: r in('/id/','/en/','/ar/') or '/library' in r or r.endswith(('/access/','/tahawwulat/'))
beda=collections.Counter()
for r in open(L+'_referensi_live/rute_live.txt').read().split():
    lc=L+'dist'+r+'index.html'
    if not os.path.exists(lc): beda[r]=-1; continue
    for tag in ('header','main','footer'):
        d=[x for x in difflib.unified_diff(teks(lc,tag),teks(L+'_referensi_live/halaman'+r+'index.html',tag),lineterm='',n=0) if x[:1] in '+-' and not x.startswith(('+++','---'))]
        if d: beda[(r,tag)]=len(d)
tetap=[k for k in beda if not ulang(k[0] if isinstance(k,tuple) else k)]
print('selisih pada halaman yang TIDAK dirombak:',len(tetap)); [print(' ',k,beda[k]) for k in tetap[:20]]
print('selisih pada halaman yang dirombak (wajar):',len(beda)-len(tetap))
if len(sys.argv)>1:
    r,tag=sys.argv[1],sys.argv[2]
    for x in difflib.unified_diff(teks(L+'dist'+r+'index.html',tag),teks(L+'_referensi_live/halaman'+r+'index.html',tag),lineterm='',n=0): print(x[:200])
