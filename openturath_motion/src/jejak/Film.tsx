import React from 'react';
import {AbsoluteFill, Audio, Easing, Img, interpolate, OffthreadVideo, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {ChatScreen, LibraryScreen, NoteReaderScreen} from '../film60/StudyUI';
import {DirectoryScreen} from '../film60/AppUI';

// Product views are cropped from the approved UI reconstruction; the physical
// visual world is an independently rendered Blender animation beneath them.
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
const DirectoryCrop:React.FC<{t:number}> = ({t}) => <div style={{...softBox,left:135,top:680,width:810,height:660,borderRadius:22,opacity:inOut(t,9.0,11.35),transform:`translateY(${35*(1-smooth(t,9,9.7))}px)`}}>
 <div style={{position:'absolute',left:-4,top:-454,width:420,height:820,transform:'scale(2.02)',transformOrigin:'top left'}}><DirectoryScreen field="fiqh"/></div>
</div>;
const ComposerCrop:React.FC<{t:number}> = ({t})=>{
 const typed=query.slice(0,Math.floor(range(t,11.6,13.9)*query.length));
 const sent=t>=14.05;
 return <div style={{...softBox,left:135,top:820,width:810,height:260,borderRadius:25,opacity:inOut(t,11.15,14.8),transform:`translateY(${26*(1-smooth(t,11.15,11.8))}px)`}}>
  <div style={{position:'absolute',left:0,top:0,right:0,fontFamily:'Outfit',fontSize:26,fontWeight:600,color:ink,padding:'24px 30px 0'}}>Contoh pertanyaan · Fikih Syafi’i</div>
  <div style={{position:'absolute',left:-5,top:-1400,width:420,height:820,transform:'scale(2.02)',transformOrigin:'top left'}}><ChatScreen typed={typed} answerProgress={0} sent={sent}/></div>
 </div>;
};

export const OpenTurathJejakIlmu:React.FC = () => {
 const frame=useCurrentFrame();const {fps}=useVideoConfig();const t=frame/fps;
 const final=inOut(t,25.1,30.6); const markP=smooth(t,25.1,26.25);
 return <AbsoluteFill style={{backgroundColor:'#F6F6F6',overflow:'hidden'}}>
  <OffthreadVideo src={staticFile('jejak/world.mp4')} muted style={{width:'100%',height:'100%',objectFit:'cover'}}/>
  <Audio src={staticFile('jejak/audio/master.wav')}/>
  <SceneTitle t={t} start={.55} end={3.8} text={'Setiap pertanyaan\nmembuka jalan.'}/>
  <SceneTitle t={t} start={4.4} end={8.85} text={'Menelusuri\nkhazanah ilmu.'}/>
  <SceneTitle t={t} start={9.1} end={11.25} text={'Pilih bidang ilmu.'} overline="OPENTURATH AI"/>
  <SceneTitle t={t} start={11.4} end={14.7} text={'Mulai dengan\npertanyaan.'} overline="OPENTURATH AI"/>
  <DirectoryCrop t={t}/><ComposerCrop t={t}/>
  <div style={{position:'absolute',left:145,right:145,top:1370,textAlign:'center',fontFamily:'Outfit, sans-serif',fontSize:21,color:'#52525B',opacity:inOut(t,9.1,14.75)}}>Visualisasi antarmuka · contoh pertanyaan</div>
  <SceneTitle t={t} start={14.9} end={18.8} text={'Baca penjelasan.\nTelusuri rujukan.'}/>
  <div style={{position:'absolute',left:100,right:100,top:510,color:'#52525B',fontFamily:'Outfit',fontSize:30,lineHeight:1.4,opacity:inOut(t,15.3,18.8)}}>Periksa pada kitab dan edisi yang digunakan.</div>
  <SceneTitle t={t} start={19.2} end={23.75} text={'Simpan untuk\ndipelajari kembali.'}/>
  <div style={{position:'absolute',left:0,right:0,top:0,bottom:0,background:'rgba(9,9,11,.58)',opacity:final}}/>
  <div style={{position:'absolute',left:0,right:0,top:540,textAlign:'center',opacity:final,transform:`translateY(${25*(1-markP)}px)`,color:'#FAFAFA'}}>
   <Img src={staticFile('promo/mark_white.svg')} style={{width:220,height:245,objectFit:'contain'}}/>
   <div style={{fontFamily:'Newsreader, serif',fontSize:102,letterSpacing:-3,marginTop:60}}>OpenTurath AI</div>
   <div style={{width:72,height:1,background:'#A1A1AA',margin:'42px auto'}}/>
   <div style={{fontFamily:'Outfit, sans-serif',fontSize:36,letterSpacing:.4}}>openturath.id ↗</div>
  </div>
 </AbsoluteFill>;
};

// Keep these approved screen components available for alternate source/notes
// inserts once the relevant content has been checked against the owning sources.
export const JejakReferenceComponents = {LibraryScreen, NoteReaderScreen};
