import fs from 'node:fs';
import vm from 'node:vm';
import path from 'node:path';
import crypto from 'node:crypto';
import { stripTypeScriptTypes } from 'node:module';

export class Stamp {
  constructor(public ms: number) {}
  toDate() { return new Date(this.ms); }
  toMillis() { return this.ms; }
  static fromDate(d: Date) { return new Stamp(d.getTime()); }
  static fromMillis(ms: number) { return new Stamp(ms); }
  static now() { return new Stamp(Date.now()); }
}
function clone(value: any): any {
  if (value instanceof Stamp) return new Stamp(value.ms);
  if (value instanceof Date) return new Date(value.getTime());
  if (Array.isArray(value)) return value.map(clone);
  if (value && typeof value === 'object') return Object.fromEntries(Object.entries(value).map(([k,v]) => [k,clone(v)]));
  return value;
}
export class MemoryDB {
  docs = new Map<string, any>();
  versions = new Map<string, number>();
  beforeCommit: (() => void) | null = null;
  seed(key: string, value: any) {
    this.docs.set(key, clone(value));
    this.versions.set(key, (this.versions.get(key) || 0) + 1);
  }
  apply(key: string, value: any, merge = false) {
    this.seed(key, merge ? { ...this.docs.get(key), ...value } : value);
  }
  snapshot(key: string) {
    const data = clone(this.docs.get(key));
    return { exists: data !== undefined, id: key.split('/').at(-1), ref: this.doc(key), data: () => clone(data) };
  }
  doc(key: string): any {
    return {
      id: key.split('/').at(-1), path: key,
      get: async () => this.snapshot(key),
      set: async (data: any, opt?: any) => this.apply(key, data, opt?.merge),
      update: async (data: any) => this.apply(key, data, true),
      delete: async () => { this.docs.delete(key); this.versions.set(key,(this.versions.get(key)||0)+1); },
      collection: (name: string) => this.collection(key + '/' + name),
    };
  }
  collection(name: string): any {
    const db = this;
    function query(filters: any[] = [], max = Infinity, cursor = ''): any {
      return {
        doc: (id = crypto.randomUUID()) => db.doc(name + '/' + id),
        add: async (data: any) => { const ref = db.doc(name + '/' + crypto.randomUUID()); await ref.set(data); return ref; },
        where: (k: string, op: string, v: any) => query([...filters,[k,op,v]],max,cursor),
        orderBy: () => query(filters,max,cursor),
        startAfter: (snap: any) => query(filters,max,snap.id),
        limit: (n: number) => query(filters,n,cursor),
        get: async () => {
          const docs = [...db.docs.entries()].filter(([k,v]) => {
            if (!k.startsWith(name + '/') || k.slice(name.length + 1).includes('/') || k.split('/').at(-1)! <= cursor) return false;
            return filters.every(([field,op,expected]) => op === 'in' ? expected.includes(v[field]) : op === '==' ? v[field] === expected : true);
          }).sort(([a],[b])=>a.localeCompare(b)).slice(0,max).map(([k])=>db.snapshot(k));
          return { docs, empty: !docs.length, size: docs.length };
        }
      };
    }
    return query();
  }
  async runTransaction(fn: any) {
    for (let attempt = 0; attempt < 100; attempt++) {
      const reads = new Map<string,number>();
      const writes: any[] = [];
      const result = await fn({
        get: async (ref: any) => {
          if (writes.length) throw Error('Firestore reads must precede writes');
          reads.set(ref.path,this.versions.get(ref.path)||0);
          return this.snapshot(ref.path);
        },
        set: (ref: any, data: any, opt?: any) => writes.push(['set',ref.path,data,opt?.merge]),
        update: (ref: any, data: any) => writes.push(['set',ref.path,data,true]),
        delete: (ref: any) => writes.push(['delete',ref.path]),
      });
      if (this.beforeCommit) { const hook = this.beforeCommit; this.beforeCommit = null; hook(); }
      if ([...reads].some(([k,v])=>(this.versions.get(k)||0)!==v)) continue;
      for (const [kind,k,data,merge] of writes) {
        if (kind === 'delete') this.docs.delete(k);
        else this.apply(k,data,merge);
      }
      return result;
    }
    throw Error('Transaction retry limit');
  }
  async recursiveDelete(ref: any) {
    for (const key of this.docs.keys()) if (key === ref.path || key.startsWith(ref.path + '/')) this.docs.delete(key);
  }
}

export function loadBackend(root = process.cwd()) {
  const db = new MemoryDB();
  const sent: any[] = [];
  const users = new Map<string,any>();
  const axios: any = { post: async (...args: any[]) => { sent.push(args); return {status:200,data:{}}; }, get: async () => ({data:{}}) };
  const auth = {
    getUser: async (uid: string) => { if (!users.has(uid)) throw Object.assign(Error('missing'),{code:'auth/user-not-found'}); return users.get(uid); },
    getUserByEmail: async (email: string) => [...users.values()].find(u=>u.email===email),
    verifyIdToken: async () => ({uid:'u',email:'u@example.test',email_verified:true}),
  };
  const firestore: any = () => db;
  firestore.Timestamp = Stamp;
  firestore.FieldValue = { serverTimestamp: () => Stamp.now(), delete: () => undefined };
  firestore.FieldPath = { documentId: () => '__name__' };
  const chain: any = {
    runWith: () => chain,
    https: { onCall: (fn: any) => fn, onRequest: (fn: any) => fn,
      HttpsError: class extends Error { code: string; constructor(code: string,msg: string){super(msg);this.code=code;} } },
    firestore: { document: () => ({onCreate:(fn: any)=>fn}) },
    auth: { user: () => ({onDelete:(fn: any)=>fn}) },
    pubsub: { schedule: () => ({timeZone:()=>({onRun:(fn: any)=>fn}),onRun:(fn: any)=>fn}) },
    config: () => ({}),
  };
  const deps: any = { 'firebase-functions':chain, 'firebase-admin':{initializeApp:()=>{},firestore,auth:()=>auth}, axios:{default:axios}, crypto };
  // Evaluate the real catalog used by production, including named ES imports.
  const catalogSource = fs.readFileSync(path.join(root, 'functions/src/notebook_catalog.ts'), 'utf8')
    .replace(/export (const|function|async function) /g, '$1 ');
  const catalogExports: any = {};
  vm.runInNewContext(stripTypeScriptTypes(catalogSource + '\nexports.NOTEBOOK_ENTITIES = NOTEBOOK_ENTITIES; exports.AGENT_TO_ENTITY = AGENT_TO_ENTITY; exports.resolveAgentNotebook = resolveAgentNotebook;'),
    {exports: catalogExports, console, Math});
  deps['./notebook_catalog'] = catalogExports;
  const nativeSource = fs.readFileSync(path.join(root, 'functions/src/native_chat.ts'), 'utf8')
    .replace(/export (class|function|async function) /g, '$1 ');
  const nativeExports: any = {};
  vm.runInNewContext(stripTypeScriptTypes(nativeSource + '\nexports.handleNativeChat = handleNativeChat; exports.NativeChatError = NativeChatError;', {mode: 'transform'}),
    {exports: nativeExports});
  deps['./native_chat'] = nativeExports;
  const accessSource = fs.readFileSync(path.join(root, 'functions/src/access_control.ts'), 'utf8')
    .replace(/^import \* as crypto from "crypto";/m, 'const crypto = require("crypto");')
    .replace(/export (const|class|function|async function) /g, '$1 ');
  const accessExports: any = {};
  vm.runInNewContext(stripTypeScriptTypes(accessSource + '\nexports.AccessControl=AccessControl; exports.AccessFault=AccessFault; exports.isVip=isVip; exports.keyOf=keyOf; exports.millis=millis; exports.billingExpiry=billingExpiry;', {mode: 'transform'}),
    {exports:accessExports, require:()=>crypto, Date});
  deps['./access_control'] = accessExports;
  const mappingSource = fs.readFileSync(path.join(root, 'functions/src/access_catalog.ts'), 'utf8')
    .replace(/^import[^\n]+\n/, 'const AGENT_TO_ENTITY = catalog.AGENT_TO_ENTITY;\n')
    .replace(/export const /g, 'const ');
  const mappingExports: any = {};
  vm.runInNewContext(stripTypeScriptTypes(mappingSource + '\nexports.AGENT_ENTITLEMENTS=AGENT_ENTITLEMENTS; exports.ENTITY_SCOPES=ENTITY_SCOPES;'),
    {exports:mappingExports, catalog:catalogExports});
  deps['./access_catalog'] = mappingExports;
  const file = path.join(root,'functions/src/index.ts');
  let source = fs.readFileSync(file,'utf8')
    .replace(/^import \* as (\w+) from "([^"]+)";/gm, 'const $1 = require("$2");')
    .replace(/^import (\w+) from "([^"]+)";/gm, 'const $1 = require("$2").default;')
    .replace(/^import\s*\{([\s\S]*?)\}\s*from\s*"([^"]+)";/gm, 'const {$1} = require("$2");')
    .replace(/export (const|function|async function) /g,'$1 ');
  source += '\nexports.api = {' + [
    'getEntitlementAccess','processSuccessfulPayment','dokuWebhook','getDokuConfig','notifySubscriptionServer',
    'onUserCreate','dailyRevoke','processProvisioningOutbox','cleanupOrphanedDeletions','redeemCode',
    'addCalendarMonthsClamped','verifySubscriptionFirestore','generateDokuSignature','handleLogin','chatGate',
    'getAgentUrl','askAgent','checkPaymentStatus','resolvePlanPricing','createCheckout',
  ].map(n=>n+':typeof '+n+' === "undefined" ? undefined : '+n).join(',') + ', onUserDeleted: typeof onUserDeleted === "undefined" ? undefined : onUserDeleted};';
  const exports: any = {};
  vm.runInNewContext(stripTypeScriptTypes(source), {require:(name: string)=>{if(!(name in deps))throw Error('Unexpected dependency '+name);return deps[name];}, exports, Buffer, process, URL, console:{log(){},warn(){},error(){}},Date, setTimeout,clearTimeout});
  return { api:exports.api, db, axios, auth, users, sent };
}
