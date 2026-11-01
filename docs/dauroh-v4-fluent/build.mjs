import fs from 'node:fs/promises';
import path from 'node:path';
import { Presentation, PresentationFile } from '/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs';

const ROOT = '/Users/apple/Downloads/ramadhan/docs/dauroh-v4-fluent';
const PRIVATE = path.join(ROOT, '.build');
const W = 1280, H = 720, FONT = 'Arial';
const slides = JSON.parse(await fs.readFile(path.join(ROOT, 'content.json'), 'utf8'));
await fs.mkdir(PRIVATE, { recursive: true });
const deck = Presentation.create({ slideSize: { width: W, height: H } });
const digits = s => String(s).replace(/[0-9]/g, n => '٠١٢٣٤٥٦٧٨٩'[n]);
const assets = {};
for (const key of ['cover','brain','search','shield','chat','plan','pen','book']) {
  assets[key] = new Uint8Array(await fs.readFile(path.join(ROOT, 'assets', `${key}.png`)));
}

function text(slide, name, value, x, y, w, h, size = 32, color = '#18181B', bold = false, align = 'right') {
  if (!value) return;
  const sh = slide.shapes.add({ name, geometry: 'textbox', position: { left:x, top:y, width:w, height:h }, fill:'none', line:{fill:'none',width:0} });
  sh.text = value;
  sh.text.style = { typeface:FONT, fontSize:size, color, bold, alignment:align, verticalAlignment:'top', insets:0, autoFit:'none', wrap:'square' };
  return sh;
}

function image(slide, key, compact = false) {
  slide.images.add({ blob:assets[key], contentType:'image/png', fit:'cover', alt:`إيضاح ثلاثي الأبعاد: ${key}`, position:compact ? {left:0,top:0,width:510,height:287} : {left:0,top:0,width:W,height:H} });
}

function motif(d, dark) {
  if (dark) return d.type === 'exercise' ? (d.id % 2 ? 'pen' : 'chat') : d.type === 'prompt' ? 'chat' : d.id % 2 ? 'shield' : 'cover';
  if (['search','book','check'].includes(d.icon)) return 'search';
  if (['plan','layers','compass'].includes(d.icon)) return 'plan';
  return d.icon === 'brain' ? 'brain' : 'book';
}

function shell(d, {dark=false, compact=false, key} = {}) {
  const s=deck.slides.add();
  s.background.fill = dark ? '#09090B' : '#FAFAFA';
  image(s, key || motif(d,dark), compact);
  const fg=dark?'#FAFAFA':'#09090B', muted=dark?'#A1A1AA':'#71717A';
  const x=compact?420:520, width=1210-x;
  text(s,'section',`اليوم ${d.day===1?'الأول':'الثاني'}  ·  ${d.section}`,x,40,width,34,22,muted);
  text(s,'title',d.title,x,94,width,122,d.title.length>35?45:50,fg,true);
  if (d.subtitle) text(s,'subtitle',d.subtitle,x,211,width,68,25,muted);
  text(s,'page',`${digits(d.id)} / ${digits(slides.length)}`,64,677,130,24,18,muted,false,'left');
  text(s,'footer-brand','أوبن تراث',1040,675,170,26,19,muted);
  s.speakerNotes.text = d.note + '\n\nالتصميم: إيضاح ثلاثي الأبعاد منشأ بالذكاء الاصطناعي، مع نص قابل للتحرير. المصدر: ملف content.json الخاص بالدورة.';
  if ([6,8,15,18,22].includes(d.id)) s.speakerNotes.text += '\nمرجع إعداد المدرّس: NIST AI 600-1، القسم 2.2: https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf';
  return {s,fg,muted,x,width};
}

function rows(s, lines, x, y, width, fg, {size=32,gap=89,numbered=false}={}) {
  lines.forEach((line,i)=>{
    if(numbered) text(s,`number-${i}`,digits(i+1),x+width-55,y+i*gap,55,55,40,fg,true);
    text(s,`body-${i}`,line,x,y+i*gap,width-(numbered?85:0),gap-10,size,fg);
  });
}

for (const d of slides) {
  if(d.type==='cover') {
    const s=deck.slides.add(); s.background.fill='#09090B'; image(s,'cover');
    text(s,'brand','أوبن تراث',900,50,310,50,31,'#FAFAFA',true);
    text(s,'cover-title','استخدام الذكاء\nالاصطناعي في مجال\nالبحث العلمي',700,160,510,268,54,'#FAFAFA',true);
    text(s,'cover-subtitle','مدخل عملي لطلاب العلم',700,475,510,58,35,'#E4E4E7');
    text(s,'cover-time','دورة تطبيقية على يومين',700,560,510,42,26,'#A1A1AA');
    text(s,'cover-page','١',1120,677,90,24,18,'#A1A1AA');
    s.speakerNotes.text=d.note+'\nالإيضاح ثلاثي الأبعاد منشأ بالذكاء الاصطناعي لأغراض التصميم.';
    continue;
  }
  if(['compare','grid'].includes(d.type) || (d.type==='split' && d.columns)) {
    const {s,fg,muted}=shell(d,{compact:true,key:d.id===8?'brain':d.id===20?'plan':'book'});
    let top=d.quote?385:295;
    if(d.quote)text(s,'source-text',d.quote,80,278,1120,95,29,fg);
    const cols=d.columns||[];
    const n=cols.length;
    cols.forEach((col,i)=>{
      const pair=n===4;
      const colW=pair?520:n===3?340:520;
      const x=pair?(i%2===0?680:80):n===3?(840-i*380):(i===0?680:80);
      const y=pair?(i<2?295:455):top;
      const height=pair?100:230;
      text(s,`column-title-${i}`,col.title,x,y,colW,55,pair?29:31,fg,true);
      text(s,`column-body-${i}`,col.body.join('\n'),x,y+61,colW,height,pair?26:n===3?28:30,fg);
    });
    const trailing=d.body?.join('  ');
    if(trailing)text(s,'takeaway',trailing,80,623,1120,38,23,muted);
    continue;
  }
  if(d.type==='prompt') {
    const {s,fg,muted}=shell(d,{dark:true,compact:true,key:'chat'});
    text(s,'prompt',d.prompt,80,310,1120,235,34,fg);
    text(s,'prompt-instruction',d.body.join('\n'),80,590,1120,57,27,muted);
    continue;
  }
  if(d.type==='exercise') {
    const hasQuote=!!d.quote;
    const {s,fg,muted}=shell(d,{dark:!hasQuote,compact:hasQuote,key:hasQuote?'plan':'pen'});
    if(hasQuote) {
      text(s,'exercise-text',d.quote,80,285,1120,144,29,fg);
      rows(s,d.body,80,458,1120,fg,{size:27,gap:44,numbered:true});
    } else rows(s,d.body,540,300,670,fg,{size:32,gap:d.body.length>3?79:100,numbered:true});
    continue;
  }
  if(d.type==='process') {
    const {s,fg,muted}=shell(d,{key:d.day===1?'brain':'plan'});
    rows(s,d.steps||d.body,530,294,680,fg,{size:31,gap:77,numbered:true});
    if(d.steps&&d.body.length)text(s,'process-caption',d.body.join(' '),530,616,680,38,24,muted);
    continue;
  }
  if(d.type==='quote') {
    const {s,fg,muted}=shell(d,{dark:true,key:'shield'});
    text(s,'principle',d.quote,530,282,680,155,44,fg,true);
    rows(s,d.body,530,475,680,muted,{size:27,gap:41});
    continue;
  }
  if(d.type==='hero'||d.type==='end') {
    const dark=d.type==='end'||d.id===47;
    const {s,fg}=shell(d,{dark,key:dark?'cover':'brain'});
    rows(s,d.body,700,306,510,fg,{size:34,gap:99});
    continue;
  }
  if(d.type==='split' && d.quote) {
    const {s,fg,muted}=shell(d,{dark:true,key:'shield'});
    text(s,'quote',d.quote,540,300,670,95,40,fg,true);
    rows(s,d.body,540,421,670,muted,{size:29,gap:70});
    continue;
  }
  {
    const dark=d.type==='overview'&&d.id===28;
    const {s,fg,muted}=shell(d,{dark,key:dark?'chat':d.id===32?'search':'plan'});
    const lines=d.body||[];
    rows(s,lines,540,295,670,fg,{size:31,gap:lines.length>4?62:78,numbered:d.type==='overview'});
    if(d.quote)text(s,'closing-principle',d.quote,540,610,670,45,24,muted);
  }
}

const pptx=await PresentationFile.exportPptx(deck);
await pptx.save(path.join(PRIVATE,'candidate-ltr.pptx'));
await fs.writeFile(path.join(PRIVATE,'authoring-summary.json'),JSON.stringify({slides:slides.length,font:FONT,size:{width:W,height:H},types:[...new Set(slides.map(x=>x.type))],backgrounds:Object.keys(assets)},null,2));
console.log(JSON.stringify({slides:deck.slides.items.length,path:path.join(PRIVATE,'candidate-ltr.pptx')}));
