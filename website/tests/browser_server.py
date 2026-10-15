"""Ephemeral local browser fixture. Never changes production config or stores real reports."""
import sys,json,tempfile,signal
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'server'))
from app import ThreadingHTTPServer,make_handler,ROOT
from storage import ReportStore
config=json.loads((ROOT/'site.config.json').read_text())
with tempfile.TemporaryDirectory(prefix='openturath-browser-') as folder:
 store=ReportStore(Path(folder)/'reports.sqlite3',30)
 server=ThreadingHTTPServer(('127.0.0.1',0),make_handler(config,store))
 config['canonicalUrl']='http://127.0.0.1:'+str(server.server_port)
 signal.signal(signal.SIGTERM,lambda *_:sys.exit(0))
 print(config['canonicalUrl'],flush=True)
 try:server.serve_forever()
 finally:server.server_close()
