// Membaca fakta produk langsung dari kode aplikasi dan menuliskannya ke
// content/app-facts.json. Situs tidak menyimpan harga atau versi sendiri.
import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const app = path.resolve(root, '../openturath_ai');
const read = file => fs.readFile(path.join(app, file), 'utf8');

// Nama rilis Android untuk tiap API level yang mungkin dipakai minSdk.
const ANDROID = {21: '5.0', 23: '6.0', 24: '7.0', 26: '8.0', 28: '9', 29: '10', 30: '11'};

export async function readAppFacts() {
  const [pubspec, pricing, gradle] = await Promise.all([
    read('pubspec.yaml'),
    read('lib/core/product_pricing.dart'),
    read('android/app/build.gradle.kts'),
  ]);
  const [, version, build] = pubspec.match(/^version:\s*([\d.]+)\+(\d+)/m);
  const minSdk = Number(gradle.match(/minSdk\s*=\s*(\d+)/)[1]);
  const offers = block =>
    [...block.matchAll(/months:\s*(\d+),\s*regularAmount:\s*(\d+),\s*amount:\s*(\d+)/g)]
      .map(([, months, regular, amount]) => ({months: +months, amount: +amount, regular: +regular}));
  const section = (from, to) => pricing.slice(pricing.indexOf(from), pricing.indexOf(to));
  const specialists = offers(section('static const specialist ', 'static const tahawwulat'));
  // Paket satu bulan didefinisikan sekali lalu dipakai ulang di daftar.
  const unique = [...new Map(specialists.map(o => [o.months, o])).values()];
  return {
    version,
    build: Number(build),
    android: {minSdk, name: ANDROID[minSdk]},
    pricing: {
      revision: pricing.match(/revision = '([^']+)'/)[1],
      specialist: unique,
      tahawwulat: offers(section('static const tahawwulat', 'static List<SubscriptionOffer> forAgent')),
    },
    sources: ['pubspec.yaml', 'lib/core/product_pricing.dart', 'android/app/build.gradle.kts'],
  };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const facts = await readAppFacts();
  await fs.writeFile(path.join(root, 'content/app-facts.json'), JSON.stringify(facts, null, 2) + '\n');
  console.log(`app-facts.json: versi ${facts.version}, Android ${facts.android.name}+, ${facts.pricing.specialist.length}+${facts.pricing.tahawwulat.length} harga`);
}
