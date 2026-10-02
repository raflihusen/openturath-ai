// Read-only preparation by default. --publish changes only workspace assets
// and the retired desktop-login helper; every other live file hash is kept.
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');
const { gzipSync } = require('node:zlib');
const { createHash } = require('node:crypto');
const auth = require(path.join(execFileSync('npm', ['root', '-g'], { encoding: 'utf8' }).trim(), 'firebase-tools/lib/auth.js'));
const site = 'sites/open-turath';
const base = 'https://firebasehosting.googleapis.com/v1beta1/';

async function main() {
  const account = auth.getGlobalDefaultAccount();
  if (!account) throw new Error('Firebase CLI account is unavailable.');
  const credentials = await auth.getAccessToken(account.tokens.refresh_token, [
    'https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/firebase',
  ]);
  const headers = { Authorization: `Bearer ${credentials.access_token}`, 'Content-Type': 'application/json' };
  async function api(resource, method = 'GET', body) {
    const response = await fetch(base + resource, { method, headers,
      body: body === undefined ? undefined : JSON.stringify(body), signal: AbortSignal.timeout(30000) });
    if (!response.ok) throw new Error(`Hosting ${method}: HTTP ${response.status}`);
    return response.json();
  }
  const live = await api(`${site}/channels/live`);
  const previous = live.release?.version?.name;
  if (!previous) throw new Error('No live version; refusing to replace an unknown site.');
  const version = await api(previous);
  const files = {};
  let pageToken = '';
  do {
    const page = await api(`${previous}/files?pageSize=1000&pageToken=${encodeURIComponent(pageToken)}`);
    for (const file of page.files || []) {
      if (file.status !== 'ACTIVE') throw new Error('Live manifest contains a non-active file.');
      files[file.path] = file.hash;
    }
    pageToken = page.nextPageToken || '';
  } while (pageToken);
  if (!Object.keys(files).length) throw new Error('Empty live manifest.');
  const publicRoot = path.join(__dirname, '../public');
  const changed = fs.readdirSync(path.join(publicRoot, 'workspace')).filter(name => !name.startsWith('.')).map(name => `/workspace/${name}`);
  for (const asset of ['/brand-mark.svg', '/favicon.svg', '/icon-192.png', '/icon-512.png']) {
    if (!files[asset]) changed.push(asset);
  }
  const preservedCount = Object.keys(files).filter(name => !changed.includes(name)).length;
  const uploads = new Map();
  for (const name of changed) {
    const compressed = gzipSync(fs.readFileSync(path.join(publicRoot, name)), { level: 9 });
    const hash = createHash('sha256').update(compressed).digest('hex');
    files[name] = hash;
    uploads.set(hash, compressed);
  }
  const config = structuredClone(version.config || {});
  config.headers = (config.headers || []).filter(item => !['/workspace/**', '/workspace/*.mjs', '/workspace/manifest.webmanifest'].includes(item.glob));
  const security = { 'Cache-Control': 'no-cache', 'Referrer-Policy': 'no-referrer', 'X-Content-Type-Options': 'nosniff', 'X-Frame-Options': 'DENY' };
  config.headers.push({ glob: '/workspace/**', headers: security });
  config.headers.push({ glob: '/workspace/*.mjs', headers: { 'Content-Type': 'text/javascript; charset=utf-8' } });
  config.headers.push({ glob: '/workspace/manifest.webmanifest', headers: { 'Content-Type': 'application/manifest+json' } });
  console.log(JSON.stringify({ previous, preservedFiles: preservedCount, changed, publish: process.argv.includes('--publish'), workspace: 'https://open-turath.firebaseapp.com/workspace/' }));
  if (!process.argv.includes('--publish')) return;
  const created = await api(`${site}/versions`, 'POST', { config, labels: { purpose: 'browser-workspace' } });
  const entries = Object.entries(files);
  for (let start = 0; start < entries.length; start += 1000) {
    const populated = await api(`${created.name}:populateFiles`, 'POST', { files: Object.fromEntries(entries.slice(start, start + 1000)) });
    for (const hash of populated.uploadRequiredHashes || []) {
      if (!uploads.has(hash)) throw new Error('An existing asset requires upload; refusing to replace live content.');
      const target = new URL(`${populated.uploadUrl}/${hash}`);
      if (target.origin !== 'https://upload-firebasehosting.googleapis.com') throw new Error('Unexpected upload origin.');
      const response = await fetch(target, { method: 'POST', headers: { Authorization: headers.Authorization, 'Content-Type': 'application/octet-stream' }, body: uploads.get(hash), signal: AbortSignal.timeout(30000) });
      if (!response.ok) throw new Error(`Upload: HTTP ${response.status}`);
    }
  }
  await api(`${created.name}?updateMask=status`, 'PATCH', { status: 'FINALIZED' });
  const fresh = await api(`${site}/channels/live`);
  if (fresh.release?.name !== live.release?.name) throw new Error('Live site changed during preparation; refusing publication.');
  const release = await api(`${site}/channels/live/releases?versionName=${encodeURIComponent(created.name)}`, 'POST', { message: 'Add shared-browser OpenTurath workspace and retire embedded desktop OAuth bridge' });
  console.log(JSON.stringify({ release: release.name, version: created.name, previous, releasedAt: release.releaseTime }));
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
