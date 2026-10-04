// Membangun situs statis ke dist/. `--release` menolak berjalan bila ada
// fakta yang belum beres, supaya halaman yang salah tidak pernah tayang.
import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {LOCALES} from '../src/copy.mjs';
import {page, rootPage, pathFor} from '../src/render.mjs';
import {readAppFacts} from './sync-app-facts.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const json = async file => JSON.parse(await fs.readFile(path.join(root, file), 'utf8'));

export async function loadData() {
  return {
    config: await json('site.config.json'),
    facts: await json('content/app-facts.json'),
    catalog: await json('content/catalog.json'),
    proof: await json('content/proof.json'),
    releases: await json('content/releases.json'),
  };
}

// Hal yang harus beres sebelum situs boleh tayang.
export async function releaseIssues(data) {
  const issues = [];
  const live = await readAppFacts();
  if (JSON.stringify(live) !== JSON.stringify(data.facts)) {
    issues.push('content/app-facts.json berbeda dari aplikasi. Jalankan: npm run sync');
  }
  if (!data.proof.reviewed) issues.push('content/proof.json belum ditinjau (reviewed: false).');
  for (const p of data.releases.platforms.filter(x => x.url)) {
    if (!/^https:\/\//.test(p.url)) issues.push(`${p.id}: url harus https.`);
    if (!/^[a-f0-9]{64}$/.test(p.sha256 ?? '')) issues.push(`${p.id}: sha256 tidak sah.`);
    if (!p.sizeBytes || !p.date) issues.push(`${p.id}: sizeBytes dan date wajib diisi.`);
  }
  return issues;
}

export async function build({release = false} = {}) {
  const data = await loadData();
  if (release) {
    const issues = await releaseIssues(data);
    if (issues.length) throw new Error('Rilis ditahan:\n' + issues.map(x => ' - ' + x).join('\n'));
  }
  const dist = path.join(root, 'dist');
  await fs.rm(dist, {recursive: true, force: true});
  await fs.cp(path.join(root, 'public'), dist, {recursive: true});
  const routes = data.config.releaseRoutes;
  for (const l of LOCALES) {
    for (const route of [...routes, '404']) {
      const dir = path.join(dist, l, route);
      await fs.mkdir(dir, {recursive: true});
      await fs.writeFile(path.join(dir, 'index.html'), page(l, route, data, {release}));
    }
  }
  await fs.writeFile(path.join(dist, 'index.html'), rootPage(data));
  await fs.writeFile(path.join(dist, '404.html'), page('id', '404', data, {release}));
  const base = data.config.canonicalUrl;
  const urls = LOCALES.flatMap(l => routes.map(r => `<url><loc>${base}${pathFor(l, r)}</loc></url>`)).join('');
  await fs.writeFile(path.join(dist, 'sitemap.xml'), `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${urls}</urlset>`);
  await fs.writeFile(path.join(dist, 'robots.txt'), release ? `User-agent: *\nAllow: /\nSitemap: ${base}/sitemap.xml\n` : 'User-agent: *\nDisallow: /\n');
  return {pages: LOCALES.length * (routes.length + 1) + 2, routes};
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    const release = process.argv.includes('--release');
    const result = await build({release});
    console.log(`${result.pages} halaman dibangun (${release ? 'rilis' : 'pratinjau, noindex'}).`);
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
