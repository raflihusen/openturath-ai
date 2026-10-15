#!/usr/bin/env python3
"""Local preview + report API. Use the WSGI adapter behind HTTPS for production."""
from http.server import ThreadingHTTPServer,SimpleHTTPRequestHandler
from pathlib import Path
from urllib.parse import urlparse,unquote,parse_qs
import html
import os,json,time,threading,hashlib,collections
from storage import ReportStore,ValidationError,ConflictError
ROOT=Path(__file__).resolve().parents[1]
MAX_BODY=50000
CSP="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; font-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'"
class ReportsAPI:
 def __init__(self,config,store):
  self.config=config;self.store=store;self.limits={};self.lock=threading.Lock();self.salt=os.urandom(32)
 def request(self,body,origin,host,client):
  configured=self.config.get('canonicalUrl','').rstrip('/')
  allowed={configured} if configured else {'http://'+host}
  if origin not in allowed:return 403,{'error':'origin_not_allowed'}
  if not self.config.get('reports',{}).get('enabled',False):return 503,{'error':'reports_unavailable'}
  if len(body)>MAX_BODY:return 413,{'error':'request_too_large'}
  key=hashlib.sha256(self.salt+client.encode()).hexdigest();now=time.monotonic()
  with self.lock:
   self.limits={k:[t for t in v if now-t<300] for k,v in self.limits.items() if any(now-t<300 for t in v)}
   recent=self.limits.get(key,[])
   if len(recent)>=8:return 429,{'error':'rate_limited'}
   recent.append(now);self.limits[key]=recent
  try:
   payload=json.loads(body)
   self.store.purge()
   ref,created=self.store.save(payload)
   return (201 if created else 200),{'status':'saved','id':ref}
  except (json.JSONDecodeError,UnicodeDecodeError,ValidationError):return 422,{'error':'invalid_report'}
  except ConflictError:return 409,{'error':'request_id_conflict'}

def make_handler(config,store):
 api=ReportsAPI(config,store)
 class Handler(SimpleHTTPRequestHandler):
  def __init__(self,*args,**kwargs):super().__init__(*args,directory=str(ROOT/'dist'),**kwargs)
  def end_headers(self):
   self.send_header('X-Content-Type-Options','nosniff');self.send_header('Referrer-Policy','strict-origin-when-cross-origin');self.send_header('Content-Security-Policy',CSP if config.get('canonicalUrl') else CSP.replace("frame-ancestors 'none'","frame-ancestors 'self'"));self.send_header('X-Frame-Options','DENY' if config.get('canonicalUrl') else 'SAMEORIGIN');self.send_header('Permissions-Policy','camera=(), microphone=(), geolocation=()');super().end_headers()
  def log_message(self,*args):pass
  def do_GET(self):
   path=urlparse(self.path).path
   if path=='/__qa/' and not config.get('canonicalUrl'):
    route=parse_qs(urlparse(self.path).query).get('path',['/id/'])[0]
    if not route.startswith(('/id/','/en/','/ar/')) or any(x in route for x in ['<','>','"',"'",'\\']):return self.send_error(400)
    body=('<!doctype html><html lang="en"><meta charset="utf-8"><title>Local viewport review</title><style>body{background:#ccc;font:14px system-ui;display:flex;gap:24px;padding:20px}iframe{border:0;background:white}p{margin:0 0 12px}</style><div><p>390 CSS px</p><iframe id="mobile" title="390px mobile preview" src="'+html.escape(route,quote=True)+'" width="390" height="840"></iframe></div><div><p>320 CSS px</p><iframe id="narrow" title="320px mobile preview" src="'+html.escape(route,quote=True)+'" width="320" height="840"></iframe></div></html>').encode()
    self.send_response(200);self.send_header('Content-Type','text/html; charset=utf-8');self.send_header('Content-Length',str(len(body)));self.end_headers();self.wfile.write(body);return
   target=Path(self.translate_path(path)).resolve()
   if not target.is_relative_to((ROOT/'dist').resolve()):return self.send_error(403)
   if path.startswith('/api/'):return self.send_error(404)
   if not target.exists():
    loc=path.split('/')[1] if path.split('/')[1] in ('id','en','ar') else 'id'
    content=(ROOT/'dist'/loc/'404/index.html').read_bytes();self.send_response(404);self.send_header('Content-Type','text/html; charset=utf-8');self.send_header('Content-Length',str(len(content)));self.end_headers();self.wfile.write(content);return
   return super().do_GET()
  def do_POST(self):
   if urlparse(self.path).path!='/api/reports':return self.send_error(404)
   if self.headers.get('Content-Type','').split(';')[0]!='application/json':return self.send_error(415)
   try:length=int(self.headers.get('Content-Length','-1'))
   except ValueError:return self.send_error(400)
   if length<0 or length>MAX_BODY:return self.send_error(413)
   self.connection.settimeout(15)
   try:
    body=self.rfile.read(length)
    status,result=api.request(body,self.headers.get('Origin',''),self.headers.get('Host',''),self.client_address[0])
   except Exception:status,result=500,{'error':'storage_unavailable'}
   data=json.dumps(result).encode();self.send_response(status);self.send_header('Content-Type','application/json');self.send_header('Cache-Control','no-store');self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data)
 return Handler

def main():
 config=json.loads((ROOT/'site.config.json').read_text())
 store=ReportStore(Path(os.environ.get('OT_DATA_DIR',str(ROOT/'server/data')))/'reports.sqlite3',config['reports']['retentionDays'])
 server=ThreadingHTTPServer((os.environ.get('HOST','0.0.0.0'),int(os.environ.get('PORT','4173'))),make_handler(config,store))
 print('OpenTurath preview ready. Report data remains private; no emails are sent.',flush=True)
 try:server.serve_forever()
 except KeyboardInterrupt:pass
 finally:server.server_close()
if __name__=='__main__':main()
