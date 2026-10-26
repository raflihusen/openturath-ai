// Menjalankan guard dialog dari notebook_skin.dart di Node (tanpa browser).
// Jalankan: node scripts/test_dialog_guard.mjs  (dari akar repo)
import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import test from 'node:test';

const src = fs.readFileSync(new URL('../openturath_ai/lib/core/notebook_skin.dart', import.meta.url), 'utf8');
const grab = name => src.match(new RegExp(`const ${name} = (\\/.*?\\/i);`))[1];
const ctx = {STRONG_DESTRUCTIVE: vm.runInNewContext(grab('STRONG_DESTRUCTIVE')), STOP_DIALOG: vm.runInNewContext(grab('STOP_DIALOG'))};
vm.createContext(ctx);
vm.runInContext(src.match(/function isDestructiveDialog\(dialog\) \{[\s\S]*?\n    \}/)[0] + ';this.f=isDestructiveDialog;', ctx);
const blocked = text => ctx.f({textContent: text});

test('dialog Stop generating asli milik Google tetap dikonfirmasi (walau memuat kata remove)', () => {
  assert.equal(blocked('Stop generating? This will stop the current response and remove it from the chat. Your message will be copied back to the input box. Keep generating Stop'), false);
});
test('dialog penghapusan tidak pernah dikonfirmasi otomatis', () => {
  for (const t of ['Delete chat history? This will permanently delete all your conversations. Cancel Delete',
    'Remove source? Cancel Remove', 'Hapus semua obrolan? Batal Hapus', 'حذف المحادثة؟ إلغاء حذف',
    'Clear chat? Cancel Clear', 'Discard changes? Cancel Discard', 'Bersihkan riwayat? Batal']) {
    assert.equal(blocked(t), true, t);
  }
});
test('dialog lain dan kosong tidak diblokir oleh guard ini', () => {
  assert.equal(blocked('Share this notebook? Cancel Share'), false);
  assert.equal(blocked(''), false);
  assert.equal(ctx.f(null), false);
});
