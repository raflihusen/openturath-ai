'use strict';
// Local design proposal. Catalog metadata is real; no authentication or NotebookLM requests run here.
const icons = {
  chat:'<path d="M21 11.5a8.4 8.4 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.4 8.4 0 0 1-3.8-.9L3 21l1.9-5.7a8.4 8.4 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.4 8.4 0 0 1 3.8-.9h.5a8.5 8.5 0 0 1 8 8v.5Z"/>',
  library:'<path d="M4 4h4v16H4zM10 4h4v16h-4zM16 5l4-1 4 15-4 1Z"/>',
  book:'<path d="M5 3h14v18H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2ZM5 17h14M7 7h8M7 10h6"/>',
  note:'<path d="M13 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-8M8 16l1-4 10-10 3 3-10 10Z"/>',
  search:'<circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/>',
  sun:'<circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M2 12h2m16 0h2M5 5l1 1m12 12 1 1M5 19l1-1M18 6l1-1"/>',
  settings:'<path d="m9 3-.5 2.2-2 1.2L4.3 6 2 10l1.7 1.5v1L2 14l2.3 4 2.2-.4 2 1.2L9 21h6l.5-2.2 2-1.2 2.2.4 2.3-4-1.7-1.5v-1L22 10l-2.3-4-2.2.4-2-1.2L15 3Z"/><circle cx="12" cy="12" r="3"/>',
  chevron:'<path d="m9 6 6 6-6 6"/>',back:'<path d="M20 12H4m6-6-6 6 6 6"/>',close:'<path d="m6 6 12 12M6 18 18 6"/>',plus:'<path d="M12 4v16M4 12h16"/>',
};
const icon = name => `<svg viewBox="0 0 24 24" aria-hidden="true">${icons[name] || icons.book}</svg>`;
const esc = value => String(value ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const number = value => new Intl.NumberFormat('id-ID').format(value);
const root = document.querySelector('#content');
const pageSize = 12;
let books = [], toastTimer, catalogRoute = '#pustaka', activeNote = null;
const notesKey = 'openturath-saas-preview-notes-v1';
const draftKey = 'openturath-saas-preview-draft-v1';
function read(key,fallback){try{return JSON.parse(localStorage.getItem(key)) ?? fallback;}catch{return fallback;}}
function write(key,value){try{localStorage.setItem(key,JSON.stringify(value));return true;}catch{return false;}}
let notes = read(notesKey,[]); if(!Array.isArray(notes)) notes=[];
function route(){const [name,query='']=(location.hash.slice(1)||'pustaka').split('?');return {name,params:new URLSearchParams(query)};}
function link(patch={}){const params=new URLSearchParams(route().name==='pustaka'?route().params:new URLSearchParams());for(const [key,value] of Object.entries(patch)){if(value===null||value===''||value===undefined)params.delete(key);else params.set(key,String(value));}return '#pustaka'+(params.size?'?'+params.toString():'');}
function updateParams(patch){history.replaceState(null,'',link(patch));catalogRoute=location.hash;}
function normalize(value){return String(value).toLowerCase().normalize('NFKD').replace(/[\u064B-\u065F\u0670\u0640]/g,'').replace(/[أإآ]/g,'ا').replace(/ى/g,'ي');}
function year(book){const value=Number(book.tahun_wafat||book.سنة_الوفاة);return Number.isFinite(value)&&value>0?value:null;}
function volumes(book){return book.عدد_الأجزاء || book.volumes || book.jilid || '—';}
function title(book){return book.الاسم_المختصر || book.الكتاب;}
function selectedBook(){return books.find(book=>String(book.id)===route().params.get('book'));}
function toast(message){clearTimeout(toastTimer);const el=document.querySelector('#toast');el.textContent=message;el.classList.add('visible');toastTimer=setTimeout(()=>el.classList.remove('visible'),4000);}
function hydrateIcons(){document.querySelectorAll('[data-icon]').forEach(el=>{el.innerHTML=icon(el.dataset.icon);});}
function renderLibrary(){
  const params=route().params;
  root.innerHTML=`<header class="page-header"><div><h1>Fikih Syafi’i</h1><p>${number(books.length)} kitab dalam katalog rujukan</p></div><a class="button primary" href="#asisten">${icon('chat')} Buka asisten</a></header>
  <div class="catalog-workspace" id="catalog-workspace"><section class="catalog-main" aria-label="Katalog kitab"><div class="toolbar"><label class="search">${icon('search')}<input id="book-search" name="q" aria-label="Cari judul atau pengarang" placeholder="Cari judul atau pengarang…" autocomplete="off" value="${esc(params.get('q')||'')}" dir="auto"></label><select id="era" name="era" aria-label="Periode pengarang"><option value="all">Semua periode</option><option value="early">Hingga 300 H</option><option value="middle">301–600 H</option><option value="late">Setelah 600 H</option></select><select id="sort" name="sort" aria-label="Urutan katalog"><option value="original">Urutan katalog</option><option value="name">Judul A–Z</option><option value="year">Tahun wafat</option></select></div><div id="catalog-results"></div><p class="source-caption">Metadata dari katalog aplikasi. Katalog ini tidak menunjukkan status akses atau pemasangan sumber di NotebookLM.</p></section><aside class="detail" id="book-detail" aria-label="Detail kitab" hidden></aside></div>`;
  document.querySelector('#era').value=params.get('era')||'all';
  document.querySelector('#sort').value=params.get('sort')||'original';
  document.querySelector('#book-search').addEventListener('input',e=>{updateParams({q:e.target.value,p:1,book:null});renderResults();});
  for(const key of ['era','sort'])document.querySelector('#'+key).addEventListener('change',e=>{updateParams({[key]:e.target.value,p:1,book:null});renderResults();});
  renderResults();
}
function renderResults(){
  const params=route().params, query=normalize(params.get('q')||''), era=params.get('era')||'all';
  let result=books.filter(book=>{
    const date=year(book);
    const matchesPeriod=era==='all'||(date!==null&&((era==='early'&&date<=300)||(era==='middle'&&date>300&&date<=600)||(era==='late'&&date>600)));
    return matchesPeriod&&normalize(`${book.الكتاب} ${book.الاسم_المختصر} ${book.المؤلف}`).includes(query);
  });
  if(params.get('sort')==='name')result=result.slice().sort((a,b)=>String(title(a)).localeCompare(String(title(b)),'ar'));
  if(params.get('sort')==='year')result=result.slice().sort((a,b)=>(year(a)||Infinity)-(year(b)||Infinity));
  const pageCount=Math.max(1,Math.ceil(result.length/pageSize));
  const page=Math.min(pageCount,Math.max(1,Number.parseInt(params.get('p')||'1',10)||1));
  const start=(page-1)*pageSize, end=Math.min(start+pageSize,result.length), selected=selectedBook();
  const rows=result.slice(start,end).map(book=>`<tr ${selected?.id===book.id?'class="selected"':''}><td><a class="book-link" href="${esc(link({book:book.id}))}" aria-label="Lihat metadata ${esc(book.الكتاب)}"><span class="book-symbol">${icon('book')}</span><span class="book-link-text"><span class="book-name arabic" lang="ar" dir="rtl">${esc(title(book))}</span><span class="inline-author author-name" lang="ar" dir="rtl">${esc(book.المؤلف)}</span></span></a></td><td class="author-col"><span class="author-name" lang="ar" dir="rtl">${esc(book.المؤلف)}</span></td><td class="year-col"><span class="mobile-data-label">Wafat </span>${year(book)?number(year(book))+' H':'—'}</td><td class="volume-col"><span class="mobile-data-label">Jilid </span>${esc(volumes(book))}</td><td class="open-col"><a class="open-link" href="${esc(link({book:book.id}))}" aria-label="Buka detail ${esc(title(book))}">${icon('chevron')}</a></td></tr>`).join('');
  document.querySelector('#catalog-results').innerHTML=`<div class="results-line"><span role="status" aria-live="polite">${query||era!=='all'?number(result.length)+' hasil ditemukan':number(books.length)+' kitab'}</span>${query||era!=='all'?'<button class="text-button" data-action="reset">Reset pencarian</button>':'<span>Katalog Fikih Syafi’i</span>'}</div>${result.length?`<table class="catalog-table" aria-label="Daftar kitab Fikih Syafi’i"><thead><tr><th scope="col">Kitab</th><th class="author-col" scope="col">Pengarang</th><th class="year-col" scope="col">Wafat</th><th class="volume-col" scope="col">Jilid</th><th class="open-col" scope="col"><span class="sr-only" aria-label="Detail kitab"></span></th></tr></thead><tbody>${rows}</tbody></table><div class="pagination"><span>${number(start+1)}–${number(end)} dari ${number(result.length)} kitab</span><div class="pagination-controls"><button class="button" data-page="${page-1}" ${page===1?'disabled':''}>Sebelumnya</button><span class="pagination-label">${number(page)} / ${number(pageCount)}</span><button class="button" data-page="${page+1}" ${page===pageCount?'disabled':''}>Berikutnya</button></div></div>`:`<div class="empty">${icon('search')}<h2>Kitab tidak ditemukan</h2><p>Coba judul Arab yang lebih singkat, nama pengarang, atau hapus filter periode.</p><button class="button" data-action="reset">Reset pencarian</button></div>`}`;
  const workspace=document.querySelector('#catalog-workspace'),detail=document.querySelector('#book-detail');
  workspace.classList.toggle('has-detail',Boolean(selected));detail.hidden=!selected;
  detail.innerHTML=selected?detailMarkup(selected):'';
}
function detailMarkup(book){
  const metadata=[['Peneliti / editor',book.المحقق_أو_المعتني,true],['Penerbit',book.الناشر,true],['Edisi',book.سنة_الطبع_والطبعة,true],['Jumlah jilid',volumes(book),false],['Jumlah halaman',book.عدد_الصفحات || book.jumlah_halaman || '—',false]];
  return `<div class="detail-top"><button class="text-button back-detail" data-action="close-book">${icon('back')} Kembali ke katalog</button><span>Metadata kitab</span><button class="icon-button" data-action="close-book" aria-label="Tutup detail kitab">${icon('close')}</button></div><h2 class="detail-title" id="detail-title" lang="ar" dir="rtl" tabindex="-1">${esc(book.الكتاب)}</h2><p class="detail-author" lang="ar" dir="rtl">${esc(book.المؤلف)}</p><dl>${metadata.map(([label,value,arabic])=>`<div><dt>${label}</dt><dd ${arabic?'lang="ar" dir="rtl"':'dir="ltr"'}>${esc(value || 'Belum tersedia')}</dd></div>`).join('')}</dl><div class="detail-actions"><button class="button primary" data-action="book-note">${icon('note')} Buat catatan rujukan</button><a class="button" href="#ruang">${icon('chat')} Lihat ruang NotebookLM</a></div><p class="detail-caption">Periksa edisi dan halaman saat memakai rujukan. Percakapan NotebookLM belum terhubung pada pratinjau ini.</p>`;
}
function renderAssistants(){
  root.innerHTML=`<header class="page-header"><div><h1>Asisten</h1><p>Pilih bidang untuk membuka ruang NotebookLM.</p></div></header><p class="assistant-intro">Layar ini memperlihatkan alur navigasi. Pilihan berikut berasal dari bidang pada aplikasi; percakapan dan hak akses tidak dijalankan dalam pratinjau.</p><div class="assistant-list">${[['Fikih Syafi’i','Rujukan fikih mazhab Syafi’i.'],['Fikih Tahawwulat','Manhaj dan rujukan Fikih Tahawwulat.'],['Hadis & Ulumul Hadis','Penelusuran hadis, syarah, dan ilmu hadis.']].map(([name,description])=>`<a class="assistant-link" href="#ruang?bidang=${encodeURIComponent(name)}"><span class="assistant-icon">${icon('chat')}</span><div><h2>${name}</h2><p>${description}</p></div>${icon('chevron')}</a>`).join('')}</div>`;
}
function renderRoom(){
  const module=route().params.get('bidang')||'Fikih Syafi’i';
  root.innerHTML=`<header class="page-header"><div><a class="text-button" href="#asisten">${icon('back')} Asisten</a><h1>${esc(module)}</h1></div><a class="button" href="#catatan">${icon('note')} Catatan</a></header><section class="notebook-state" aria-label="Status pratinjau NotebookLM"><div>${icon('chat')}<h2>NotebookLM belum terhubung</h2><p>Ini pratinjau tampilan. Ruang NotebookLM tetap menjadi bagian OpenTurath; login dan percakapan perlu diverifikasi pada aplikasi sebenarnya.</p><a class="button" href="#akun">Lihat akun & koneksi</a></div></section><a class="text-button" href="${esc(catalogRoute)}">${icon('book')} Kembali ke pustaka</a>`;
}
function draft(){const value=read(draftKey,{title:'',body:''});return typeof value?.title==='string'&&typeof value?.body==='string'?value:{title:'',body:''};}
function renderNotes(){
  const current=activeNote?notes.find(note=>note.id===activeNote):draft();
  root.innerHTML=`<header class="page-header"><div><h1>Catatan</h1><p>Rujukan dan catatan telaah Anda.</p></div><button class="button" data-action="new-note">${icon('plus')} Catatan baru</button></header><div class="note-layout"><aside class="note-list" aria-label="Daftar catatan">${notes.length?notes.map(note=>`<button class="note-item" data-note="${esc(note.id)}" aria-pressed="${note.id===activeNote}"><span dir="auto">${esc(note.title||'Tanpa judul')}</span><small>Tersimpan lokal</small></button>`).join(''):'<p>Catatan yang disimpan muncul di sini.</p>'}</aside><section><div class="note-editor"><div class="note-toolbar"><small id="save-status" role="status">${activeNote?'Catatan tersimpan':'Draf baru'}</small><button class="text-button" data-action="save-note">Simpan catatan</button></div><input id="note-title" name="note-title" aria-label="Judul catatan" placeholder="Judul catatan…" autocomplete="off" value="${esc(current?.title||'')}" dir="auto"><textarea id="note-body" name="note-body" aria-label="Isi catatan" placeholder="Tulis catatan dan rujukan halaman…" dir="auto">${esc(current?.body||'')}</textarea></div><p class="note-caption">Catatan pratinjau disimpan di browser ini. Belum terhubung ke akun OpenTurath.</p></section></div>`;
  for(const id of ['note-title','note-body'])document.querySelector('#'+id).addEventListener('input',persistNote);
}
function persistNote(){
  const data={title:document.querySelector('#note-title').value,body:document.querySelector('#note-body').value};
  let saved;
  if(activeNote){const note=notes.find(item=>item.id===activeNote);Object.assign(note,data);saved=write(notesKey,notes);}
  else saved=write(draftKey,data);
  document.querySelector('#save-status').textContent=saved?'Tersimpan di browser':'Penyimpanan gagal. Salin catatan Anda.';
}
function saveNote(){
  const data={title:document.querySelector('#note-title').value.trim(),body:document.querySelector('#note-body').value};
  if(!data.title&&!data.body.trim()){toast('Tulis judul atau isi catatan terlebih dahulu.');document.querySelector('#note-title').focus();return;}
  if(!activeNote){activeNote=crypto.randomUUID();notes.unshift({id:activeNote,...data});}
  else Object.assign(notes.find(note=>note.id===activeNote),data);
  if(!write(notesKey,notes)){toast('Catatan belum disimpan. Salin teks sebelum menutup browser.');return;}
  write(draftKey,{title:'',body:''});renderNotes();toast('Catatan disimpan di browser ini.');
}
function newNote(){const old=draft();if(old.title||old.body){const updated=[{id:crypto.randomUUID(),...old},...notes];if(!write(notesKey,updated)){toast('Salin atau simpan draf sebelum membuat catatan baru.');return;}notes=updated;write(draftKey,{title:'',body:''});}activeNote=null;renderNotes();document.querySelector('#note-title').focus();}
function renderAccount(){
  root.innerHTML=`<header class="page-header"><div><h1>Akun & koneksi</h1><p>Status akun pada pratinjau desain.</p></div></header><div class="settings"><section class="settings-section"><h2>Koneksi</h2><div class="connection-row"><span>OpenTurath</span><span class="connection-status">Belum terhubung</span></div><div class="connection-row"><span>NotebookLM</span><span class="connection-status">Belum terhubung</span></div><p>Pratinjau ini tidak melakukan login. NotebookLM tetap dipakai dalam aplikasi; satu login Google masih memerlukan pengujian alur browser dan akses notebook.</p></section><section class="settings-section"><h2>Tampilan</h2><p>Pilih tampilan terang atau gelap untuk meninjau antarmuka.</p><button class="text-button" data-action="theme">Ganti tampilan</button></section><section class="settings-section"><h2>Data pratinjau</h2><p>${number(books.length)} metadata kitab berasal dari katalog Fikih Syafi’i pada aplikasi. Catatan hanya disimpan lokal. Tidak ada percakapan atau jawaban AI contoh.</p></section></div>`;
}
function navigate(){
  const current=route(), safe=['pustaka','asisten','ruang','catatan','akun'].includes(current.name)?current.name:'pustaka';
  if(safe==='pustaka')catalogRoute=location.hash||'#pustaka';
  const nav=safe==='ruang'?'asisten':safe;
  document.querySelectorAll('[data-nav]').forEach(el=>{if(el.dataset.nav===nav)el.setAttribute('aria-current','page');else el.removeAttribute('aria-current');});
  document.querySelectorAll('[data-collection]').forEach(el=>{if(safe==='pustaka')el.setAttribute('aria-current','page');else el.removeAttribute('aria-current');});
  const labels={pustaka:['Pustaka','Fikih Syafi’i'],asisten:['OpenTurath','Asisten'],ruang:['Asisten',current.params.get('bidang')||'Fikih Syafi’i'],catatan:['OpenTurath','Catatan'],akun:['OpenTurath','Akun & koneksi']};
  document.querySelector('#parent-crumb').textContent=labels[safe][0];document.querySelector('#parent-crumb').href=safe==='ruang'?'#asisten':'#pustaka';document.querySelector('#current-crumb').textContent=labels[safe][1];
  ({pustaka:renderLibrary,asisten:renderAssistants,ruang:renderRoom,catatan:renderNotes,akun:renderAccount})[safe]();
  document.querySelectorAll('[data-nav=pustaka]').forEach(el=>{el.href=catalogRoute;});
  document.title=`OpenTurath — ${labels[safe][1]} (pratinjau)`;
}
function search(){if(route().name!=='pustaka'){location.hash=catalogRoute;return;}document.querySelector('#book-search').focus();}
function theme(){document.body.classList.toggle('dark');const dark=document.body.classList.contains('dark');document.documentElement.style.colorScheme=dark?'dark':'light';document.querySelector('meta[name=theme-color]').content=dark?'#18191c':'#ffffff';document.querySelector('.topbar [data-action=theme]').setAttribute('aria-label',dark?'Gunakan tampilan terang':'Gunakan tampilan gelap');}
document.addEventListener('click',e=>{
  const page=e.target.closest('[data-page]');if(page&&!page.disabled){updateParams({p:page.dataset.page,book:null});renderResults();document.querySelector('#book-search').scrollIntoView({block:'start'});return;}
  const note=e.target.closest('[data-note]');if(note){activeNote=note.dataset.note;renderNotes();return;}
  const action=e.target.closest('[data-action]')?.dataset.action;
  if(action==='search')search();
  if(action==='theme')theme();
  if(action==='reset'){updateParams({q:null,era:null,p:null,book:null});renderLibrary();document.querySelector('#book-search').focus();}
  if(action==='close-book'){const book=selectedBook();updateParams({book:null});renderResults();document.querySelector(`.book-link[href*="book=${book?.id}"]`)?.focus();}
  if(action==='book-note'){
    const book=selectedBook(),old=draft();
    const reference=`Rujukan: ${book.الكتاب}\nPengarang: ${book.المؤلف}\nPenerbit: ${book.الناشر || 'Belum tersedia'}\nEdisi: ${book.سنة_الطبع_والطبعة || 'Belum tersedia'}`;
    if(!write(draftKey,{title:old.title||title(book),body:[old.body,reference].filter(Boolean).join('\n\n')})){toast('Draf tidak dapat disimpan. Salin metadata kitab terlebih dahulu.');return;}
    activeNote=null;location.hash='catatan';
  }
  if(action==='save-note')saveNote();
  if(action==='new-note')newNote();
});
document.addEventListener('keydown',e=>{if((e.metaKey||e.ctrlKey)&&e.key.toLowerCase()==='k'){e.preventDefault();search();}if(e.key==='Escape'&&route().name==='pustaka'&&selectedBook()){document.querySelector('[data-action=close-book]')?.click();}});
document.querySelector('.skip').addEventListener('click',e=>{e.preventDefault();root.focus();});
window.addEventListener('hashchange',()=>{navigate();const detail=document.querySelector('#detail-title');if(detail)detail.focus({preventScroll:false});else{window.scrollTo({top:0,behavior:'instant'});root.focus({preventScroll:true});}});
hydrateIcons();
fetch('assets/catalog-syafii.json').then(response=>{if(!response.ok)throw Error('Catalog unavailable');return response.json();}).then(data=>{if(!Array.isArray(data))throw Error('Invalid catalog');books=data;navigate();}).catch(()=>{root.innerHTML='<div class="empty"><h1>Katalog tidak dapat dimuat</h1><p>Buka prototipe melalui server lokal. Jika server aktif, muat ulang halaman.</p><button class="button" id="reload">Muat ulang</button></div>';document.querySelector('#reload').addEventListener('click',()=>location.reload());});
