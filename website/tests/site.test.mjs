import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {build, loadData, releaseIssues} from '../scripts/build.mjs';
import {readAppFacts} from '../scripts/sync-app-facts.mjs';
import {copy, LOCALES} from '../src/copy.mjs';
import {articles} from '../src/articles.mjs';
import {page, rupiah, catalogTotals} from '../src/render.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const data = await loadData();
const strings = value =>
  typeof value === 'string' ? [value] : Array.isArray(value) || typeof value === 'object' ? Object.values(value).flatMap(strings) : [];

test('fakta situs sama dengan aplikasi', async () => {
  assert.deepEqual(data.facts, await readAppFacts());
});

test('harga di beranda dan halaman akses berasal dari aplikasi', () => {
  for (const l of LOCALES) {
    for (const route of ['', 'access']) {
      const html = page(l, route, data);
      for (const offer of [...data.facts.pricing.specialist, ...data.facts.pricing.tahawwulat]) {
        assert.ok(html.includes(rupiah(offer.amount, l)), `${l}/${route}: ${offer.amount}`);
      }
    }
  }
});

test('halaman unduh menyebut versi Android minimum dari aplikasi dan tidak menjanjikan iOS', () => {
  const html = page('id', 'download', data);
  assert.ok(html.includes(`Android ${data.facts.android.name}`));
  assert.ok(html.includes('iPhone dan iPad belum tersedia.'));
});

test('angka katalog dihitung dari katalog, bukan ditulis tangan', () => {
  const totals = catalogTotals(data.catalog);
  assert.equal(totals.fields, data.catalog.filter(c => c.status === 'active').length);
  assert.ok(page('id', '', data).includes(new Intl.NumberFormat('id-ID').format(totals.books)));
});

test('naskah mengikuti pedoman suara', () => {
  const all = strings(copy);
  for (const text of all) assert.ok(!/[!！]/.test(text), `tanda seru: ${text}`);
  const banned = /khadim|presisi|tanpa batas|akses penuh|korpus|komprehensif|terlengkap|canggih|terintegrasi|mutakhir/i;
  for (const text of all) assert.ok(!banned.test(text), `kata terlarang: ${text}`);
  for (const route of data.config.releaseRoutes.filter(r => articles[r])) {
    for (const text of strings(articles[route])) assert.ok(!/khadim/i.test(text), `${route}: khadim`);
  }
});

test('setiap entri naskah punya tiga bahasa', () => {
  const walk = value => {
    if (Array.isArray(value) && value.every(x => typeof x === 'string')) return assert.equal(value.length, 3);
    if (value && typeof value === 'object') Object.values(value).forEach(walk);
  };
  walk(copy);
});

test('build menghasilkan halaman yang utuh dan tautan internal yang hidup', async () => {
  const {routes} = await build();
  const dist = path.join(root, 'dist');
  for (const l of LOCALES) {
    for (const route of routes) {
      const html = await fs.readFile(path.join(dist, l, route, 'index.html'), 'utf8');
      assert.equal((html.match(/<h1[ >]/g) ?? []).length, 1, `${l}/${route}: satu h1`);
      assert.ok(html.includes(`<html lang="${l}" dir="${l === 'ar' ? 'rtl' : 'ltr'}">`));
      assert.ok(!html.includes('undefined'), `${l}/${route}: undefined`);
      for (const [, href] of html.matchAll(/href="(\/[^"#]*)/g)) {
        const target = path.join(dist, href.endsWith('/') ? href + 'index.html' : href);
        await assert.doesNotReject(fs.access(target), `${l}/${route} → ${href}`);
      }
    }
  }
});

test('halaman tanpa skrip sebaris dan tanpa sumber pihak ketiga', () => {
  const html = page('id', '', data);
  assert.ok(!/<script(?![^>]*(src=|application\/ld\+json))/.test(html));
  assert.ok(!/ style="/.test(html), 'CSP melarang style sebaris');
  assert.ok(!/(src|href)="https?:\/\/(?!openturath\.id)/.test(html.replace(/<link rel="(canonical|alternate)"[^>]*>/g, '')));
});

test('rilis ditahan selama contoh bukti belum ditinjau', async () => {
  const issues = await releaseIssues({...data, proof: {...data.proof, reviewed: false}});
  assert.ok(issues.some(x => x.includes('proof.json')));
});
