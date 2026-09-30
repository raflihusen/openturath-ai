'use strict';
// Local design prototype. No Firebase SDK, OAuth, NotebookLM RPC or iframe.
const icons = {
  compass:'<circle cx="12" cy="12" r="9"/><path d="m16 8-3 5-5 3 3-5Z"/>',
  book:'<path d="M12 5v15M3 4c3-1 6 0 9 2 3-2 6-3 9-2v15c-3-1-6 0-9 2-3-2-6-3-9-2Z"/>',
  note:'<path d="M14 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-9M9 15l1-4L20 1l3 3-10 10Z"/>',
  chevron:'<path d="m9 5 7 7-7 7"/>',arrow:'<path d="M4 12h16m-6-6 6 6-6 6"/>',
  search:'<circle cx="10" cy="10" r="6"/><path d="m15 15 5 5"/>',sun:'<circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M2 12h2m16 0h2M5 5l1 1m12 12 1 1M5 19l1-1M18 6l1-1"/>',
  close:'<path d="m6 6 12 12M6 18 18 6"/>',user:'<circle cx="12" cy="8" r="4"/><path d="M4 22v-2a8 8 0 0 1 16 0v2"/>',
  plus:'<path d="M12 4v16M4 12h16"/>',back:'<path d="M20 12H4m6-6-6 6 6 6"/>',link:'<path d="m10 13 4-4m-6 7-2 2a4 4 0 0 1-6-6l5-5a4 4 0 0 1 6 0m2 1 2-2a4 4 0 0 1 6 6l-5 5a4 4 0 0 1-6 0"/>',
};
const icon = name => `<svg viewBox="0 0 24 24" aria-hidden="true">${icons[name] || icons.book}</svg>`;
const escapeHtml = value => String(value ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function hydrateIcons(){document.querySelectorAll('[data-icon]').forEach(el=>{el.innerHTML=icon(el.dataset.icon);});}
const titles={kajian:'Ruang kajian',pustaka:'Pustaka',catatan:'Catatan',akun:'Akun',ruang:'Fikih Syafi’i'};
const root=document.querySelector('#content');
let books=[],selectedBook=null,currentModule='Fikih Syafi’i',activeNote=null;
const storageKey='openturath-design-20260930-notes';
const draftKey='openturath-design-20260930-draft';
function read(key,fallback){try{return JSON.parse(localStorage.getItem(key)) ?? fallback;}catch{return fallback;}}
function write(key,value){try{localStorage.setItem(key,JSON.stringify(value));return true;}catch{return false;}}
let notes=read(storageKey,[]);if(!Array.isArray(notes))notes=[];
let toastTimer;
function toast(message){const el=document.querySelector('#toast');el.textContent=message;el.classList.add('visible');clearTimeout(toastTimer);toastTimer=setTimeout(()=>el.classList.remove('visible'),3500);}
function extent(book){
 const volumes=book?.jilid || book?.volumes || book?.عدد_الأجزاء;
 const pages=book?.pages || book?.jumlah_halaman || book?.عدد_الصفحات;
 return [volumes ? `${volumes} jilid` : '', pages ? `${pages} halaman` : ''].filter(Boolean).join(' · ') || 'Jumlah belum tercatat';
}
function bookFeature(book){return `<div class="book-feature"><p class="eyebrow">DARI KATALOG FIKIH SYAFI’I</p><div class="book-rule"></div><h2 class="arabic" lang="ar" dir="rtl">${escapeHtml(book?.الاسم_المختصر || 'الأم')}</h2><p class="arabic" lang="ar" dir="rtl">${book?.id===1?'للإمام الشافعي':escapeHtml(book?.المؤلف || '')}</p><div class="book-rule"></div><p class="fine">${escapeHtml(extent(book))}</p></div>`;}
function renderKajian(){
 root.innerHTML=`<div class="workspace"><section><div class="welcome"><p class="eyebrow">RUANG KAJIAN</p><h1>Mulai sebuah telaah.</h1><p>Pilih bidang kajian, buka NotebookLM, lalu simpan hasil telaah Anda bersama rujukannya.</p></div><div class="section-top"><h2>Pilih ruang telaah</h2><a class="text-button" href="#pustaka">Jelajahi pustaka ${icon('arrow')}</a></div><div class="module-list"><button class="module" data-module="Fikih Syafi’i"><span class="module-mark" lang="ar">ش</span><span><h3>Fikih Syafi’i</h3><p>Telusuri pendapat, ibarah, dan konteks dalam mazhab.</p><small>${books.length} judul pada katalog lokal</small></span>${icon('arrow')}</button><button class="module" data-module="Fikih Tahawwulat"><span class="module-mark" lang="ar">ت</span><span><h3>Fikih Tahawwulat</h3><p>Kaji istilah dan pemikiran dalam fikih perubahan.</p><small>Contoh navigasi ruang kajian</small></span>${icon('arrow')}</button><button class="module" data-module="Hadits & Syarah"><span class="module-mark" lang="ar">ح</span><span><h3>Hadits & Syarah</h3><p>Baca penjelasan dan hubungkan pembahasan antar sumber.</p><small>Contoh navigasi ruang kajian</small></span>${icon('arrow')}</button></div><div class="start-note">${icon('note')}<p>Catat hal yang penting saat menelaah.<br><a class="text-button" href="#catatan">Buka catatan Anda ${icon('arrow')}</a></p></div></section><aside class="reference-rail" aria-label="Pilihan dari pustaka"><div class="rail-heading"><span>Dari pustaka</span>${icon('book')}</div>${bookFeature(books[0])}<p>Periksa pengarang dan edisi sebelum mulai menelaah.</p><button class="text-button" data-book="1">Lihat metadata kitab ${icon('arrow')}</button><hr class="rail-divider"><p class="eyebrow">KENALI SUMBERNYA</p><button class="mini-book" data-book="2"><h3 lang="ar" dir="rtl">الأمر والنهي على معنى الشافعي</h3><p>1 jilid · 384 halaman</p></button><button class="mini-book" data-book="3"><h3 lang="ar" dir="rtl">المختصر من علم الشافعي</h3><p>3 jilid · 2.107 halaman</p></button></aside></div>`;
}
function normalizeArabic(value){return String(value).toLowerCase().normalize('NFKD').replace(/[\u064B-\u065F\u0670\u0640]/g,'').replace(/[أإآ]/g,'ا').replace(/ى/g,'ي');}
function renderPustaka(){
 root.innerHTML=`<div class="page-heading"><div><p class="eyebrow">PUSTAKA OPENTURATH</p><h1>Khazanah Fikih Syafi’i.</h1><p>Kenali kitab, pengarang, dan edisi yang menjadi rujukan.</p></div><a class="secondary" href="#kajian">${icon('compass')} Ruang kajian</a></div><div class="catalog-tools"><label class="search-field">${icon('search')}<input id="book-search" type="search" placeholder="Cari judul atau pengarang…" aria-label="Cari judul atau pengarang" autocomplete="off"></label><select class="filter" id="era" aria-label="Periode pengarang"><option value="all">Semua periode</option><option value="early">Hingga 300 H</option><option value="middle">301–600 H</option><option value="late">Setelah 600 H</option></select><select class="filter" id="sort" aria-label="Urutan katalog"><option value="original">Urutan katalog</option><option value="name">Judul A–Z</option></select></div><p class="result-count" id="result-count" role="status"></p><div class="catalog-grid" id="catalog-grid"></div>`;
 document.querySelector('#book-search').addEventListener('input',renderBooks);
 document.querySelector('#era').addEventListener('change',renderBooks);
 document.querySelector('#sort').addEventListener('change',renderBooks);
 renderBooks();
}
function renderBooks(){
 const query=normalizeArabic(document.querySelector('#book-search').value.trim());
 const era=document.querySelector('#era').value;
 let result=books.filter(book=>{
  const text=normalizeArabic(`${book.الكتاب} ${book.الاسم_المختصر} ${book.المؤلف} ${book.الناشر}`);
  const year=Number(book.سنة_الوفاة || book.tahun_wafat);
  const period=era==='all'||(era==='early'&&year<=300)||(era==='middle'&&year>300&&year<=600)||(era==='late'&&year>600);
  return text.includes(query)&&period;
 });
 if(document.querySelector('#sort').value==='name') result=result.slice().sort((a,b)=>String(a.الكتاب).localeCompare(String(b.الكتاب),'ar'));
 document.querySelector('#result-count').textContent=`${result.length} dari ${books.length} judul · metadata dari katalog aplikasi`;
 document.querySelector('#catalog-grid').innerHTML=result.length?result.map(book=>`<button class="catalog-card" data-book="${book.id}" aria-label="Lihat metadata ${escapeHtml(book.الكتاب)}"><span class="book-number">FIKIH SYAFI’I · ${String(book.id).padStart(2,'0')}</span><h2 lang="ar">${escapeHtml(book.الاسم_المختصر || book.الكتاب)}</h2><p lang="ar">${escapeHtml(book.المؤلف)}</p><span class="card-meta"><span>${escapeHtml(extent(book))}</span>${icon('arrow')}</span></button>`).join(''):`<div class="empty"><h2>Kitab belum ditemukan.</h2><p>Coba judul Arab yang lebih singkat, nama pengarang, atau ubah filter periode.</p><button class="secondary" id="clear-search">Hapus pencarian</button></div>`;
}
function showBook(id){
 const book=books.find(b=>Number(b.id)===Number(id));if(!book)return;
 selectedBook=book;
 const dialog=document.querySelector('#book-dialog');
 dialog.innerHTML=`<button class="close icon-button" data-close="book-dialog" aria-label="Tutup metadata">${icon('close')}</button><p class="eyebrow">METADATA KITAB · FIKIH SYAFI’I</p><div class="book-dialog-heading"><h2 id="book-title" lang="ar" dir="rtl">${escapeHtml(book.الكتاب)}</h2><p lang="ar" dir="rtl">${escapeHtml(book.المؤلف)}</p></div><dl class="book-metadata"><div class="metadata-row"><dt>Peneliti / editor</dt><dd lang="ar">${escapeHtml(book.المحقق_أو_المعتني)}</dd></div><div class="metadata-row"><dt>Penerbit</dt><dd lang="ar">${escapeHtml(book.الناشر)}</dd></div><div class="metadata-row"><dt>Edisi</dt><dd lang="ar">${escapeHtml(book.سنة_الطبع_والطبعة)}</dd></div><div class="metadata-row"><dt>Jumlah</dt><dd class="count-value" dir="ltr">${escapeHtml(extent(book))}</dd></div></dl><div class="dialog-actions"><button class="primary" id="book-to-room">${icon('compass')} Telaah di NotebookLM</button><button class="secondary" id="book-to-note">${icon('note')} Buat catatan</button></div><p class="book-disclaimer">Metadata ini berasal dari katalog aplikasi. Pratinjau tidak memuat teks kitab dan tidak membuktikan kitab ini terpasang sebagai sumber pada suatu notebook.</p>`;
 dialog.showModal();
}
function renderRoom(){
 root.innerHTML=`<div class="room-header"><a class="icon-button" href="#kajian" aria-label="Kembali ke ruang kajian">${icon('back')}</a><h1>${escapeHtml(currentModule)}</h1><span class="provider">NotebookLM</span><a class="secondary" href="#catatan">${icon('note')} Catatan</a></div><div class="room"><section><div class="notebook-area"><div class="notebook-toolbar"><span>Ruang NotebookLM</span><span>Konsep tata letak</span></div><div class="notebook-placeholder">${icon('compass')}<h2>Ruang untuk menelaah.</h2><p>NotebookLM tetap menjadi mesin telaah OpenTurath. Area ini disediakan untuk ruang NotebookLM yang berjalan pada wadah browser yang didukung.</p><button class="secondary" id="notebook-info">${icon('link')} Lihat status koneksi</button></div></div><p class="room-notice">Pratinjau desain: NotebookLM belum terhubung di halaman ini. Tidak ada pertanyaan yang dikirim, jawaban contoh, atau kutipan sumber buatan.</p></section><aside class="room-side"><h3>Rujukan & catatan</h3><p>${selectedBook?`Kitab yang Anda pilih dari katalog:`:'Buka metadata kitab dari pustaka sebelum menelaah ibarah.'}</p>${selectedBook?bookFeature(selectedBook):bookFeature(books[0])}<button class="text-button" data-book="${selectedBook?.id || 1}">Periksa metadata ${icon('arrow')}</button><hr class="rail-divider"><a class="text-button" href="#catatan">${icon('note')} Tulis catatan telaah</a><p class="fine">Rujukan hasil NotebookLM harus diperiksa pada sumber aslinya.</p></aside></div>`;
}
function draft(){return read(draftKey,{title:'',body:''});}
function renderNotes(){
 const data=activeNote?notes.find(n=>n.id===activeNote):draft();
 root.innerHTML=`<div class="page-heading"><div><p class="eyebrow">CATATAN TELAAH</p><h1>Simpan yang bermakna.</h1><p>Tulis ibarah, konteks, dan hal yang masih perlu Anda periksa.</p></div><button class="secondary" id="new-note">${icon('plus')} Catatan baru</button></div><div class="note-layout"><aside class="note-list" aria-label="Daftar catatan">${notes.length?notes.map(n=>`<button class="note-item" data-note="${n.id}" aria-pressed="${n.id===activeNote}">${escapeHtml(n.title || 'Tanpa judul')}<small>Catatan lokal pratinjau</small></button>`).join(''):'<p>Catatan yang Anda simpan akan muncul di sini.</p>'}</aside><section><div class="note-editor"><div class="note-top"><small id="draft-status">${activeNote?'Catatan tersimpan':'Draf baru'}</small><button class="text-button" id="save-note">Simpan catatan ${icon('arrow')}</button></div><input id="note-title" aria-label="Judul catatan" placeholder="Judul catatan" value="${escapeHtml(data?.title || '')}" dir="auto"><textarea id="note-body" aria-label="Isi catatan" placeholder="Tulis catatan Anda. Sertakan kitab, edisi, jilid, dan halaman jika tersedia." dir="auto">${escapeHtml(data?.body || '')}</textarea></div><p class="notes-fine">Catatan pratinjau disimpan hanya di browser ini, terpisah dari catatan akun OpenTurath. Draf bertahan saat pindah layar atau memuat ulang.</p></section></div>`;
 for(const id of ['note-title','note-body'])document.querySelector('#'+id).addEventListener('input',persistDraft);
}
function persistDraft(){
 const title=document.querySelector('#note-title').value,body=document.querySelector('#note-body').value;
 let ok;
 if(activeNote){const n=notes.find(n=>n.id===activeNote);if(n){n.title=title;n.body=body;}ok=write(storageKey,notes);}
 else ok=write(draftKey,{title,body});
 document.querySelector('#draft-status').textContent=ok?'Tersimpan di browser ini':'Browser tidak dapat menyimpan catatan';
}
function saveNote(){
 const title=document.querySelector('#note-title').value.trim(),body=document.querySelector('#note-body').value;
 if(!title&&!body.trim()){toast('Tulis judul atau isi catatan terlebih dahulu.');return;}
 if(!activeNote){activeNote=String(Date.now());notes.unshift({id:activeNote,title,body});}
 else{const note=notes.find(n=>n.id===activeNote);note.title=title;note.body=body;}
 if(!write(storageKey,notes)){toast('Browser tidak dapat menyimpan catatan. Salin teks Anda terlebih dahulu.');return;}
 write(draftKey,{title:'',body:''});renderNotes();toast('Catatan disimpan di browser pratinjau.');
}
function renderAccount(){
 root.innerHTML=`<div class="page-heading"><div><p class="eyebrow">AKUN OPENTURATH</p><h1>Satu ruang. Akun yang jelas.</h1><p>Status OpenTurath dan NotebookLM ditampilkan secara terpisah.</p></div></div><div class="account-panel"><section class="account-section"><h3>Akun & koneksi</h3><div class="status-row"><span>OpenTurath · Firebase</span><small>Belum terhubung — pratinjau</small></div><div class="status-row"><span>NotebookLM · Google</span><small>Belum terhubung — pratinjau</small></div><button class="primary" id="open-login"><span class="google-g" aria-hidden="true">G</span> Lihat rancangan masuk</button></section><section class="account-section"><h3>Gunakan akun Google yang sama</h3><p>Firebase mengelola akun dan akses OpenTurath. NotebookLM memakai sesi Google pada browser. Satu autentikasi Google dapat digunakan kembali jika keduanya berjalan pada browser dan profil yang sama; akses notebook tetap harus diperiksa.</p></section><section class="account-section"><h3>Tampilan</h3><p>Permukaan tenang, teks yang terbaca, dan warna hijau untuk tindakan utama.</p><button class="secondary" id="account-theme">Ganti terang / gelap</button></section><section class="account-section"><h3>Tentang pratinjau</h3><p>Ini usulan desain yang dapat diklik. Metadata berasal dari katalog Fikih Syafi’i pada aplikasi. Login, hak akses, dan percakapan NotebookLM tidak dijalankan.</p></section></div>`;
}
function navigate(){
 const route=location.hash.slice(1)||'kajian';const safe=titles[route]?route:'kajian';
 document.querySelector('#crumb').textContent=safe==='ruang'?currentModule:titles[safe];
 document.querySelectorAll('[data-nav]').forEach(a=>{if(a.dataset.nav===(safe==='ruang'?'kajian':safe))a.setAttribute('aria-current','page');else a.removeAttribute('aria-current');});
 ({kajian:renderKajian,pustaka:renderPustaka,ruang:renderRoom,catatan:renderNotes,akun:renderAccount})[safe]();
 window.scrollTo({top:0,behavior:'instant'});
}
function theme(){document.body.classList.toggle('dark');document.querySelector('#theme').setAttribute('aria-label',document.body.classList.contains('dark')?'Ganti tampilan terang':'Ganti tampilan gelap');}
function search(){if(location.hash!=='#pustaka'){location.hash='pustaka';setTimeout(()=>document.querySelector('#book-search')?.focus(),50);}else document.querySelector('#book-search')?.focus();}
document.querySelector('#theme').addEventListener('click',theme);
document.querySelector('#find').addEventListener('click',search);
document.querySelector('.skip').addEventListener('click',e=>{e.preventDefault();root.focus();});
document.addEventListener('keydown',e=>{if((e.metaKey||e.ctrlKey)&&e.key.toLowerCase()==='k'){e.preventDefault();search();}});
document.addEventListener('click',e=>{
 const close=e.target.closest('[data-close]');if(close){document.getElementById(close.dataset.close).close();return;}
 const module=e.target.closest('[data-module]');if(module){currentModule=module.dataset.module;selectedBook=null;location.hash='ruang';return;}
 const book=e.target.closest('[data-book]');if(book){showBook(book.dataset.book);return;}
 const note=e.target.closest('[data-note]');if(note){activeNote=note.dataset.note;renderNotes();return;}
 const id=e.target.closest('[id]')?.id;
 if(id==='clear-search'){document.querySelector('#book-search').value='';document.querySelector('#era').value='all';renderBooks();document.querySelector('#book-search').focus();}
 if(id==='book-to-room'){document.querySelector('#book-dialog').close();currentModule='Fikih Syafi’i';if(location.hash==='#ruang')navigate();else location.hash='ruang';}
 if(id==='book-to-note'){document.querySelector('#book-dialog').close();activeNote=null;const old=draft();const reference='Rujukan: '+selectedBook.الكتاب;write(draftKey,{title:old.title || selectedBook.الاسم_المختصر,body:[old.body,reference].filter(Boolean).join('\n\n')});if(location.hash==='#catatan')renderNotes();else location.hash='catatan';}
 if(id==='notebook-info'){location.hash='akun';}
 if(id==='open-login')document.querySelector('#login-dialog').showModal();
 if(id==='demo-login'){document.querySelector('#login-dialog').close();location.hash='kajian';toast('Alur contoh dibuka. Tidak ada login yang dilakukan.');}
 if(id==='account-theme')theme();
 if(id==='save-note')saveNote();
 if(id==='new-note'){const old=draft();if(old.title || old.body){notes.unshift({id:String(Date.now()),...old});if(!write(storageKey,notes)){toast('Simpan atau salin draf sebelum membuat catatan baru.');return;}write(draftKey,{title:'',body:''});}activeNote=null;renderNotes();document.querySelector('#note-title').focus();}
});
window.addEventListener('hashchange',()=>{navigate();root.focus({preventScroll:true});});
hydrateIcons();
fetch('assets/catalog-syafii.json').then(response=>{if(!response.ok)throw Error('Catalog unavailable');return response.json();}).then(data=>{books=data;navigate();}).catch(()=>{root.innerHTML='<div class="empty"><h2>Katalog tidak dapat dimuat.</h2><p>Buka pratinjau melalui server lokal, bukan langsung sebagai file. Petunjuk tersedia pada README.</p></div>';});
