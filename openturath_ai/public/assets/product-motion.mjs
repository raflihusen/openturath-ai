// V6: progressive entrances, native scroll narrative, and interruptible motion.
export function initProductMotion() {
 const root=document.documentElement;
 const reduced=matchMedia('(prefers-reduced-motion: reduce)');
 const fine=matchMedia('(hover: hover) and (pointer: fine)');
 const art=document.querySelector('[data-hero-art]');
 const hero=document.querySelector('.scholar-hero');
 const story=document.querySelector('[data-method-story]');
 const sheet=story?.querySelector('.method-sheet');
 const steps=[...document.querySelectorAll('[data-method-step]')];
 const archive=document.querySelector('.manuscript-card');
 const adab=document.querySelector('.adab-calligraphy');
 const member=document.querySelector('.membership-banner');
 const animations=new Set();
 const animatedCards=new WeakSet();
 let manual=false,frame=0,observer,stage=-1,pointer={x:0,y:0},current={x:0,y:0};
 try{manual=localStorage.getItem('ot_motion')==='reduce';}catch{}
 const quiet=()=>reduced.matches||manual;
 const clamp=(v,min,max)=>Math.min(max,Math.max(min,v));
 const animate=(element,keyframes,options)=>{
  if(quiet()||!element?.animate)return;
  const animation=element.animate(keyframes,options);animations.add(animation);
  animation.finished.catch(()=>{}).finally(()=>animations.delete(animation));
  return animation;
 };
 const resetVariables=()=>{
  for(const [el,keys] of [[art,['--book-x','--book-y','--book-scale','--calligraphy-x','--calligraphy-y']],[archive,['--archive-y','--archive-rotate']],[adab,['--adab-y']],[member,['--membership-y']]])
   for(const key of keys)el?.style.removeProperty(key);
 };
 const setStage=n=>{
  if(n===stage||!sheet)return;stage=n;sheet.dataset.stage=String(n);
  sheet.style.setProperty('--method-progress',String((n+1)/4));
  sheet.querySelector('.method-counter').textContent=`0${n+1} / 04`;
  steps.forEach((s,i)=>s.classList.toggle('is-current',i===n));
 };
 const update=()=>{
  frame=0;if(quiet()||document.hidden)return;
  const height=innerHeight;
  if(hero&&art){
   const rect=hero.getBoundingClientRect();
   if(rect.bottom>0&&rect.top<height){
    current.x+=(pointer.x-current.x)*.12;current.y+=(pointer.y-current.y)*.12;
    const progress=clamp(-rect.top/rect.height,0,1);
    art.style.setProperty('--book-x',`${current.x*11}px`);
    art.style.setProperty('--book-y',`${current.y*7+progress*32}px`);
    art.style.setProperty('--book-scale',String(1+progress*.13));
    art.style.setProperty('--calligraphy-x',`${-current.x*24}px`);
    art.style.setProperty('--calligraphy-y',`${-current.y*12-progress*100}px`);
    if(Math.abs(pointer.x-current.x)+Math.abs(pointer.y-current.y)>.01)schedule();
   }
  }
  if(story){
   const rect=story.getBoundingClientRect();
   if(rect.bottom>0&&rect.top<height){
    const anchor=height*.3;
    let nearest=0;
    steps.forEach((s,i)=>{if(s.getBoundingClientRect().top<=anchor)nearest=i;});
    setStage(nearest);
   }
  }
  for(const [el,key,range] of [[archive,'--archive-y',24],[adab,'--adab-y',42],[member,'--membership-y',40]]){
   if(!el)continue;const r=el.getBoundingClientRect();
   if(r.bottom>0&&r.top<height){const progress=clamp((r.top+r.height/2-height/2)/height,-1,1);el.style.setProperty(key,`${progress*range}px`);if(el===archive)el.style.setProperty('--archive-rotate',`${progress*1.5}deg`);}
  }
 };
 const schedule=()=>{if(!frame&&!quiet())frame=requestAnimationFrame(update);};
 hero?.addEventListener('pointermove',event=>{
  if(!fine.matches||quiet())return;const r=hero.getBoundingClientRect();pointer={x:(event.clientX-r.left)/r.width*2-1,y:(event.clientY-r.top)/r.height*2-1};schedule();
 },{passive:true});
 hero?.addEventListener('pointerleave',()=>{pointer={x:0,y:0};schedule();});
 addEventListener('scroll',schedule,{passive:true});addEventListener('resize',schedule,{passive:true});
 document.addEventListener('visibilitychange',()=>{if(document.hidden){cancelAnimationFrame(frame);frame=0;}else schedule();});
 for(const card of document.querySelectorAll('[data-spotlight]')){
  let pending=0,pos;
  card.addEventListener('pointermove',event=>{
   if(quiet()||!fine.matches)return;const r=card.getBoundingClientRect();pos={x:event.clientX-r.left,y:event.clientY-r.top};
   if(!pending)pending=requestAnimationFrame(()=>{pending=0;if(quiet())return;card.style.setProperty('--mouse-x',`${pos.x}px`);card.style.setProperty('--mouse-y',`${pos.y}px`);});
  },{passive:true});
 }
 const revealAll=()=>{observer?.disconnect();document.querySelectorAll('.reveal-pending').forEach(el=>el.classList.remove('reveal-pending'));};
 const reveal=el=>{el.classList.remove('reveal-pending');el.classList.add('has-revealed');animatedCards.add(el);observer?.unobserve(el);};
 const setupReveals=()=>{
  if(!('IntersectionObserver' in window)||quiet())return;
  try{
   observer=new IntersectionObserver(entries=>{
    const visible=entries.filter(entry=>entry.isIntersecting);
    visible.forEach((entry,i)=>{entry.target.style.setProperty('--reveal-delay',`${Math.min(i,3)*75}ms`);reveal(entry.target);});
   },{threshold:0,rootMargin:'0px 0px -35px 0px'});
   root.classList.add('motion-ready');
   document.querySelectorAll('.editorial-heading,.archive-layout>div,.membership-banner,.faq-heading,.footer-top,.footer-grid>div,.page-head .container,.reading-content>section').forEach(el=>el.setAttribute('data-reveal',''));
   for(const el of document.querySelectorAll('[data-reveal]')){
    // No opacity-hidden tab stops, and no expiry disconnecting later sections.
    if(el.getBoundingClientRect().top>innerHeight-35&&!animatedCards.has(el)){el.classList.add('reveal-pending');observer.observe(el);}
   }
  }catch{revealAll();root.classList.remove('motion-ready');}
 };
 document.addEventListener('focusin',event=>{let el=event.target.closest('[data-reveal]');while(el){reveal(el);el=el.parentElement?.closest('[data-reveal]');}});
 const applyPreference=()=>{
  root.dataset.motion=quiet()?'reduce':'full';
  document.querySelectorAll('[data-motion-control]').forEach(b=>{b.hidden=false;b.setAttribute('aria-pressed',String(quiet()));});
  if(quiet()){
   cancelAnimationFrame(frame);frame=0;pointer={x:0,y:0};current={x:0,y:0};
   for(const a of animations)a.cancel();resetVariables();revealAll();root.classList.remove('motion-ready');
  }else{setupReveals();schedule();}
 };
 document.querySelectorAll('[data-motion-control]').forEach(b=>b.addEventListener('click',()=>{
  manual=!manual;try{localStorage.setItem('ot_motion',manual?'reduce':'full');}catch{}applyPreference();
 }));
 reduced.addEventListener('change',applyPreference);
 // Native details semantics remain intact. Closing is committed at once so
 // Enter/Space and rapid repeated activation always reflect the latest state.
 for(const list of document.querySelectorAll('[data-faq]')){
  list.addEventListener('click',event=>{
   const summary=event.target.closest('summary');if(!summary||!list.contains(summary)||quiet())return;
   const details=summary.parentElement;
   const siblings=[...list.querySelectorAll('details')].filter(el=>el.offsetTop>details.offsetTop);
   const before=new Map(siblings.map(el=>[el,el.getBoundingClientRect().top]));
   event.preventDefault();for(const a of animations)a.cancel();details.open=!details.open;
   for(const el of siblings){const delta=before.get(el)-el.getBoundingClientRect().top;if(Math.abs(delta)>.5)animate(el,[{transform:`translateY(${delta}px)`},{transform:'translateY(0)'}],{duration:440,easing:'cubic-bezier(.16,1,.3,1)'});}
   if(details.open)animate(details.querySelector('.faq-answer'),[{opacity:0,transform:'translateY(-10px)'},{opacity:1,transform:'translateY(0)'}],{duration:380,easing:'cubic-bezier(.16,1,.3,1)'});
  });
 }
 applyPreference();
 if(!quiet()){
  [...document.querySelectorAll('.hero-copy .eyebrow,.hero-copy h1,.hero-tagline,.hero-description,.hero-actions,.hero-art')].forEach((el,i)=>
   animate(el,[{opacity:0,transform:'translateY(22px)'},{opacity:1,transform:'translateY(0)'}],{duration:950,delay:i*75,easing:'cubic-bezier(.16,1,.3,1)'}));
 }
}
