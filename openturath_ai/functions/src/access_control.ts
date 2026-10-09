import * as crypto from "crypto";

// Shared by Firebase callable functions and the Ubuntu worker. No Google RPC in
// database transactions; opening a notebook never allocates a seat.
export const VIP_EMAILS = new Set([
  "openturath@gmail.com", "ramah@ptct.net", "raflimaulan@gmail.com", "mas.raflihusen@gmail.com",
  "alkhateeb23@gmail.com", "omarasb1441@gmail.com", "prilatief@gmail.com", "udinvoldigoad05@gmail.com",
  "aaadman40@gmail.com", "abo.omar5539@gmail.com", "abualgilani2024@gmail.com", "ahobh4241@gmail.com",
  "alhamodi65@gmail.com", "ali.bafdhl36@gmail.com", "alshykhkmalbahrmz@gmail.com", "atinrahmak@gmail.com",
  "hafamfb551985@gmail.com", "loyos839@gmail.com", "mohammedhalahdal@gmail.com", "mostajadt25@gmail.com",
  "nona.alyaziza@gmail.com", "omar739037802@gmail.com", "yasser110271@gmail.com",
]);
export const normalEmail = (s: unknown): string => typeof s === "string" ? s.trim().toLowerCase() : "";
export const keyOf = (...parts: string[]): string => crypto.createHash("sha256").update(JSON.stringify(parts)).digest("hex");
export const millis = (v: any): number => v?.toMillis?.() ?? (v?.toDate ? v.toDate().getTime() : typeof v === "number" ? v : Date.parse(v || ""));
export const isVip = (u: any, grants: any[] = []): boolean => VIP_EMAILS.has(normalEmail(u?.email)) ||
  u?.is_vip === true || ["vip", "admin", "guru", "special"].includes(String(u?.role || "").toLowerCase()) ||
  grants.some(g => g.kind === "VIP_PERMANENT");
export function rights(u: any, grants: any[], scope: string, now = Date.now()): boolean {
  if (isVip(u, grants)) return true;
  if (!u || u.account_deleted || u.pending_deletion) return false;
  return grants.some(g => g.status === "active" && [scope, "all_access", "all_ai"].includes(g.scope) &&
    Number.isFinite(g.expires_ms) && g.expires_ms > now &&
    (g.kind === "payment" && g.amount > 0 || g.kind === "admin" && g.admin_verified === true || g.kind === "voucher"));
}
export class AccessFault extends Error {
  constructor(public code: string, message: string) { super(message); }
}
export interface Entity { code: string; legacyIds?: string[]; masterId: string; masterUrl: string; name: string; clones: Array<{id: string; url: string; name: string}>; }
export interface ShareObservation { notebookId: string; isPublic: boolean; emails: string[]; complete: boolean; }
export interface Provider { observe(id: string): Promise<ShareObservation>; apply(id: string, email: string, desired: boolean): Promise<ShareObservation>; }

export class AccessControl {
  constructor(public db: any, public entities: Record<string, Entity>, public scopes: Record<string, string>,
    public provider?: Provider, public clock: () => number = Date.now) {}
  assignmentRef(uid: string, entity: string): any { return this.db.collection("access_assignments").doc(keyOf(uid, entity)); }
  async grants(uid: string): Promise<any[]> {
    const s = await this.db.collection("access_grants").where("uid", "==", uid).get();
    return s.docs.map((d: any) => ({id: d.id, ...d.data()}));
  }
  async owner(uid: string): Promise<{user: any; grants: any[]}> {
    const [u, grants] = await Promise.all([this.db.collection("users").doc(uid).get(), this.grants(uid)]);
    return {user: u.data(), grants};
  }
  async resolve(uid: string, entity: string): Promise<any> {
    const {user, grants} = await this.owner(uid);
    if (!rights(user, grants, this.scopes[entity], this.clock())) throw new AccessFault("permission-denied", "Hak akses kajian ini sudah tidak aktif.");
    const a = (await this.assignmentRef(uid, entity).get()).data();
    if (!a || a.status !== "ready" || a.email !== normalEmail(user.email)) {
      throw new AccessFault("failed-precondition", "Pembayaran/hak akses tercatat. Akses notebook sedang disiapkan; Anda tidak perlu membeli ulang.");
    }
    const n = (await this.db.collection("access_notebooks").doc(a.notebook_id).get()).data();
    if (!n || n.entity !== entity || !["active", "draining"].includes(n.status) || n.is_public !== false || !a.verified_ms) {
      throw new AccessFault("unavailable", "Notebook sedang diperiksa. Silakan coba lagi.");
    }
    return {status: "ready", url: `https://notebook.google.com/notebook/${a.notebook_id}`, notebookId: a.notebook_id,
      entityCode: entity, revision: a.revision, isMaster: a.notebook_id === this.entities[entity].masterId,
      cloneName: n.name, validUntil: new Date(this.clock() + 60000).toISOString()};
  }
  async reserve(uid: string, entity: string): Promise<any> {
    const {user, grants} = await this.owner(uid);
    if (!rights(user, grants, this.scopes[entity], this.clock())) throw new AccessFault("permission-denied", "No current grant");
    const email = normalEmail(user.email);
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new AccessFault("failed-precondition", "Verified owner email required");
    const e = this.entities[entity];
    if (!e) throw new AccessFault("invalid-argument", "Unknown entity");
    const ids = [e.masterId, ...e.clones.map(c => c.id), ...(e.legacyIds || [])];
    const ar = this.assignmentRef(uid, entity);
    const identity = this.db.collection("access_identities").doc(keyOf(email, entity));
    return this.db.runTransaction(async (t: any) => {
      const existing = (await t.get(ar)).data();
      const bound = (await t.get(identity)).data();
      if (bound && bound.uid !== uid) throw new AccessFault("failed-precondition", "Google identity requires ownership recovery");
      if (existing && existing.email !== email) throw new AccessFault("failed-precondition", "Email change requires verified migration");
      if (existing && ["ready", "provisioning"].includes(existing.status)) return existing;
      const candidates = [];
      for (const id of ids) {
        const nr = this.db.collection("access_notebooks").doc(id);
        const mr = this.db.collection("access_memberships").doc(keyOf(id, email));
        candidates.push({id, nr, mr, n: (await t.get(nr)).data(), m: (await t.get(mr)).data()});
      }
      // Reuse observed registration before waterfall: imports retain the real
      // notebook and do not consume a second seat, including legacy notebooks.
      const found = candidates.find(c => c.m?.present === true && c.n?.is_public === false && ["active", "draining"].includes(c.n?.status)) ||
        candidates.find(c => c.n?.status === "active" && c.n?.is_public === false &&
          c.n?.healthy_until_ms > this.clock() && c.n.occupied < Math.min(2000, c.n.admission_limit || 1995));
      if (!found) throw new AccessFault("resource-exhausted", "paid_waiting_capacity");
      const revision = (existing?.revision || 0) + 1;
      const assignment = {uid, entity, scope: this.scopes[entity], email, notebook_id: found.id,
        status: "provisioning", revision, created_ms: existing?.created_ms || this.clock(),
        history: [...new Set([...(existing?.history || []), found.id])], updated_ms: this.clock()};
      if (!found.m?.present) t.update(found.nr, {occupied: found.n.occupied + 1});
      t.set(found.mr, {uid, entity, email, notebook_id: found.id, present: found.m?.present === true,
        counted: true, revision, reserved_ms: this.clock()}, {merge: true});
      t.set(identity, {uid, email, entity});
      t.set(ar, assignment);
      t.set(this.db.collection("access_jobs").doc(keyOf(uid, entity, String(revision))), {
        ...assignment, desired: true, status: "pending", attempts: 0, due_ms: this.clock()});
      return assignment;
    });
  }
  async revoke(uid: string, entity: string): Promise<void> {
    const {user, grants} = await this.owner(uid);
    if (rights(user, grants, this.scopes[entity], this.clock())) return;
    const ar = this.assignmentRef(uid, entity);
    await this.db.runTransaction(async (t: any) => {
      const a = (await t.get(ar)).data();
      if (!a || ["revoked", "revoking"].includes(a.status)) return;
      const revision = a.revision + 1;
      t.update(ar, {status: "revoking", revision, updated_ms: this.clock()});
      for (const notebook of a.history || [a.notebook_id]) {
        t.set(this.db.collection("access_jobs").doc(keyOf(uid, entity, String(revision), notebook)), {
          ...a, notebook_id: notebook, revision, desired: false, status: "pending", attempts: 0, due_ms: this.clock()});
      }
    });
  }
  async repair(uid: string, entity: string): Promise<void> {
    const owner = await this.owner(uid);
    if (!rights(owner.user, owner.grants, this.scopes[entity], this.clock())) return this.revoke(uid, entity);
    const ar = this.assignmentRef(uid, entity);
    await this.db.runTransaction(async (t: any) => {
      const a = (await t.get(ar)).data();
      if (!a || a.status !== "ready") return;
      const revision = a.revision + 1;
      t.update(ar, {status: "provisioning", revision, updated_ms: this.clock()});
      t.set(this.db.collection("access_jobs").doc(keyOf(uid, entity, String(revision))), {
        ...a, revision, desired: true, status: "pending", attempts: 0, due_ms: this.clock()});
    });
  }
  async runJob(ref: any): Promise<void> {
    if (!this.provider) throw new Error("Sharing provider is not configured");
    const token = crypto.randomUUID(), now = this.clock();
    const job = await this.db.runTransaction(async (t: any) => {
      const j = (await t.get(ref)).data();
      if (!j || !["pending", "retry", "processing"].includes(j.status) || j.due_ms > now) return null;
      const lr = this.db.collection("access_locks").doc(keyOf(j.notebook_id, j.email));
      const lock = (await t.get(lr)).data();
      if (lock?.until_ms > now) return null;
      t.set(lr, {token, until_ms: now + 300000});
      t.update(ref, {status: "processing", lease: token, due_ms: now + 300000, attempts: (j.attempts || 0) + 1});
      return {...j, lockRef: lr, attempts: (j.attempts || 0) + 1};
    });
    if (!job) return;
    try {
      let owner = await this.owner(job.uid);
      const a = (await this.assignmentRef(job.uid, job.entity).get()).data();
      if (!a || a.revision !== job.revision || job.desired !== rights(owner.user, owner.grants, job.scope, this.clock())) {
        await ref.update({status: "superseded", due_ms: 8640000000000000}); return;
      }
      if (!job.desired && isVip(owner.user, owner.grants)) throw new Error("Protected VIP");
      const observation = await this.provider.apply(job.notebook_id, job.email, job.desired);
      this.validateObservation(observation, job.notebook_id);
      const present = observation.emails.map(normalEmail).includes(job.email);
      if (present !== job.desired) throw new Error("Target membership not verified");
      owner = await this.owner(job.uid);
      const desiredNow = rights(owner.user, owner.grants, job.scope, this.clock());
      if (desiredNow !== job.desired) {
        // Database and Google are not atomic. Repair a concurrent renewal or
        // expiry before declaring the stale operation complete.
        await this.provider.apply(job.notebook_id, job.email, desiredNow);
        throw new Error("Grant changed during external operation; repair queued");
      }
      await this.db.runTransaction(async (t: any) => {
        const current = (await t.get(this.assignmentRef(job.uid, job.entity))).data();
        const lock = (await t.get(job.lockRef)).data();
        const mr = this.db.collection("access_memberships").doc(keyOf(job.notebook_id, job.email));
        const member = (await t.get(mr)).data();
        const nr = this.db.collection("access_notebooks").doc(job.notebook_id);
        const notebook = (await t.get(nr)).data();
        if (lock?.token !== token || current?.revision !== job.revision) throw new Error("Lease/revision changed after sharing");
        t.set(mr, {present, verified_ms: this.clock()}, {merge: true});
        if (!present && member?.counted && notebook) {
          t.update(nr, {occupied: Math.max(0, notebook.occupied - 1)});
          t.set(mr, {counted: false}, {merge: true});
        }
        t.update(ref, {status: "completed", due_ms: 8640000000000000, verified_ms: this.clock()});
        // For multi-target revokes only this target is confirmed here. A later
        // reconciliation marks the overall assignment revoked once all finish.
        if (job.desired) t.update(this.assignmentRef(job.uid, job.entity), {status: "ready", verified_ms: this.clock()});
      });
    } catch (e: any) {
      await ref.update({status: "retry", last_error: String(e.message).slice(0, 240),
        due_ms: this.clock() + Math.min(300000, 1000 * 2 ** Math.min(job.attempts, 8)), updated_ms: this.clock()});
    } finally {
      await this.db.runTransaction(async (t: any) => {
        if ((await t.get(job.lockRef)).data()?.token === token) t.delete(job.lockRef);
      });
    }
  }
  validateObservation(s: ShareObservation, id: string): void {
    if (s.notebookId !== id || !s.complete || s.isPublic || !Array.isArray(s.emails) || s.emails.some(e => !normalEmail(e).includes("@"))) {
      throw new Error("Notebook is public or sharing evidence is incomplete");
    }
  }
}
