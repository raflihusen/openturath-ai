import fs from 'node:fs/promises';
import path from 'node:path';
import {Presentation,PresentationFile} from '/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs';

const ROOT='/Users/apple/Downloads/ramadhan/docs/dauroh-v4-fluent';
const BUILD=ROOT+'/.build/redesign';
const W=1440,H=810,FONT='IBM Plex Sans Arabic';
const data=JSON.parse(await fs.readFile(ROOT+'/content.json','utf8'));
const notes={};
for(const f of ['notes-01-18.json','notes-19-36.json','notes-37-52.json'])Object.assign(notes,JSON.parse(await fs.readFile(ROOT+'/'+f,'utf8')));
const deck=Presentation.create({slideSize:{width:W,height:H}});
const audit=[],used=new Set(),cache={};
const C={ink:'#09090B',dark:'#18181B',charcoal:'#27272A',paper:'#FAFAFA',white:'#FFFFFF',mist:'#F0F0F2',line:'#D4D4D8',muted:'#71717A',light:'#A1A1AA'};
const ar=n=>String(n).replace(/[0-9]/g,c=>'٠١٢٣٤٥٦٧٨٩'[c]);
const body=d=>d.body.join('\n');
const col=(d,i)=>d.columns[i].body.join('\n');
const T=(s,n,v,x,y,w,h,size=30,color=C.ink,bold=false,align='right')=>{
 const a=s.shapes.add({name:n,geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:'none',line:{fill:'none',width:0}});
 a.text=v||'';a.text.style={typeface:FONT,fontSize:size,color,bold,alignment:align,verticalAlignment:'top',insets:0,autoFit:'none',wrap:'square'};return a;
};
function P(s,n,x,y,w,h,{fill=C.white,r=28,stroke='none',shadow=true}={}){
 const p=s.shapes.add({name:n,geometry:'roundRect',position:{left:x,top:y,width:w,height:h},fill,borderRadius:r,line:{fill:stroke,width:stroke==='none'?0:1},shadow:shadow?'0px 7px 20px #000000/8':'shadow-none'});return p;
}
function card(s,n,title,content,x,y,w,h,{dark=false,size=29,titleSize=29,fill,tag,center=false}={}){
 const bg=P(s,n,x,y,w,h,{fill:fill||(dark?C.dark:C.white)}),fg=dark?C.paper:C.ink;
 const pad=28;
 if(tag)T(s,n+'-tag',tag,x+pad,y+18,w-2*pad,30,19,dark?C.light:C.muted);
 const ty=y+(tag?57:25);
 if(title)T(s,n+'-title',title,x+pad,ty,w-2*pad,58,titleSize,fg,true,center?'center':'right');
 if(content)T(s,n+'-body',content,x+pad,ty+(title?70:0),w-2*pad,h-(ty-y)-(title?86:22),size,fg,false,center?'center':'right');
 return bg;
}
function pill(s,n,v,x,y,w,{dark=false}={}){P(s,n,x,y,w,48,{fill:dark?C.dark:C.mist,r:24,shadow:false});T(s,n+'-text',v,x+18,y+9,w-36,30,21,dark?C.paper:C.dark,true,'center');}
function link(s,a,b,{from='left',to='right',kind='straight',dark=false}={}){s.shapes.connect(a,b,{kind,fromSide:from,toSide:to,line:{fill:dark?C.light:'#A1A1AA',width:2.2},tail:{type:'triangle',width:'sm',length:'sm'}});}
async function img(s,key,x=0,y=0,w=W,h=H,{old=false,fit='contain'}={}){
 if(used.has(key))throw Error('Repeated primary artwork '+key);used.add(key);
 const p=ROOT+'/assets/'+(old?key:'rev-'+key)+'.png';
 cache[p]||=new Uint8Array(await fs.readFile(p));
 s.images.add({blob:cache[p],contentType:'image/png',fit,alt:'إيضاح ثلاثي الأبعاد خاص بهذه الشريحة',position:{left:x,top:y,width:w,height:h}});
}
function start(d,layout,{dark=false,header=true}={}){
 const s=deck.slides.add();s.background.fill=dark?C.ink:C.mist;
 audit.push({slide:d.id,layout,panels:0,primaryArtwork:null});
 if(header)head(s,d,dark);
 const note=notes[String(d.id)];if(!note?.script)throw Error('Missing spoken script '+d.id);
 const refs=[...(note.sources||[])];
 if([6,8,15,18,22].includes(d.id))refs.push('NIST AI 600-1، القسم 2.2: https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf');
 s.speakerNotes.text=note.script+(refs.length?'\n\nالمراجع:\n'+refs.join('\n'):'');
 return s;
}
function head(s,d,dark=false){
 const fg=dark?C.paper:C.ink,muted=dark?C.light:C.muted;
 T(s,'section','اليوم '+(d.day===1?'الأول':'الثاني')+'  ·  '+d.section,70,24,1300,30,19,muted);
 T(s,'title',d.title,70,77,1300,90,d.title.length>40?47:53,fg,true);
 if(d.subtitle)T(s,'subtitle',d.subtitle.replace(/\s*\|\s*/g,'  '),70,177,1300,62,23,muted);
 T(s,'page',ar(d.id)+' / '+ar(data.length),70,774,160,24,17,muted,false,'left');
 T(s,'brand','أوبن تراث',1150,772,220,28,18,muted,true);
}
function footer(s,txt,{dark=false,y=700}={}){if(!txt)return;P(s,'caption',70,y,1300,54,{fill:dark?C.charcoal:'#E4E4E7',shadow:false,r:22});T(s,'caption-text',txt,92,y+10,1256,38,22,dark?C.paper:C.dark);}
function node(s,n,title,x,y,w=275,h=150,opts={}){return card(s,n,title,'',x,y,w,h,opts);}
function step(s,n,txt,x,y,w,h,{dark=false,num=n}={}){const b=P(s,'step-'+n,x,y,w,h,{fill:dark?C.dark:C.white});pill(s,'step-number-'+n,ar(num),x+w-76,y+22,48,{dark:!dark});T(s,'step-text-'+n,txt,x+26,y+31,w-130,h-48,29,dark?C.paper:C.ink,true);return b;}

for(const d of data){
 let s;
 switch(d.id){
 case 1:
  s=start(d,'cover / book and inset title',{dark:true,header:false});await img(s,'cover',0,0,W,H,{old:true,fit:'cover'});
  P(s,'cover-title-panel',790,135,580,480,{fill:C.dark,r:36});
  T(s,'cover-brand','أوبن تراث',840,55,530,55,30,C.paper,true);
  T(s,'cover-title','استخدام الذكاء\nالاصطناعي في مجال\nالبحث العلمي',835,185,490,240,51,C.paper,true);
  T(s,'cover-subtitle','مدخل عملي لطلاب العلم',835,476,490,65,28,C.paper);
  pill(s,'duration','دورة تطبيقية على يومين',963,660,407,{dark:true});break;
 case 2:{
  s=start(d,'deliverable ribbon / four stations');
  const names=['السؤال','الخطة','الفقرة','المراجعة'];
  d.body.forEach((t,i)=>card(s,'station-'+i,names[i],t,1050-i*325,290+(i%2)*58,300,270,{dark:i===0,tag:'الناتج '+ar(i+1),size:31}));
  footer(s,'ملف واحد، نضيف إليه نتيجة كل تطبيق');break;}
 case 3:
  s=start(d,'workspace / readiness board');
  card(s,'ready-center','مساحة العمل',d.body[0],490,270,460,170,{dark:true,size:28});
  card(s,'ready-right','المادة',d.body[1],1000,490,370,190,{size:29});
  card(s,'ready-left','المساعدة',d.body[2],70,490,370,190,{size:29});
  card(s,'ready-middle','الشراكة',d.body[3],490,490,460,190,{size:29});break;
 case 4:
  s=start(d,'evidence source / stacked answer cards');
  card(s,'source',d.columns[0].title,col(d,0),785,270,585,370,{size:31,tag:'نص تدريبي — إعداد الدورة'});
  card(s,'answer-a','أ',d.columns[1].body[0].replace(/^أ:\s*/,''),70,270,650,180,{dark:true,size:29});
  card(s,'answer-b','ب',d.columns[1].body[1].replace(/^ب:\s*/,''),70,480,650,180,{size:29});footer(s,'أيّ إضافة يسندها النص؟ وما العبارة التي تدل عليها؟');break;
 case 5:
  s=start(d,'asymmetric research bento');
  card(s,'understand',d.columns[0].title,col(d,0),830,270,540,420,{dark:true,size:38,titleSize:37});
  card(s,'organize',d.columns[1].title,col(d,1),70,270,700,195,{size:30});
  card(s,'review',d.columns[2].title,col(d,2),70,495,700,195,{size:30});break;
 case 6:
  s=start(d,'model sculpture / input and output cards',{header:false});await img(s,'brain',0,0,W,H,{old:true,fit:'cover'});head(s,d);
  card(s,'request','المهمة',d.body[0],825,280,545,145,{size:29});
  card(s,'generation','توليد الجواب',d.body[1],760,449,610,155,{dark:true,size:28});
  pill(s,'caution',d.body[2],755,650,615);break;
 case 7:{
  s=start(d,'annotated document / summary slips');
  card(s,'training-document',d.columns[0].title,col(d,0),720,270,650,420,{size:30,tag:'نص تدريبي — إعداد الدورة'});
  d.columns[1].body.forEach((t,i)=>card(s,'summary-'+i,'',t,70+i*22,285+i*130,550,108,{dark:i===0,size:31}));footer(s,'ملخص تعليمي يمكن مقارنته بالنص');break;}
 case 8:{
  s=start(d,'nested model / application / independent source');
  const app=P(s,'application-container',700,270,670,410,{fill:C.dark});T(s,'app-label','التطبيق',735,298,600,60,37,C.paper,true);
  T(s,'app-desc',col(d,1),735,365,600,55,28,C.paper);
  card(s,'model','النموذج',col(d,0),770,455,530,160,{size:31});
  const source=card(s,'real-source','المصدر',col(d,2),70,340,550,270,{size:34});
  link(s,app,source);break;}
 case 9:
  s=start(d,'privacy shield / controlled materials',{dark:true,header:false});await img(s,'shield',0,0,W,H,{old:true,fit:'cover'});head(s,d,true);
  card(s,'authorized','المادة المأذونة',d.body[0]+'\n'+d.body[3],790,280,580,195,{size:30});
  card(s,'private','قبل المشاركة',d.body[1]+'\n'+d.body[2],790,505,580,195,{dark:true,size:30});break;
 case 10:{
  s=start(d,'educational chat mockup / four marked operations');
  P(s,'chat-window',70,265,960,435,{fill:C.white,r:34});
  pill(s,'mock-label','تمثيل تعليمي لشاشة محادثة',100,290,510);
  card(s,'user-message','أنت','لخّص النص المرفق في ثلاث نقاط.',445,365,545,135,{dark:true,size:29});
  card(s,'assistant-message','الجواب','نقرأ الناتج كاملًا، ثم نعود إلى المادة.',105,525,715,135,{fill:C.mist,size:29});
  d.steps.forEach((v,i)=>step(s,i+1,v,1070,270+i*105,300,87,{num:i+1}));break;}
 case 11:
  s=start(d,'first prompt / single-use dialogue sculpture',{dark:true,header:false});await img(s,'chat',0,0,W,H,{old:true,fit:'cover'});head(s,d,true);
  card(s,'first-prompt','الأمر الذي نكتبه',d.prompt,760,275,610,310,{dark:true,size:31,tag:'نموذج للتطبيق'});
  footer(s,body(d),{dark:true,y:690});break;
 case 12:{
  s=start(d,'conversation fork / saved notebook');
  const a=card(s,'continue',d.columns[0].title,col(d,0),745,270,625,290,{dark:true,size:29});
  const b=card(s,'notebook',d.columns[1].title,col(d,1),70,350,600,290,{size:31});
  link(s,a,b);pill(s,'topic-rule','موضوع مستقل؟ محادثة جديدة.',800,610,570);break;}
 case 13:
  s=start(d,'practice staircase',{dark:true});
  d.body.forEach((v,i)=>step(s,i+1,v,920-i*270,270+i*92,440,120,{dark:i%2===1}));break;
 case 14:
  s=start(d,'source rule / two contrasting answers');
  card(s,'rule','النص الذي نفحص عليه',d.quote,180,260,1080,170,{dark:true,size:31});
  d.columns.forEach((c,i)=>card(s,'candidate-'+i,c.title,c.body.join('\n'),i===0?745:70,470,625,210,{size:30}));break;
 case 15:
  s=start(d,'error anatomy / three evidence drawers');
  d.columns.forEach((c,i)=>card(s,'error-'+i,c.title,c.body.join('\n'),1000-i*465,285+(i===1?75:0),370,285,{dark:i===1,tag:'موضع الفحص',size:34,titleSize:38}));footer(s,d.body[0]);break;
 case 16:
  s=start(d,'microscope / inspection ladder');await img(s,'microscope',40,275,480,450);
  d.steps.forEach((v,i)=>step(s,i+1,v,600,270+i*103,770,86));
  break;
 case 17:
  s=start(d,'primary quote / manufactured claim',{header:false});await img(s,'book',0,0,W,H,{old:true,fit:'cover'});head(s,d);
  card(s,'ibn-khaldun',d.columns[0].title,col(d,0),650,270,720,245,{size:32});
  card(s,'invented-claim',d.columns[1].title,col(d,1),650,545,720,155,{dark:true,size:30});break;
 case 18:
  s=start(d,'principle slab / unsupported confidence tokens',{dark:true});
  card(s,'principle','',d.quote,170,275,1100,195,{size:43,center:true});
  d.body.forEach((v,i)=>card(s,'not-evidence-'+i,'',v,1060-i*330,545,300,120,{dark:true,size:29,center:true}));break;
 case 19:
  s=start(d,'before after prompt / unequal panels');
  card(s,'vague',d.columns[0].title,col(d,0),900,290,470,330,{size:35,tag:'قبل'});
  card(s,'specific',d.columns[1].title,col(d,1),70,290,760,330,{dark:true,size:32,tag:'بعد'});footer(s,d.body[0]);break;
 case 20:
  s=start(d,'prompt anatomy / four numbered bands');
  d.columns.forEach((c,i)=>{card(s,'part-'+i,c.title,c.body.join('\n'),i<2?745:70,i%2===0?270:490,625,185,{dark:i===0,size:31,tag:'العنصر '+ar(i+1)});});break;
 case 21:
  s=start(d,'prompt document / constraints footer',{dark:true});
  card(s,'bounded-prompt','نص الطلب',d.prompt,150,270,1140,350,{size:34});
  pill(s,'only-source','المادة المحددة',1030,660,260,{dark:true});pill(s,'quote-separation','النقل والشرح',730,660,260,{dark:true});pill(s,'no-fiction','بيانات متحققة',430,660,260,{dark:true});break;
 case 22:
  s=start(d,'two conversation styles / source anchor');
  d.columns.forEach((c,i)=>card(s,'followup-'+i,c.title,c.body.join('\n'),i===0?745:70,280+(i===0?0:60),625,320,{dark:i===1,size:31}));footer(s,d.body[0]);break;
 case 23:
  s=start(d,'request worksheet / raw draft and four fields');
  card(s,'raw-task','الطلب الخام','اشرح لي النص، واكتب كل ما يتعلق به.',70,290,470,290,{dark:true,size:37});
  ['المهمة','المادة','شكل الجواب','الحدود'].forEach((v,i)=>card(s,'field-'+i,v,'اكتب صياغتك هنا',i%2===0?980:600,i<2?280:490,350,180,{size:25}));break;
 case 24:
  s=start(d,'research compass / interview questions');await img(s,'compass',45,310,490,410);
  d.steps.forEach((v,i)=>card(s,'interview-'+i,'',v,610+(i%2)*100,270+i*105,660-(i%2)*100,88,{dark:i===0,size:29}));break;
 case 25:{
  s=start(d,'feasibility decision fork');
  const q=card(s,'question','السؤال المبدئي',d.body[0],480,265,520,170,{dark:true,size:28});
  const a=card(s,'available','مادة متاحة',d.body[1],745,525,625,160,{size:31});
  const b=card(s,'narrow','تحتاج إلى تضييق',d.body[2],70,525,625,160,{size:31});
  link(s,q,a,{from:'bottom',to:'top',kind:'elbow'});link(s,q,b,{from:'bottom',to:'top',kind:'elbow'});break;}
 case 26:
  s=start(d,'project passport / structured first draft');
  P(s,'passport',120,265,1200,430,{fill:C.white});pill(s,'passport-kind','مسودة أولية',1040,286,245,{dark:true});
  d.columns.forEach((c,i)=>card(s,'passport-field-'+i,c.title,c.body.join('\n'),i%2===0?770:165,i<2?365:535,550,130,{fill:C.mist,size:27,titleSize:26}));break;
 case 27:
  s=start(d,'hourglass / homework notebook',{dark:true});await img(s,'hourglass',40,280,490,440);
  pill(s,'time','١٥–٢٠ دقيقة',1000,252,370);
  card(s,'homework','من المصدر الذي فتحناه',body(d),600,325,770,380,{size:30});break;
 case 28:
  s=start(d,'second-day recap / overlapping answer cards');
  T(s,'day-two','٢',90,270,300,350,250,'#D4D4D8',true,'center');
  d.body.forEach((v,i)=>card(s,'recap-'+i,ar(i+1),v,440+i*40,265+i*102,810-i*30,110,{dark:i===0,size:29,titleSize:24}));break;
 case 29:
  s=start(d,'help triage / three diagnosis tickets');
  d.columns.forEach((c,i)=>card(s,'help-'+i,c.title,c.body.join('\n'),1000-i*465,270+i*62,370,235,{dark:i===2,size:30,tag:'موضع التعثر'}));footer(s,d.body[0]);break;
 case 30:{
  s=start(d,'source families / document shelves');
  d.columns.forEach((c,i)=>{P(s,'shelf-back-'+i,i===0?770:95,305,600,340,{fill:'#E4E4E7'});card(s,'source-family-'+i,c.title,c.body.join('\n'),i===0?745:70,275,600,340,{dark:i===0,size:33});});footer(s,d.body[0]);break;}
 case 31:
  s=start(d,'search sculpture / keyword ladder',{header:false});await img(s,'search',0,0,W,H,{old:true,fit:'cover'});head(s,d);
  d.steps.forEach((v,i)=>step(s,i+1,v,740,270+i*106,630,90));break;
 case 32:
  s=start(d,'edition page / four annotations');
  card(s,'edition-page','هوية الكتاب','المؤلف\nالعنوان\nالطبعة\nالجزء والصفحة',70,270,510,420,{dark:true,size:36,tag:'تمثيل تعليمي لبيانات المصدر'});
  d.body.forEach((v,i)=>card(s,'annotation-'+i,'',v,650,265+i*110,720,95,{size:28}));break;
 case 33:
  s=start(d,'source collection exercise / paired forms');
  card(s,'source-one','بطاقة مصدر','العنوان والمؤلف\nبيانات الطبعة المتاحة\nموضع النص ورابطه',745,270,625,330,{size:33,tag:'مصدر أول'});
  card(s,'source-two','بطاقة إضافية','ما وجدته\nما لم أتحقق منه\nأثره في سؤال البحث',70,350,625,330,{dark:true,size:33,tag:'بحسب المادة المتاحة'});break;
 case 34:{
  s=start(d,'research problem tree / aims and limits');
  const p=card(s,'central-problem',d.columns[0].title,d.columns[0].body[0],450,260,600,160,{dark:true,size:31});
  const sub=card(s,'subquestions','الأسئلة الفرعية',d.columns[0].body[1],990,525,380,170,{size:29});
  const goals=card(s,'aims','الأهداف',d.columns[1].body[0],535,525,380,170,{size:29});
  const limits=card(s,'limits','الحدود',d.columns[1].body[1],70,525,380,170,{size:29});
  for(const n of [sub,goals,limits])link(s,p,n,{from:'bottom',to:'top',kind:'elbow'});break;}
 case 35:
  s=start(d,'target sculpture / title scope comparison');await img(s,'target',40,300,450,410);
  card(s,'wide-title',d.columns[0].title,col(d,0),560,270,810,175,{size:32});
  card(s,'bounded-title',d.columns[1].title,col(d,1),560,490,810,190,{dark:true,size:32});break;
 case 36:
  s=start(d,'interview instruction sheet / verify understanding');
  card(s,'interviewer-prompt','المحاوِر',d.prompt,475,270,895,390,{dark:true,size:31});
  card(s,'human-check','قبل قبول البدائل',d.body[0],70,370,350,260,{size:29});break;
 case 37:
  s=start(d,'plan sculpture / reasoning cards',{header:false});await img(s,'plan',0,0,W,H,{old:true,fit:'cover'});head(s,d);
  d.steps.forEach((v,i)=>card(s,'outline-step-'+i,ar(i+1),v,760+(i%2)*40,265+i*104,610-(i%2)*40,90,{dark:i===0,size:28,titleSize:22}));break;
 case 38:
  s=start(d,'plan audit / evidence matrix');
  const xs=[965,520,75],ws=[400,400,400],headers=['القسم','وظيفته في السؤال','مادته الأولية'];
  headers.forEach((v,i)=>card(s,'matrix-heading-'+i,'',v,xs[i],270,ws[i],80,{dark:true,size:27,center:true}));
  for(let r=0;r<3;r++)for(let c=0;c<3;c++)card(s,`matrix-${r}-${c}`,'',c===0?'المبحث '+ar(r+1):c===1?'ما الذي يجيب عنه؟':'أي مصدر يسنده؟',xs[c],380+r*88,ws[c],70,{size:25,center:true});
  footer(s,'التكرار والفجوات يظهران حين نربط كل قسم بسؤاله ومادته');break;
 case 39:{
  s=start(d,'outline worksheet / two branches',{dark:true});
  const q=card(s,'research-question','سؤالي','صياغة محددة يمكن مناقشتها',480,265,520,150,{size:30});
  const a=card(s,'first-section','المبحث الأول','وظيفته\nمصدره الأولي',745,515,625,175,{dark:true,size:30});
  const b=card(s,'second-section','المبحث الثاني','وظيفته\nما يحتاج إلى استكمال',70,515,625,175,{dark:true,size:30});
  link(s,q,a,{from:'bottom',to:'top',kind:'elbow',dark:true});link(s,q,b,{from:'bottom',to:'top',kind:'elbow',dark:true});break;}
 case 40:
  s=start(d,'research index card / source quotation');await img(s,'cards',20,375,430,340);
  P(s,'index-card',500,260,870,450,{fill:C.white,r:32});
  d.columns.forEach((c,i)=>card(s,'index-field-'+i,c.title,c.body.join('\n'),i%2===0?960:535,i<2?290:495,375,180,{fill:i===0?C.dark:C.mist,dark:i===0,size:26,titleSize:27}));break;
 case 41:
  s=start(d,'three authorial voices / cascading cards');
  d.columns.forEach((c,i)=>card(s,'voice-'+i,c.title,c.body.join('\n'),1000-i*465,270+i*55,370,300,{dark:i===0,size:28,tag:['كلام المؤلف','عرض المعنى','عمل الباحث'][i]}));footer(s,d.body[0]);break;
 case 42:{
  s=start(d,'evidence links / paragraph construction');await img(s,'link',525,235,390,240);
  const claim=card(s,'claim','الدعوى',d.steps[0],965,310,405,165,{dark:true,size:30});
  const evidence=card(s,'evidence','المادة الموثقة',d.steps[1],70,310,405,165,{size:30});
  card(s,'inference','وجه الاستدلال وحدوده',d.steps[2]+'\n'+d.steps[3],305,555,830,150,{size:28});break;}
 case 43:
  s=start(d,'review document / criterion sidebar',{dark:true});
  card(s,'critical-prompt','نص المراجعة',d.prompt,70,270,900,400,{size:31});
  ['الجملة','سبب الملاحظة','العبارة الداعمة'].forEach((v,i)=>card(s,'review-marker-'+i,'',v,1030,290+i*125,340,96,{dark:true,size:27,center:true}));break;
 case 44:
  s=start(d,'balanced critique / three decisions');await img(s,'scale',485,290,450,390);
  card(s,'accept',d.columns[0].title,col(d,0),980,290,390,200,{dark:true,size:29});
  card(s,'reject',d.columns[1].title,col(d,1),70,290,390,200,{size:29});
  card(s,'investigate',d.columns[2].title,col(d,2),550,565,820,145,{size:28});break;
 case 45:
  s=start(d,'language correction / protected quotation',{dark:true,header:false});await img(s,'pen',0,0,W,H,{old:true,fit:'cover'});head(s,d,true);
  d.columns.forEach((c,i)=>card(s,'language-'+i,c.title,c.body.join('\n'),690,270+i*215,680,190,{dark:i===1,size:31}));break;
 case 46:{
  s=start(d,'revision ledger / four decisions');
  const cards=d.steps.map((v,i)=>card(s,'revision-'+i,['المعنى','الحاجة','الصياغة','الأثر'][i],v,1055-i*330,300+(i%2)*80,300,240,{dark:i===0,size:30}));
  for(let i=0;i<3;i++)link(s,cards[i],cards[i+1],{kind:'elbow'});footer(s,d.body[0]);break;}
 case 47:
  s=start(d,'OpenTurath / logo and scholarly standards',{dark:true});
  P(s,'logo-surface',70,275,470,420,{fill:C.dark,r:40});
  s.images.add({path:ROOT+'/assets/openturath_light.svg',fit:'contain',position:{left:145,top:310,width:320,height:320},alt:'شعار أوبن تراث'});
  card(s,'project','أوبن تراث',d.body[0],610,275,760,170,{size:32});
  card(s,'same-standard','معيار التحقق',d.body[1]+'\n'+d.body[2],610,480,760,215,{dark:true,size:30});break;
 case 48:{
  s=start(d,'live demonstration / inspection stages');
  d.steps.forEach((v,i)=>card(s,'demo-stage-'+i,ar(i+1),v,1050-i*325,280,300,245,{dark:i===0,size:30}));
  d.body.forEach((v,i)=>pill(s,'demo-check-'+i,v,925-i*440,615,410));break;}
 case 49:
  s=start(d,'individual assessment / text and task sheet');
  card(s,'assessment-text','النص الجديد',d.quote,650,270,720,390,{size:30,tag:'نص تدريبي — إعداد الدورة'});
  card(s,'assessment-task','عمل فردي',body(d),70,330,510,350,{dark:true,size:28});break;
 case 50:
  s=start(d,'claim examination / four inspection tiles');
  card(s,'unproven-claim','الدعوى التي نفحصها',d.quote,310,265,1060,160,{dark:true,size:34,tag:'محاكاة تعليمية'});
  d.body.forEach((v,i)=>card(s,'inspection-'+i,'',v,1050-i*325,510,300,160,{size:29,center:true}));break;
 case 51:
  s=start(d,'learning portfolio / four completed artifacts');
  d.body.forEach((v,i)=>card(s,'portfolio-'+i,['المحادثة','المهمة','التصميم','الفقرة'][i],v,1050-i*325,280+(i%2)*42,300,290,{dark:i===2,size:30,tag:'أستطيع أن'}));
  footer(s,d.quote);break;
 case 52:
  s=start(d,'continued learning / cap and next steps',{dark:true});await img(s,'cap',30,275,520,430);
  d.body.forEach((v,i)=>card(s,'next-step-'+i,['هذا الأسبوع','مع المشرف','بعد ذلك'][i],v,610,270+i*145,760,125,{dark:i!==0,size:27,titleSize:27}));break;
 default:throw Error('Unmapped slide '+d.id);
 }
 const count=s.shapes.items.filter(x=>x.geometry==='roundRect').length;
 audit.at(-1).panels=count;if(count<1)throw Error('No rounded text container on '+d.id);
}
if(deck.slides.items.length!==52)throw Error('Wrong slide count');
await fs.mkdir(BUILD,{recursive:true});
const draft=await PresentationFile.exportPptx(deck);await draft.save(BUILD+'/candidate.pptx');
await fs.writeFile(ROOT+'/design-map.json',JSON.stringify({font:FONT,size:{width:W,height:H},slides:audit,primaryArtworkUsedOnce:[...used]},null,2));
console.log(JSON.stringify({slides:52,layouts:new Set(audit.map(a=>a.layout)).size,uniqueArtwork:used.size,candidate:BUILD+'/candidate.pptx'}));
