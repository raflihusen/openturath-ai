// Loads the real access_worker.ts against MemoryDB with every external effect stubbed.
import fs from 'node:fs';
import vm from 'node:vm';
import path from 'node:path';
import {stripTypeScriptTypes} from 'node:module';
import * as AC from '../src/access_control.ts';
import * as CAT from '../src/notebook_catalog.ts';
import {MemoryDB, Stamp} from './audit_harness.ts';

const SRC = path.join(import.meta.dirname, '../src');
const MAP: any = {};
vm.runInNewContext(stripTypeScriptTypes(fs.readFileSync(path.join(SRC, 'access_catalog.ts'), 'utf8')
  .replace(/^import[^\n]+\n/, 'const AGENT_TO_ENTITY = catalog.AGENT_TO_ENTITY, NOTEBOOK_ENTITIES = catalog.NOTEBOOK_ENTITIES;\n')
  .replace(/export (const|function) /g, '$1 '), {mode: 'transform'})
  + '\nexports.AGENT_ENTITLEMENTS=AGENT_ENTITLEMENTS;exports.ENTITY_SCOPES=ENTITY_SCOPES;exports.resolveAkalScopes=resolveAkalScopes;',
  {exports: MAP, catalog: CAT});
export const CATALOG = CAT;
export const SCOPES = MAP;

// `mode` is the worker CLI flag, e.g. "--prepare-assignments" runs one assignments() pass.
export async function runWorker(db: MemoryDB, authUsers: Map<string, any>, mode = '--prepare-assignments', settleMs = 100) {
  const src = fs.readFileSync(path.join(SRC, 'access_worker.ts'), 'utf8')
    .replace(/^import \* as admin from "firebase-admin";/m, 'const admin = deps.admin;')
    .replace(/^import \{([\s\S]*?)\} from "([^"]+)";/gm, "const {$1} = deps['$2'];");
  const admin = {
    initializeApp() {},
    firestore: Object.assign(() => db, {FieldPath: {documentId: () => '__name__'},
      // Like the real SDK, a non-finite instant is rejected.
      Timestamp: {fromMillis: (ms: number) => { if (!Number.isFinite(ms)) throw new Error('invalid timestamp'); return Stamp.fromMillis(ms); }},
      FieldValue: {delete: () => null, serverTimestamp: () => Stamp.now()}}),
    auth: () => ({getUser: async (uid: string) => {
      const u = authUsers.get(uid);
      if (!u) throw Object.assign(Error('missing'), {code: 'auth/user-not-found'});
      return u;
    }}),
  };
  const deps: any = {admin, child_process: {execFile() {}}, http: {createServer: () => ({listen() {}})},
    'fs/promises': {}, util: {promisify: (f: any) => f}, './access_control': AC, './notebook_catalog': CAT, './access_catalog': MAP};
  const ctx: any = {deps, process: {env: {}, argv: ['node', 'worker', mode], exitCode: 0}, console: {log() {}, error() {}},
    Date, setTimeout, JSON, Math, Promise, Object, Array, Set, Map, Number, String, Error};
  vm.runInNewContext(stripTypeScriptTypes(src, {mode: 'transform'}), ctx);
  await new Promise(r => setTimeout(r, settleMs));
}

export function seedNotebooks(db: MemoryDB, now: number, occupied = 0) {
  for (const [id, e] of Object.entries<any>(CAT.NOTEBOOK_ENTITIES)) for (const n of [e.masterId, ...e.clones.map((c: any) => c.id)])
    db.seed(`access_notebooks/${n}`, {entity: id, occupied, admission_limit: 1995, status: 'active', is_public: false, healthy_until_ms: now + 86400000});
}
