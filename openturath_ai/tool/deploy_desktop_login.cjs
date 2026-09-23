// Explicit maintenance command: node tool/deploy_desktop_login.cjs [--publish]
// Preserves the live site's exact file hashes/config; only two login files change.
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
  if (!account) throw new Error('Run firebase login before this command.');
  const credentials = await auth.getAccessToken(account.tokens.refresh_token, [
    'https://www.googleapis.com/auth/cloud-platform',
    'https://www.googleapis.com/auth/firebase',
  ]);
  const headers = { Authorization: `Bearer ${credentials.access_token}`, 'Content-Type': 'application/json' };
  async function api(resource, method = 'GET', body) {
    const res = await fetch(base + resource, { method, headers,
      body: body === undefined ? undefined : JSON.stringify(body), signal: AbortSignal.timeout(30000) });
    if (!res.ok) throw new Error(`Hosting API ${method} ${resource}: HTTP ${res.status}`);
    return res.json();
  }
  const live = await api(`${site}/channels/live`);
  const previous = live.release?.version?.name;
  if (!previous) throw new Error('No live version: refusing to replace an unknown site.');
  const version = await api(previous);
  const files = {};
  let pageToken = '';
  do {
    const page = await api(`${previous}/files?pageSize=1000&pageToken=${encodeURIComponent(pageToken)}`);
    for (const file of page.files ?? []) {
      if (file.status !== 'ACTIVE') throw new Error('Live version contains non-active files.');
      files[file.path] = file.hash;
    }
    pageToken = page.nextPageToken ?? '';
  } while (pageToken);
  const preserved = { ...files };
  if (Object.keys(files).length === 0) throw new Error('Empty manifest: refusing deployment.');
  const uploads = new Map();
  const changed = ['/desktop-auth.html', '/desktop-auth.js'];
  for (const name of changed) {
    const content = fs.readFileSync(path.join(__dirname, '../public', name));
    const compressed = gzipSync(content, { level: 9 });
    const hash = createHash('sha256').update(compressed).digest('hex');
    files[name] = hash;
    uploads.set(hash, compressed);
  }
  const config = structuredClone(version.config ?? {});
  config.headers = (config.headers ?? []).filter((h) => h.glob !== '/desktop-auth{.html,.js}');
  config.headers.push({ glob: '/desktop-auth{.html,.js}', headers: {
    'Cache-Control': 'no-store', 'Referrer-Policy': 'no-referrer',
    'X-Content-Type-Options': 'nosniff', 'X-Frame-Options': 'DENY',
  }});
  console.log(JSON.stringify({ previous, preservedFiles: Object.keys(preserved).length,
    changed, existingConfigKeys: Object.keys(version.config ?? {}), publish: process.argv.includes('--publish') }));
  if (!process.argv.includes('--publish')) return;
  const created = await api(`${site}/versions`, 'POST', { config, labels: { purpose: 'desktop-login' } });
  const entries = Object.entries(files);
  for (let i = 0; i < entries.length; i += 1000) {
    const populated = await api(`${created.name}:populateFiles`, 'POST', { files: Object.fromEntries(entries.slice(i, i + 1000)) });
    for (const hash of populated.uploadRequiredHashes ?? []) {
      if (!uploads.has(hash)) throw new Error('An existing file requires re-upload: refusing to replace live content.');
      const upload = new URL(`${populated.uploadUrl}/${hash}`);
      if (upload.origin !== 'https://upload-firebasehosting.googleapis.com') throw new Error('Unexpected upload origin.');
      const res = await fetch(upload, { method: 'POST', headers: {
        Authorization: headers.Authorization, 'Content-Type': 'application/octet-stream',
      }, body: uploads.get(hash), signal: AbortSignal.timeout(30000) });
      if (!res.ok) throw new Error(`Hosting upload failed: HTTP ${res.status}`);
    }
  }
  await api(`${created.name}?updateMask=status`, 'PATCH', { status: 'FINALIZED' });
  // Detect another publisher before making our version live.
  const fresh = await api(`${site}/channels/live`);
  if (fresh.release?.name !== live.release?.name) throw new Error('Live release changed during preparation; stop and re-plan.');
  const release = await api(`${site}/channels/live/releases?versionName=${encodeURIComponent(created.name)}`, 'POST', {
    message: 'Enable Windows browser login; preserve all other live files and configuration',
  });
  console.log(JSON.stringify({ release: release.name, version: created.name, previous,
    preservedFiles: Object.keys(preserved).length, changed, releasedAt: release.releaseTime }));
}
main().catch((error) => { console.error(error.message); process.exitCode = 1; });
