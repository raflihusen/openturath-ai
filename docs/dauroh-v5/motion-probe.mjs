import fs from 'node:fs/promises';
import {Presentation,PresentationFile} from '/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs';

const base='/Users/apple/Downloads/ramadhan/docs/dauroh-v5/.build';
const deck=Presentation.create({slideSize:{width:1440,height:810}});
const slide=deck.slides.add();
slide.background.fill='#F0F0F2';
function text(name,value,x,y,w,h,size=32,color='#09090B',bold=false){
 const a=slide.shapes.add({name,geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:'none',line:{fill:'none',width:0}});
 a.text=value;a.text.style={typeface:'IBM Plex Sans Arabic',fontSize:size,color,bold,alignment:'right',verticalAlignment:'top',insets:0,autoFit:'none',wrap:'square'};
}
text('chrome-title','اختبار الحركة في عرض الشرائح',70,55,1300,95,54,'#09090B',true);
text('chrome-instruction','تظهر البطاقة الأولى تلقائيًّا، ثم تكشف كل نقرة البطاقة التالية.',70,165,1300,65,29,'#71717A');
const cards=[
 ['١','النص الذي نقرأه','يبقى المصدر مطلوبًا عند النقل الحرفي وعند تلخيص المعنى.'],
 ['٢','ما حفظه الملخّص','النقل والتلخيص يحتاجان إلى توثيق.'],
 ['٣','إضافة لا يدلّ عليها النص','كل تلخيص صحيح، ولو لم نراجع أصله.']
];
cards.forEach((c,i)=>{
 const x=1000-i*465,p='b'+(i+1)+'-',dark=i===1;
 slide.shapes.add({name:p+'panel',geometry:'roundRect',position:{left:x,top:300,width:370,height:355},fill:dark?'#18181B':'#FFFFFF',borderRadius:30,line:{fill:'none',width:0}});
 text(p+'number',c[0],x+25,325,320,65,42,dark?'#FAFAFA':'#09090B',true);
 text(p+'label',c[1],x+28,415,314,70,27,dark?'#FAFAFA':'#09090B',true);
 text(p+'body',c[2],x+28,505,314,125,29,dark?'#FAFAFA':'#09090B');
});
await fs.mkdir(base,{recursive:true});
await (await PresentationFile.exportPptx(deck)).save(base+'/motion-probe-source.pptx');
console.log(base+'/motion-probe-source.pptx');
