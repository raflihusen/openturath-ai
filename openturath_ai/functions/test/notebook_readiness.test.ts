import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
const root = process.env.AUDIT_SOURCE_ROOT || process.cwd();
const source = fs.readFileSync(path.join(root, 'lib/core/notebook_ui_script.dart'), 'utf8');
const inputBody = source.match(/function inputReady\(\) \{([\s\S]*?)\n  \}/)![1];
function input(disabled = false, shown = true) {
  return { disabled, getAttribute: () => null, getClientRects: () => shown ? [{}] : [] };
}
function probe(inputs: any[]) {
  return vm.runInNewContext(`(function(){ ${inputBody} })()`, {
    document: { querySelectorAll: () => inputs },
    visible: (item: any) => item.getClientRects().length > 0,
  });
}
test('a hidden first input does not mask the usable composer', () => {
  assert.equal(probe([input(false, false), input(false, true)]), true);
});
test('a disabled first input does not mask the usable composer', () => {
  assert.equal(probe([input(true), input(false)]), true);
});
test('empty, hidden and disabled inputs cannot declare a session ready', () => {
  assert.equal(probe([]), false);
  assert.equal(probe([input(false, false), input(true)]), false);
});
test('unrelated source-panel progress cannot block an enabled conversation input', () => {
  const readyBody = source.match(/function ready\(\) \{([\s\S]*?)\n  \}/)![1];
  assert.equal(vm.runInNewContext(`(function(){ ${readyBody} })()`, {
    accessDenied: () => false, inputReady: () => true, isStillLoading: () => true,
  }), true);
});

test('notebookUiScript parses with valid JavaScript syntax without any unexpected tokens', () => {
  const uiMatch = source.match(/const notebookUiScript = r'''([\s\S]*?)''';/);
  assert.ok(uiMatch, 'Could not find notebookUiScript in source');
  assert.doesNotThrow(() => {
    new Function(uiMatch[1]);
  }, 'notebookUiScript contains a JavaScript syntax error!');
});

