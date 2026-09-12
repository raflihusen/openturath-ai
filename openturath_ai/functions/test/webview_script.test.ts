import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
const root=process.env.AUDIT_SOURCE_ROOT || process.cwd();
const dart=fs.readFileSync(path.join(root,'lib/screens/agent_webview_screen.dart'),'utf8');
const source=dart.match(/_turatsMasterScript = r"""([\s\S]*?)""";/)![1];
function page(hostname='notebooklm.google.com'){
  const styles=new Map<string,any>();
  const appendChild=(el: any)=>styles.set(el.id,el);
  const document={getElementById:(id: string)=>styles.get(id),createElement:()=>({textContent:'',style:{setProperty(){}}}),
    head:{appendChild},documentElement:{appendChild},body:{},querySelectorAll:()=>[]};
  const window: any={};window.top=window;
  vm.runInNewContext(source,{window,document,location:{hostname},MutationObserver:class{observe(){} disconnect(){}},setTimeout,clearTimeout});
  return {styles,window};
}
test('A11 injected UI script does not modify Google sign-in pages',()=>{
  assert.equal(page('accounts.google.com').styles.size,0);
});
test('font scaling remains absolute across 100 repeated applications',()=>{
  const {window,styles}=page();window.applyTurathFontScale(1.4);
  const expected=styles.get('ot-font-scale-style').textContent;
  for(let i=0;i<100;i++)window.applyTurathFontScale(1.4);
  assert.equal(styles.get('ot-font-scale-style').textContent,expected);
  assert.match(expected,/21px/);
});
test('nonfinite scale cannot produce invalid CSS',()=>{
  const {window,styles}=page();window.applyTurathFontScale(1);window.applyTurathFontScale(NaN);
  assert.doesNotMatch(styles.get('ot-font-scale-style').textContent,/NaNpx/);
});
test('reading styles never hide arbitrary content or toolbar elements',()=>{
  const {window,styles}=page();window.applyTurathFontScale(1);
  assert.ok([...styles.values()].every(style=>!String(style.textContent).includes('display: none')));
});
