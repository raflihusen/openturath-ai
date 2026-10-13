const puppeteer = require('puppeteer');
const path = require('path');

// Target Notebook URL
const NOTEBOOK_URL = 'https://notebooklm.google.com/notebook/362ed063-b398-4e76-93cf-c540db261156';

// Session directory to persist Google login cookies
const USER_DATA_DIR = path.join(__dirname, 'chrome_session');

async function manageAccess(action, email) {
  if (action !== 'add' && action !== 'remove') {
    console.error('❌ Invalid action. Use "add" or "remove".');
    return;
  }

  console.log(`\n🚀 [NotebookLM Sharer] Starting action "${action.toUpperCase()}" for: ${email}`);

  // Launching browser with user session
  const browser = await puppeteer.launch({
    headless: false, // Set to true in production once login is saved
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
    console.log('[1/5] Opening NotebookLM...');
    await page.goto(NOTEBOOK_URL, { waitUntil: 'networkidle2' });

    // Check if Google Sign-In is required
    const isLoginRequired = await page.evaluate(() => {
      const text = document.body.innerText;
      return text.includes('Sign in') || !!document.querySelector('input[type="email"]');
    });

    if (isLoginRequired) {
      console.log('⚠️ [WARNING] Google login required in this session.');
      console.log('Please log in manually in the browser window that has opened.');
      console.log('Waiting for login success (max 2 minutes)...');

      try {
        await page.waitForSelector('button[aria-label*="Share"], button[aria-label*="Bagikan"]', { timeout: 120000 });
        console.log('✅ Manual login detected successfully!');
      } catch (err) {
        console.error('❌ Manual login timed out. Aborting.');
        await browser.close();
        return;
      }
    }

    console.log('✅ Notebook loaded successfully.');

    // Click the Share button
    console.log('[2/5] Opening Share dialog...');
    const shareButtonSelector = 'button[aria-label*="Share"], button[aria-label*="Bagikan"], button[title*="Share"]';
    await page.waitForSelector(shareButtonSelector, { timeout: 10000 });
    await page.click(shareButtonSelector);

    // Wait for the share dialog/modal
    await page.waitForSelector('mat-dialog-container, [role="dialog"]', { timeout: 8000 });
    console.log('✅ Share dialog is open.');

    // Dismiss any autofill contact dropdowns by pressing Escape
    await page.keyboard.press('Escape');
    await new Promise(r => setTimeout(r, 500));

    if (action === 'add') {
      // ── ADDING EMAIL ACCESS ──
      console.log(`[3/5] Typing email: ${email}...`);

      const inputSelector = 'input[placeholder*="Add people"], input[placeholder*="Tambahkan orang"], input[class*="mat-mdc-input-element"]';
      await page.waitForSelector(inputSelector, { timeout: 5000 });
      await page.click(inputSelector);
      await page.type(inputSelector, email, { delay: 100 });

      // Click the autocomplete suggestion
      console.log('Waiting for autocomplete suggestion...');
      const autocompleteSelector = '.peoplekitComponentsResultlistitemResultListItem, [role="option"]';
      await page.waitForSelector(autocompleteSelector, { timeout: 5000 });
      await page.click(autocompleteSelector);
      console.log('✅ Email selected from dropdown.');

      // Click the Send button
      console.log('[4/5] Sending invite...');
      await page.evaluate(() => {
        const buttons = Array.from(document.querySelectorAll('button'));
        const sendBtn = buttons.find(btn => {
          const text = btn.textContent.toLowerCase();
          return text.includes('send') || text.includes('kirim');
        });
        if (sendBtn) {
          sendBtn.click();
        } else {
          throw new Error('Send button not found.');
        }
      });

      // Wait for dialog to close
      await page.waitForFunction(() => !document.querySelector('mat-dialog-container'), { timeout: 10000 });
      console.log(`🎉 [5/5] SUCCESS: Added ${email} as a Viewer.`);

    } else if (action === 'remove') {
      // ── REMOVING EMAIL ACCESS ──
      console.log(`[3/5] Finding email row for ${email}...`);

      const userFound = await page.evaluate((targetEmail) => {
        const items = Array.from(document.querySelectorAll('mat-list-item, .mat-mdc-list-item, div'));
        const emailEl = items.find(el => el.textContent.trim() === targetEmail);
        if (!emailEl) return false;

        // Traverse up to find the row and click the permission dropdown button
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
        console.log(`⚠️ Email ${email} not found in active share list.`);
        await browser.close();
        return;
      }

      console.log('✅ Clicked role dropdown. Selecting "Remove access"...');
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
          throw new Error('"Remove access" option not found.');
        }
      });

      // Save changes (Google Share Dialog button text changes to Save/Simpan)
      console.log('[4/5] Saving permission changes...');
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
          throw new Error('Save button not found.');
        }
      });

      // Wait for dialog to close
      await page.waitForFunction(() => !document.querySelector('mat-dialog-container'), { timeout: 10000 });
      console.log(`🎉 [5/5] SUCCESS: Revoked access for ${email}.`);
    }

  } catch (error) {
    console.error('❌ Error during execution:', error);
  } finally {
    await browser.close();
    console.log('[System] Browser closed.\n');
  }
}

// CLI Usage:
// node notebooklm_sharer.js add email@gmail.com
// node notebooklm_sharer.js remove email@gmail.com
const args = process.argv.slice(2);
const action = args[0] || 'add';
const email = args[1] || 'chenhuha135@gmail.com';

manageAccess(action, email);
