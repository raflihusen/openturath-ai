// Halaman akar memilih bahasa sendiri: pilihan pengunjung yang tersimpan,
// lalu bahasa peramban, dan bila tidak ada yang cocok, bahasa Indonesia.
(function(){
  var supported=['id','en','ar'],target='id';
  try{
    var saved=localStorage.getItem('ot_preferred_language');
    if(supported.indexOf(saved)>=0){target=saved;}
    else{
      var list=navigator.languages&&navigator.languages.length?navigator.languages:[navigator.language||''];
      for(var i=0;i<list.length;i++){
        var code=String(list[i]).slice(0,2).toLowerCase();
        if(code==='ms'){code='id';}
        if(supported.indexOf(code)>=0){target=code;break;}
      }
    }
  }catch(_){}
  location.replace('/'+target+'/');
})();
