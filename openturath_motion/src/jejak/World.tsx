import React, {useLayoutEffect, useMemo} from 'react';
import {ThreeCanvas} from '@remotion/three';
import {useThree} from '@react-three/fiber';
import {useCurrentFrame, useVideoConfig} from 'remotion';
import * as THREE from 'three';

// A deterministic 3D fallback: intact pages, a growing ink line and six
// independently staged camera moves. Nothing is rasterised from styleframes.
const clamp=(v:number)=>Math.max(0,Math.min(1,v));
const ease=(v:number)=>{const p=clamp(v);return p*p*(3-2*p);};
const mix=(a:number,b:number,p:number)=>a+(b-a)*p;
type V3=[number,number,number];
const vmix=(a:V3,b:V3,p:number):V3=>[mix(a[0],b[0],p),mix(a[1],b[1],p),mix(a[2],b[2],p)];
const page='#dededb', edge='#bbbcb9', obsidian='#111113';

// Repeatable fiber noise; it does not sample a photograph or alter over time.
function paperTexture():THREE.DataTexture {
 const size=256, data=new Uint8Array(size*size*4);let seed=97823;
 const rand=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;};
 for(let y=0;y<size;y++)for(let x=0;x<size;x++){
  const i=(y*size+x)*4;const v=Math.round(113+rand()*28+7*Math.sin(x*.18+y*.025));
  data[i]=v;data[i+1]=v;data[i+2]=v;data[i+3]=255;
 }
 const tex=new THREE.DataTexture(data,size,size,THREE.RGBAFormat);
 tex.wrapS=tex.wrapT=THREE.RepeatWrapping;tex.repeat.set(3,3);tex.needsUpdate=true;return tex;
}
const fibers=paperTexture();

type SurfaceFn=(u:number,v:number)=>V3;
function makeSurface(nx:number,ny:number,fn:SurfaceFn):THREE.BufferGeometry {
 const points:number[]=[],uv:number[]=[],indices:number[]=[];
 for(let j=0;j<=ny;j++)for(let i=0;i<=nx;i++){const u=i/nx,v=j/ny;points.push(...fn(u,v));uv.push(u,v);}
 for(let j=0;j<ny;j++)for(let i=0;i<nx;i++){
  const k=j*(nx+1)+i;indices.push(k,k+nx+1,k+1,k+1,k+nx+1,k+nx+2);
 }
 const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.Float32BufferAttribute(points,3));g.setAttribute('uv',new THREE.Float32BufferAttribute(uv,2));g.setIndex(indices);g.computeVertexNormals();return g;
}
const Sheet:React.FC<{surface:SurfaceFn;nx?:number;ny?:number;color?:string;bump?:boolean}> = ({surface,nx=32,ny=32,color=page,bump=true})=>{
 const geometry=useMemo(()=>makeSurface(nx,ny,surface),[nx,ny,surface]);
 return <mesh geometry={geometry} castShadow receiveShadow><meshStandardMaterial color={color} roughness={.86} metalness={0} side={THREE.DoubleSide} bumpMap={bump?fibers:null} bumpScale={.025}/></mesh>;
};
const Ink:React.FC<{points:V3[];portion:number;color?:string;radius?:number}> = ({points,portion,color='#111112',radius=.009})=>{
 const geometry=useMemo(()=>{
  const n=Math.max(2,Math.ceil(points.length*clamp(portion)));const curve=new THREE.CatmullRomCurve3(points.slice(0,n).map(p=>new THREE.Vector3(...p)));
  return new THREE.TubeGeometry(curve,Math.max(8,n*2),radius,6,false);
 },[points,portion,radius]);
 return <mesh geometry={geometry} castShadow><meshStandardMaterial color={color} roughness={.9}/></mesh>;
};
const Ground:React.FC<{dark?:boolean}> = ({dark=false})=><mesh rotation={[-Math.PI/2,0,0]} position={[0,-.1,0]} receiveShadow><planeGeometry args={[120,120]}/><meshStandardMaterial color={dark?obsidian:page} roughness={.92} bumpMap={dark?null:fibers} bumpScale={.018}/></mesh>;
const Rig:React.FC<{pos:V3;target:V3;fov?:number}> = ({pos,target,fov=35})=>{
 const {camera,gl}=useThree();
 useLayoutEffect(()=>{camera.position.set(...pos);camera.up.set(0,1,0);camera.lookAt(...target);if(camera instanceof THREE.PerspectiveCamera){camera.fov=fov;camera.updateProjectionMatrix();}gl.shadowMap.enabled=true;gl.shadowMap.type=THREE.PCFSoftShadowMap;},[camera,gl,pos[0],pos[1],pos[2],target[0],target[1],target[2],fov]);return null;
};
const Lights:React.FC<{dark:boolean}> = ({dark})=><>
 <ambientLight intensity={dark?.36:.85}/>
 <directionalLight position={[-4,8,5]} intensity={dark?1.7:2.1} castShadow shadow-mapSize-width={2048} shadow-mapSize-height={2048} shadow-camera-left={-10} shadow-camera-right={10} shadow-camera-top={12} shadow-camera-bottom={-10} shadow-bias={-.00015}/>
 <directionalLight position={[5,5,-6]} intensity={dark?2.5:1.1}/>
 <directionalLight position={[0,3,8]} intensity={dark?.45:.55}/>
</>;

const Macro:React.FC<{t:number}> = ({t})=>{
 const p=ease(t/4), lift=.08+.55*ease((t-1.2)/2.8);
 const surface=(u:number,v:number):V3=>{const x=(u-.5)*5,z=(v-.5)*8;return [x,.025*Math.sin(z*1.2)+lift*Math.pow(Math.max(0,(Math.abs(x)-.9)/1.6),2)+.018*Math.sin(x*1.8+z*.6),z];};
 const points:V3[]=Array.from({length:120},(_,i)=>{const q=i/119,z=-1.7+5.2*q,x=.32*Math.sin(q*Math.PI*2-.3);const y=surface(x/5+.5,z/8+.5)[1]+.016;return [x,y,z];});
 return <><Rig pos={vmix([.12,1.35,3.1],[.38,2.1,2.4],p)} target={vmix([0,0,.4],[0,0,-.7],p)} fov={32}/><Ground/><Sheet surface={surface} nx={60} ny={64}/><Ink points={points} portion={ease((t-.05)/2.95)}/></>;
};
const Portal:React.FC<{t:number}> = ({t})=>{
 const s=(t-4)/5,p=ease(s);const path:V3[]=Array.from({length:140},(_,i)=>{const z=5-i*.13;return [.32*Math.sin(z*.65),-.075,z];});
 return <><Rig pos={vmix([-.22,1.45,7],[.2,1.7,.5],p)} target={[0,2.2,-6]} fov={39}/><Ground/><Ink points={path} portion={.5+s*.5}/>{Array.from({length:10},(_,k)=>{
 const surface=(u:number,v:number):V3=>{const a=Math.PI*u,r=2+.06*k,x=-r*Math.cos(a),y=(4.4+.08*k)*Math.pow(Math.sin(a),.85);return [x+.14*Math.sin(y*.8+k*.35+s*1.5)*Math.sin(a),y,-k*1.32+(v-.5)*.32+.2*Math.sin(a*2+k*.3+s*1.5)];};
 return <Sheet key={k} surface={surface} nx={72} ny={3}/>;})}</>;
};
const QuestionWorld:React.FC<{t:number}> = ({t})=>{
 const p=ease((t-9)/5.8),curl=(1-ease(p*2.5))*.65;
 const surface=(u:number,v:number):V3=>[(u-.5)*3.8,.18+curl*Math.sin(u*Math.PI)*Math.sin(v*Math.PI),(v-.5)*6];
 return <><Rig pos={vmix([.5,9,4.8],[0,10.5,1],p)} target={[0,.2,0]} fov={38}/><Ground/><Sheet surface={surface} nx={48} ny={64}/>{[-1,1].flatMap(side=>[0,1,2].map(j=>{const fn=(u:number,v:number):V3=>[side*(2.5+j*.26+.4*Math.sin(v*Math.PI)),v*5.5,(u-.5)*4+.3*j];return <Sheet key={`${side}-${j}`} surface={fn} nx={12} ny={40}/>;}))}</>;
};
const SourceWorld:React.FC<{t:number}> = ({t})=>{
 const p=ease((t-14.8)/4.2), theta=.12+Math.PI*.8*ease((p-.05)/.8);
 return <><Rig pos={vmix([3.4,6.5,4.9],[-.4,8.4,4.2],p)} target={[0,.3,0]} fov={38}/><Ground/>{Array.from({length:16},(_,j)=>{const fn=(u:number,v:number):V3=>{const x=(u-.5)*4.6;return [x,j*.014+.11*Math.pow(Math.abs(x/2.3),1.6),(v-.5)*6.4];};return <Sheet key={j} surface={fn} nx={26} ny={20} color={j%3? page:edge}/>;})}<Sheet nx={48} ny={32} surface={(u,v)=>{const r=u*4.5;return [-2.25+r*Math.cos(theta),.35+r*Math.sin(theta)+.14*Math.sin(u*Math.PI),(v-.5)*6.4];}}/></>;
};
const NoteWorld:React.FC<{t:number}> = ({t})=>{
 const p=ease((t-19)/5),lift=.7*Math.sin(Math.PI*p);
 const trace:V3[]=Array.from({length:100},(_,i)=>[.4*Math.sin(i*.04),.31,-2.5+i*.05]);
 return <><Rig pos={vmix([1.6,8.4,3.2],[-.25,10.6,1.1],p)} target={[0,.2,0]} fov={38}/><Ground/>{Array.from({length:5},(_,j)=>{const fn=(u:number,v:number):V3=>[(u-.5)*4.2+.03*j*Math.sin(p*Math.PI),j*.045+.08*Math.sin(u*Math.PI),(v-.5)*5.5];return <Sheet key={j} surface={fn} nx={28} ny={36}/>;})}<Sheet color="#27272A" nx={8} ny={32} surface={(u,v)=>[(u-.5)*.48-.7+1.4*p,.37+lift*Math.sin(v*Math.PI),(v-.5)*5]}/><Ink points={trace} portion={p*1.7}/></>;
};
const BookWorld:React.FC<{t:number}> = ({t})=>{
 const s=(t-24)/6,p=ease(s); const trace:V3[]=Array.from({length:100},(_,i)=>[.18*Math.sin(i*.035),-.075,5-i*.05]);
 return <><Rig pos={vmix([4.1,4.5,6.4],[2.1,5.2,8.5],p)} target={[0,1.2+p*.6,0]} fov={38}/><Ground dark/><Ink points={trace} portion={1} color={edge}/><Sheet color="#222225" nx={48} ny={8} surface={(u,v)=>[(u-.5)*5.08,.11+.08*(1-Math.abs(u-.5)*2),(v-.5)*3.46]}/>{[-1,1].flatMap(side=>Array.from({length:18},(_,j)=>{
 const a=(.16+.22*Math.sin(j/17*Math.PI))*(1-.4*p)+.48*(1-ease(s*2))*(j/17);
 const fn=(u:number,v:number):V3=>{const r=u*2.45;return [side*r*Math.cos(a),.2+j*.012+r*Math.sin(a)+.13*Math.sin(u*Math.PI),(v-.5)*3.35+.025*Math.sin(u*Math.PI)*Math.sin(s*2+j*.1)];};
 return <Sheet key={`${side}-${j}`} surface={fn} nx={24} ny={12} color={j%4?page:edge}/>;}))}</>;
};

export const JejakWorld3D:React.FC = () => {
 const frame=useCurrentFrame();const {fps,width,height}=useVideoConfig();const t=frame/fps;const dark=t>=24;
 return <ThreeCanvas width={width} height={height} shadows camera={{position:[0,6,6],fov:38,near:.02,far:200}} gl={{antialias:true,alpha:false}}>
  <color attach="background" args={[dark?obsidian:'#e5e5e2']}/><Lights dark={dark}/>
  {t<4?<Macro t={t}/>:t<9?<Portal t={t}/>:t<14.8?<QuestionWorld t={t}/>:t<19?<SourceWorld t={t}/>:t<24?<NoteWorld t={t}/>:<BookWorld t={t}/>}
 </ThreeCanvas>;
};
