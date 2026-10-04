#!/usr/bin/env python3
"""Portable deliverable; never include live reports, secrets or machine caches."""
from pathlib import Path
import zipfile,hashlib,sys
root=Path(__file__).resolve().parents[1]
out=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else root.parent/'OPENTURATH_WEBSITE_COMPLETE.zip'
allowed={'src','public','content','scripts','tests','docs','server','dist','deploy'}
rootfiles={'README.md','START_HERE.html','package.json','site.config.json','.gitignore','LICENSES.md'}
files=[]
for f in sorted(root.rglob('*')):
 if not f.is_file() or f.is_symlink():continue
 p=f.relative_to(root)
 if p.parts[0] not in allowed and str(p) not in rootfiles:continue
 if '__pycache__' in p.parts or 'data' in p.parts or f.suffix in ('.sqlite3','.db','.pyc') or f.name.startswith('.env'):continue
 if f.name.endswith('.backup.json'):continue
 files.append(f)
if not (root/'dist/index.html').exists():raise SystemExit('Run npm run build first.')
out.parent.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 for f in files:z.write(f,'openturath-website/'+str(f.relative_to(root)))
 manifest='\n'.join(hashlib.sha256(f.read_bytes()).hexdigest()+'  '+str(f.relative_to(root)) for f in files)+'\n'
 z.writestr('openturath-website/SHA256SUMS.txt',manifest)
with zipfile.ZipFile(out) as z:
 if z.testzip():raise SystemExit('ZIP integrity check failed')
print(f'{out}\n{len(files)} files; {out.stat().st_size:,} bytes\nSHA-256: {hashlib.sha256(out.read_bytes()).hexdigest()}')
