import React from 'react';
import {AbsoluteFill, Audio, Img, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {loadFont} from '@remotion/fonts';
import {chan, clamp, mix, step} from '../promo/pegas';
import {DashboardScreen, DirectoryScreen, TahawwulatScreen, NotesScreen, U} from '../film60/AppUI';
import {ChatScreen, LibraryScreen, NoteReaderScreen} from '../film60/StudyUI';
import {AssistantTile, CatalogRow, NoteCard, QuoteCard, RoleSheet} from './SharedUI';

loadFont({family:'Scheherazade New',url:staticFile('fonts/NativeArabic.ttf'),weight:'400'});
loadFont({family:'FilmArabicUI',url:staticFile('film60/Cairo-700.ttf'),weight:'700'});
const A:React.CSSProperties={position:'absolute'};
const k=(t:number,v:number,keys:[number,number][],w=17,z=.92)=>chan(t,v,keys.map(([at,to])=>({t:at,v:to,w,z})));
const s=(t:number,at:number,w=19,z=1)=>step(t-at,w,z);
const p=(t:number,a:number,b:number)=>clamp((t-a)/(b-a));
const win=(t:number,a:number,b:number)=>clamp(s(t,a,27)*(1-s(t,b,28)));
const smooth=(x:number)=>x*x*(3-2*x);
const Q='Bagaimana hukum bersentuhan kulit dengan non-mahram terhadap wudhu?';
const fields=[['Hadits','الحديث'],['Tafsir','التفسير'],['Akidah','العقيدة'],['Ushul & Kaidah Fikih','أصول الفقه'],['Bahasa Arab','علوم العربية'],['Sejarah & Sirah','التاريخ'],['Tasawuf','التصوف'],['Bibliografi Kitab','الفهارس']];
const captions:[number,number,string][]=[
 [2.1,3.65,'Ruang belajar\nkitab.'],[3.85,7.3,'Bidang demi\nbidang.'],[7.55,10.65,'Lima cara\nmendalami.'],
 [11.35,13.35,'Mulai dengan\npertanyaan.'],[13.6,16.9,'Ibarahnya.\nRujukannya.'],[17.45,20.4,'Dekat dengan\nsumbernya.'],
 [20.85,24.4,'Terhubung.\nTersimpan.']
];
const Headline:React.FC<{t:number;start:number;end:number;text:string;dark:number}>=({t,start,end,text,dark})=><div style={{...A,left:86,right:86,top:112,color:dark>.5?'#FAFAFA':U.ink,fontFamily:'Newsreader',fontSize:94,fontWeight:400,lineHeight:.96,letterSpacing:-3,zIndex:50,opacity:1-s(t,end,27)}}>{text.split('\n').map((line,i)=><div key={line} style={{overflow:'hidden',paddingBottom:5}}><div style={{opacity:s(t,start+i*.075,24),transform:`translateY(${105*(1-s(t,start+i*.075,18))}%) rotate(${(1-s(t,start+i*.075,18))*3}deg)`,transformOrigin:'left bottom'}}>{line}</div></div>)}</div>;
const NativeRoute:React.FC<{t:number;a:number;b:number;children:React.ReactNode}>=({t,a,b,children})=>{
 const enter=s(t,a,24),leave=s(t,b,26);
 return <div style={{...A,inset:0,opacity:clamp(enter*(1-leave)),transform:`translateX(${420*(1-enter)-55*leave}px)`,overflow:'hidden'}}>{children}</div>;
};
const Logo:React.FC<{t:number;ending?:boolean}>=({t,ending=false})=>{
 const u=ending?t-25.3:t;
 return <div style={{...A,left:'50%',top:'50%',width:1024,height:1024,transform:`translate(-50%,-50%) scale(${ending?.73:.79})`}}>{['arch','dome','left','right'].map((part,i)=>{
 const q=s(u,.08+i*.19,11,.82),x=[-145,30,-150,150][i]*(1-q),y=[-180,-150,150,150][i]*(1-q);
 return <Img key={part} src={staticFile(`film60/logo_${part}.svg`)} style={{...A,inset:0,width:1024,height:1024,opacity:clamp(q),filter:`${ending?'brightness(0) invert(1)':'brightness(0)'} blur(${Math.min(3,Math.abs(1-q)*3)}px)`,transform:`translate(${x}px,${y}px) rotate(${[15,-15,-25,25][i]*(1-q)}deg)`}}/>;
 })}</div>;
};

export const OpenTurathLaunch30:React.FC=()=>{
 const frame=useCurrentFrame(),{fps}=useVideoConfig(),t=frame/fps;
 const dark=clamp(k(t,0,[[7.45,1],[10.8,0],[25.1,1]],12));
 const grey=Math.round(mix(246,9,dark));
 const fan=win(t,4.02,7.3);
 const quote=win(t,14.4,16.58),book=win(t,19,20.13),note=win(t,23.15,23.95);
 const focusBlur=(quote+book+note)*.9;
 const scale=k(t,.14,[[1.75,.22],[2.15,1.68],[3.8,1.5],[4.15,1.13],[6.9,1.13],[7.4,1.68],[8.0,1.70],[10.9,1.7],[11.7,1.72],[13.4,1.70],[14.5,1.57],[16.6,1.70],[17.3,1.70],[19,1.6],[20.3,1.7],[20.8,1.7],[22.9,1.7],[23.65,1.68]],14);
 const px=k(t,540,[[3.8,540],[4.4,540],[7.4,540],[13.4,542],[16.6,540],[19,525],[20.3,540],[23.65,540]],10);
 const py=k(t,880,[[2.15,1040],[3.8,1040],[4.15,1060],[7.4,1040],[13.4,1040],[14.5,1040],[16.6,1040],[17.3,1040],[20.8,1040],[23.65,1040]],12);
 const tilt=k(t,0,[[2.15,-2],[3.8,1],[4.15,0],[6.9,-1],[7.4,0],[11.7,-1],[13.4,0],[17.3,1],[20.8,-1],[22.9,0],[23.65,0]],13);
 const ry=k(t,-20,[[2.15,-4],[3.8,0],[4.15,0],[6.9,0],[7.4,0],[11.7,0],[17.3,-3],[20.8,2],[22.9,0],[23.65,0]],13);
 const planeOpacity=win(t,1.75,24.56);
 const directoryScroll=k(t,0,[[4.1,280],[4.8,590],[5.55,930],[6.2,1290],[6.75,1660]],11);
 const modal=clamp(s(t,8,16)*(1-s(t,10.6,23)));
 const role=t>=8.25&&t<10.5?Math.min(4,Math.floor((t-8.25)/.45)):-1;
 const typed=Q.slice(0,Math.floor(p(t,12,13)*Q.length));
 const answer=p(t,13.5,14.4);
 const transcriptScroll=k(t,0,[[14.1,90],[14.7,170],[16.3,160]],10);
 const libraryScroll=k(t,0,[[17.7,45],[18.2,100],[18.8,150],[19.9,200]],10);
 const clickTimes=[3.6,7.8,10.6,11.4,13.2,17,20.5,21.3,22,22.6,22.9,23.7];
 const cursorX=k(t,210,[[3.45,157],[7.7,174],[10.5,210],[11.3,110],[13.1,384],[16.9,355],[20.4,26],[21.2,175],[21.9,64],[22.5,26],[22.85,265],[23.6,200]],21);
 const cursorY=k(t,890,[[3.45,788],[7.7,240],[10.5,76],[11.3,357],[13.1,786],[16.9,33],[20.4,31],[21.2,85],[21.9,85],[22.5,31],[22.85,788],[23.6,242]],21);
 const cursorV=clickTimes.reduce((v,a)=>Math.max(v,win(t,a-.13,a+.16)),0);
 const press=clickTimes.reduce((v,a)=>Math.max(v,Math.sin(p(t,a,a+.17)*Math.PI)),0);
 const qp=smooth(p(t,14.4,14.95))*(1-smooth(p(t,16.4,16.65)));
 const bp=smooth(p(t,19,19.4))*(1-smooth(p(t,20.1,20.35)));
 const np=smooth(p(t,23.15,23.48))*(1-smooth(p(t,23.72,24.02)));
 return <AbsoluteFill style={{backgroundColor:`rgb(${grey},${grey},${grey})`,fontFamily:U.fontOutfit,overflow:'hidden',color:U.ink}}>
  <Audio src={staticFile('film30/soundtrack.wav')}/>
  {/* Stable editorial registration leaves room for the shared-element choreography. */}
  <div style={{...A,left:64,right:64,top:72,bottom:68,borderLeft:`1px solid ${dark>.5?'#ffffff0a':'#00000008'}`,borderRight:`1px solid ${dark>.5?'#ffffff0a':'#00000008'}`}}/>
  <div style={{...A,left:87,top:54,fontSize:20,letterSpacing:2.2,opacity:win(t,2,24.4)*.46,color:dark>.5?'#FAFAFA':U.ink}}>OPENTURATH AI</div>
  <div style={{...A,left:0,right:0,top:95,height:1050,opacity:1-s(t,1.85,25),transform:`translateY(${-100*s(t,1.8,18)}px) scale(${1-.22*s(t,1.8,18)})`}}><Logo t={t}/></div>
  <div style={{...A,left:70,right:70,top:1170,fontFamily:'Newsreader',fontSize:91,letterSpacing:-3,textAlign:'center',opacity:win(t,.9,1.95)}}>OpenTurath AI</div>
  {captions.map(([a,b,text])=><Headline key={a} t={t} start={a} end={b} text={text} dark={dark}/>)}
  {/* Native InkCards travel on staggered curved paths, then return to one viewport. */}
  {fields.map(([title,arabic],i)=>{
   const enter=s(t,4.05+i*.065,16,.88),exit=s(t,7.14+i*.012,21,.95);
   const amount=clamp(enter*(1-exit));const row=Math.floor(i/2),side=i%2?1:-1;
   const targetX=side<0?181:899,targetY=590+row*292;
   const originX=540+side*85,originY=1000+row*30;
   const x=mix(originX,targetX,amount),y=mix(originY,targetY,amount)+Math.sin(t*1.2+i)*4*amount;
   return <div key={title} style={{...A,left:x,top:y,width:180,height:160,zIndex:i%3,opacity:fan*clamp(enter*2)*(1-exit),transform:`translate(-50%,-50%) perspective(1300px) rotateY(${side*-9*amount}deg) rotateZ(${side*(3+row*.5)*amount}deg) scale(${mix(.6,1.37,amount)})`,filter:`blur(${Math.abs(1-amount)*.8}px)`,boxShadow:'0 19px 42px #00000020',borderRadius:24}}><AssistantTile title={title} arabic={arabic}/></div>;
  })}
  <div style={{...A,left:px,top:py,width:420,height:820,transform:`translate(-50%,-50%) perspective(1600px) rotateY(${ry}deg) rotateZ(${tilt}deg) scale(${scale})`,transformOrigin:'center',borderRadius:27,background:U.paper,boxShadow:'0 0 0 1px #ffffff70,0 0 0 6px #171717,0 25px 80px #00000029',overflow:'hidden',zIndex:10,opacity:planeOpacity,filter:`blur(${focusBlur}px)`}}>
   <NativeRoute t={t} a={1.8} b={3.9}><DashboardScreen scrollY={k(t,0,[[2.6,60],[3.3,160]],10)}/></NativeRoute>
   <NativeRoute t={t} a={3.8} b={7.55}><DirectoryScreen scrollY={directoryScroll}/></NativeRoute>
   <NativeRoute t={t} a={7.4} b={10.95}><TahawwulatScreen/></NativeRoute>
   <div style={{...A,inset:0,opacity:win(t,7.95,10.82)}}><RoleSheet progress={modal} focus={role} stagger={Math.max(0,t-8.02)}/></div>
   <NativeRoute t={t} a={10.9} b={11.85}><DirectoryScreen field="fiqh"/></NativeRoute>
   <NativeRoute t={t} a={11.7} b={17.45}><ChatScreen typed={typed} sent={t>=13.2} answerProgress={answer} scrollY={transcriptScroll}/></NativeRoute>
   <NativeRoute t={t} a={17.3} b={20.65}><LibraryScreen scrollY={libraryScroll}/></NativeRoute>
   <NativeRoute t={t} a={20.5} b={22.72}><ChatScreen typed={Q} sent answerProgress={1} tabbed activeTab={t>=21.3&&t<22?1:0} scrollY={t>=21.3&&t<22?0:120}/></NativeRoute>
   <NativeRoute t={t} a={22.6} b={23.05}><DashboardScreen/></NativeRoute>
   <NativeRoute t={t} a={22.9} b={23.85}><NotesScreen saved/></NativeRoute>
   <NativeRoute t={t} a={23.7} b={24.7}><NoteReaderScreen/></NativeRoute>
   <div style={{...A,inset:0,background:'#F6F6F6',opacity:Math.max(quote*.3,book*.22,note*.15),pointerEvents:'none'}}/>
   {/* Pointer contacts remain on the app controls; graphic layers are not new UI. */}
   <div style={{...A,left:cursorX,top:cursorY,opacity:cursorV,transform:`scale(${1-press*.14})`,zIndex:40}}><svg width="18" height="23" viewBox="0 0 28 36" style={{filter:'drop-shadow(1px 2px 2px #0005)'}}><path d="M2 2v29l7-7 5 10 5-3-5-10h11z" fill="#fff" stroke="#171717" strokeWidth="2.2" strokeLinejoin="round"/></svg></div>
   {clickTimes.map(at=>{const q=p(t,at,at+.33);return q>0&&q<1?<div key={at} style={{...A,left:cursorX,top:cursorY,width:7+q*44,height:7+q*44,transform:'translate(-50%,-50%)',border:'1px solid #606060',borderRadius:'50%',opacity:(1-q)*.4,zIndex:40}}/>:null;})}
  </div>
  {/* The actual ibarah and its locator stay intact as the paper panel is magnified. */}
  <div style={{...A,left:mix(540,540,qp),top:mix(1015,1050,qp),width:360,zIndex:22,opacity:quote,transform:`translate(-50%,-50%) perspective(1400px) rotateY(${mix(-4,0,qp)}deg) rotateZ(${mix(-1,0,qp)}deg) scale(${mix(1.70,2.28,qp)})`,boxShadow:`0 ${10+qp*18}px ${30+qp*30}px #00000025`,borderRadius:'0 10px 10px 0'}}><QuoteCard/></div>
  <svg width="1080" height="1920" style={{...A,inset:0,pointerEvents:'none',opacity:win(t,16.4,17.3),zIndex:23}}><path d="M930 1100C1000 1100 1000 410 790 398" pathLength={1} stroke="#A1A1AA" strokeWidth="2" fill="none" strokeDasharray={1} strokeDashoffset={1-smooth(p(t,16.4,17.05))}/></svg>
  {/* A real catalog row, not an invented book cover, becomes the next shared surface. */}
  <div style={{...A,left:mix(540,540,bp),top:mix(1010,1060,bp),width:384,height:116,zIndex:22,opacity:book,transform:`translate(-50%,-50%) perspective(1400px) rotateY(${mix(-3,0,bp)}deg) rotateZ(${mix(1,0,bp)}deg) scale(${mix(1.70,2.22,bp)})`,boxShadow:`0 ${12+bp*16}px ${36+bp*24}px #00000022`,borderRadius:12,overflow:'hidden'}}><CatalogRow/><div style={{...A,right:12,top:39,height:1,width:80,background:'#171717',transform:`scaleX(${smooth(p(t,19.12,19.55))})`,transformOrigin:'right'}}/></div>
  {/* The saved item expands toward the real note reader, preserving its title. */}
  <div style={{...A,left:540,top:mix(755,820,np),width:380,height:110,zIndex:24,opacity:note,transform:`translate(-50%,-50%) rotate(${mix(0,-1,np)}deg) scale(${mix(1.70,2.04,np)})`,boxShadow:`0 ${14+np*12}px ${40+np*14}px #00000020`,borderRadius:20}}><NoteCard/></div>
  {/* Four real viewport quadrants fold along their edges into the four-part mark. */}
  {[0,1,2,3].map(i=>{
   const col=i%2,row=Math.floor(i/2),delay=i*.055,q=smooth(p(t,24.5+delay,25.7+delay));
   const x=mix(540+(col?105:-105)*1.68,540+(col?38:-38),q),y=mix(1040+(row?205:-205)*1.68,775+(row?45:-45),q);
   return <div key={i} style={{...A,left:x,top:y,width:210,height:410,overflow:'hidden',background:U.paper,border:'1px solid #DADADA',borderRadius:row||col?4:'24px 4px 4px 4px',transform:`translate(-50%,-50%) perspective(1100px) rotateY(${(col?1:-1)*q*88}deg) rotateX(${(row?-1:1)*q*12}deg) rotateZ(${(i-1.5)*q*8}deg) scale(${mix(1.68,.65,q)})`,opacity:win(t,24.49+delay,25.82)*(1-q*.85),zIndex:25+i,boxShadow:'0 16px 40px #00000020'}}><div style={{...A,left:-col*210,top:-row*410,width:420,height:820}}><NoteReaderScreen/></div></div>;
  })}
  <div style={{...A,left:0,right:0,top:150,height:1000,opacity:win(t,25.48,40),transform:`translateY(${60*(1-s(t,25.5,13))}px)`,zIndex:35}}><Logo t={t} ending/></div>
  <div style={{...A,left:70,right:70,top:1115,textAlign:'center',color:'#FAFAFA',opacity:win(t,26.5,40),transform:`translateY(${40*(1-s(t,26.5,17))}px)`,zIndex:36}}><div style={{fontFamily:'Newsreader',fontSize:96,letterSpacing:-3}}>OpenTurath AI</div><div style={{height:1,width:72,background:'#71717A',margin:'45px auto'}}/><div style={{fontSize:38}}>openturath.id <span style={{marginLeft:18}}>↗</span></div></div>
  <div style={{...A,left:87,right:87,bottom:108,textAlign:'center',fontSize:21,color:dark>.5?'#B8B8B8':'#777',opacity:win(t,2,24.35),zIndex:45}}>Visualisasi antarmuka · contoh percakapan</div>
 </AbsoluteFill>;
};
