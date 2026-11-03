from pathlib import Path
import json
R=Path(__file__).resolve().parent
items=json.loads((R/'slides-id.json').read_text());extensions={}
for p in sorted(R.glob('spoken-*.json')):
 for k,v in json.loads(p.read_text()).items():
  if k in extensions:raise ValueError('Duplicate note '+k)
  extensions[k]=v
for d in items:d['notes']=d['baseNotes']+('\n\n'+extensions[str(d['id'])].strip() if str(d['id']) in extensions else '')
(R/'slides-id.json').write_text(json.dumps(items,ensure_ascii=False,indent=2)+'\n')
print('Expanded',len(extensions),'notes; words min/max',min(len(d['notes'].split()) for d in items if str(d['id']) in extensions),max(len(d['notes'].split()) for d in items if str(d['id']) in extensions))
