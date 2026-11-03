import React from 'react';
import {AbsoluteFill, Audio, Easing, Img, interpolate, OffthreadVideo, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {ChatScreen, LibraryScreen, NoteReaderScreen} from '../film60/StudyUI';
import {DirectoryScreen} from '../film60/AppUI';
import {JejakWorld3D} from './World';

// Product views are cropped from the approved UI reconstruction; the physical
// visual world may be an independently rendered Blender video or a live ThreeCanvas.
const clamp = {extrapolateLeft:'clamp',extrapolateRight:'clamp'} as const;
const range=(t:number,a:number,b:number)=>interpolate(t,[a,b],[0,1],clamp);
const inOut=(t:number,a:number,b:number)=>Math.min(range(t,a,a+.55),1-range(t,b-.55,b));
const smooth=(t:number,a:number,b:number)=>interpolate(t,[a,b],[0,1],{...clamp,easing:Easing.bezier(.22,1,.36,1)});
const query="Apa rukun wudu menurut pendapat mu'tamad dalam mazhab Syafi'i?";
const ink='#18181B';
const heading:React.CSSProperties={position:'absolute',left:94,right:94,top:185,color:ink,fontFamily:'Newsreader, serif',fontSize:84,lineHeight:1.05,letterSpacing:-2.3,fontWeight:400,whiteSpace:'pre-line'};
const softBox:React.CSSProperties={position:'absolute',background:'#F6F6F6',overflow:'hidden',boxShadow:'0 22px 65px rgba(0,0,0,.12), 0 2px 3px rgba(0,0,0,.06)',border:'1px solid rgba(24,24,27,.12)'};

const SceneTitle:React.FC<{t:number; start:number;end:number; text:string; overline?:string}> = ({t,start,end,text,overline})=> {
 const p=smooth(t,start,start+.9);
 return <div style={{...heading,opacity:inOut(t,start,end),transform:`translateY(${22*(1-p)}px)`}}>{overline && <div style={{fontFamily:'Outfit, sans-serif',fontSize:23,letterSpacing:3.2,fontWeight:600,marginBottom:24}}>{overline}</div>}{text}</div>;
};

// These two windows expose only the real UI controls relevant to this moment,
// not an invented phone shell or a synthetic AI answer.
const DirectoryCrop:React.FC<{t:number}> = ({t}) => <div style={{...softBox,left:135,top:640,width:810,height:850,borderRadius:22,opacity:inOut(t,9.0,11.35),transform:`translateY(${35*(1-smooth(t,9,9.7))}px)`}}>
 <div style={{position:'absolute',left:-4,top:-454,width:420,height:820,transform:'scale(2.02)',transformOrigin:'top left'}}><DirectoryScreen field="fiqh"/></div>
</div>;
const ComposerCrop:React.FC<{t:number}> = ({t})=>{
 const typed=query.slice(0,Math.floor(range(t,11.6,12.95)*query.length));
 const sent=t>=14.65;
 return <div style={{...softBox,left:135,top:820,width:810,height:260,borderRadius:25,opacity:inOut(t,11.15,14.8),transform:`translateY(${26*(1-smooth(t,11.15,11.8))}px)`}}>
  <div style={{position:'absolute',left:0,top:0,right:0,fontFamily:'Outfit',fontSize:26,fontWeight:600,color:ink,padding:'24px 30px 0',zIndex:2}}>Contoh pertanyaan · Fikih Syafi’i</div>
  <div style={{position:'absolute',left:-5,top:-1400,width:420,height:820,transform:'scale(2.02)',transformOrigin:'top left'}}><ChatScreen typed={typed} answerProgress={0} sent={sent}/></div>
 </div>;
};

export const OpenTurathJejakIlmu:React.FC<{worldRenderer?:'video'|'three'}> = ({worldRenderer='three'}) => {
 const frame=useCurrentFrame();const {fps}=useVideoConfig();const t=frame/fps;
 const final=inOut(t,25.1,30.6); const markP=smooth(t,25.1,26.25);
 return <AbsoluteFill style={{backgroundColor:'#F6F6F6',overflow:'hidden'}}>
  {worldRenderer==='three' ? <JejakWorld3D/> : <OffthreadVideo src={staticFile('jejak/world.mp4')} muted style={{width:'100%',height:'100%',objectFit:'cover'}}/>}
  <Audio src={staticFile('jejak/audio/master.wav')}/>
  <div style={{position:'absolute',left:96,bottom:250,width:600,fontFamily:'Newsreader, serif',fontSize:62,lineHeight:1.12,letterSpacing:-1.5,color:ink,opacity:inOut(t,.7,3.8),transform:`translateY(${16*(1-smooth(t,.7,1.6))}px)`}}>Setiap pertanyaan<br/>membuka jalan.</div>
  {/* Sparse labels belong to the 3D space; the arch and paper remain visible. */}
  {[{text:'Fikih',x:145,y:750,a:5.0,b:7.8},{text:'Hadis',x:702,y:990,a:5.65,b:8.3},{text:'Tafsir',x:310,y:1250,a:6.25,b:8.6}].map(({text,x,y,a,b})=><div key={text} style={{position:'absolute',left:x,top:y,fontFamily:'Outfit, sans-serif',fontSize:27,letterSpacing:1,color:'#3F3F46',opacity:inOut(t,a,b)*.8,transform:`translateY(${12*(1-smooth(t,a,a+.7))}px)`}}>{text}</div>)}
  <SceneTitle t={t} start={9.1} end={11.25} text={'Pilih asisten AI.'} overline="OPENTURATH AI"/>
  <SceneTitle t={t} start={11.4} end={14.7} text={'Mulai dengan\npertanyaan.'} overline="OPENTURATH AI"/>
  <DirectoryCrop t={t}/><ComposerCrop t={t}/>
  <div style={{...heading,top:1080,left:135,right:105,opacity:inOut(t,14.9,18.8),transform:`translateY(${22*(1-smooth(t,14.9,15.8))}px)`}}>Baca penjelasan.<br/>Telusuri rujukan.</div>
  <div style={{position:'absolute',left:140,right:120,top:1315,color:'#52525B',fontFamily:'Outfit',fontSize:27,lineHeight:1.4,opacity:inOut(t,15.3,18.8)}}>Periksa pada kitab dan edisi yang digunakan.</div>
  <div style={{position:'absolute',left:100,top:150,color:ink,fontFamily:'Newsreader, serif',fontSize:76,lineHeight:1.08,letterSpacing:-2,opacity:inOut(t,19.2,23.75)}}>Catat.<br/>Pelajari kembali.</div>
  {/* An illustrative saved note, based on the approved note-card geometry. */}
  <div style={{position:'absolute',left:210,top:1040,width:660,boxSizing:'border-box',padding:'30px 34px',border:'1px solid #DADADA',borderRadius:24,background:'#fff',boxShadow:'0 22px 65px rgba(0,0,0,.12)',fontFamily:'Outfit, sans-serif',color:ink,opacity:inOut(t,20.05,23.3),transform:`translateY(${30*(1-smooth(t,20.05,20.9))}px) rotate(${1.5*(1-smooth(t,20.05,20.9))}deg)`}}><div style={{fontSize:20,color:'#71717A'}}>Contoh catatan · Fikih Syafi’i</div><div style={{fontSize:30,fontWeight:600,marginTop:13}}>Pertanyaan tentang rukun wudu</div></div>
  <div style={{position:'absolute',left:0,right:0,top:210,textAlign:'center',opacity:final,transform:`translateY(${25*(1-markP)}px)`,color:'#FAFAFA'}}>
   <Img src={staticFile('promo/mark_white.svg')} style={{width:180,height:200,objectFit:'contain'}}/>
   <div style={{fontFamily:'Newsreader, serif',fontSize:94,letterSpacing:-2.7,marginTop:40}}>OpenTurath AI</div>
   <div style={{width:72,height:1,background:'#A1A1AA',margin:'28px auto'}}/>
   <div style={{fontFamily:'Outfit, sans-serif',fontSize:32,letterSpacing:.4}}>openturath.id ↗</div>
  </div>
  <div style={{position:'absolute',left:80,right:80,bottom:88,textAlign:'center',fontFamily:'Outfit, sans-serif',fontSize:20,lineHeight:1.45,color:'#A1A1AA',opacity:inOut(t,27.0,30.7)}}>Reawakening — Scott Buckley<br/>CC BY 4.0 · scottbuckley.com.au</div>
 </AbsoluteFill>;
};

// Keep these approved screen components available for alternate source/notes
// inserts once the relevant content has been checked against the owning sources.
export const JejakReferenceComponents = {LibraryScreen, NoteReaderScreen};
