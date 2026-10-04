import test from 'node:test';
import assert from 'node:assert/strict';
import {escapeHtml, normalizeSearch, safeExternal, releaseIssues} from '../src/core.mjs';
test('untrusted source text is rendered as text',()=>assert.equal(escapeHtml('<script>"&'), '&lt;script&gt;&quot;&amp;'));
test('Arabic title search tolerates harakat tatweel and hamzah',()=>assert.equal(normalizeSearch('أَلْـأُمّ'), 'الام'));
test('external links cannot execute javascript or carry credentials',()=>{assert.equal(safeExternal('javascript:alert(1)'),null);assert.equal(safeExternal('https://u:p@host.test'),null);assert.equal(safeExternal('https://example.com/book'),'https://example.com/book');});
test('missing production facts prevent a production release',()=>{const issues=releaseIssues({operator:{},downloads:[],plans:[]});assert.ok(issues.some(x=>x.includes('canonicalUrl')));assert.ok(issues.some(x=>x.includes('downloads')));assert.ok(issues.some(x=>x.includes('operator')));});

import {markdown} from '../src/core.mjs';
test('markdown keeps untrusted HTML inert and tables semantic',()=>{const html=markdown('| A | B |\n| --- | --- |\n| <img src=x onerror=alert(1)> | **safe** |');assert.ok(html.includes('<table>'));assert.ok(!html.includes('<img'));assert.ok(html.includes('&lt;img'));assert.ok(html.includes('<strong>safe</strong>'));});
test('production gate rejects unsafe URLs, incomplete plans and invalid release slugs',()=>{const errors=releaseIssues({canonicalUrl:'https://example.com/?x=1',operator:{},downloads:[{url:'javascript:alert(1)',type:'apk'}],plans:[{}],releaseNotes:[{version:'../../escape'}],reports:{retentionDays:0}});for(const key of ['canonicalUrl','downloads.url','downloads.sha256','plans','releaseNotes.version','retentionDays'])assert.ok(errors.some(x=>x.includes(key)),key);});
