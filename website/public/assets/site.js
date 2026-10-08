import {initProductMotion} from './product-motion.mjs';
import {copy} from './ui.mjs';
import {normalizeSearch} from './core.mjs';
const root=document.documentElement;
root.classList.add('js');
const locale=document.body.dataset.locale||'id';
const t=copy[locale];
const $=(q,r=document)=>r.querySelector(q);
const $$=(q,r=document)=>[...r.querySelectorAll(q)];
const storage={get(k){try{return localStorage.getItem(k);}catch{return null;}},set(k,v){try{localStorage.setItem(k,v);}catch{}}};
let toastTimer;
function toast(message){const el=$('#toast');if(!el)return;el.textContent=message;el.classList.add('show');clearTimeout(toastTimer);toastTimer=setTimeout(()=>el.classList.remove('show'),3500);}
$$('.theme-toggle').forEach(b=>b.addEventListener('click',()=>{const v=root.dataset.theme==='dark'?'light':'dark';root.dataset.theme=v;document.querySelector('meta[name=theme-color]')?.setAttribute('content',v==='dark'?'#08090a':'#ffffff');storage.set('ot_theme',v);}));
const dialogTriggers=new WeakMap();
$$('[data-dialog]').forEach(b=>b.addEventListener('click',()=>{const d=document.getElementById(b.dataset.dialog);if(!d)return;dialogTriggers.set(d,b);d.showModal();}));
$$('dialog').forEach(d=>{d.addEventListener('click',ev=>{if(ev.target!==d)return;const r=d.getBoundingClientRect();if(ev.clientX<r.left||ev.clientX>r.right||ev.clientY<r.top||ev.clientY>r.bottom)d.close();});d.addEventListener('close',()=>dialogTriggers.get(d)?.focus());$$('[data-close]',d).forEach(b=>b.addEventListener('click',()=>d.close()));});
$$('a[data-locale]').forEach(a=>{const u=new URL(a.href);u.search=location.search;u.hash=location.hash;a.href=u.href;a.addEventListener('click',()=>storage.set('ot_preferred_language',a.dataset.locale));});
$$('[data-search-form]').forEach(form=>{const input=$('[data-search]',form),items=$$('[data-search-item]',form.closest('[data-search-scope]')||document),filters=$$('[data-filter]',form),count=$('[data-count]',form),empty=$('[data-empty]',form.closest('[data-search-scope]')||document);let active='all';
 const render=(write=false)=>{const query=normalizeSearch(input.value);let n=0;items.forEach(item=>{const match=(!query||normalizeSearch(item.dataset.searchText).includes(query))&&(active==='all'||item.dataset.group===active);item.hidden=!match;if(match)n++;});filters.forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.filter===active)));if(count)count.textContent=`${n.toLocaleString(locale)} ${t.results}`;if(empty)empty.hidden=n!==0;if(write){const url=new URL(location.href);query?url.searchParams.set('q',input.value):url.searchParams.delete('q');active==='all'?url.searchParams.delete('field'):url.searchParams.set('field',active);history.replaceState(null,'',url);}};
 const restore=()=>{const p=new URLSearchParams(location.search);input.value=p.get('q')||'';const wanted=p.get('field')||'all';active=filters.some(x=>x.dataset.filter===wanted)?wanted:'all';render();};
 input.addEventListener('input',()=>render(true));form.addEventListener('submit',ev=>{ev.preventDefault();render(true);});filters.forEach(b=>b.addEventListener('click',()=>{active=b.dataset.filter;render(true);}));form.addEventListener('reset',()=>{active='all';input.value='';render(true);});window.addEventListener('popstate',restore);restore();});
async function copyText(text,message){try{await navigator.clipboard.writeText(text);toast(message);}catch{toast(t.copyFailed);}}
$$('[data-copy]').forEach(b=>b.addEventListener('click',()=>copyText(b.dataset.copy,t.copied)));
const comparison=$('[data-compare]');
if(comparison){const params=new URLSearchParams(location.search);$$('[data-answer-select]').forEach(select=>{const slot=select.dataset.answerSelect;const requested=params.get(slot);if(requested&&[...select.options].some(x=>x.value===requested))select.value=requested;const render=(write=false)=>{const template=document.getElementById('answer-'+select.value);const target=$(`[data-answer-slot="${slot}"]`);if(!template||!target)return;target.replaceChildren(template.content.cloneNode(true));const mobileLabel=$(`[data-mobile-tab="${slot}"]`);if(mobileLabel)mobileLabel.textContent=select.selectedOptions[0].textContent;if(write){const url=new URL(location.href);url.searchParams.set(slot,select.value);history.replaceState(null,'',url);}};select.addEventListener('change',()=>render(true));window.addEventListener('popstate',()=>{const q=new URLSearchParams(location.search).get(slot);if(q&&[...select.options].some(o=>o.value===q)){select.value=q;render();}});render();});}
let readerSize=Math.max(0.875,Math.min(1.5,Number(storage.get('ot_reader_size'))||1));
function applySize(){root.style.setProperty('--reader',readerSize+'rem');}applySize();
$$('[data-font]').forEach(b=>b.addEventListener('click',()=>{readerSize=Math.max(.875,Math.min(1.5,readerSize+Number(b.dataset.font)*.125));applySize();storage.set('ot_reader_size',String(readerSize));}));
let readingTrigger;
function exitReading(){document.body.classList.remove('reading-mode');readingTrigger?.focus();}
$$('[data-focus]').forEach(b=>b.addEventListener('click',()=>{readingTrigger=b;document.body.classList.add('reading-mode');$('[data-focus-exit]').focus();}));
$$('[data-focus-exit]').forEach(b=>b.addEventListener('click',exitReading));
document.addEventListener('keydown',ev=>{if(ev.key==='Escape'&&document.body.classList.contains('reading-mode'))exitReading();});
function newRequestId(){if(crypto.randomUUID)return crypto.randomUUID();const a=crypto.getRandomValues(new Uint8Array(16));a[6]=(a[6]&15)|64;a[8]=(a[8]&63)|128;const h=[...a].map(x=>x.toString(16).padStart(2,'0')).join('');return `${h.slice(0,8)}-${h.slice(8,12)}-${h.slice(12,16)}-${h.slice(16,20)}-${h.slice(20)}`;}
function downloadText(text,filename){const url=URL.createObjectURL(new Blob([text],{type:'text/plain;charset=utf-8'}));const a=document.createElement('a');a.href=url;a.download=filename;document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);}
$$('[data-report-form]').forEach(form=>{let requestId=newRequestId(),lastFingerprint='';const status=$('.form-status',form);const submit=$('[type=submit]',form);const originalLabel=submit?.textContent;
 const values=()=>{const fd=new FormData(form);return{topic:fd.get('topic'),email:fd.get('email'),message:fd.get('message'),consent:fd.get('consent')==='on',website:fd.get('website'),locale,page:location.pathname};};
 $('[data-save-report]',form).addEventListener('click',()=>{const v=values();downloadText(`OpenTurath — ${t.report}\n${t.subject}: ${v.topic}\n${t.email}: ${v.email}\n\n${v.message}\n\n${location.pathname}\n`,'openturath-report.txt');});
 form.addEventListener('submit',async ev=>{ev.preventDefault();if(!submit||!form.reportValidity())return;const payload=values(),fingerprint=JSON.stringify(payload);if(lastFingerprint&&lastFingerprint!==fingerprint)requestId=newRequestId();lastFingerprint=fingerprint;submit.disabled=true;submit.textContent=t.sending;status.textContent='';try{const response=await fetch('/api/reports',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({...payload,requestId}),signal:AbortSignal.timeout(15000)});const result=await response.json();if(!response.ok||result.status!=='saved'||!result.id)throw new Error('not-saved');status.textContent=t.sent+' '+result.id;if(JSON.stringify(values())===fingerprint)form.reset();else status.textContent+=' '+{id:'Perubahan terbaru pada formulir belum dikirim.',en:'Your latest edits have not been submitted.',ar:'لم تُرسل تعديلاتك الأخيرة على النموذج.'}[locale];requestId=newRequestId();lastFingerprint='';}catch{status.textContent=t.failed;}finally{submit.disabled=false;submit.textContent=originalLabel;}});});
// Decorative entrance motion never delays core content or reading controls.

if(comparison){
 const mq=matchMedia('(max-width: 560px)'); let active=new URLSearchParams(location.search).get('panel')==='right'?'right':'left';
 const sync=()=>{for(const side of ['left','right']){const panel=document.getElementById('compare-'+side),tab=$('[data-mobile-tab="'+side+'"]');panel.hidden=mq.matches&&active!==side;if(mq.matches){panel.setAttribute('role','tabpanel');panel.setAttribute('aria-labelledby','compare-tab-'+side);}else{panel.removeAttribute('role');panel.removeAttribute('aria-labelledby');}tab.setAttribute('aria-selected',String(active===side));tab.tabIndex=active===side?0:-1;}};
 $$('[data-mobile-tab]').forEach(b=>{b.addEventListener('click',()=>{active=b.dataset.mobileTab;sync();});b.addEventListener('keydown',e=>{if(['ArrowLeft','ArrowRight','Home','End'].includes(e.key)){e.preventDefault();active=e.key==='Home'?'left':e.key==='End'?'right':active==='left'?'right':'left';sync();$('[data-mobile-tab="'+active+'"] ').focus();}});});mq.addEventListener('change',sync);sync();
}

$$('[data-locate-quote]').forEach(b=>b.addEventListener('click',()=>{const select=$('[data-answer-select="left"]');select.value='openturath';select.dispatchEvent(new Event('change'));$('[data-mobile-tab="left"]')?.click();const q=$('#quote-'+b.dataset.locateQuote).content.textContent;const matches=$$('[data-answer-slot="left"] strong').filter(n=>n.textContent===q);$$('.quote-highlight').forEach(n=>n.classList.remove('quote-highlight'));if(matches[0]){matches[0].classList.add('quote-highlight');matches[0].tabIndex=-1;matches[0].focus({preventScroll:true});matches[0].scrollIntoView({behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'auto':'smooth',block:'center'});}}));
const reportEvidence=new URLSearchParams(location.search).get('evidence');if(reportEvidence&&/^q001-e\d{2}$/.test(reportEvidence)){const input=$('[data-report-form] textarea');if(input&&!input.value)input.value='Q001 · '+reportEvidence+'\n\n';}

const device=/Android/i.test(navigator.userAgent)?'android':/iPhone|iPad|iPod/i.test(navigator.userAgent)?'ios':'';
$$('[data-platform]').forEach(card=>{if(device&&!card.hasAttribute('data-coming-soon')&&card.dataset.platform.includes(device))$('[data-device-hint]',card).hidden=false;});
$$('[data-download]').forEach(a=>a.addEventListener('click',()=>toast({id:'Tautan unduhan dibuka.',en:'Download link opened.',ar:'فُتح رابط التنزيل.'}[locale])));

// Read a fixed archival example without pretending to run a live AI model.
const experienceTabs=$$('[data-experience-tab]');
if(experienceTabs.length){
 let stage=0;
 const tablist=experienceTabs[0].closest('[role="tablist"]');
 const mobileStages=matchMedia('(max-width:600px)');
 const syncOrientation=()=>tablist.setAttribute('aria-orientation',mobileStages.matches?'horizontal':'vertical');
 const syncStage=()=>{
  experienceTabs.forEach((b,i)=>{b.setAttribute('aria-selected',String(i===stage));b.tabIndex=i===stage?0:-1;});
  $$('[data-experience-panel]').forEach((p,i)=>{p.hidden=i!==stage;p.tabIndex=0;});
 };
 experienceTabs.forEach((b,i)=>{
  b.addEventListener('click',()=>{stage=i;syncStage();});
  b.addEventListener('keydown',ev=>{
   const keys=mobileStages.matches?['ArrowLeft','ArrowRight','Home','End']:['ArrowUp','ArrowDown','Home','End'];
   if(!keys.includes(ev.key))return;
   ev.preventDefault();
   const previous=mobileStages.matches?(locale==='ar'?'ArrowRight':'ArrowLeft'):'ArrowUp';
   stage=ev.key==='Home'?0:ev.key==='End'?experienceTabs.length-1:(stage+(ev.key===previous?-1:1)+experienceTabs.length)%experienceTabs.length;
   syncStage();experienceTabs[stage].focus();
  });
 });
 mobileStages.addEventListener('change',syncOrientation);syncOrientation();syncStage();
}
initProductMotion();

// Accessible introductory choices; these never create an AI session.
$$('[data-tahawwulat-framework]').forEach(panel=>{const choices=$$('[data-framework-choice]',panel);const out=$('[data-framework-output]',panel);choices.forEach(button=>button.addEventListener('click',()=>{choices.forEach(other=>other.setAttribute('aria-pressed',String(other===button)));out.textContent=button.dataset.explanation;}));});
