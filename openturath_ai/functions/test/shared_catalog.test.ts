import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {loadBackend} from "./audit_harness.ts";

const shared = path.join(process.cwd(), "../ecosystem/openturath_subscription/shared");
const read = (name: string) => JSON.parse(fs.readFileSync(path.join(shared, name), "utf8"));
const plain = (value: unknown) => JSON.parse(JSON.stringify(value));

test("exported VIP registry matches the canonical list", () => {
  const f = loadBackend();
  assert.deepEqual(read("vip_emails.json"), [...f.access.VIP_EMAILS].sort());
});

test("exported product catalog matches the canonical catalog", () => {
  const f = loadBackend();
  assert.deepEqual(read("product_catalog.json"), plain(f.catalog.sharedCatalog()));
});

test("every GoAkal product grants a scope its agents actually require", () => {
  const f = loadBackend();
  const required = new Set([...Object.values(f.catalog.ENTITY_SCOPES), "all_access"]);
  for (const service of f.catalog.AKAL_SERVICES) {
    for (const scope of service.scopes) assert.ok(required.has(scope), `${service.name} -> ${scope}`);
    assert.deepEqual(f.catalog.resolveAkalScopes(service.name), service.scopes);
  }
});

test("service titles resolve to their own module and unknown titles are never guessed", () => {
  const catalog = loadBackend().catalog;
  const resolveAkalScopes = (title: unknown) => plain(catalog.resolveAkalScopes(title));
  assert.deepEqual(resolveAkalScopes("Super AI Fikih Hanafi"), ["fiqh_hanafi"]);
  assert.deepEqual(resolveAkalScopes("Super AI Aqidah & Ushuluddin"), ["aqidah"]);
  assert.deepEqual(resolveAkalScopes("Super AI Fatawa & Masail"), ["fiqh"]);
  assert.deepEqual(resolveAkalScopes("Super AI Tajwid & Qiraat"), ["tafsir"]);
  assert.deepEqual(resolveAkalScopes("AI Fikih Syafi'i"), ["fiqh_syafii"]);
  assert.deepEqual(resolveAkalScopes("Kelas Memasak"), []);
  assert.deepEqual(resolveAkalScopes(""), []);
  assert.deepEqual(resolveAkalScopes(null), []);
});
