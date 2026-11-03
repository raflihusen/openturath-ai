import React from 'react';

// Visual reconstruction of the app's study room and Arabic catalog at 420 × 820.
// Example question, answer and excerpt: website/redesign-v7/carousel-rilis/carousel.html, slide 06.
// Catalog metadata: canonical_syafii.json. These are examples, not a live session.
const paper = '#F6F6F6';
const ink = '#171717';
const muted = '#777777';
const line = '#E3E3E3';
const ui = 'Outfit, sans-serif';
const arabic = 'Scheherazade, serif';
const clamp = (v: number) => Math.min(1, Math.max(0, v));
const Icon: React.FC<{name: 'back'|'book'|'more'|'search'|'send'|'close'|'bubble'|'grid'|'sort'; size?: number}> = ({name, size = 20}) => {
 const paths: Record<string, React.ReactNode> = {
  back: <path d="M19 12H5m0 0 6-6m-6 6 6 6"/>,
  book: <path d="M3 5c4-1 7 0 9 2 2-2 5-3 9-2v14c-4-1-7 0-9 2-2-2-5-3-9-2V5Zm9 2v14"/>,
  more: <><circle cx="12" cy="5" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="12" cy="19" r="1"/></>,
  search: <><circle cx="10.5" cy="10.5" r="6.5"/><path d="m15.5 15.5 5 5"/></>,
  send: <path d="M4 12h16m0 0-6-6m6 6-6 6"/>,
  close: <path d="m6 6 12 12M18 6 6 18"/>,
  bubble: <path d="M4 4h16v12H9l-5 4z"/>,
  grid: <><rect x="4" y="4" width="6" height="6" rx="1"/><rect x="14" y="4" width="6" height="6" rx="1"/><rect x="4" y="14" width="6" height="6" rx="1"/><rect x="14" y="14" width="6" height="6" rx="1"/></>,
  sort: <path d="m8 9 4-4 4 4M8 15l4 4 4-4"/>,
 };
 return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" style={{display:'block', flexShrink:0}}>{paths[name]}</svg>;
};
const frame: React.CSSProperties = {width:420,height:820,background:paper,color:ink,fontFamily:ui,overflow:'hidden',position:'relative',boxSizing:'border-box'};
const bar: React.CSSProperties = {height:64,display:'flex',alignItems:'center',gap:17,padding:'0 18px',boxSizing:'border-box'};

export const ChatScreen: React.FC<{typed:string; answerProgress:number; scrollY?:number; tabbed?:boolean; activeTab?:number; sent?:boolean}> = ({typed,answerProgress,scrollY=0,tabbed=false,activeTab=0,sent=true}) => {
 const top=tabbed?106:64;
 const isTahawwulat=tabbed && activeTab===1;
 const progress=clamp(answerProgress);
 return <div style={frame}>
  <div style={bar}><Icon name="back"/><span style={{fontSize:16,fontWeight:600,flex:1}}>{isTahawwulat?'Al-Muhaqqiq':"Fikih Syafi’i"}</span><Icon name="book"/><Icon name="more"/></div>
  {tabbed && <div style={{height:42,display:'flex',gap:6,alignItems:'center',padding:'0 8px',background:'#ECECEC',borderTop:`1px solid ${line}`,borderBottom:`1px solid ${line}`,boxSizing:'border-box'}}>
   {["Fikih Syafi’i",'Fikih Tahawwulat'].map((label,i)=><div key={label} style={{display:'flex',alignItems:'center',gap:5,background:i===activeTab?'#fff':'transparent',border:i===activeTab?`1px solid ${line}`:'1px solid transparent',borderRadius:5,padding:'6px 6px',whiteSpace:'nowrap',fontSize:11,fontWeight:i===activeTab?600:400}}><Icon name="bubble" size={12}/>{label}<Icon name="close" size={13}/></div>)}
  </div>}
  <div style={{position:'absolute',top,bottom:72,left:0,right:0,overflow:'hidden'}}>
   <div style={{padding:'20px 22px 24px',transform:`translateY(${-Math.max(0,scrollY)}px)`}}>
    {isTahawwulat ? <div style={{fontSize:15,lineHeight:1.5,color:'#555'}}><div style={{fontSize:12,color:muted,marginBottom:12}}>Contoh pertanyaan</div><div style={{background:'#fff',border:'1px solid #E3E3E3',borderRadius:14,padding:'14px 16px'}}>Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?</div></div> : <>{sent && typed && <div style={{display:'flex',justifyContent:'flex-end'}}><div style={{background:'#E9E9E9',borderRadius:'18px 18px 5px 18px',maxWidth:315,padding:'12px 15px',fontSize:15,lineHeight:1.42}}>{typed}</div></div>}
    {sent && <div style={{opacity:clamp(progress*5),marginTop:24}}>
     <div style={{fontSize:12,color:muted,marginBottom:10}}>Contoh jawaban · AI Fikih Syafi’i</div>
     <div style={{fontSize:15,lineHeight:1.55,opacity:clamp(progress*4)}}>Menurut mazhab Syafi’i, bertemunya kulit laki-laki dengan perempuan non-mahram membatalkan wudhu.</div>
     <div style={{marginTop:18,opacity:clamp((progress-.25)*4),borderLeft:'2px solid #BDBDBD',padding:'8px 14px',background:'#FFFFFF',borderRadius:'0 10px 10px 0'}}>
      <div lang="ar" dir="rtl" style={{fontFamily:arabic,fontSize:24,lineHeight:1.75,textAlign:'right'}}>«وَإِذَا أَفْضَى الرَّجُلُ بِيَدِهِ إلَى امْرَأَتِهِ أَوْ بِبَعْضِ جَسَدِهِ إلَى بَعْضِ جَسَدِهَا لَا حَائِلَ بَيْنَهُ وَبَيْنَهَا بِشَهْوَةٍ أَوْ بِغَيْرِ شَهْوَةٍ وَجَبَ عَلَيْهِ الْوُضُوءُ…»</div>
      <div lang="ar" dir="rtl" style={{fontFamily:arabic,fontSize:20,color:'#666',marginTop:6}}>الأم ج١، ص٢٩-٣٠</div>
     </div>
     <div style={{fontSize:12,color:muted,marginTop:16,opacity:clamp((progress-.65)*4)}}>Rincian dan pengecualian perlu ditelaah pada sumbernya.</div>
    </div>}</>}
   </div>
  </div>
  <div style={{position:'absolute',bottom:0,left:0,right:0,height:72,boxSizing:'border-box',padding:'9px 18px',background:paper}}><div style={{height:50,border:'1px solid #D6D6D6',background:'#fff',borderRadius:27,display:'flex',alignItems:'center',padding:'0 8px 0 17px',gap:10}}><span style={{flex:1,fontSize:13,color:!sent && typed && !isTahawwulat?ink:'#929292',overflow:'hidden',whiteSpace:'nowrap',textOverflow:'ellipsis'}}>{!sent && !isTahawwulat && typed ? typed : 'Tanyakan sesuatu...'}</span><div style={{width:34,height:34,background:ink,color:'#fff',borderRadius:20,display:'grid',placeItems:'center'}}><Icon name="send" size={17}/></div></div></div>
 </div>;
};

const books = [
 {title:'الاصطلام في الخلاف بين الإمامين الشافعي وأبي حنيفة',author:'أبو المظفر السمعاني',death:'ت ٤٨٩ هـ',volumes:'المجلدات: ٢'},
 {title:'الأجوبة العيثاوية عن المسائل الطرابلسية',author:'أحمد بن عبيد الله العيثاوي',death:'ت ١٠٢٥ هـ',volumes:'المجلدات: ١'},
 {title:'الأم',author:'الإمام الشافعي',death:'ت ٢٠٤ هـ',volumes:'المجلدات: ٨'},
 {title:'الإقناع في حل ألفاظ أبي شجاع',author:'الخطيب الشربيني',death:'ت ٩٧٧ هـ',volumes:'المجلدات: ٢'},
 {title:'البيان في مذهب الإمام الشافعي',author:'العمراني',death:'ت ٥٥٨ هـ',volumes:'المجلدات: ١٣'},
];
export const LibraryScreen: React.FC<{scrollY:number}> = ({scrollY}) => <div style={frame}>
 <div style={{...bar,borderBottom:`1px solid ${line}`}}><Icon name="back"/><span lang="ar" dir="rtl" style={{fontFamily:arabic,fontSize:25,fontWeight:600,flex:1,textAlign:'right'}}>فهرس الكتب</span></div>
 <div style={{position:'absolute',top:64,bottom:0,left:0,right:0,overflow:'hidden'}}><div style={{padding:'14px 18px 24px',transform:`translateY(${-Math.max(0,scrollY)}px)`}}>
  <div dir="rtl" style={{height:46,borderRadius:12,background:'#ECECEC',display:'flex',alignItems:'center',gap:9,padding:'0 13px',color:'#737373',fontFamily:arabic,fontSize:16}}><Icon name="search" size={19}/><span>ابحث بعنوان الكتاب أو المؤلف أو المحقق أو الناشر</span></div>
  <div dir="rtl" style={{display:'flex',gap:7,marginTop:12,fontFamily:arabic,fontSize:15}}>{['جميع الكتب','مجلد واحد','عدة مجلدات'].map((x,i)=><span key={x} style={{background:i===0?ink:'#ECECEC',color:i===0?'#fff':ink,borderRadius:25,padding:'5px 13px',whiteSpace:'nowrap'}}>{x}</span>)}</div>
  <div dir="rtl" style={{display:'flex',alignItems:'center',gap:8,marginTop:14,marginBottom:8,color:muted,fontFamily:arabic,fontSize:15}}><span style={{flex:1}}>العنوان</span><Icon name="sort" size={17}/><Icon name="grid" size={17}/></div>
  {books.map((book,i)=><div key={book.title} dir="rtl" lang="ar" style={{padding:'15px 3px',borderTop:`1px solid ${line}`,fontFamily:arabic,textAlign:'right'}}><div style={{display:'flex',gap:10,alignItems:'baseline'}}><span style={{fontSize:22,fontWeight:600,lineHeight:1.35,flex:1}}>{book.title}</span><span style={{fontSize:13,color:muted}}>{['١','٢','٣','٤','٥'][i]}</span></div><div style={{fontSize:17,color:'#666',marginTop:4}}>{book.author}</div><div style={{display:'flex',gap:18,color:'#777',fontSize:14,marginTop:5}}><span>{book.death}</span><span>{book.volumes}</span></div></div>)}
 </div></div>
</div>;
