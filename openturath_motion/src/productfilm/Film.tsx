import React from 'react';
import {
  AbsoluteFill, Audio, Easing, Img, interpolate, staticFile,
  useCurrentFrame, useVideoConfig,
} from 'remotion';
import {DEMO, FIELDS, ASSISTANTS} from './content';
import {Icon} from '../film60/AppUI';

// A film made from live DOM layers, not screen captures. UI controls and states
// follow the Flutter source; choreography and enlarged crops are film-specific.
const C = {paper:'#F6F6F6', white:'#FFFFFF', ink:'#09090B', card:'#18181B',
  line:'#DADADA', gray:'#606060', wash:'#EDEDED', quiet:'#A1A1AA'};
const UI='Outfit, sans-serif', EDIT='Newsreader, serif', AR='Scheherazade, serif';
const clamp={extrapolateLeft:'clamp',extrapolateRight:'clamp'} as const;
const out=Easing.bezier(.16,1,.3,1), both=Easing.bezier(.65,0,.25,1);
const p=(t:number,a:number,b:number)=>interpolate(t,[a,b],[0,1],clamp);
const e=(t:number,a:number,b:number)=>interpolate(t,[a,b],[0,1],{...clamp,easing:out});
const m=(a:number,b:number,n:number)=>a+(b-a)*n;
const blend=(t:number,a:number,b:number)=>interpolate(t,[a,b],[0,1],{...clamp,easing:both});
const visible=(t:number,a:number,b:number)=>p(t,a,a+.22)*(1-p(t,b-.22,b));
const box:React.CSSProperties={position:'absolute',boxSizing:'border-box'};
const row:React.CSSProperties={display:'flex',alignItems:'center'};
const shadow='0 32px 85px rgba(9,9,11,.10), 0 2px 4px rgba(9,9,11,.035)';

function CopyIcon({size=30}:{size?:number}) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"><rect x="8" y="7" width="12" height="14" rx="2"/><path d="M16 7V5a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h2"/></svg>;
}
function Check({size=28}:{size?:number}) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="m5 12 4 4L19 6"/></svg>;
}
function Tap({t,at,x,y,dark=false}:{t:number;at:number;x:number;y:number;dark?:boolean}) {
  const a=p(t,at,at+.55); if(t<at||a>=1)return null;
  return <div style={{...box,left:x-58,top:y-58,width:116,height:116,borderRadius:'50%',border:`2px solid ${dark?'#fff':C.ink}`,background:dark?'rgba(255,255,255,.09)':'rgba(9,9,11,.04)',scale:.4+1.1*a,opacity:(1-a)*.6,pointerEvents:'none',zIndex:30}}/>;
}

function Headline({t,start,end,lines}:{t:number;start:number;end:number;lines:string[]}) {
  return <div style={{...box,left:94,top:244,right:80,color:C.ink,fontFamily:EDIT,fontSize:100,fontWeight:400,letterSpacing:-3.7,lineHeight:.99,opacity:1-p(t,end-.35,end),translate:`0 ${-22*p(t,end-.35,end)}px`}}>
    {lines.map((line,i)=><div key={line} style={{overflow:'hidden',paddingBottom:9}}><div style={{translate:`0 ${115*(1-e(t,start+i*.085,start+.7+i*.085))}%`}}>{line}</div></div>)}
  </div>;
}

function BrandHeader({t}:{t:number}) {
  return <div style={{...box,left:94,right:94,top:118,...row,justifyContent:'space-between',opacity:e(t,.05,.6)*(1-p(t,26.6,27.1)),color:C.ink}}>
    <div style={{...row,gap:15}}><Img src={staticFile('promo/mark_black.svg')} style={{width:36,height:48,objectFit:'contain'}}/><span style={{fontFamily:EDIT,fontSize:38,fontWeight:600,letterSpacing:-.7}}>OpenTurath AI</span></div>
    <div style={{fontSize:22,color:C.gray,letterSpacing:2}}>RUANG BELAJAR TURATS</div>
  </div>;
}

const FieldCards:React.FC<{t:number}>=({t})=>{
  const chosen=blend(t,2.8,3.6), end=p(t,4.75,5.25);
  return <>
    <div style={{...box,left:94,top:562,fontSize:32,fontWeight:600,opacity:1-end}}>Pilih bidang</div>
    {FIELDS.map(([label,ar],i)=>{
      const x=94+(i%2)*458, y=644+Math.floor(i/2)*276;
      const arrive=e(t,.15+i*.085,1.05+i*.085);
      const dx=i===0?m(x,94,chosen):x+(i%2?240:-240)*chosen;
      const dy=i===0?m(y,550,chosen):y+85*chosen;
      return <div key={label} style={{...box,left:dx,top:dy+120*(1-arrive),width:i===0?m(434,892,chosen):434,height:i===0?m(248,152,chosen):248,borderRadius:32,background:C.card,color:C.white,overflow:'hidden',opacity:arrive*(i===0?1-end:1-p(t,2.9+i*.035,3.45+i*.035)),scale:i===0?1-.018*Math.sin(p(t,2.72,3.04)*Math.PI):.92+.08*arrive,boxShadow:'0 12px 24px rgba(9,9,11,.04)'}}>
        <div style={{...box,left:30,right:24,top:m(36,35,i===0?chosen:0),fontSize:i===0?m(44,42,chosen):label.length>14?36:44,fontWeight:600,lineHeight:1.15,zIndex:2}}>{label}</div>
        <div dir="rtl" lang="ar" style={{...box,left:20,right:20,bottom:16,fontFamily:'FilmArabicUI, sans-serif',fontSize:Math.min(94,650/ar.length),lineHeight:1.25,textAlign:'center',opacity:.08,whiteSpace:'nowrap'}}>{ar}</div>
        {i===0&&<div style={{...box,right:34,top:49,opacity:chosen}}><Icon name="chevron" size={36}/></div>}
      </div>;
    })}
    <div style={{...box,left:94,right:94,top:1545,...row,justifyContent:'space-around',color:C.gray,opacity:e(t,1,1.5)*(1-p(t,2.8,3.35))}}>
      {(['Beranda','AI','Catatan','Pengaturan'] as const).map((label,i)=><div key={label} style={{...row,flexDirection:'column',gap:12,fontSize:26,color:i===0?C.ink:C.gray}}><div style={{background:i===0?C.wash:'transparent',borderRadius:40,padding:'10px 24px'}}><Icon name={(['home','ai','notes','settings'] as const)[i]} size={32}/></div>{label}</div>)}
    </div>
    <Tap t={t} at={2.74} x={311} y={765} dark/>
  </>;
};

function AssistantCards({t}:{t:number}) {
  const move=blend(t,4.75,5.75), leave=p(t,21.4,21.95);
  return <>
    {ASSISTANTS.map(([label,ar],i)=>{
      const arrival=e(t,3.25+i*.06,3.95+i*.06);
      const x=94+(i%2)*458, y=760+Math.floor(i/2)*276;
      const chosen=i===0;
      return <div key={label} style={{...box,left:chosen?m(x,94,move):x+(i%2?180:-180)*move,top:chosen?m(y,534,move):y+50*move,width:chosen?m(434,892,move):i===4?892:434,height:chosen?m(248,122,move):i===4?148:248,borderRadius:chosen?m(32,23,move):32,background:C.card,color:C.white,overflow:'hidden',opacity:arrival*(chosen?1-leave:1-p(t,4.8+i*.025,5.35+i*.025)),translate:`0 ${60*(1-arrival)}px`,zIndex:5}}>
        <div style={{...box,left:chosen?m(30,90,move):30,right:i===4?230:24,top:chosen?m(38,41,move):i===4?52:38,fontSize:chosen?m(39,36,move):i===4?34:39,fontWeight:600,lineHeight:1.15,zIndex:2}}>{label}</div>
        {chosen&&<div style={{...box,left:28,top:43,opacity:move}}><Icon name="back" size={30}/></div>}
        <div lang="ar" dir="rtl" style={{...box,left:20,right:20,bottom:16,fontFamily:'FilmArabicUI, sans-serif',fontSize:Math.min(94,650/ar.length),lineHeight:1.25,textAlign:'center',opacity:.08*(1-move),whiteSpace:'nowrap'}}>{ar}</div>
        <div style={{...box,right:28,top:43,...row,gap:24,opacity:move}}><Icon name="book" size={32}/><svg width="24" height="32" viewBox="0 0 24 32" fill="currentColor"><circle cx="12" cy="6" r="2"/><circle cx="12" cy="16" r="2"/><circle cx="12" cy="26" r="2"/></svg></div>
        <div style={{...box,left:i===4?undefined:30,right:i===4?30:undefined,bottom:i===4?45:30,...row,gap:20,opacity:1-move}}><div style={{background:C.white,color:C.card,borderRadius:32,padding:'12px 26px'}}><Icon name="chat" size={30}/></div><div style={{border:'1px solid #555',borderRadius:32,padding:12}}><Icon name="book" size={30}/></div></div>
      </div>;
    })}
    <div style={{...box,left:94,top:1485,fontSize:25,color:C.gray,opacity:visible(t,3.45,5.25)}}>Akses mengikuti akun</div>
    <Tap t={t} at={4.73} x={165} y={947} dark/>
  </>;
}

function Question({t}:{t:number}) {
  const sending=blend(t,8.0,8.85), leave=p(t,21.35,21.8);
  const typed=DEMO.question.slice(0,Math.floor(p(t,6.05,7.5)*DEMO.question.length));
  return <>
    <div style={{...box,left:m(116,246,sending),top:m(1070,708,sending),width:m(848,718,sending),height:m(240,174,sending),borderRadius:m(38,32,sending),background:C.wash,color:C.ink,padding:'32px 36px',opacity:e(t,5.65,6.1)*(1-leave),zIndex:7,boxShadow: sending<.95?'0 14px 30px rgba(9,9,11,.035)':'none'}}>
      <div style={{...box,left:36,right:m(122,36,sending),top:32,fontSize:m(43,37,sending),lineHeight:1.27,fontWeight:400}}>{typed}<span style={{display:t>7.6||t<6.05?'none':'inline-block',width:2,height:43,background:C.ink,marginLeft:4,verticalAlign:'middle',opacity:Math.floor(t*3)%2===0?1:.15}}/></div>
      <div style={{...box,right:22,bottom:22,width:74,height:74,borderRadius:'50%',background:C.card,color:C.white,display:'grid',placeItems:'center',opacity:1-p(t,8.0,8.35),scale:1-.14*Math.sin(p(t,7.97,8.24)*Math.PI)}}><Icon name="arrow" size={34}/></div>
    </div>
    <div style={{...box,left:118,top:978,fontSize:26,color:C.gray,opacity:visible(t,5.9,8.0),zIndex:6}}>Tanyakan sesuatu…</div>
    <Tap t={t} at={8.03} x={905} y={1251} dark/>
  </>;
}

function AnswerList({t,note=false}:{t:number;note?:boolean}) {
  const reveal=e(t,8.85,9.3), focus=blend(t,14.4,15.4);
  if(note)return <div>
    <div style={{fontSize:34,lineHeight:1.5,marginBottom:20}}>{DEMO.introduction}</div>
    {DEMO.items.map((text,i)=><div key={text} style={{...row,gap:20,minHeight:62,fontSize:34,lineHeight:1.3}}><span style={{fontSize:24,color:C.gray,width:32}}>{i+1}.</span>{text}</div>)}
  </div>;
  return <div style={{...box,left:116,right:116,top:932-360*focus,opacity:reveal*(1-p(t,14.5,15.15)),zIndex:6}}>
    <div style={{fontSize:46,fontWeight:600,letterSpacing:-.7,marginBottom:23,translate:`0 ${20*(1-reveal)}px`}}>{DEMO.title}</div>
    <div style={{fontSize:34,color:C.gray,marginBottom:16}}>{DEMO.introduction}</div>
    {DEMO.items.map((text,i)=>{
      const a=e(t,9.35+i*.14,9.9+i*.14);
      return <div key={text} style={{...row,gap:20,height:72,opacity:a,translate:`0 ${22*(1-a)}px`}}><span style={{display:'grid',placeItems:'center',width:37,height:37,borderRadius:'50%',border:`1px solid ${C.line}`,fontSize:22,color:C.gray}}>{i+1}</span><span style={{fontSize:36,lineHeight:1.25}}>{text}</span></div>;
    })}
  </div>;
}

function Source({t}:{t:number}) {
  const focus=blend(t,14.4,15.5), leave=blend(t,21.1,21.9);
  const a=e(t,10.6,11.2)*(1-leave);
  return <div style={{...box,left:116,top:m(1515,945,focus),width:848,height:m(75,466,focus),padding:m(20,38,focus),borderRadius:m(15,24,focus),background:C.white,border:`1px solid ${C.line}`,borderLeft:`${m(3,4,focus)}px solid #767676`,opacity:a,zIndex:7,overflow:'hidden',translate:`0 ${20*(1-e(t,10.6,11.2))}px`}}>
    <div style={{...row,justifyContent:'space-between',fontSize:m(28,32,focus),color:C.gray}}><span>Rujukan dalam jawaban</span><Icon name="book" size={m(26,32,focus)}/></div>
    <div dir="rtl" lang="ar" style={{...box,left:30,right:30,top:103,fontFamily:AR,fontSize:83,lineHeight:1.7,textAlign:'right',opacity:focus,translate:`0 ${25*(1-focus)}px`}}>{DEMO.excerpt}</div>
    <div style={{...box,left:38,right:38,top:278,opacity:focus}}><div style={{fontFamily:EDIT,fontSize:51,letterSpacing:-.8}}>{DEMO.book}</div><div style={{fontSize:31,color:C.gray,marginTop:17}}>{DEMO.section}</div></div>
  </div>;
}

function CopyAndSave({t}:{t:number}) {
  const copied=t>=19.55, saved=t>=20.65;
  const bar=e(t,19.65,20.02)*(1-p(t,21.2,21.55));
  return <>
    <div style={{...box,left:116,top:1475,...row,gap:15,padding:'16px 22px',border:`1px solid ${C.line}`,borderRadius:18,fontSize:29,color:C.gray,opacity:visible(t,15.5,21.3),background:copied?C.wash:C.white,scale:1-.025*Math.sin(p(t,19.5,19.75)*Math.PI),zIndex:8}}>{copied?<Check/>:<CopyIcon/>}<span>{copied?'Tersalin':'Salin jawaban'}</span></div>
    <div style={{...box,left:116,right:116,top:1577,height:105,borderRadius:20,background:C.card,color:C.white,...row,justifyContent:'space-between',padding:'0 28px',fontSize:31,opacity:bar,translate:`0 ${50*(1-bar)}px`,zIndex:12}}>
      <span>Jawaban disalin.</span>
      <span style={{fontWeight:600,padding:'14px 18px',borderRadius:12,background:saved?'#353535':'transparent'}}>Simpan</span>
    </div>
    <Tap t={t} at={19.53} x={287} y={1510}/>
    <Tap t={t} at={20.56} x={873} y={1630} dark/>
    <Tap t={t} at={21.36} x={136} y={594} dark/>
  </>;
}

function Conversation({t}:{t:number}) {
  const reveal=blend(t,4.8,5.65), leave=blend(t,21.4,22.05);
  return <>
    <div style={{...box,left:m(94,64,reveal),top:m(760,504,reveal),width:m(434,952,reveal),height:m(248,1200,reveal),borderRadius:m(32,45,reveal),background:C.white,border:`1px solid ${C.line}`,boxShadow:shadow,opacity:reveal*(1-leave),zIndex:1}}/>
    <Question t={t}/><AnswerList t={t}/><Source t={t}/><CopyAndSave t={t}/>
    <div style={{...box,left:116,top:905,...row,gap:10,fontSize:24,color:C.gray,opacity:visible(t,8.7,14.8),zIndex:6}}><div style={{width:7,height:7,borderRadius:'50%',background:C.gray}}/>Contoh jawaban · diringkas dari Safinatun Najah</div>
  </>;
}

function NotesJourney({t}:{t:number}) {
  const show=blend(t,21.65,22.2), open=blend(t,23.25,24.05), end=blend(t,26.3,27.15);
  const notes=e(t,22.12,22.5);
  const close=1-end;
  return <div style={{...box,left:64,top:504,width:952,height:1200,opacity:show*close,zIndex:10,translate:`${100*(1-show)}px ${-24*end}px`,scale:1-.04*end,transformOrigin:'center center'}}>
    <div style={{...box,inset:0,borderRadius:45,background:C.paper,border:`1px solid ${C.line}`,boxShadow:shadow,overflow:'hidden'}}>
      <div style={{...box,left:46,right:46,top:44,...row,gap:24,height:64}}>
        <div style={{opacity:open}}><Icon name="back" size={32}/></div><div style={{fontSize:t<22.12?36:42,fontWeight:600,translate:`${-56*(1-open)}px 0`}}>{t<22.12?'Halo, Penuntut Ilmu':'Catatan'}</div><div style={{marginLeft:'auto',opacity:open}}><CopyIcon size={32}/></div>
      </div>
      <div style={{...box,left:46,right:46,top:153,height:88,borderRadius:44,background:C.wash,...row,gap:20,padding:'0 25px',fontSize:31,color:C.gray,opacity:1-open}}><Icon name="search" size={31}/>{t<22.12?'Cari AI atau bidang keilmuan…':'Cari catatan…'}</div>
      <div style={{...box,left:46,right:46,top:285,opacity:1-notes}}><div style={{fontSize:32,fontWeight:600,marginBottom:28}}>Pilih bidang</div><div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:22}}>{FIELDS.slice(0,4).map(([title])=><div key={title} style={{height:186,borderRadius:25,background:C.card,color:C.white,padding:28,fontSize:36,fontWeight:600}}>{title}</div>)}</div></div>
      <div style={{...box,left:46,top:280,fontSize:25,color:C.gray,opacity:(1-open)*notes}}>TERSIMPAN</div>
      <div style={{...box,left:m(46,48,open),right:m(46,48,open),top:m(338,174,open),height:m(245,885,open),background:open>.98?'transparent':C.white,border:`1px solid rgba(218,218,218,${1-open})`,borderRadius:m(28,0,open),padding:m(32,0,open),overflow:'hidden',opacity:notes,translate:`0 ${24*(1-notes)}px`}}>
        <div style={{...row,gap:20,fontSize:24,color:C.gray}}><span style={{background:open>.98?'transparent':C.wash,padding:open>.98?0:'5px 12px',borderRadius:20}}>Fikih Syafi’i</span><span style={{opacity:1-open}}>·</span><span style={{opacity:1-open}}>3 Nov 2026</span></div>
        <div style={{fontFamily:open>.5?EDIT:UI,fontSize:m(40,60,open),lineHeight:1.15,marginTop:m(22,14,open),letterSpacing:-1,fontWeight:600}}>{DEMO.title}</div>
        <div style={{...box,top:143,fontSize:29,color:C.gray,opacity:open}}>Fikih Syafi’i</div>
        <div style={{fontSize:31,color:C.gray,marginTop:20,opacity:1-open,whiteSpace:'nowrap'}}>Fardu wudu ada enam: niat, membasuh wajah…</div>
        <div style={{...box,left:0,right:0,top:201,opacity:open,translate:`0 ${30*(1-open)}px`}}>
          <div style={{height:1,background:C.line,marginBottom:25}}/>
          <AnswerList t={t} note/>
          <div style={{marginTop:26,padding:'18px 24px',background:C.white,borderLeft:`3px solid ${C.gray}`}}>
            <div dir="rtl" lang="ar" style={{fontFamily:AR,fontSize:56,lineHeight:1.65,textAlign:'right'}}>{DEMO.excerpt}</div>
            <div style={{fontSize:29,color:C.gray,marginTop:4}}>{DEMO.book} · {DEMO.section}</div>
          </div>
        </div>
      </div>
      <div style={{...box,bottom:0,left:0,right:0,height:152,borderTop:`1px solid ${C.line}`,background:C.white,...row,justifyContent:'space-around',opacity:1-open}}>
        {(['Beranda','AI','Catatan','Pengaturan'] as const).map((label,i)=><div key={label} style={{...row,flexDirection:'column',gap:10,fontSize:25,color:i===(t<22.12?0:2)?C.ink:C.gray}}><div style={{padding:'10px 28px',borderRadius:40,background:i===(t<22.12?0:2)?C.wash:'transparent'}}><Icon name={(['home','ai','notes','settings'] as const)[i]} size={32}/></div>{label}</div>)}
      </div>
    </div>
    <Tap t={t} at={22.12} x={595} y={1127}/>
    <Tap t={t} at={23.3} x={470} y={450}/>
  </div>;
}

function Finale({t}:{t:number}) {
  const a=blend(t,26.3,27.25);
  const reveal=e(t,26.6,27.8);
  return <>
    {/* The final surface grows from the reading plane and closes the task. */}
    <div style={{...box,left:m(64,-80,a),top:m(504,-80,a),width:m(952,1240,a),height:m(1200,2080,a),borderRadius:m(45,0,a),background:C.ink,opacity:a,zIndex:15}}/>
    <div style={{...box,left:94,right:94,top:520,color:C.white,textAlign:'center',zIndex:16,opacity:reveal,translate:`0 ${32*(1-reveal)}px`}}>
      <Img src={staticFile('promo/mark_white.svg')} style={{width:134,height:178,objectFit:'contain',opacity:e(t,26.75,27.7),scale:.9+.1*reveal}}/>
      <div style={{fontFamily:EDIT,fontSize:99,fontWeight:400,letterSpacing:-3.1,marginTop:54}}>OpenTurath AI</div>
      <div style={{fontFamily:EDIT,fontSize:67,lineHeight:1.1,letterSpacing:-1.6,marginTop:48,overflow:'hidden'}}><div style={{translate:`0 ${110*(1-e(t,27.2,28.0))}%`}}>Lebih dekat dengan ilmu.</div></div>
      <div style={{height:1,width:80,background:'#52525B',margin:'56px auto 41px',scale:`${e(t,27.5,28.3)} 1`}}/>
      <div style={{fontSize:36,...row,justifyContent:'center',gap:16,opacity:e(t,27.6,28.25)}}>openturath.id<Icon name="arrow" size={30}/></div>
    </div>
    <div style={{...box,left:94,right:94,bottom:170,fontSize:24,textAlign:'center',color:'#A1A1AA',zIndex:17,opacity:e(t,28,28.6)}}>Fikih · Hadis · Tafsir · Akidah · Usul Fikih · Bahasa Arab</div>
  </>;
}

export const OpenTurathProductFilm:React.FC<{silent?:boolean}>=({silent=false})=>{
  const f=useCurrentFrame(), {fps}=useVideoConfig(), t=f/fps;
  return <AbsoluteFill style={{background:C.paper,color:C.ink,fontFamily:UI,overflow:'hidden'}}>
    {!silent&&<Audio src={staticFile('productfilm/audio/master.wav')}/>}
    <BrandHeader t={t}/>
    {t<3.15&&<Headline t={t} start={.06} end={3.15} lines={['Ilmu, berawal','dari bertanya.']}/>}
    {t>=2.95&&t<5.5&&<Headline t={t} start={3.04} end={5.5} lines={['Pilih bidangmu.']}/>}
    {t>=5.25&&t<9.25&&<Headline t={t} start={5.35} end={9.25} lines={['Tanyakan.']}/>}
    {t>=9.05&&t<14.85&&<Headline t={t} start={9.08} end={14.85} lines={['Pahami','jawabannya.']}/>}
    {t>=14.65&&t<19.8&&<Headline t={t} start={14.72} end={19.8} lines={['Baca dengan','rujukan.']}/>}
    {t>=19.6&&t<23.5&&<Headline t={t} start={19.68} end={23.5} lines={['Simpan untuk','dipelajari lagi.']}/>}
    {t>=23.3&&t<26.8&&<Headline t={t} start={23.38} end={26.8} lines={['Ilmunya','tetap bersama.']}/>}
    <Conversation t={t}/>
    <FieldCards t={t}/><AssistantCards t={t}/>
    <NotesJourney t={t}/>
    <div style={{...box,left:94,right:94,bottom:122,fontSize:25,color:C.gray,opacity:visible(t,5.7,26.6),textAlign:'center',zIndex:13}}>{DEMO.qualifier}</div>
    <Finale t={t}/>
  </AbsoluteFill>;
};
