import fs from 'node:fs/promises';
import {Presentation,PresentationFile} from '/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs';
const R='/Users/apple/Downloads/ramadhan/docs/dauroh-v5', A=R+'/../dauroh-v4-fluent/assets';
const W=1440,H=810,F='IBM Plex Sans Arabic', C={ink:'#09090B',dark:'#18181B',gray:'#27272A',paper:'#FAFAFA',mist:'#F0F0F2',muted:'#71717A',light:'#A1A1AA'};
const data=[];for(const f of ['part-01-17.json','part-18-35.json','part-36-52.json'])data.push(...JSON.parse(await fs.readFile(R+'/'+f,'utf8')));
if(data.length!==52||data.some((d,i)=>d.id!==i+1))throw Error('Sequence must be 1–52');
const deck=Presentation.create({slideSize:{width:W,height:H}}),report=[],manifest=[];
const ar=n=>String(n).replace(/[0-9]/g,c=>'٠١٢٣٤٥٦٧٨٩'[c]);
const darkSlides=new Set([1,7,10,13,17,21,26,27,39,44,45,48,52]);
const art={1:['cover',true,true],4:['brain',true,true],7:['shield',true,true],8:['book',true,true],10:['chat',true,true],21:['compass',false,false],26:['hourglass',false,false],27:['cards',false,false],41:['scale',false,false],52:['cap',false,false]};
const used=new Set();
function T(s,n,v,x,y,w,h,size=30,color=C.ink,bold=false,align='right'){
 const a=s.shapes.add({name:n,geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:'none',line:{fill:'none',width:0}});
 a.text=v||'';a.text.style={typeface:F,fontSize:size,color,bold,alignment:align,verticalAlignment:'top',insets:0,autoFit:'none',wrap:'square'};return a;
}
function P(s,n,x,y,w,h,fill=C.paper,r=28,shadow=true){return s.shapes.add({name:n,geometry:'roundRect',position:{left:x,top:y,width:w,height:h},fill,borderRadius:r,line:{fill:'none',width:0},shadow:shadow?'0px 6px 18px #000000/8':'shadow-none'});}
function estimate(v,size,w){
 const perLine=w/(size*.49);let lines=0;
 for(const p of v.split('\n'))lines+=Math.max(1,Math.ceil(p.length/perLine));
 return lines*size*1.23;
}
function fit(v,w,h,max=31,min=25){let f=max;while(f>min&&estimate(v,f,w)>h-8)f-=1;return f;}
function block(s,d,i,rect,opts={}){
 const b=d.blocks[i],g=Math.min(i+1,d.notes.length),n='b'+g+'-block'+(i+1),[x,y,w,h]=rect;
 const dark=opts.dark??(i===0&&!darkSlides.has(d.id)&&!['source','reference'].includes(b.role));
 const fill=opts.fill||(dark?C.dark:C.paper),fg=dark?C.paper:C.ink,pad=h<165?23:30;
 P(s,n+'-panel',x,y,w,h,fill,opts.radius||28);
 const labelH=b.label.length>31?62:42;
 const bodyY=y+pad+labelH+10,bodyH=y+h-pad-bodyY;
 const size=fit(b.text,w-pad*2,bodyH,opts.size||31,opts.min||25);
 T(s,n+'-label',b.label,x+pad,y+pad,w-2*pad,labelH,h<170?24:27,fg,true);
 T(s,n+'-text',b.text,x+pad,bodyY,w-2*pad,bodyH,size,fg);
 report.at(-1).blocks.push({index:i+1,stage:g,rect,bodyFont:size,estimatedHeight:Math.round(estimate(b.text,size,w-pad*2)),bodyHeight:Math.round(bodyH)});
 return n;
}
function arrow(s,g,x,y,w=55){s.shapes.add({name:'b'+g+'-arrow-'+x+'-'+y,geometry:'leftArrow',position:{left:x,top:y,width:w,height:26},fill:C.light,line:{fill:'none',width:0}});}
const rects={
2:[[390,250,980,340],[70,300,280,320]],
3:[[960,270,410,355],[510,320,410,355],[60,270,410,355]],
4:[[790,240,580,145],[790,405,580,145],[790,570,580,130]],
5:[[950,260,420,400],[510,290,400,370],[70,260,400,400]],
6:[[745,245,625,210],[70,245,625,210],[745,480,625,210],[70,480,625,210]],
7:[[770,270,600,205],[770,505,600,190]],
8:[[650,245,720,240],[650,510,720,180],[70,555,500,135]],
9:[[745,250,625,425],[70,250,625,200],[70,475,625,200]],
10:[[740,245,630,320],[740,590,630,110]],
11:[[745,270,625,350],[70,330,625,350]],
12:[[880,260,490,350],[70,260,750,175],[70,465,750,185]],
13:[[745,250,625,180],[70,250,625,270],[745,460,625,230]],
14:[[960,265,410,350],[515,305,405,350],[70,265,405,350]],
15:[[730,245,640,185],[70,245,610,425],[730,460,640,210]],
16:[[70,250,410,380],[510,285,410,380],[960,250,410,380]],
17:[[745,245,625,245],[70,245,625,245],[340,525,1030,160]],
18:[[900,280,470,320],[460,360,400,300],[70,275,350,320]],
19:[[840,260,530,340],[70,300,720,340],[240,655,1130,45]],
20:[[745,245,625,205],[70,245,625,205],[745,480,625,205],[70,480,625,205]],
21:[[590,245,780,120],[590,385,780,135],[590,540,780,160]],
22:[[745,245,625,180],[70,310,625,180],[470,525,900,160]],
23:[[760,250,610,260],[70,290,640,260],[400,585,970,105]],
24:[[990,245,380,205],[550,245,400,205],[110,245,400,205],[110,480,1260,205]],
25:[[900,255,470,195],[70,255,780,340],[900,480,470,195]],
26:[[570,250,800,120],[570,390,800,160],[570,570,800,130]],
27:[[610,250,760,120],[610,390,760,120],[610,530,760,150]],
28:[[530,250,840,150],[70,250,410,340],[530,435,840,240]],
29:[[960,260,410,280],[70,260,830,165],[70,455,830,220]],
30:[[745,245,625,185],[70,245,625,185],[745,455,625,230],[70,455,625,230]],
31:[[860,255,510,370],[70,255,735,165],[70,450,735,225]],
32:[[960,245,410,360],[515,290,405,360],[70,335,405,360]],
33:[[745,245,625,205],[70,245,625,205],[745,480,625,205],[70,480,625,205]],
34:[[650,250,720,425],[70,250,530,190],[70,470,530,205]],
35:[[70,245,1300,125],[745,395,625,190],[70,395,625,190],[70,610,1300,90]],
36:[[100,245,1240,310],[360,590,980,110]],
37:[[900,260,470,280],[70,260,770,180],[70,470,770,220]],
38:[[470,245,900,440],[70,335,350,345]],
39:[[160,260,1210,240],[70,535,1080,150]],
40:[[745,250,625,160],[70,250,625,240],[745,440,625,255]],
41:[[590,245,780,300],[590,575,780,125]],
42:[[960,255,410,350],[515,300,405,350],[70,255,405,350]],
43:[[745,245,625,175],[70,290,625,220],[745,450,625,235]],
44:[[745,245,625,280],[70,245,625,280],[300,560,1070,140]],
45:[[650,245,720,140],[650,410,720,140],[650,575,720,125]],
46:[[600,245,770,280],[70,245,480,240],[70,520,480,170]],
47:[[890,260,480,365],[70,260,760,180],[70,470,760,220]],
48:[[690,245,680,350],[70,245,570,280],[70,555,570,140]],
49:[[745,250,625,250],[70,310,625,190],[745,530,625,160]],
50:[[960,250,410,330],[515,290,405,330],[70,330,405,330]],
51:[[830,245,540,420],[70,245,710,195],[70,475,710,195]],
52:[[610,245,760,130],[610,400,760,130],[610,555,760,145]]
};
const refsA="ابن خلدون، المقدمة، فصل «في أن التعليم للعلم من جملة الصنائع»، الجزء الأول، ترقيم النسخة النصية ٥٤٥: https://usul.ai/ar/t/ta'rikh-ibn-khaldun/543";
const refsB="تعريف الملكة في الفصل نفسه، الجزء الأول، ترقيم النسخة النصية ٥٤٣: https://usul.ai/ar/t/ta'rikh-ibn-khaldun/541";
for(const d of data){
 const s=deck.slides.add(),dark=darkSlides.has(d.id),fg=dark?C.paper:C.ink,muted=dark?C.light:C.muted;
 s.background.fill=dark?C.ink:C.mist;
 report.push({slide:d.id,layout:d.kind+' / composition '+d.id,stages:d.notes.length,blocks:[]});
 const artSpec=art[d.id];
 if(artSpec){const[key,old,full]=artSpec;if(used.has(key))throw Error('Repeated artwork');used.add(key);s.images.add({blob:new Uint8Array(await fs.readFile(A+'/'+(old?'':'rev-')+key+'.png')),contentType:'image/png',fit:full?'cover':'contain',position:full?{left:0,top:0,width:W,height:H}:{left:45,top:280,width:490,height:410},alt:'إيضاح ثلاثي الأبعاد'});}
 if(d.id!==1){
  T(s,'chrome-section','اليوم '+(d.day===1?'الأول':'الثاني')+'  ·  '+d.section,70,26,1300,30,19,muted);
  T(s,'chrome-title',d.title,70,81,1300,115,d.title.length>45?45:50,fg,true);
  P(s,'chrome-rule',70,210,1300,2,dark?C.gray:'#D4D4D8',0,false);
  T(s,'chrome-page',ar(d.id)+' / ٥٢',70,779,160,23,16,muted,false,'left');
  T(s,'chrome-brand','أوبن تراث',1150,775,220,28,18,muted,true);
 }
 if(d.id===1){
  P(s,'b1-title-panel',775,125,595,500,C.dark,36);
  T(s,'chrome-brand','أوبن تراث',840,52,530,50,30,C.paper,true);
  T(s,'b1-title','استخدام الذكاء\nالاصطناعي في مجال\nالبحث العلمي',820,175,505,235,51,C.paper,true);
  T(s,'b1-subtitle','من أول محادثة إلى فقرة تفهمها',820,480,505,100,29,C.paper);
  P(s,'b2-summary-panel',790,650,580,95,C.dark,28);
  T(s,'b2-summary',d.blocks[1].text,820,671,520,65,24,C.paper);
 }else{
  if(d.id===45){P(s,'b1-logo-surface',70,270,510,400,C.dark,38);s.images.add({blob:new Uint8Array(await fs.readFile(A+'/openturath_light.png')),contentType:'image/png',fit:'contain',position:{left:150,top:315,width:350,height:300},alt:'شعار أوبن تراث'});}
  const rr=rects[d.id];if(!rr||rr.length!==d.blocks.length)throw Error('Missing composition '+d.id);
  d.blocks.forEach((b,i)=>block(s,d,i,rr[i],{dark:([4,8,10,21,26,27,41,45,52].includes(d.id)?i>0:undefined),size:d.id===36?32:31,min:25}));
  if([11,12,19,32,37,40,43].includes(d.id))arrow(s,Math.min(2,d.notes.length),695,390,45);
  if(d.takeaway){const n='b'+d.notes.length+'-takeaway';P(s,n+'-panel',70,719,1300,45,dark?C.gray:'#E4E4E7',20,false);T(s,n+'-text',d.takeaway,92,728,1256,34,21,dark?C.paper:C.gray);}
 }
 const notes=d.notes.map(n=>n.cue+'\n'+n.say).join('\n\n');
 const refs=d.id>=8?[refsA,...(d.id>=28?[refsB]:[])]:[];
 const runGuide='طريقة العرض: يظهر العنوان والجزء الأول تلقائيًا. تفتح النقرات التالية بقية الأجزاء بحسب عناوين المقاطع أدناه.';
 s.speakerNotes.text=runGuide+'\n\n'+notes+(refs.length?'\n\nالمراجع:\n'+refs.join('\n'):'');
 const effects=[{targets:['chrome-*'],effect:'fade',durationMs:300},{targets:['b1-*'],effect:'floatUp',durationMs:520,delayMs:70}];
 if(artSpec||d.id===45)effects.push({targets:['art-*'],effect:artSpec?.[2]?'fade':'floatUp',durationMs:760,delayMs:0});
 const stages=[{trigger:'auto',effects}];
 for(let g=2;g<=d.notes.length;g++)stages.push({trigger:'click',effects:[{targets:['b'+g+'-*'],effect:([12,19,21,32,37,40].includes(d.id)?'floatRight':g===2?'fade':'floatUp'),durationMs:g===2?440:520}]});
 manifest.push({slide:d.id,stages});
}
await fs.mkdir(R+'/.build',{recursive:true});await fs.mkdir(R+'/review',{recursive:true});
await (await PresentationFile.exportPptx(deck)).save(R+'/.build/candidate.pptx');
await fs.writeFile(R+'/.build/animation-manifest.json',JSON.stringify({slides:manifest},null,2));
await fs.writeFile(R+'/.build/content.json',JSON.stringify(data,null,2));
await fs.writeFile(R+'/design-map.json',JSON.stringify({font:F,slideSize:{width:W,height:H},uniqueArtwork:[...used],slides:report},null,2));
console.log(JSON.stringify({slides:data.length,artwork:used.size,stages:manifest.reduce((n,s)=>n+s.stages.length,0),candidate:R+'/.build/candidate.pptx'}));
