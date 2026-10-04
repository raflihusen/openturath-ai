// Only a visitor's explicit choice can redirect the language-entry page.
try{const locale=localStorage.getItem('ot_preferred_language');if(['id','en','ar'].includes(locale))location.replace('/'+locale+'/');}catch{}
document.querySelectorAll('.language-list a[lang]').forEach(a=>a.addEventListener('click',()=>{try{localStorage.setItem('ot_preferred_language',a.lang);}catch{}}));
