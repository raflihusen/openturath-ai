import test from "node:test";
import assert from "node:assert/strict";
import {AccessControl, isVip, keyOf, rights} from "../src/access_control.ts";
import {MemoryDB} from "./audit_harness.ts";

const entity = "entity", scope = "fiqh_syafii", now = 100000;
function setup(occupied = 0, limit = 2) {
  const db = new MemoryDB();
  const members = new Map<string, Set<string>>();
  const calls: any[] = [];
  const provider = {
    async observe(id: string) {return {notebookId: id, isPublic: false, complete: true, emails: [...(members.get(id) || [])]};},
    async apply(id: string, email: string, desired: boolean) {
      calls.push({id, email, desired});
      if (!members.has(id)) members.set(id, new Set());
      if (desired) members.get(id)!.add(email); else members.get(id)!.delete(email);
      return this.observe(id);
    },
  };
  const e = {code: entity, name: "E", masterId: "master", masterUrl: "", clones: [{id: "clone", name: "C", url: ""}]};
  const engine = new AccessControl(db, {[entity]: e}, {[entity]: scope}, provider, () => now);
  for (const id of ["master", "clone"]) db.seed(`access_notebooks/${id}`, {entity, name: id, occupied, admission_limit: limit,
    status: "active", is_public: false, healthy_until_ms: now + 60000});
  function user(uid: string, extra = {}) {
    db.seed(`users/${uid}`, {email: `${uid}@example.test`, ...extra});
    db.seed(`access_grants/${uid}`, {uid, scope, kind: "payment", status: "active", amount: 50000, expires_ms: now + 60000});
  }
  async function jobs() {
    const s = await db.collection("access_jobs").get();
    for (const d of s.docs) await engine.runJob(d.ref);
  }
  return {db, engine, user, members, provider, jobs, calls};
}
test("100 concurrent opens/reservations for one UID consume exactly one seat", async () => {
  const {db, engine, user} = setup(); user("u");
  await Promise.all(Array.from({length:100}, () => engine.reserve("u", entity)));
  assert.equal(db.docs.get("access_notebooks/master").occupied, 1);
  assert.equal((await db.collection("access_jobs").get()).size, 1);
});
test("concurrent buyers overflow atomically; all-full never returns a full notebook", async () => {
  const {db, engine, user} = setup(1, 2); user("a"); user("b"); user("c");
  const r = await Promise.allSettled(["a","b","c"].map(uid => engine.reserve(uid, entity)));
  assert.equal(r.filter(x=>x.status==="fulfilled").length, 2);
  assert.equal(r.filter(x=>x.status==="rejected").length, 1);
  assert.equal(db.docs.get("access_notebooks/master").occupied, 2);
  assert.equal(db.docs.get("access_notebooks/clone").occupied, 2);
});
test("resolver is read-only and returns the verified assigned clone", async () => {
  const {db, engine, user, jobs} = setup(2, 2); user("u");
  db.docs.get("access_notebooks/clone").occupied = 0;
  await engine.reserve("u", entity);
  await assert.rejects(engine.resolve("u", entity), {code:"failed-precondition"});
  await jobs();
  for (let i=0;i<20;i++) assert.equal((await engine.resolve("u", entity)).notebookId, "clone");
  assert.equal(db.docs.get("access_notebooks/clone").occupied, 1);
});
test("observed existing membership is sticky and not counted twice", async () => {
  const {db, engine, user} = setup(1, 2); user("u");
  db.seed(`access_memberships/${keyOf("clone","u@example.test")}`, {present:true,counted:true});
  const a = await engine.reserve("u", entity);
  assert.equal(a.notebook_id,"clone");
  assert.equal(db.docs.get("access_notebooks/clone").occupied,1);
});
test("public, stale, disabled or missing pools never fallback to master", async () => {
  const {db, engine, user} = setup(); user("u");
  db.docs.get("access_notebooks/master").is_public = true;
  db.docs.get("access_notebooks/clone").healthy_until_ms = 0;
  await assert.rejects(engine.reserve("u",entity), {code:"resource-exhausted"});
});
test("no ready access or freed seat until exact target evidence is verified", async () => {
  const {db, engine, user, jobs} = setup(); user("u"); await engine.reserve("u",entity);
  engine.provider!.apply = async id => ({notebookId:id,isPublic:false,complete:true,emails:["other@example.test"]});
  await jobs();
  assert.equal((await engine.assignmentRef("u",entity).get()).data().status,"provisioning");
  assert.equal((await db.collection("access_jobs").get()).docs[0].data().status,"retry");
  assert.equal(db.docs.get("access_notebooks/master").occupied,1);
});
test("expired stale add is superseded and never grants access", async () => {
  const {db, engine, user, jobs, calls} = setup(); user("u"); await engine.reserve("u",entity);
  db.docs.get("access_grants/u").expires_ms = now - 1;
  await jobs(); assert.equal(calls.length,0);
});
test("expiration is granular; only confirmed absence frees the seat", async () => {
  const {db, engine, user, jobs} = setup(); user("u"); await engine.reserve("u",entity); await jobs();
  db.seed("access_grants/other",{uid:"u",scope:"fiqh_tahawwulat",kind:"payment",status:"active",amount:50000,expires_ms:now+1});
  db.docs.get("access_grants/u").expires_ms = now - 1;
  await engine.revoke("u",entity);
  assert.equal(db.docs.get("access_notebooks/master").occupied,1);
  await jobs(); assert.equal(db.docs.get("access_notebooks/master").occupied,0);
  assert.equal(db.docs.get("access_grants/other").status,"active");
});
test("renewal arriving after remove was queued supersedes the stale removal", async () => {
  const {db, engine, user, jobs, calls} = setup(); user("u"); await engine.reserve("u",entity); await jobs();
  db.docs.get("access_grants/u").expires_ms = now - 1; await engine.revoke("u",entity);
  db.docs.get("access_grants/u").expires_ms = now + 50000; await jobs();
  assert.equal(calls.filter(c=>!c.desired).length,0);
});
test("Google identity collision and unverified email change require recovery", async () => {
  const {db, engine, user} = setup(); user("u"); await engine.reserve("u",entity);
  user("b",{email:"u@example.test"}); await assert.rejects(engine.reserve("b",entity), {code:"failed-precondition"});
  db.docs.get("users/u").email="changed@example.test";
  await assert.rejects(engine.reserve("u",entity), {code:"failed-precondition"});
});
test("zero payment and another module/yearly grant do not create global rights", () => {
  const g = {kind:"payment",scope,amount:0,status:"active",expires_ms:now+1};
  assert.equal(rights({},[g],scope,now),false);
  assert.equal(rights({},[{...g,amount:50000}],"fiqh_tahawwulat",now),false);
});
for (const u of [{email:"prilatief@gmail.com"},{is_vip:true},{role:"vip"},{email:"udinvoldigoad05@gmail.com"}]) {
  test(`VIP protected: ${JSON.stringify(u)}`, async () => {
    const {db, engine, user, jobs, calls} = setup(); user("u",u); await engine.reserve("u",entity); await jobs();
    db.docs.get("access_grants/u").expires_ms=0;
    await engine.revoke("u",entity); await jobs();
    assert.equal(calls.filter(c=>!c.desired).length,0); assert.equal(isVip(u),true);
  });
}
