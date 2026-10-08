import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {publicationIntegrityIssues,releaseManifest} from '../scripts/publication-integrity.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url)));
const fixture=()=>({config:read('site.config.json'),appFacts:read('content/app-facts.json'),proof:read('content/proof.json'),evidence:read('content/evidence.json'),releases:read('content/releases.json')});
test('pending archive is allowed but verified promotion requires source and reviewer',()=>{
 const d=fixture();assert.deepEqual(publicationIntegrityIssues(d),[]);d.proof.reviewed=true;
 assert.ok(publicationIntegrityIssues(d).some(i=>i.includes('source-edition')));
 Object.assign(d.evidence.find(r=>r.id==='q001-e03'),{status:'matched',edition:'TEST EDITION',sourceUrl:'https://example.invalid/source',sourceText:'TEST SOURCE',reviewer:'TEST REVIEWER',reviewDate:'2026-10-08'});
 assert.deepEqual(publicationIntegrityIssues(d),[]);
});
test('app price drift is rejected for both general fields and the exclusive package',()=>{
 const d=fixture();d.config.plans[0].price=49000;d.config.tahawwulatPlans[0].amount=50000;
 const issues=publicationIntegrityIssues(d);assert.ok(issues.some(i=>i.includes('general-field')));assert.ok(issues.some(i=>i.includes('Tahawwulat')));
});
test('release manifest cannot expose an inactive download or silently mismatch an active file',()=>{
 const d=fixture();d.releases.platforms[0].url='https://example.invalid/missing.apk';assert.ok(publicationIntegrityIssues(d).some(i=>i.includes('inactive release')));
 d.releases=releaseManifest(d.config);d.config.downloads[0].comingSoon=false;assert.ok(publicationIntegrityIssues(d).some(i=>i.includes('active release')));
});
