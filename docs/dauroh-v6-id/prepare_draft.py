from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parent
s=(ROOT/'NASKAH_INDUK_DAUROH_AI_INDONESIA.md').read_text()
matches=list(re.finditer(r'^### (\d{2})\. (.+)$',s,re.M));items=[]
for idx,m in enumerate(matches):
 end=matches[idx+1].start() if idx+1<len(matches) else s.index('\n## Lampiran A')
 chunk=s[m.end():end]
 screen=chunk.split('**Teks layar**',1)[1].split('**Catatan pengajar**',1)[0].strip()
 points=[x[2:].strip() for x in screen.splitlines() if x.startswith('- ')]
 notechunk=chunk.split('**Catatan pengajar**',1)[1]
 base=re.split(r'\n(?:\*\*|### |## )',notechunk,maxsplit=1)[0].strip()
 extra=re.split(r'\n### |\n## ',notechunk,maxsplit=1)[0]
 tails=extra[len(base):].strip()
 prefix=s[:m.start()]
 blocks=list(re.finditer(r'^### Blok (.+)$',prefix,re.M))
 block=blocks[-1].group(1) if blocks else ''
 n=int(m.group(1))
 items.append({'id':n,'day':1 if n<=40 else 2,'block':block,'title':m.group(2),'body':points,'baseNotes':base,'notes':base,'demo':tails})
assert len(items)==80 and all(i['body'] and i['baseNotes'] for i in items)
(ROOT/'slides-id.json').write_text(json.dumps(items,ensure_ascii=False,indent=2)+'\n')
print('Parsed',len(items),'slides')
