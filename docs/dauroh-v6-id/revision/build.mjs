import fs from 'node:fs/promises';
import path from 'node:path';
import {Presentation,PresentationFile} from '/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs';

const ROOT='/Users/apple/Downloads/ramadhan/docs/dauroh-v6-id';
const BUILD=path.join(ROOT,'revision/.build');
const FONT='IBM Plex Sans Arabic',W=1440,H=810;
const K={paper:'#FAFAFA',ink:'#09090B',muted:'#606060',line:'#DADADA',quiet:'#A1A1AA'};
const specs=JSON.parse(await fs.readFile(process.env.SPEC_PATH??path.join(ROOT,'revision/deck-spec.json'),'utf8'));
const pres=Presentation.create({slideSize:{width:W,height:H}});
await fs.mkdir(BUILD,{recursive:true});
const audit=[];

function text(slide,name,value,x,y,w,h,size=30,{color=K.ink,bold=false,align='left'}={}){
 const s=slide.shapes.add({name,geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:'none',line:{fill:'none',width:0}});
 s.text=String(value??'').replaceAll('**','');
 s.text.style={typeface:FONT,fontSize:size,bold,color,alignment:align,verticalAlignment:'top',insets:0,autoFit:'none',wrap:'square'};
 return s;
}
function base(d,i,dark=false){
 const s=pres.slides.add();s.background.fill=dark?K.ink:K.paper;
 const fg=dark?K.paper:K.ink,muted=dark?K.quiet:K.muted;
 if(!['cover','chapter','closing'].includes(d.kind)){
  text(s,'chapter-label',`Hari ${d.day}   /   ${d.chapter}`,84,45,1210,36,20,{color:muted});
  text(s,'slide-title',d.title,84,110,1272,135,d.title.length>72?46:54,{bold:true,color:fg});
 }
 if(d.kind!=='cover')text(s,'page-number',String(i+1).padStart(2,'0'),1290,755,66,26,17,{align:'right',color:muted});
 return s;
}
function table(s,d){
 const vals=d.values,rows=vals.length,cols=vals[0].length;
 const tb=s.tables.add({rows,columns:cols,left:84,top:270,width:1272,height:Math.min(420,rows*76),values:vals,columnWidths:d.widths??Array(cols).fill(1272/cols)});
 tb.borders.assign({fill:K.line,width:1,style:'solid'});
 tb.cells.block({row:0,column:0,rowCount:rows,columnCount:cols}).assign({fill:K.paper,textStyle:{typeface:FONT,fontSize:d.fontSize??27,color:K.ink},margins:{left:18,right:18,top:12,bottom:12}});
 tb.cells.block({row:0,column:0,rowCount:1,columnCount:cols}).assign({fill:K.ink,textStyle:{typeface:FONT,fontSize:d.fontSize??27,bold:true,color:K.paper}});
 return tb;
}
async function screenshot(s,d){
 const imgPath=path.isAbsolute(d.screenshot)?d.screenshot:path.join(ROOT,d.screenshot);
 const bytes=await fs.readFile(imgPath), ext=path.extname(imgPath).toLowerCase();
 s.images.add({blob:bytes,contentType:ext==='.jpg'||ext==='.jpeg'?'image/jpeg':'image/png',alt:d.imageAlt??d.title,fit:'contain',position:{left:84,top:266,width:820,height:432}});
 const paragraphs=d.steps??d.body??[];
 let at=270;
 paragraphs.slice(0,3).forEach((p,i)=>{
  const v=typeof p==='string'?p:(p.text??p.description??JSON.stringify(p));
  text(s,`reveal-${i+1}-number`,String(i+1).padStart(2,'0'),952,at,58,42,24,{color:K.muted});
  text(s,`reveal-${i+1}-caption`,v,1015,at-3,341,126,v.length>145?25:28);
  at+=145;
 });
 text(s,'image-source-label',d.imageCaption??'Cuplikan dari dokumentasi resmi. Tampilan mengikuti versi dan akses akun.',84,712,1272,32,17,{color:K.muted});
}

for(const [i,d] of specs.entries()){
 const dark=['cover','chapter','exercise','closing','break'].includes(d.kind);
 const s=base(d,i,dark),fg=dark?K.paper:K.ink,muted=dark?K.quiet:K.muted;
 const b=d.body??[];
 switch(d.kind){
  case 'cover':
   text(s,'course-label','DAUROH',84,74,900,45,25,{color:K.quiet});
   text(s,'cover-title','AI untuk Belajar\n& Penelitian Ilmiah',84,190,1272,250,86,{bold:true,color:K.paper});
   text(s,'cover-subtitle','Dari pengenalan aplikasi hingga proyek penelitian',84,486,1200,100,33,{color:K.paper});
   text(s,'presenter-name-ar','رفلي حسين',850,636,505,90,48,{color:K.paper,align:'right'});
   text(s,'course-duration','Dua hari praktik',84,696,600,38,24,{color:K.quiet});
   break;
  case 'chapter':
   text(s,'chapter-index',`BAB ${String(d.number).padStart(2,'0')}`,84,88,1100,52,26,{color:K.quiet});
   text(s,'chapter-name',d.title,84,230,1272,220,d.title.length>23?82:112,{bold:true,color:K.paper});
   text(s,'chapter-description',d.subtitle??b.join(' '),84,497,1150,125,38,{color:K.paper});
   text(s,'chapter-outcome',d.outcome??'',84,675,1180,70,25,{color:K.quiet});
   break;
  case 'agenda':
   (d.items??b).forEach((a,j)=>{
    const y=270+j*75;
    text(s,`agenda-${j}-index`,String(j+1).padStart(2,'0'),84,y,72,45,28,{color:K.muted});
    text(s,`agenda-${j}-text`,typeof a==='string'?a:a.label,184,y-2,1030,60,34,{bold:j===0});
    if(typeof a==='object'&&a.time)text(s,`agenda-${j}-time`,a.time,1190,y,166,40,23,{align:'right',color:K.muted});
   });
   break;
  case 'screenshot': await screenshot(s,d);break;
  case 'table':table(s,d);break;
  case 'formula':
   ['S','I','A','P'].forEach((letter,j)=>{
    const x=84+j*324;
    text(s,`reveal-${j+1}-letter`,letter,x,258,285,175,144,{bold:true});
    text(s,`reveal-${j+1}-term`,['Sasaran','Informasi','Aturan','Penyajian'][j],x,450,280,60,35,{bold:true});
    text(s,`reveal-${j+1}-detail`,b[j],x,538,278,140,28);
   });
   break;
  case 'comparison':
   text(s,'comparison-left-label',d.leftLabel??'Permintaan awal',84,270,598,65,28,{color:K.muted});
   text(s,'comparison-right-label',d.rightLabel??'Permintaan yang diperjelas',758,270,598,65,28,{bold:true});
   text(s,'reveal-1-before',d.left??b[0],84,355,598,300,d.left?.length>270?27:34);
   text(s,'reveal-2-after',d.right??b[1],758,355,598,300,d.right?.length>300?27:32);
   if(d.takeaway)text(s,'comparison-takeaway',d.takeaway,84,690,1272,58,25,{color:K.muted});
   break;
  case 'sequence': {
   const n=b.length,step=n<=3?424:318;
   b.forEach((v,j)=>{
    const x=84+j*step;
    text(s,`reveal-${j+1}-index`,String(j+1).padStart(2,'0'),x,275,step-44,84,62,{color:K.muted});
    text(s,`reveal-${j+1}-body`,v,x,397,step-48,275,n<=3?34:30);
   });break;
  }
  case 'exercise': {
   text(s,'exercise-minutes',String(d.minutes??15),84,286,330,220,190,{bold:true,color:fg});
   text(s,'exercise-unit','menit praktik',88,520,330,80,38,{color:fg});
   const st=d.steps??b;
   st.slice(0,4).forEach((v,j)=>text(s,`reveal-${j+1}-step`,`${j+1}. ${v}`,500,282+j*84,856,78,29,{color:fg}));
   text(s,'exercise-deliverable-label','Hasil yang dikumpulkan',500,644,856,42,23,{color:muted});
   text(s,'exercise-deliverable',d.deliverable??'',500,689,856,69,28,{color:fg});
   break;
  }
  case 'prompt':
   text(s,'prompt-label',d.promptLabel??'Contoh permintaan',84,268,1272,42,23,{color:muted});
   if(d.promptParts){
    d.promptParts.forEach((part,j)=>{
     text(s,`reveal-${j+1}-prompt-key`,part.key,84,336+j*87,180,70,29,{bold:true});
     text(s,`reveal-${j+1}-prompt-value`,part.value,292,336+j*87,1064,76,29);
    });
   }else text(s,'reveal-1-prompt',d.prompt??b.join('\n\n'),84,343,1200,330,32);
   if(d.takeaway)text(s,'prompt-takeaway',d.takeaway,84,709,1240,52,23,{color:muted});
   break;
  case 'definition':
   text(s,'definition-main',d.lead??b[0],84,286,1200,205,47,{bold:true});
   text(s,'reveal-1-definition-detail',d.detail??b.slice(1).join(' '),84,540,1120,160,32);
   break;
  case 'quote':
   text(s,'quote-main',d.quote??b[0],84,286,1272,250,54,{bold:true});
   text(s,'reveal-1-quote-comment',d.detail??b.slice(1).join(' '),84,590,1120,120,30);
   break;
  case 'break':
   text(s,'break-title','Istirahat',84,235,1272,160,112,{color:fg,bold:true});
   text(s,'break-duration',`${d.minutes??15} menit`,84,456,1000,100,52,{color:fg});
   text(s,'break-return',d.subtitle??'Simpan pekerjaan Anda. Kita lanjutkan pada bab berikutnya.',84,620,1160,100,30,{color:muted});
   break;
  case 'closing':
   text(s,'closing-label','PENUTUP',84,77,1150,42,24,{color:muted});
   text(s,'closing-title',d.title,84,235,1272,205,84,{bold:true,color:fg});
   text(s,'closing-detail',d.detail??b.join(' '),84,496,1180,130,36,{color:fg});
   text(s,'closing-presenter','رفلي حسين',850,666,505,83,44,{align:'right',color:fg});
   break;
  default:
   text(s,'explain-lead',d.lead??b[0],84,285,590,360,43,{bold:true});
   text(s,'reveal-1-explain-detail',d.detail??b.slice(1).join('\n\n'),758,291,598,360,31);
   if(d.example)text(s,'reveal-2-explain-example',d.example,84,680,1272,65,25,{color:muted});
 }
 let notes=(d.notes??'').trim();
 if(d.demo&&d.demo!=='.')notes+='\n\nDEMONSTRASI\n'+d.demo.replaceAll('**','');
 if(d.sources?.length)notes+='\n\nRUJUKAN\n'+d.sources.join('\n');
 if(d.screenshot)notes+='\n\nKETERANGAN GAMBAR\n'+(d.imageProvenance??'Cuplikan yang diterbitkan pemilik produk; contoh antarmuka, bukan rekaman akun peserta.');
 s.speakerNotes.text=notes;
 audit.push({slide:i+1,id:s.id,kind:d.kind,title:d.title,chapter:d.chapter,day:d.day,screenshot:d.screenshot??null,sourceIds:d.sourceIds??[],notesWords:notes.split(/\s+/).length});
}
await (await PresentationFile.exportPptx(pres)).save(path.join(BUILD,'draft.pptx'));
await fs.writeFile(path.join(BUILD,'slide-map.json'),JSON.stringify(audit,null,2));
await fs.writeFile(path.join(BUILD,'spec-summary.json'),JSON.stringify({slides:audit.length,screenshots:audit.filter(s=>s.screenshot).length,kinds:[...new Set(audit.map(s=>s.kind))],nativeTables:audit.filter(s=>s.kind==='table').map(s=>s.slide),chapters:audit.filter(s=>s.kind==='chapter').map(s=>({slide:s.slide,title:s.title}))},null,2));
console.log(JSON.stringify({slides:audit.length,screenshots:audit.filter(s=>s.screenshot).length}));
if(process.env.RENDER_SLIDES==='1'){
 const requested=process.env.ONLY_SLIDES?new Set(process.env.ONLY_SLIDES.split(',').map(Number)):null;
 for(const [i,s] of pres.slides.items.entries()){
  if(requested&&!requested.has(i+1))continue;
  const png=await pres.export({slide:s,format:'png',scale:1});
  await fs.writeFile(path.join(BUILD,`slide-${String(i+1).padStart(3,'0')}.png`),new Uint8Array(await png.arrayBuffer()));
  if((i+1)%10===0)console.log('rendered',i+1);
 }
}
