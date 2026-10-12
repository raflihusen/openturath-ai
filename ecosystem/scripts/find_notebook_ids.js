/**
 * 🔍 Script untuk mencari File ID notebook NotebookLM di Google Drive
 * 
 * NotebookLM notebooks disimpan sebagai file di Google Drive.
 * Script ini mencari semua file bertipe NotebookLM di Drive akun Anda.
 * 
 * Cara pakai:
 *   node find_notebook_ids.js
 * 
 * Prasyarat:
 *   - service-account.json harus ada di direktori ini
 *   - Service account harus sudah di-share akses ke notebook-notebook yang ada
 *     ATAU notebook dibuat oleh akun di domain yang sama
 */

const { google } = require('googleapis');
const path = require('path');

const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'service-account.json');
const serviceAccount = require(SERVICE_ACCOUNT_PATH);

async function main() {
  // Autentikasi menggunakan Service Account
  const auth = new google.auth.GoogleAuth({
    credentials: serviceAccount,
    scopes: [
      'https://www.googleapis.com/auth/drive.readonly',
      'https://www.googleapis.com/auth/drive.metadata.readonly',
    ],
  });

  const drive = google.drive({ version: 'v3', auth });

  console.log('🔍 Mencari file NotebookLM di Google Drive...\n');
  console.log(`Service Account: ${serviceAccount.client_email}\n`);

  // ── Strategi 1: Cari berdasarkan MIME type NotebookLM ──
  // NotebookLM biasanya menggunakan mime type khusus Google
  const mimeQueries = [
    'application/vnd.google.notebook',
    'application/vnd.google-apps.notebook',
    'application/vnd.google-apps.map',  // kadang terindeks sebagai ini
  ];

  for (const mime of mimeQueries) {
    try {
      console.log(`📂 Mencari MIME: ${mime}...`);
      const res = await drive.files.list({
        q: `mimeType='${mime}' and trashed=false`,
        fields: 'files(id, name, mimeType, webViewLink, createdTime, modifiedTime, owners, permissions)',
        pageSize: 50,
        supportsAllDrives: true,
        includeItemsFromAllDrives: true,
      });

      if (res.data.files && res.data.files.length > 0) {
        console.log(`  ✅ Ditemukan ${res.data.files.length} file(s):`);
        for (const file of res.data.files) {
          console.log(`\n  📓 Nama: ${file.name}`);
          console.log(`     ID:   ${file.id}`);
          console.log(`     MIME: ${file.mimeType}`);
          console.log(`     Link: ${file.webViewLink || '-'}`);
          console.log(`     Dibuat: ${file.createdTime}`);
          if (file.owners) {
            console.log(`     Owner: ${file.owners.map((o) => o.emailAddress).join(', ')}`);
          }
        }
      } else {
        console.log('  ⚠️ Tidak ditemukan file dengan MIME type ini.');
      }
    } catch (err) {
      console.log(`  ❌ Error: ${err.message}`);
    }
  }

  // ── Strategi 2: Cari berdasarkan nama "NotebookLM" atau nama notebook ──
  const nameQueries = [
    'NotebookLM',
    'Sains Kuantum',
    'Fiqh Tahawwulat',
    'fiqh_tahawwulat',
  ];

  console.log('\n─────────────────────────────────────');
  console.log('📂 Mencari berdasarkan nama file...\n');

  for (const name of nameQueries) {
    try {
      console.log(`🔎 Nama mengandung: "${name}"...`);
      const res = await drive.files.list({
        q: `name contains '${name}' and trashed=false`,
        fields: 'files(id, name, mimeType, webViewLink, createdTime)',
        pageSize: 10,
        supportsAllDrives: true,
        includeItemsFromAllDrives: true,
      });

      if (res.data.files && res.data.files.length > 0) {
        for (const file of res.data.files) {
          console.log(`  📄 ${file.name} (${file.mimeType})`);
          console.log(`     ID: ${file.id}`);
          console.log(`     Link: ${file.webViewLink || '-'}`);
        }
      } else {
        console.log('  ⚠️ Tidak ditemukan.');
      }
    } catch (err) {
      console.log(`  ❌ Error: ${err.message}`);
    }
  }

  // ── Strategi 3: List semua file milik service account ──
  console.log('\n─────────────────────────────────────');
  console.log('📂 Semua file yang dapat diakses service account:\n');
  
  try {
    const res = await drive.files.list({
      q: 'trashed=false',
      fields: 'files(id, name, mimeType, webViewLink)',
      pageSize: 100,
      supportsAllDrives: true,
      includeItemsFromAllDrives: true,
    });

    if (res.data.files && res.data.files.length > 0) {
      console.log(`Total file yang terlihat: ${res.data.files.length}`);
      for (const file of res.data.files) {
        console.log(`  📄 ${file.name}`);
        console.log(`     ID: ${file.id} | MIME: ${file.mimeType}`);
      }
    } else {
      console.log('  ⚠️ Service account tidak memiliki akses ke file manapun.');
      console.log('  💡 SOLUSI: Anda perlu share notebook ke service account email:');
      console.log(`     ${serviceAccount.client_email}`);
      console.log('  Buka NotebookLM → Share → tambahkan email service account di atas sebagai Editor.');
    }
  } catch (err) {
    console.log(`  ❌ Error: ${err.message}`);
  }

  console.log('\n═══════════════════════════════════════');
  console.log('💡 LANGKAH PENTING JIKA TIDAK ADA HASIL:');
  console.log('═══════════════════════════════════════');
  console.log(`1. Buka setiap NotebookLM di browser`);
  console.log(`2. Klik Share → tambahkan email ini sebagai Editor:`);
  console.log(`   📧 ${serviceAccount.client_email}`);
  console.log(`3. Jalankan script ini lagi`);
  console.log(`4. Catat File ID yang muncul`);
  console.log('');
}

main().catch(console.error);
