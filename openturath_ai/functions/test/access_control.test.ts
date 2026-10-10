import test from "node:test";
import assert from "node:assert/strict";
import {AccessControl, isVip, keyOf, rights, verifiedAkalPeriods, hasLegacyAccessAdjustment, REVOCATION_POLICY, evidenceHash} from "../src/access_control.ts";
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

test("verified legacy ownership transfer preserves grants and resumes in-flight jobs", async () => {
  const {db, engine, user, jobs, calls} = setup(); user("old");
  await engine.reserve("old", entity);
  db.seed("access_legacy_owners/old", {email:"old@example.test", legacy_revoke_only:true});
  db.seed("users/new", {email:"old@example.test",access_grant_ids:["existing"]});
  await engine.adoptLegacy("new", "old");
  assert.equal(db.docs.get("access_grants/old").uid,"new");
  assert.deepEqual(new Set(db.docs.get("users/new").access_grant_ids),new Set(["existing","old"]));
  await jobs();
  assert.equal(calls.length,1);
  assert.equal((await engine.resolve("new",entity)).notebookId,"master");
  assert.equal(db.docs.get("access_notebooks/master").occupied,1);
  await engine.adoptLegacy("new", "old");
  assert.equal(db.docs.get("access_notebooks/master").occupied,1);
});
test("permanent legacy VIP registry protects an owner without profile VIP flags", async () => {
  const {db,engine,user,jobs,calls}=setup();user("u");
  await engine.reserve("u",entity);await jobs();
  db.docs.get("access_grants/u").expires_ms=now-1;
  db.seed(`access_vip_registry/${keyOf("u@example.test")}`,{permanent:true});
  await engine.revoke("u",entity);
  assert.equal(calls.length,1);
  assert.equal((await engine.resolve("u",entity)).notebookId,"master");
});
test("deleted static VIP accounts retain their physical notebook membership", async () => {
  const {db,engine,user,jobs,calls}=setup();user("u",{email:"prilatief@gmail.com"});
  await engine.reserve("u",entity);await jobs();
  db.docs.delete("users/u"); db.docs.delete("access_grants/u");
  await engine.revoke("u",entity);await jobs();
  assert.equal(calls.length,1);
  assert.equal((await engine.assignmentRef("u",entity).get()).data().status,"ready");
});
test("an unresolved legacy hold prevents an already queued removal", async () => {
  const {db,engine,user,jobs,calls}=setup();user("u");
  await engine.reserve("u",entity);await jobs();
  db.docs.get("access_grants/u").expires_ms=now-1;
  await engine.revoke("u",entity);
  db.docs.get("users/u").access_revocation_hold=true;
  await jobs();
  assert.equal(calls.length,1);
  assert.equal(db.docs.get("access_notebooks/master").occupied,1);
});

const akalRow = (extra={}) => ({status:"PAID",incomingAmount:50000,payerEmail:"u@example.test",paymentId:"p1",
  serviceTitle:"SUPER AI FIKIH SYAFI'I",priceSchemeTitle:"1 Bulan",paidAt:"2026-01-01T00:00:00Z",expiryDate:"2026-01-01T01:00:00Z",...extra});
test("incident pause blocks queued removals while preserving access grants",async()=>{
  const {db,engine,user,jobs,calls}=setup();user("u");await engine.reserve("u",entity);await jobs();
  db.docs.get("access_grants/u").expires_ms=now-1;await engine.revoke("u",entity);
  db.seed("access_control/runtime",{revocations_paused:true});
  await jobs();assert.equal(calls.length,1);assert.equal(db.docs.get("access_notebooks/master").occupied,1);
  user("new");await engine.reserve("new",entity);await jobs();
  assert.equal(calls.filter(c=>c.desired===true).length,2);
});
test("owner bonuses and free transfers block legacy revocation despite verified expired receipts",async()=>{
  for (const tx of [{amount:2995000,bonus_reason:"specific override request",bonus_applied_at:1},
    {amount:0,source:"transfer_from_original",original_transaction_id:"paid_original"},
    {amount:0,source:"manual_override",uid:"legacy-email@example.test"}]) {
    const {db,engine,user,calls}=setup();user("u");
    await engine.reserve("u",entity);const before=calls.length;
    db.docs.get("access_grants/u").expires_ms=now-1;
    assert.equal(hasLegacyAccessAdjustment(tx),true);
    db.docs.get("users/u").access_revocation_hold=hasLegacyAccessAdjustment(tx);
    await engine.revoke("u",entity);
    assert.equal(calls.length,before);
    assert.equal(db.docs.get(engine.assignmentRef("u",entity).path).status,"provisioning");
  }
  assert.equal(hasLegacyAccessAdjustment({amount:50000,status:"PAID",source:"akal"}),false);
});
test("provider invoice expiry and unpaid expired quotations never determine subscription rights",()=>{
  const periods=verifiedAkalPeriods([akalRow(),akalRow({paymentId:"unpaid",status:"EXPIRED"}),akalRow({paymentId:"free",incomingAmount:0})]);
  assert.equal(periods.length,1);
  assert.equal(periods[0].expires-Date.parse("2026-01-01T00:00:00Z"),30*86400000);
});
test("historical renewals sort by real payment time and duplicate receipts never compound",()=>{
  const second=akalRow({paymentId:"p2",paidAt:"2026-01-15T00:00:00Z"});
  const periods=verifiedAkalPeriods([second,akalRow(),second]);
  assert.equal(periods.length,2);
  assert.equal(periods[1].expires-Date.parse("2026-01-01T00:00:00Z"),60*86400000);
});
test("provider annual packages remain module specific and unknown products do not grant access",()=>{
  const periods=verifiedAkalPeriods([akalRow({priceSchemeTitle:"12 Bulan"}),akalRow({paymentId:"unknown",serviceTitle:"unrecognized"})]);
  assert.equal(periods.length,1);assert.equal(periods[0].scope,"fiqh_syafii");
  assert.equal(periods[0].expires,Date.parse("2027-01-01T00:00:00Z"));
});
test("the same provider payment cannot be reassigned to another email",()=>{
  assert.throws(()=>verifiedAkalPeriods([akalRow(),akalRow({payerEmail:"other@example.test"})]),/identity collision/);
});
test("legacy app routing uses its registered clone even when a master has spare capacity",async()=>{
  const {db,engine}=setup();
  db.seed(`access_memberships/${keyOf("clone","u@example.test")}`,{email:"u@example.test",notebook_id:"clone",entity,present:true,verified_ms:now});
  const before=db.docs.get("access_notebooks/master").occupied;
  const result=await engine.resolveObservedLegacy("u","u@example.test",entity);
  assert.equal(result.notebookId,"clone");assert.equal(db.docs.get("access_notebooks/master").occupied,before);
  await assert.rejects(engine.resolveObservedLegacy("unknown","unknown@example.test",entity),{code:"failed-precondition"});
});

async function approveLegacy(db:any,engine:any,uid="u",module=scope) {
  const draft=await engine.assessRevocation(uid,module);
  assert.equal(draft.reason,"legacy_audit_missing_or_stale");
  db.seed(`access_legacy_audits/${keyOf(uid,module)}`,{uid,scope:module,email:`${uid}@example.test`,
    status:"approved",owner_approved:true,policy:REVOCATION_POLICY,fingerprint:draft.fingerprint});
}
test("Muhammad incident: provider receipt cannot supersede a later owner bonus even if hold was lost",async()=>{
  const {db,engine,user,jobs,calls}=setup();user("u");await engine.reserve("u",entity);await jobs();
  Object.assign(db.docs.get("access_grants/u"),{provider:"goakal",provider_verified:true,expires_ms:now-1});
  db.seed("transactions/owner_bonus",{customer_email:"u@example.test",amount:2995000,bonus_reason:"specific override request",
    subscription_expires_at:now+999999,entitlement_key:scope});
  await engine.revoke("u",entity);await jobs();
  assert.equal(calls.filter(c=>!c.desired).length,0);
  assert.equal((await engine.assessRevocation("u",scope)).reason,"legacy_audit_missing_or_stale");
});
test("Arie incident: new zero-value transfer invalidates a previously approved removal before Google",async()=>{
  const {db,engine,user,jobs,calls}=setup();user("u");await engine.reserve("u",entity);await jobs();
  Object.assign(db.docs.get("access_grants/u"),{provider:"goakal",expires_ms:now-1});
  await approveLegacy(db,engine);await engine.revoke("u",entity);
  db.seed("transactions/transfer",{customer_email:"u@example.test",amount:0,source:"transfer_from_original",
    original_transaction_id:"paid_original",modules:[scope],subscription_expires_at:now+999999});
  await jobs();assert.equal(calls.filter(c=>!c.desired).length,0);
  assert.equal((await engine.assignmentRef("u",entity).get()).data().status,"revocation_review");
  assert.equal([...db.docs.values()].some(d=>d.status === "review_required"),true);
});
test("a hold arriving during Google removal restores the original permission and preserves its seat",async()=>{
  const {db,engine,user,jobs,calls,members,provider}=setup();user("u");await engine.reserve("u",entity);await jobs();
  db.docs.get("access_grants/u").expires_ms=now-1;await engine.revoke("u",entity);
  const original=provider.apply.bind(provider);
  provider.apply=async(id,email,desired)=>{const result=await original(id,email,desired);
    if(!desired)db.docs.get("users/u").access_revocation_hold=true;return result;};
  await jobs();assert.deepEqual(calls.map(c=>c.desired),[true,false,true]);
  assert.equal(members.get("master")!.has("u@example.test"),true);
  assert.equal(db.docs.get("access_notebooks/master").occupied,1);
  assert.equal([...db.docs.values()].some(d=>d.status === "review_required"),true);
});
test("manual evidence arriving during removal restores membership even without a hold or renewal grant",async()=>{
  const {db,engine,user,jobs,calls,members,provider}=setup();user("u");await engine.reserve("u",entity);await jobs();
  db.docs.get("access_grants/u").expires_ms=now-1;await engine.revoke("u",entity);
  const original=provider.apply.bind(provider);
  provider.apply=async(id,email,desired)=>{const result=await original(id,email,desired);
    if(!desired)db.seed("transactions/new_bonus",{customer_email:email,bonus_reason:"owner exception",entitlement_key:scope});return result;};
  await jobs();assert.deepEqual(calls.map(c=>c.desired),[true,false,true]);
  assert.equal(members.get("master")!.has("u@example.test"),true);
  assert.equal(db.docs.get("access_notebooks/master").occupied,1);
});
test("grant job never directly removes a membership if expiry changes during provisioning",async()=>{
  const {db,engine,user,jobs,calls,provider,members}=setup();user("u");await engine.reserve("u",entity);
  const original=provider.apply.bind(provider);
  provider.apply=async(id,email,desired)=>{const result=await original(id,email,desired);
    db.docs.get("access_grants/u").expires_ms=now-1;return result;};
  await jobs();assert.deepEqual(calls.map(c=>c.desired),[true]);assert.equal(members.get("master")!.has("u@example.test"),true);
});
test("legacy audit is bound to identity scope policy and the exact evidence snapshot",async()=>{
  const {db,engine,user}=setup();user("u");Object.assign(db.docs.get("access_grants/u"),{provider:"goakal",expires_ms:now-1});
  await approveLegacy(db,engine);assert.equal((await engine.assessRevocation("u",scope)).allowed,true);
  const cert=db.docs.get(`access_legacy_audits/${keyOf("u",scope)}`);
  cert.uid="other";assert.equal((await engine.assessRevocation("u",scope)).allowed,false);cert.uid="u";
  cert.scope="fiqh_tahawwulat";assert.equal((await engine.assessRevocation("u",scope)).allowed,false);cert.scope=scope;
  cert.policy=REVOCATION_POLICY-1;assert.equal((await engine.assessRevocation("u",scope)).allowed,false);cert.policy=REVOCATION_POLICY;
  db.docs.get("access_grants/u").expires_ms=now-2;assert.equal((await engine.assessRevocation("u",scope)).allowed,false);
});
test("manual rights in another known module do not invalidate an independent modern scope decision",async()=>{
  const {db,engine,user}=setup();user("u");db.docs.get("access_grants/u").expires_ms=now-1;
  db.seed("transactions/other_module",{customer_email:"u@example.test",source:"manual_override",
    modules:["fiqh_tahawwulat"],subscription_expires_at:now+999999});
  assert.equal((await engine.assessRevocation("u",scope)).allowed,true);
});
test("unknown scope evidence blocks revocation instead of guessing the module",async()=>{
  const {db,engine,user}=setup();user("u");db.docs.get("access_grants/u").expires_ms=now-1;
  db.seed("transactions/unknown",{customer_email:"u@example.test",source:"manual_override",plan:"tholib_1m"});
  assert.equal((await engine.assessRevocation("u",scope)).allowed,false);
});
test("missing scope evidence or deleted profile does not prove permission to remove access",async()=>{
  const {db,engine,user}=setup();user("u");db.docs.delete("access_grants/u");
  assert.equal((await engine.assessRevocation("u",scope)).reason,"missing_scope_evidence");
  db.docs.delete("users/u");assert.equal((await engine.assessRevocation("u",scope)).reason,"identity_unresolved");
});
test("legacy identity adoption preserves holds and requires a new identity-specific audit",async()=>{
  const {db,engine,user}=setup();user("new",{email:"old@example.test"});
  db.seed("access_legacy_owners/old",{email:"old@example.test",access_revocation_hold:true});
  await engine.adoptLegacy("new","old");
  assert.equal(db.docs.get("users/new").access_revocation_hold,true);
  assert.equal(db.docs.get("users/new").access_legacy_audit_required,true);
});
test("evidence hash is independent of property order and changes for an owner adjustment",()=>{
  assert.equal(evidenceHash({b:2,a:1}),evidenceHash({a:1,b:2}));
  assert.notEqual(evidenceHash({a:1}),evidenceHash({a:1,bonus_reason:"owner"}));
});
test("an audit label alone cannot discard an unresolved future bonus",async()=>{
  const {db,engine,user}=setup();user("u");db.docs.get("access_grants/u").expires_ms=now-1;
  db.seed("transactions/bonus",{customer_email:"u@example.test",bonus_reason:"owner exception",entitlement_key:scope,
    subscription_expires_at:now+999999});
  await approveLegacy(db,engine);
  assert.equal((await engine.assessRevocation("u",scope)).reason,"manual_adjustment_unresolved");
  db.docs.get(`access_legacy_audits/${keyOf("u",scope)}`).adjustments={bonus:{action:"expired_owner_confirmed"}};
  assert.equal((await engine.assessRevocation("u",scope)).allowed,false);
});
test("owner evidence arriving during the initial Google observation prevents any removal",async()=>{
  const {db,engine,user,jobs,calls,provider}=setup();user("u");await engine.reserve("u",entity);await jobs();
  db.docs.get("access_grants/u").expires_ms=now-1;await engine.revoke("u",entity);
  const original=provider.observe.bind(provider);
  provider.observe=async id=>{db.seed("transactions/bonus",{customer_email:"u@example.test",bonus_reason:"new owner exception",entitlement_key:scope});return original(id);};
  await jobs();assert.deepEqual(calls.map(c=>c.desired),[true]);
});
test("a timeout after Google removes the member restores the original verified membership",async()=>{
  const {db,engine,user,jobs,calls,members,provider}=setup();user("u");await engine.reserve("u",entity);await jobs();
  db.docs.get("access_grants/u").expires_ms=now-1;await engine.revoke("u",entity);
  const original=provider.apply.bind(provider);
  provider.apply=async(id,email,desired)=>{const result=await original(id,email,desired);if(!desired)throw Error("response lost after Google mutation");return result;};
  await jobs();assert.deepEqual(calls.map(c=>c.desired),[true,false,true]);
  assert.equal(members.get("master")!.has("u@example.test"),true);
  assert.equal(db.docs.get("access_notebooks/master").occupied,1);
  const job=[...db.docs.values()].find(d=>d.mutation_started_ms);
  assert.equal(job.safety_restore_required,false);assert.equal(job.status,"review_required");
});
test("failed safety restoration is persisted and retried before pause and expiry checks",async()=>{
  const {db,engine,user,jobs,provider,members}=setup();user("u");await engine.reserve("u",entity);await jobs();
  db.docs.get("access_grants/u").expires_ms=now-1;await engine.revoke("u",entity);
  const original=provider.apply.bind(provider);
  provider.apply=async(id,email,desired)=>{if(desired)throw Error("network unavailable during restoration");
    await original(id,email,desired);throw Error("response lost after removal");};
  await jobs();const entry=[...db.docs.entries()].find(([k,d])=>k.startsWith("access_jobs/")&&d.desired===false)!;
  assert.equal(entry[1].safety_restore_required,true);assert.equal(entry[1].status,"retry");
  db.seed("access_control/runtime",{revocations_paused:true});entry[1].due_ms=now;provider.apply=original;
  await jobs();assert.equal(members.get("master")!.has("u@example.test"),true);
  assert.equal(db.docs.get(entry[0]).safety_restore_required,false);
  assert.equal(db.docs.get(entry[0]).status,"review_required");
});
test("restart recovery restores a journaled original membership without issuing another removal",async()=>{
  const {db,engine,user,jobs,members,calls}=setup();user("u");await engine.reserve("u",entity);await jobs();
  db.docs.get("access_grants/u").expires_ms=now-1;await engine.revoke("u",entity);
  const job=[...db.docs.values()].find(d=>d.desired===false);
  Object.assign(job,{safety_restore_required:true,original_present:true,status:"processing",due_ms:now});
  members.get("master")!.delete("u@example.test");db.seed("access_control/runtime",{revocations_paused:true});
  await jobs();assert.deepEqual(calls.map(c=>c.desired),[true,true]);
  assert.equal(members.get("master")!.has("u@example.test"),true);
  assert.equal(db.docs.get("access_notebooks/master").occupied,1);
});
