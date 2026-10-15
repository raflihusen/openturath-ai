import sys,tempfile,unittest,uuid,sqlite3,time,json
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'server'))
from storage import ReportStore,validate_report,ValidationError,ConflictError
class ReportsTest(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.store=ReportStore(Path(self.tmp.name)/'reports.sqlite3')
  self.data={'topic':'reference','message':'Testing a source correction','email':'','consent':True,'website':'','locale':'id','page':'/id/report/','requestId':str(uuid.uuid4())}
 def tearDown(self):self.tmp.cleanup()
 def test_valid_report_is_persisted_and_duplicate_is_idempotent(self):
  first,created=self.store.save(self.data);second,again=self.store.save(self.data)
  self.assertEqual(first,second);self.assertTrue(created);self.assertFalse(again)
  with self.store.connect() as db:self.assertEqual(db.execute('SELECT COUNT(*) FROM reports').fetchone()[0],1)
 def test_saved_report_records_consent_and_policy_version(self):
  self.store.save(self.data)
  with self.store.connect() as db:payload=json.loads(db.execute('SELECT payload FROM reports').fetchone()[0])
  self.assertIs(payload['consent'],True)
  self.assertEqual(payload['consentVersion'],'website-2026-09-20')
 def test_reused_request_id_cannot_change_saved_report(self):
  self.store.save(self.data);self.data['message']='Different body under the same id'
  with self.assertRaises(ConflictError):self.store.save(self.data)
 def test_consent_and_message_validation(self):
  for field,value in [('consent',False),('message','short'),('topic','security'),('email','bad'),('page','https://evil.test'),('page','//evil.test'),('website','spam')]:
   with self.subTest(field=field):
    with self.assertRaises(ValidationError):validate_report(dict(self.data,**{field:value}))
 def test_retention_removes_expired_reports(self):
  self.store.save(self.data)
  with self.store.connect() as db:db.execute('UPDATE reports SET created_at=?',(int(time.time())-31*86400,))
  self.store.purge()
  with self.store.connect() as db:self.assertEqual(db.execute('SELECT COUNT(*) FROM reports').fetchone()[0],0)
if __name__=='__main__':unittest.main()

class APITest(ReportsTest):
 def setUp(self):
  super().setUp()
  from app import ReportsAPI
  self.api=ReportsAPI({'canonicalUrl':'https://example.com','reports':{'enabled':True}},self.store)
 def call(self,data=None,origin='https://example.com',client='test'):
  import json
  return self.api.request(json.dumps(data or self.data).encode(),origin,'example.com',client)
 def test_origin_and_disabled_service(self):
  self.assertEqual(self.call(origin='https://other.example')[0],403)
  self.api.config['reports']['enabled']=False
  self.assertEqual(self.call()[0],503)
 def test_persistence_and_rate_limit(self):
  self.assertEqual(self.call()[0],201)
  self.assertEqual(self.call()[0],200)
  for _ in range(6):self.call()
  self.assertEqual(self.call()[0],429)
 def test_invalid_json_and_size(self):
  self.assertEqual(self.api.request(b'{','https://example.com','example.com','test')[0],422)
  self.assertEqual(self.api.request(b'x'*50001,'https://example.com','example.com','test')[0],413)
