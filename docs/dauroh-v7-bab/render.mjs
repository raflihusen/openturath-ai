import fs from 'node:fs/promises';
import {FileBlob,PresentationFile} from '/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs';
const R='/Users/apple/Downloads/ramadhan/docs/dauroh-v7-bab';
const p=await PresentationFile.importPptx(await FileBlob.load(R+'/review/review-01.pptx'));
await fs.mkdir(R+'/review/png',{recursive:true});
for(let i=0;i<p.slides.items.length;i++){
 const png=await p.export({slide:p.slides.items[i],format:'png',scale:1});
 await fs.writeFile(R+'/review/png/slide-'+String(i+1).padStart(3,'0')+'.png',new Uint8Array(await png.arrayBuffer()));
 if(i%20===0)console.log('Rendered '+(i+1));
}
