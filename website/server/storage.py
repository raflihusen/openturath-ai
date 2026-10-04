"""Private report persistence; no outbound messages or third-party SDKs."""
from pathlib import Path
import hashlib, json, re, sqlite3, time, uuid

class ValidationError(ValueError): pass
class ConflictError(ValueError): pass

def validate_report(data):
    if not isinstance(data,dict): raise ValidationError('invalid_report')
    if data.get('website'): raise ValidationError('invalid_report')
    if data.get('consent') is not True: raise ValidationError('consent_required')
    topic=data.get('topic')
    if topic not in ('reference','technical','access','other'): raise ValidationError('invalid_topic')
    message=data.get('message','')
    if not isinstance(message,str) or not 10<=len(message.strip())<=10000: raise ValidationError('invalid_message')
    email=data.get('email','')
    if not isinstance(email,str) or len(email)>254 or (email and not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+',email)): raise ValidationError('invalid_email')
    try: request_id=str(uuid.UUID(data.get('requestId','')))
    except (ValueError,TypeError,AttributeError): raise ValidationError('invalid_request_id')
    locale=data.get('locale','id')
    if locale not in ('id','en','ar'): raise ValidationError('invalid_locale')
    page=data.get('page','')
    if not isinstance(page,str) or len(page)>500 or not page.startswith('/') or page.startswith('//') or '\n' in page or '\r' in page: raise ValidationError('invalid_page')
    return dict(requestId=request_id,topic=topic,message=message.strip(),email=email.strip(),locale=locale,page=page,consent=True,consentVersion="website-2026-09-20")

class ReportStore:
    def __init__(self,path,retention_days=30):
        self.path=Path(path); self.path.parent.mkdir(parents=True,exist_ok=True)
        self.path.parent.chmod(0o700)
        self.retention_days=int(retention_days)
        if not 1<=self.retention_days<=365: raise ValueError('retentionDays must be between 1 and 365')
        with self.connect() as db:
            db.execute('PRAGMA journal_mode=WAL')
            db.execute('CREATE TABLE IF NOT EXISTS reports (id TEXT PRIMARY KEY, request_id TEXT UNIQUE NOT NULL, created_at INTEGER NOT NULL, fingerprint TEXT NOT NULL, payload TEXT NOT NULL)')
        self.path.chmod(0o600)
        self.purge()
    def connect(self): return sqlite3.connect(self.path,timeout=10)
    def purge(self):
        with self.connect() as db:
            db.execute('DELETE FROM reports WHERE created_at < ?', (int(time.time())-self.retention_days*86400,))
    def save(self,data):
        report=validate_report(data)
        payload=json.dumps(report,ensure_ascii=False,sort_keys=True)
        digest=hashlib.sha256(payload.encode()).hexdigest()
        with self.connect() as db:
            db.execute('BEGIN IMMEDIATE')
            previous=db.execute('SELECT id,fingerprint FROM reports WHERE request_id=?',(report['requestId'],)).fetchone()
            if previous:
                if previous[1]!=digest: raise ConflictError('request_id_conflict')
                return previous[0],False
            report_id='OT-'+uuid.uuid4().hex[:16].upper()
            db.execute('INSERT INTO reports VALUES (?,?,?,?,?)',(report_id,report['requestId'],int(time.time()),digest,payload))
        return report_id,True
