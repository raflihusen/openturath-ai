import fs from 'node:fs/promises';
import readline from 'node:readline/promises';
import {stdin,stdout} from 'node:process';
import {releaseIssues} from '../src/core.mjs';
const file=new URL('../site.config.json',import.meta.url),c=JSON.parse(await fs.readFile(file,'utf8'));
const rl=readline.createInterface({input:stdin,output:stdout});
async function ask(label,old=''){const answer=(await rl.question(`${label}${old?' ['+old+']':''}: `)).trim();return answer||old;}
console.log('OpenTurath · konfigurasi lokal. Isi fakta resmi; Enter mempertahankan nilai. Tidak ada data yang dikirim ke layanan lain.');
try{
 c.canonicalUrl=await ask('Domain HTTPS resmi, tanpa path',c.canonicalUrl);
 for(const [key,label] of Object.entries({name:'Nama pengelola',email:'Email bantuan',jurisdiction:'Domisili/yurisdiksi pengelola',privacyEmail:'Email privasi',securityEmail:'Email keamanan'}))c.operator[key]=await ask(label,c.operator[key]);
 if((await ask('Tambahkan satu rilis resmi? ketik ya'))==='ya'){
  const d={};for(const [key,label] of Object.entries({platform:'Platform (Android/iOS/Web)',type:'Tipe (apk/store/web)',version:'Nomor versi',date:'Tanggal YYYY-MM-DD',minimumOS:'Sistem minimum',url:'URL HTTPS resmi',size:'Ukuran unduhan (untuk APK)',sha256:'SHA-256 APK asli (kosong untuk store)'}))d[key]=await ask(label);
  c.downloads.push(d);
 }
 console.log('Paket, catatan rilis, dan persetujuan kebijakan diisi setelah pemeriksaan di site.config.json. Lihat docs/CONFIGURATION.md.');
 await fs.copyFile(file,new URL('../site.config.backup.json',import.meta.url));await fs.writeFile(file,JSON.stringify(c,null,2)+'\n');
 console.log('Konfigurasi tersimpan. Persyaratan yang masih perlu dilengkapi:\n'+releaseIssues(c).map(x=>'• '+x).join('\n'));
}finally{rl.close();}
