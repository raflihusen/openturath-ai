#!/usr/bin/env python3
"""Local-only report administration. Run on the server, never expose as a URL."""
import argparse,json,os
from pathlib import Path
from storage import ReportStore
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('action',choices=['list','export','purge','delete']);p.add_argument('--id');p.add_argument('--output');args=p.parse_args()
c=json.loads((ROOT/'site.config.json').read_text());s=ReportStore(Path(os.environ.get('OT_DATA_DIR',str(ROOT/'server/data')))/'reports.sqlite3',c['reports']['retentionDays'])
if args.action=='purge':s.purge();print('Retention policy applied.')
elif args.action=='delete':
 if not args.id:p.error('--id is required')
 with s.connect() as db:result=db.execute('DELETE FROM reports WHERE id=?',(args.id,));print(f'{result.rowcount} report(s) deleted.')
else:
 with s.connect() as db:rows=db.execute('SELECT id,created_at,payload FROM reports ORDER BY created_at DESC').fetchall()
 data=[{'id':a,'createdAt':b,**json.loads(c)} for a,b,c in rows]
 if args.action=='export':
  if not args.output:p.error('--output is required')
  f=Path(args.output);f.write_text(json.dumps(data,ensure_ascii=False,indent=2));f.chmod(0o600);print(f'{len(data)} reports exported.')
 else:
  for x in data:print(x['id'],x['createdAt'],x['topic'],x['locale'])
