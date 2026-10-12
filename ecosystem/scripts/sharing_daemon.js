const admin = require('firebase-admin');
const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

// Path ke berkas Service Account Firebase Admin SDK
const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'service-account.json');

// Validasi keberadaan file service account
if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
  console.error('❌ ERROR: Berkas credentials "service-account.json" tidak ditemukan di direktori ini.');
  console.error('Silakan buat dan unduh private key Admin SDK Anda dari Firebase Console:');
  console.log('Project Settings -> Service Accounts -> Generate new private key');
  console.log(`Lalu simpan di: ${SERVICE_ACCOUNT_PATH}\n`);
  process.exit(1);
}

// Inisialisasi Firebase Admin
const serviceAccount = require(SERVICE_ACCOUNT_PATH);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Target Notebook URL
const NOTEBOOK_URL = 'https://notebooklm.google.com/notebook/362ed063-b398-4e76-93cf-c540db261156';

// Direktori untuk menyimpan session login Google Chrome agar tidak perlu login ulang
const USER_DATA_DIR = path.join(__dirname, 'chrome_session');

// Flag untuk menandakan daemon sedang memproses tugas agar tidak tabrakan
let isProcessing = false;

console.log('✨ [Sharing Daemon] Daemon pembagi akses NotebookLM aktif.');
console.log(`Mendengarkan antrean tugas pending di Firestore...\n`);

// Daftarkan listener real-time pada koleksi sharing_queue
db.collection('sharing_queue')
  .where('status', '==', 'pending')
  .onSnapshot(async (snapshot) => {
    if (snapshot.empty) return;
    if (isProcessing) {
      console.log('⏳ Daemon sedang memproses tugas lain, menunggu giliran...');
      return;
    }

    isProcessing = true;

    // Ambil semua dokumen pending dalam antrean dan urutkan berdasarkan created_at di memori
    const docs = [...snapshot.docs].sort((a, b) => {
      const aTime = a.data().created_at ? a.data().created_at.toMillis() : 0;
      const bTime = b.data().created_at ? b.data().created_at.toMillis() : 0;
      return aTime - bTime;
    });
    
    for (const doc of docs) {
      const data = doc.data();
      const docId = doc.id;
      const { email, action } = data;

      try {
        // 1. Ubah status menjadi processing
        await doc.ref.update({
          status: 'processing',
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`\n========================================`);
        console.log(`📦 Memproses Tugas [${docId}] - Aksi: ${action.toUpperCase()}, Email: ${email}`);
        
        // 2. Jalankan Puppeteer
        const success = await executePuppeteerAction(action, email);

        if (success) {
          // 3. Jika sukses, ubah status menjadi completed
          await doc.ref.update({
            status: 'completed',
            updated_at: admin.firestore.FieldValue.serverTimestamp()
          });
          console.log(`✅ Sukses memproses tugas ${docId}`);
        } else {
          throw new Error('Gagal mengeksekusi otomatisasi browser.');
        }

      } catch (err) {
        console.error(`❌ Gagal memproses tugas ${docId}:`, err.message);
        
        const attempts = (data.attempts || 0) + 1;
        const maxAttempts = 3;

        await doc.ref.update({
          status: attempts >= maxAttempts ? 'failed' : 'pending', // Coba lagi jika belum max attempts
          attempts: attempts,
          error: err.message,
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }

    isProcessing = false;
  }, (error) => {
    console.error('❌ Firestore listener error:', error);
  });

async function executePuppeteerAction(action, email) {
  // Meluncurkan browser dengan persistent user session
  const browser = await puppeteer.launch({
    headless: false, // Set ke true saat deployment produksi (headless mode)
    executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    userDataDir: USER_DATA_DIR,
    defaultViewport: { width: 1280, height: 800 },
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-blink-features=AutomationControlled'
    ]
  });

  const page = await browser.newPage();

  try {
    console.log('[1/5] Membuka NotebookLM...');
    await page.goto(NOTEBOOK_URL, { waitUntil: 'networkidle2' });

    // Cek apakah halaman meminta login
    const isLoginRequired = await page.evaluate(() => {
      const text = document.body.innerText;
      return text.includes('Sign in') || !!document.querySelector('input[type="email"]');
    });

    if (isLoginRequired) {
      console.log('⚠️ [PERHATIAN] Google account belum login.');
      console.log('Silakan login manual pada jendela browser Chromium yang terbuka.');
      
      // Tunggu manual login selesai (maks 2 menit)
      try {
        await page.waitForSelector('button[aria-label*="Share"], button[aria-label*="Bagikan"]', { timeout: 120000 });
        console.log('✅ Login manual berhasil dideteksi!');
      } catch (err) {
        console.error('❌ Login manual habis waktu (timeout).');
        await browser.close();
        return false;
      }
    }

    // Klik tombol Share
    console.log('[2/5] Membuka dialog Share...');
    const shareButtonSelector = 'button[aria-label*="Share"], button[aria-label*="Bagikan"], button[title*="Share"]';
    await page.waitForSelector(shareButtonSelector, { timeout: 10000 });
    await page.click(shareButtonSelector);

    // Tunggu dialog
    await page.waitForSelector('mat-dialog-container, [role="dialog"]', { timeout: 8000 });
    console.log('✅ Dialog Share terbuka.');

    // Tutup auto-complete dialog kontak bawaan
    await page.keyboard.press('Escape');
    await new Promise(r => setTimeout(r, 500));

    if (action === 'add') {
      console.log(`[3/5] Mengisi email: ${email}...`);
      const inputSelector = 'input[placeholder*="Add people"], input[placeholder*="Tambahkan orang"], input[class*="mat-mdc-input-element"]';
      await page.waitForSelector(inputSelector, { timeout: 5000 });
      await page.click(inputSelector);
      await page.type(inputSelector, email, { delay: 100 });

      console.log('Menunggu popup autocomplete...');
      const autocompleteSelector = '.peoplekitComponentsResultlistitemResultListItem, [role="option"]';
      await page.waitForSelector(autocompleteSelector, { timeout: 5000 });
      await page.click(autocompleteSelector);
      console.log('✅ Email terkonfirmasi dari dropdown.');

      console.log('[4/5] Mengirim undangan perizinan...');
      await page.evaluate(() => {
        const buttons = Array.from(document.querySelectorAll('button'));
        const sendBtn = buttons.find(btn => {
          const text = btn.textContent.toLowerCase();
          return text.includes('send') || text.includes('kirim');
        });
        if (sendBtn) {
          sendBtn.click();
        } else {
          throw new Error('Tombol Send tidak ditemukan.');
        }
      });

      await page.waitForFunction(() => !document.querySelector('mat-dialog-container'), { timeout: 10000 });
      console.log(`🎉 [5/5] SUKSES: Email ${email} berhasil terdaftar.`);
      return true;

    } else if (action === 'remove') {
      console.log(`[3/5] Mencari email ${email} untuk dihapus...`);
      
      const userFound = await page.evaluate((targetEmail) => {
        const items = Array.from(document.querySelectorAll('mat-list-item, .mat-mdc-list-item, div'));
        const emailEl = items.find(el => el.textContent.trim() === targetEmail);
        if (!emailEl) return false;

        let parent = emailEl;
        let dropdownBtn = null;
        for (let i = 0; i < 7; i++) {
          if (!parent) break;
          dropdownBtn = parent.querySelector('button[aria-haspopup="listbox"], button[role="combobox"]');
          if (dropdownBtn) break;
          parent = parent.parentElement;
        }

        if (dropdownBtn) {
          dropdownBtn.click();
          return true;
        }
        return false;
      }, email);

      if (!userFound) {
        console.log(`⚠️ Email ${email} tidak ada dalam daftar share aktif.`);
        await browser.close();
        return true; // Sukses karena email target memang sudah tidak terdaftar
      }

      console.log('✅ Dropdown perizinan terbuka. Memilih "Remove access"...');
      await new Promise(r => setTimeout(r, 1000));

      await page.evaluate(() => {
        const options = Array.from(document.querySelectorAll('mat-option, [role="option"]'));
        const removeOption = options.find(opt => {
          const txt = opt.textContent.toLowerCase();
          return txt.includes('remove') || txt.includes('hapus') || txt.includes('cabut');
        });
        if (removeOption) {
          removeOption.click();
        } else {
          throw new Error('Opsi "Remove access" tidak ditemukan.');
        }
      });

      console.log('[4/5] Menyimpan perubahan...');
      await new Promise(r => setTimeout(r, 500));

      await page.evaluate(() => {
        const buttons = Array.from(document.querySelectorAll('button'));
        const saveBtn = buttons.find(btn => {
          const txt = btn.textContent.toLowerCase();
          return txt.includes('save') || txt.includes('simpan') || txt.includes('done') || txt.includes('selesai');
        });
        if (saveBtn) {
          saveBtn.click();
        } else {
          throw new Error('Tombol Save tidak ditemukan.');
        }
      });

      await page.waitForFunction(() => !document.querySelector('mat-dialog-container'), { timeout: 10000 });
      console.log(`🎉 [5/5] SUKSES: Akses untuk email ${email} berhasil dicabut.`);
      return true;
    }

  } catch (error) {
    console.error('❌ Terjadi error pada Puppeteer browser:', error.message);
    return false;
  } finally {
    await browser.close();
  }
}
