// Run with NODE_PATH pointing to a runtime containing playwright.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { webkit } = require('playwright');
const source = fs.readFileSync(path.resolve(__dirname, '../../lib/core/notebook_ui_script.dart'), 'utf8');
const script = source.match(/r'''([\s\S]*?)''';/)[1];
new Function(script); // Validate the complete injected script, not only the fixture subset.
const css = source.match(/style.textContent = `([\s\S]*?)`;/)[1];
const layout = source.slice(source.indexOf('  function anchorConversationInput()'), source.indexOf('  let lastCleanAt'));
const boot = `const visible = el => el.getClientRects().length > 0 && getComputedStyle(el).display !== 'none' && getComputedStyle(el).visibility !== 'hidden';
const answerSelector = '.model-message'; const questionSelector = '.user-message';
const text = el => (el.textContent || '').trim(); ${layout}
window.layout = anchorConversationInput; anchorConversationInput();`;
const composer = '<div class="query-box-container"><div class="pill"><textarea placeholder="Ajukan pertanyaan atau buat konten"></textarea><button aria-label="Kirim">↑</button></div></div>';
async function geometry(page) {
  return page.evaluate(() => {
    const c = document.querySelector('.ot-chat-composer').getBoundingClientRect();
    const pill = document.querySelector('.pill');
    return { gap: innerHeight - c.bottom, x: c.x, width: c.width,
      row: getComputedStyle(pill).flexDirection,
      placeholder: document.querySelector('textarea:not([hidden])').getAttribute('placeholder'),
      label: document.querySelector('textarea:not([hidden])').getAttribute('aria-label') };
  });
}
test('WebKit composer remains bottom anchored through empty, populated, resized and replaced DOM', async () => {
  const browser = await webkit.launch({ headless: true });
  try {
    const page = await browser.newPage({ viewport: { width: 1200, height: 900 } });
    await page.setContent(`<style>${css}\n.pill { display:flex; flex-direction:row; border-radius:28px; padding:16px; background:#222; } textarea { flex:1; } button { width:40px; } </style>
      <textarea hidden disabled></textarea><app-root><div class="unknown-shell"><main><div class="unknown-empty-wrapper">${composer}</div></main></div></app-root>`);
    await page.addScriptTag({ content: boot });
    let g = await geometry(page);
    assert.ok(Math.abs(g.gap - 22) < 2, JSON.stringify(g));
    assert.equal(g.row, 'row'); assert.equal(g.placeholder, null); assert.ok(g.label);
    assert.ok(Math.abs(g.x - (1200 - g.width) / 2) < 2);
    await page.evaluate(() => {
      const host = document.querySelector('.unknown-empty-wrapper');
      const messages = document.createElement('div'); messages.className = 'message-list';
      messages.innerHTML = '<div class="user-message">Pertanyaan</div><div class="model-message">' + 'Jawaban<br>'.repeat(200) + '</div>';
      host.prepend(messages); window.layout();
    });
    g = await geometry(page); assert.ok(Math.abs(g.gap - 22) < 2, JSON.stringify(g));
    assert.equal(await page.$eval('.message-list', el => el.scrollHeight > el.clientHeight), true);
    await page.setViewportSize({ width: 390, height: 600 });
    await page.waitForFunction(() => document.documentElement.style.getPropertyValue('--ot-chat-height') === '600px');
    g = await geometry(page); assert.ok(Math.abs(g.gap - 22) < 2, JSON.stringify(g));
    assert.ok(g.width <= 390); assert.ok(g.x >= 0);
    await page.evaluate(html => {
      document.querySelector('.unknown-empty-wrapper').innerHTML = html; window.layout();
    }, composer);
    g = await geometry(page); assert.ok(Math.abs(g.gap - 22) < 2, JSON.stringify(g));
    assert.equal(g.placeholder, null);
    await page.$eval('textarea:not([hidden])', el => el.setAttribute('placeholder', 'Ajukan pertanyaan atau buat konten'));
    await page.waitForFunction(() => !document.querySelector('textarea:not([hidden])').hasAttribute('placeholder'));
    await page.screenshot({ path: process.env.OT_COMPOSER_SCREENSHOT || '/tmp/ot-composer-layout.png' });
    // Upstream can rename both empty-state and composer classes.
    await page.evaluate(html => {
      document.querySelector('.unknown-empty-wrapper').innerHTML = html.replace('query-box-container', 'renamed-composer');
      window.layout();
    }, composer);
    g = await geometry(page); assert.ok(Math.abs(g.gap - 22) < 2, JSON.stringify(g));
    assert.equal(g.row, 'row'); assert.equal(g.placeholder, null);
    await page.evaluate(() => { document.querySelector('.renamed-composer').remove(); window.layout(); });
    assert.equal(await page.locator('.ot-chat-path, .ot-chat-composer, .ot-chat-transcript').count(), 0);
  } finally { await browser.close(); }
});

test('complete NotebookLM presentation script keeps input usable without placeholder', async () => {
  const browser = await webkit.launch({ headless: true });
  try {
    const page = await browser.newPage({ viewport: { width: 1200, height: 900 } });
    const errors = []; page.on('pageerror', error => errors.push(error.message));
    await page.route('https://notebooklm.google.com/**', route => route.fulfill({
      contentType: 'text/html', body: `<style>.pill {display:flex;flex-direction:row;padding:16px;border-radius:28px;background:#222} textarea{flex:1} button{width:40px}</style><app-root><main><div class="unknown-empty-wrapper">${composer}</div></main></app-root>`
    }));
    await page.goto('https://notebooklm.google.com/notebook/layout-fixture');
    await page.addScriptTag({ content: script });
    const g = await geometry(page);
    assert.ok(Math.abs(g.gap - 22) < 2, JSON.stringify(g));
    assert.equal(g.placeholder, null); assert.equal(g.row, 'row');
    assert.equal(await page.evaluate(() => window.otNotebook.ready()), true);
    await page.locator('textarea').fill('Uji input');
    assert.equal(await page.locator('textarea').inputValue(), 'Uji input');
    assert.deepEqual(errors, []);
  } finally { await browser.close(); }
});


test('separate composer branch does not consume transcript space, including disabled generation', async () => {
  const browser = await webkit.launch({ headless: true });
  try {
    const page = await browser.newPage({ viewport: { width: 920, height: 900 } });
    await page.setContent(`<style>${css}
      .pill {display:flex;flex-direction:row;padding:16px} textarea{flex:1}
      .composer-branch {min-height:50%;padding-bottom:48px}
      .message-list {height:450px;max-height:450px;overflow:auto}
      </style><app-root><main><div class="chat-panel">
      <div class="transcript-branch"><div class="message-list"><div class="model-message">${'جواب عربي طويل لاختبار مساحة القراءة والتمرير<br>'.repeat(200)}</div></div></div>
      <div class="composer-branch">${composer}</div></div></main></app-root>`);
    await page.addScriptTag({content:boot});
    const check = async () => {
      const g = await geometry(page);
      assert.ok(Math.abs(g.gap - 22) < 2, JSON.stringify(g));
      const transcript = await page.$eval('.message-list', el => ({height:el.clientHeight,scroll:el.scrollHeight}));
      assert.ok(transcript.height > 750, JSON.stringify(transcript));
      assert.ok(transcript.scroll > transcript.height);
    };
    await check();
    await page.screenshot({path:'/tmp/ot-webview-nested-light.png'});
    await page.addStyleTag({content:'body{background:#1f1f1f;color:#f5f5f5}.pill{background:#292929}textarea{background:transparent;color:inherit}'});
    await page.screenshot({path:'/tmp/ot-webview-nested-dark.png'});
    await page.$eval('textarea', el => {el.disabled = true;window.layout()});
    await check();
    await page.$eval('textarea', el => {el.disabled = false;window.layout()});
    await check();
  } finally {await browser.close()}
});

test('Angular Material mat-sidenav-container maintains visible messages and bottom anchored composer', async () => {
  const browser = await webkit.launch({ headless: true });
  try {
    const page = await browser.newPage({ viewport: { width: 1000, height: 800 } });
    await page.setContent(`<style>${css}
      .pill {display:flex;flex-direction:row;padding:16px;border-radius:28px;background:#222} textarea{flex:1} button{width:40px}
      </style>
      <app-root>
        <mat-sidenav-container>
          <mat-sidenav style="height:800px;width:300px;display:block">Sidebar</mat-sidenav>
          <mat-sidenav-content>
            <div class="chat-panel-content">
              <div class="query-box-container">${composer}</div>
            </div>
          </mat-sidenav-content>
        </mat-sidenav-container>
      </app-root>`);
    await page.addScriptTag({ content: boot });
    let g = await geometry(page);
    assert.ok(Math.abs(g.gap - 22) < 2, JSON.stringify(g));
    
    // Add messages into the conversation
    await page.evaluate(() => {
      const host = document.querySelector('.chat-panel-content');
      const messages = document.createElement('div');
      messages.className = 'message-list';
      messages.innerHTML = '<div class="user-message">Pertanyaan</div><div class="model-message">' + 'Jawaban AI<br>'.repeat(50) + '</div>';
      host.insertBefore(messages, document.querySelector('.query-box-container'));
      window.layout();
    });

    const positions = await page.evaluate(() => {
      const content = document.querySelector('mat-sidenav-content').getBoundingClientRect();
      const userMsg = document.querySelector('.user-message').getBoundingClientRect();
      const modelMsg = document.querySelector('.model-message').getBoundingClientRect();
      const comp = document.querySelector('.ot-chat-composer').getBoundingClientRect();
      return {
        contentTop: content.top,
        userTop: userMsg.top,
        modelTop: modelMsg.top,
        composerGap: innerHeight - comp.bottom
      };
    });

    assert.equal(positions.contentTop, 0);
    assert.ok(positions.userTop >= 0 && positions.userTop < 100, JSON.stringify(positions));
    assert.ok(positions.modelTop > positions.userTop, JSON.stringify(positions));
    assert.ok(Math.abs(positions.composerGap - 22) < 2, JSON.stringify(positions));
  } finally { await browser.close(); }
});

