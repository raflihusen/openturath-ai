"""Production report API: gunicorn --chdir server wsgi:application --workers 1 --threads 4
Serve dist/ through Nginx; route only /api/reports to this process.
"""
from pathlib import Path
import os,json,ipaddress
from app import ReportsAPI,MAX_BODY,ROOT
from storage import ReportStore
config=json.loads((ROOT/'site.config.json').read_text())
if not config.get('canonicalUrl','').startswith('https://'):raise RuntimeError('Configure HTTPS canonicalUrl before production startup')
store=ReportStore(Path(os.environ.get('OT_DATA_DIR',str(ROOT/'server/data')))/'reports.sqlite3',config['reports']['retentionDays'])
api=ReportsAPI(config,store)
def application(environ,start_response):
 status=404;result={'error':'not_found'}
 if environ.get('PATH_INFO')=='/api/reports':
  if environ.get('REQUEST_METHOD')!='POST':status,result=405,{'error':'method_not_allowed'}
  elif environ.get('CONTENT_TYPE','').split(';')[0]!='application/json':status,result=415,{'error':'json_required'}
  else:
   try:length=int(environ.get('CONTENT_LENGTH','0'))
   except ValueError:length=-1
   if length<0 or length>MAX_BODY:status,result=413,{'error':'request_too_large'}
   else:
    try:
     client=environ.get('REMOTE_ADDR','')
     if os.environ.get('OT_TRUST_LOCAL_PROXY')=='1' and client in ('127.0.0.1','::1'):
      try:client=str(ipaddress.ip_address(environ.get('HTTP_X_REAL_IP','')))
      except ValueError:pass
     status,result=api.request(environ['wsgi.input'].read(length),environ.get('HTTP_ORIGIN',''),environ.get('HTTP_HOST',''),client)
    except Exception:status,result=500,{'error':'storage_unavailable'}
 reasons={200:'OK',201:'Created',403:'Forbidden',404:'Not Found',405:'Method Not Allowed',409:'Conflict',413:'Payload Too Large',415:'Unsupported Media Type',422:'Unprocessable Entity',429:'Too Many Requests',500:'Internal Server Error',503:'Service Unavailable'}
 output=json.dumps(result).encode();start_response(f'{status} {reasons[status]}',[('Content-Type','application/json'),('Content-Length',str(len(output))),('Cache-Control','no-store'),('X-Content-Type-Options','nosniff')]);return [output]
