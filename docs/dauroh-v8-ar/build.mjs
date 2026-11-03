import fs from 'node:fs/promises';
import {Presentation,PresentationFile} from '/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs';
const R='/Users/apple/Downloads/ramadhan/docs/dauroh-v8-ar';
const data=JSON.parse(await fs.readFile(R+'/slides.json','utf8'));
const p=Presentation.create({slideSize:{width:1440,height:810}}),F='IBM Plex Sans Arabic';
function tx(s,name,value,x,y,w,h,size=32,color='#09090B',bold=false){
 const z=s.shapes.add({name,geometry:'textbox',position:{left:1440-x-w,top:y,width:w,height:h},fill:'none',line:{fill:'none',width:0}});z.text=String(value).replace(/@shamelaws/g,"\u2066@shamelaws\u2069");z.text.style={typeface:F,fontSize:size,bold,color,alignment:'right',verticalAlignment:'top',insets:0,autoFit:'none',wrap:'square'};return z;
}
const an=x=>String(x).replace(/[0-9]/g,c=>'٠١٢٣٤٥٦٧٨٩'[+c]);
const val=x=>Array.isArray(x)?x[1]:x;
const pair=x=>Array.isArray(x)?x:['',x];
for(const d of data){
 const s=p.slides.add(),dark=['cover','chapter','break','closing'].includes(d.kind),C=dark?'#FAFAFA':'#09090B',M=dark?'#A1A1AA':'#71717A';s.background.fill=dark?'#09090B':d.kind==='exercise'?'#F1F1F2':'#FAFAFA';
 const total=data.length;
 tx(s,'location',d.kind==='cover'?`اليوم ${an(d.day)}`:`اليوم ${an(d.day)}${d.bab?'   /   الباب '+an(d.bab):''}   /   ${d.chapter}`,78,35,1270,35,18,M);
 tx(s,'page',`${an(String(d.id).padStart(3,'0'))} / ${an(total)}`,1220,765,145,28,16,M);
 const body=d.body;
 if(d.kind==='cover'){
  tx(s,'title',d.title,78,198,1280,220,77,C,true);
  tx(s,'intro',body.join('\n'),82,495,1170,150,32,C);
  tx(s,'brand','أوبن تراث',82,735,450,35,21,M);
 }else if(d.kind==='chapter'){
  tx(s,'chapter-number',an(String(d.bab).padStart(2,'0')),78,145,310,240,170,M);
  tx(s,'title',d.title,425,160,925,200,62,C,true);
  tx(s,'question',body[0],430,405,870,140,36,C);
  tx(s,'scope',body[1],430,585,870,108,27,M);
 }else if(d.kind==='break'){
  tx(s,'title',d.title,78,145,1200,120,72,C,true);
  tx(s,'duration',body[0],78,325,1180,140,100,C);
  tx(s,'return',body[1],85,575,1150,115,33,M);
 }else if(d.kind==='exercise'){
  tx(s,'title',d.title,78,102,1260,145,d.title.length>55?46:52,C,true);
  tx(s,'minutes',an(d.minutes||10),78,285,300,190,130,C,true);
  tx(s,'minutes-label','المدة بالدقائق',85,477,290,48,22,M);
  const st=440,sp=Math.min(112,Math.floor(350/body.length));
  body.forEach((b,i)=>tx(s,'task-'+i,`${an(i+1)}. ${val(b)}`,st,290+i*sp,870,sp-8,30,C));
  tx(s,'outcome','المطلوب: '+(d.result||'احفظ العمل مع بيان سبب التعديل.'),445,656,860,80,22,M);
 }else{
  tx(s,'title',d.title,78,96,1280,150,d.title.length>64?43:51,C,true);
  if(d.kind==='formula'){
   tx(s,'mnemonic','مفتاح',78,300,450,140,86,C,true);
   tx(s,'reminder','قاعدة لتوضيح\nالعمل المطلوب',85,470,380,125,28,M);
   body.forEach((b,i)=>tx(s,'letter-'+i,b,570,270+i*88,770,78,29,C));
  }else if(d.kind==='feature'||(d.kind==='definition'&&body.every(Array.isArray))){
   body.forEach((b,i)=>{const a=pair(b),step=body.length>3?110:143;tx(s,'label-'+i,a[0],82,275+i*step,360,step-10,31,C,true);tx(s,'explanation-'+i,a[1],485,275+i*step,825,step-10,32,C);});
  }else if(d.kind==='agenda'){
   const step=body.length>2?115:205;
   body.forEach((b,i)=>{tx(s,'order-'+i,an(String(i+1).padStart(2,'0')),80,290+i*step,115,90,48,M);tx(s,'agenda-'+i,val(b),245,290+i*step,1060,145,body.length>2?34:43,C);});
  }else if(d.kind==='compare'){
   if(body.every(Array.isArray)){
    body.forEach((b,i)=>{const step=body.length>3?110:143;tx(s,'term-'+i,b[0],82,275+i*step,360,95,29,C,true);tx(s,'meaning-'+i,b[1],475,275+i*step,850,100,31,C);});
   }else if(body.length===2){body.forEach((b,i)=>{tx(s,'side-'+i,i===0?'الأول':'الثاني',85+i*650,290,570,40,20,M);tx(s,'comparison-'+i,b,85+i*650,365,560,320,37,C);});}
   else{body.forEach((b,i)=>{tx(s,'comparison-index-'+i,an(String(i+1).padStart(2,'0')),80,285+i*(body.length===4?108:144),100,80,44,M);tx(s,'comparison-'+i,b,220,285+i*(body.length===4?108:144),1100,body.length===4?96:128,32,C);});}
  }else if(d.kind==='timeline'){
   body.forEach((b,i)=>tx(s,'milestone-'+i,b,85,275+i*110,1240,98,34,C));
  }else if(d.kind==='definition'){
   tx(s,'main-definition',body[0],85,285,1220,165,41,C,true);
   body.slice(1).forEach((b,i)=>tx(s,'detail-'+i,val(b),85,490+i*104,1210,95,31,C));
  }else if(d.kind==='quote'){
   tx(s,'lead',body[0],85,285,1200,180,45,C,true);
   body.slice(1).forEach((b,i)=>tx(s,'comment-'+i,val(b),85,485+i*103,1200,92,31,C));
  }else if(d.kind==='prompt'){
   const step=body.length>3?83:143;
   body.forEach((b,i)=>tx(s,'prompt-part-'+i,val(b),85,285+i*step,1230,step-8,body.length>3?30:34,C));
  }else if(d.kind==='workflow'){
   const step=body.length>3?110:143;
   body.forEach((b,i)=>{const a=pair(b);tx(s,'step-'+i,an(String(i+1).padStart(2,'0')),80,285+i*step,95,70,46,M);tx(s,'step-copy-'+i,a[0]?a[0]+'\n'+a[1]:a[1],220,285+i*step,1100,step-8,31,C);});
  }else if(d.kind==='closing'){
   body.forEach((b,i)=>tx(s,'closing-'+i,val(b),85,285+i*104,1225,98,32,C));
  }else if(d.kind==='checklist'){
   body.forEach((b,i)=>{tx(s,'check-'+i,'□',85,285+i*(body.length>3?105:143),50,65,35,M);tx(s,'check-copy-'+i,val(b),155,285+i*(body.length>3?105:143),1160,body.length>3?95:130,32,C);});
  }else{
   const step=body.length>3?107:143;
   body.forEach((b,i)=>tx(s,'body-'+i,val(b),85,285+i*step,1225,step-8,33,C));
  }
 }
 let notes=`الشريحة ${an(d.id)}: ${d.title}\nاليوم ${an(d.day)}. ${d.bab?'الباب '+an(d.bab)+'. ':''}${d.chapter}\n\nنص الإلقاء\n\n${d.notes}`;
 if(d.refs?.length)notes+='\n\nالمراجع\n'+d.refs.join('\n');
 if(d.bab>=2&&d.bab<=6)notes+='\n\nتختلف إتاحة المزايا بحسب الحساب والمنطقة والجهاز والإعدادات. ويمكن تطبيق أمثلة المحادثة في مجموعات صغيرة بالحسابات المتاحة.';
 s.speakerNotes.text=notes;
}
await fs.mkdir(R+'/.build',{recursive:true});await fs.mkdir(R+'/review',{recursive:true});
await(await PresentationFile.exportPptx(p)).save(R+'/.build/candidate.pptx');
console.log(JSON.stringify({slides:data.length,notesWords:data.reduce((a,d)=>a+d.notes.split(/\s+/).length,0)}));
