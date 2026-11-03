import fs from 'node:fs/promises';
import {Presentation,PresentationFile} from '/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs';
const ROOT='/Users/apple/Downloads/ramadhan/docs/dauroh-v6-id';
const FONT='IBM Plex Sans Arabic',W=1440,H=810;
const data=JSON.parse(await fs.readFile(ROOT+'/slides-id.json','utf8'));
const deck=Presentation.create({slideSize:{width:W,height:H}});
const refs={
6:['https://home.dartmouth.edu/about/artificial-intelligence-ai-coined-dartmouth','https://openai.com/index/chatgpt/'],
9:['https://help.openai.com/en/articles/7842364-how-chatgpt-and-our-foundation-models-are-developed'],
10:['https://help.openai.com/en/articles/7842364-how-chatgpt-and-our-foundation-models-are-developed'],
11:['https://www.anthropic.com/research/exploring-model-welfare'],
12:['https://openai.com/index/chatgpt/'],
14:['https://help.openai.com/en/articles/9260256-chatgpt-capabilities-overview'],
15:['https://help.openai.com/en/articles/9260256-chatgpt-capabilities-overview','https://help.openai.com/en/articles/11780217-study-mode'],
16:['https://support.google.com/gemini/answer/16275805?hl=en'],
17:['https://support.google.com/gemini/answer/16047321?hl=en','https://support.google.com/gemini/answer/15719111?hl=en'],
18:['https://support.claude.com/en/articles/10684626-enable-and-use-web-search'],
19:['https://support.claude.com/en/articles/11088861-use-research-on-claude','https://support.claude.com/en/articles/17153992-what-are-artifacts-and-how-do-i-use-them'],
20:['https://api-docs.deepseek.com/news/news250115/','https://api-docs.deepseek.com/updates/'],
21:['https://api-docs.deepseek.com/guides/thinking_mode/','https://api-docs.deepseek.com/updates/']};
const materialA='CATATAN LATIHAN BUATAN\nSaya ingin mengulang tiga bab pelajaran selama enam hari. Waktu yang tersedia 45 menit per hari. Bab pertama lebih mudah, bab kedua paling sulit, dan bab ketiga belum selesai dibaca. Saya ingin ada latihan mengingat kembali tanpa melihat buku. Saya juga perlu menulis tiga pertanyaan untuk dibawa ke kelompok belajar. Waktu pertemuan kelompok belum ditentukan. Saya mempunyai catatan lama yang perlu dirapikan. Saya ingin mengetahui bagian mana yang belum dipahami sebelum meminta bantuan pengajar.';
const comparison='PERMINTAAN PEMBANDING\nSaya mahasiswa yang ingin mengulang tiga bab dalam enam hari. Saya punya 45 menit setiap hari. Bab pertama relatif mudah, bab kedua paling sulit, dan bab ketiga belum selesai dibaca. Susun jadwal dalam tabel: hari, kegiatan, alokasi menit, dan cara mengecek pemahaman. Pastikan jumlah waktu harian tidak melebihi 45 menit. Jika ada informasi penting yang belum tersedia, sebutkan pertanyaan klarifikasinya.';
function text(s,name,value,x,y,w,h,size,color='#09090B',bold=false){
 const t=s.shapes.add({name,geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:'none',line:{fill:'none',width:0}});
 t.text=value;t.text.style={typeface:FONT,fontSize:size,bold,color,alignment:'left',verticalAlignment:'top',insets:0,autoFit:'none',wrap:'square'};return t;
}
const reports=[];
for(const d of data){
 if(d.notes.split(/\s+/).length<200)throw Error('Spoken notes too short '+d.id);
 const s=deck.slides.add(),dark=[1,40,41,80].includes(d.id),fg=dark?'#FAFAFA':'#09090B',muted=dark?'#A1A1AA':'#71717A';
 s.background.fill=dark?'#09090B':'#FAFAFA';
 const section=d.block.split(' · ').at(-1)||'Dauroh AI';
 text(s,'section',`Hari ${d.day}  /  ${section}`,90,43,1260,36,20,muted);
 text(s,'title',d.title,90,d.id===1?135:105,1260,d.id===1?180:155,d.id===1?64:d.title.length>65?46:52,fg,true);
 const n=d.body.length,y0=d.id===1?395:305,step=n===4?96:n===3?125:165,h=n===4?89:n===3?108:145;
 d.body.forEach((v,i)=>{
  text(s,'point-'+(i+1),v,90,y0+i*step,1240,h,v.length>125?30:34,fg);
 });
 text(s,'page',`${String(d.id).padStart(2,'0')} / 80`,90,769,220,24,17,muted);
 text(s,'brand','OpenTurath AI',1090,769,260,24,17,muted);
 let note=`SLIDE ${String(d.id).padStart(2,'0')} — ${d.title}\nHari ${d.day}. ${d.block}\n\nNASKAH TUTUR\n\n${d.notes}`;
 if(d.demo)note+='\n\nCONTOH PERMINTAAN / ARAHAN DEMONSTRASI\n'+d.demo.replaceAll('**','');
 if([3,34,35,39].includes(d.id))note+='\n\n'+materialA;
 if([14,15,16,17,18,19,20,21,22].includes(d.id))note+='\n\n'+comparison;
 if([43,45,51,53,54,56,57,58,60,68,70].includes(d.id))note+='\n\nPERSIAPAN PENGAJAR\nPilih bahan atau topik latihan yang boleh dibagikan sebelum pelaksanaan. Untuk demo sumber, periksa teks, identitas versi, dan lokasi terlebih dahulu. Petikan kitab dan artikel khusus belum ditetapkan dalam draf ini; hindari menyajikan contoh buatan sebagai kutipan atau data penelitian nyata.';
 if(refs[d.id])note+='\n\nRUJUKAN\n'+refs[d.id].join('\n');
 s.speakerNotes.text=note;
 reports.push({slide:d.id,title:d.title,spokenWords:d.notes.split(/\s+/).length,totalNoteWords:note.split(/\s+/).length,points:n});
}
await fs.mkdir(ROOT+'/.build',{recursive:true});await fs.mkdir(ROOT+'/review',{recursive:true});
await (await PresentationFile.exportPptx(deck)).save(ROOT+'/.build/candidate.pptx');
await fs.writeFile(ROOT+'/.build/notes-audit.json',JSON.stringify(reports,null,2));
if(process.env.RENDER_SLIDES==='1'){
 for(let i=0;i<deck.slides.items.length;i++){
  const png=await deck.export({slide:deck.slides.items[i],format:'png',scale:1});
  await fs.writeFile(ROOT+'/.build/slide-'+String(i+1).padStart(2,'0')+'.png',new Uint8Array(await png.arrayBuffer()));
 }
}
console.log(JSON.stringify({slides:data.length,spokenWords:reports.reduce((n,r)=>n+r.spokenWords,0),min:Math.min(...reports.map(r=>r.spokenWords)),max:Math.max(...reports.map(r=>r.spokenWords))}));
