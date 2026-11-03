import * as THREE from 'three';
import {EffectComposer} from 'three/examples/jsm/postprocessing/EffectComposer.js';
import {RenderPass} from 'three/examples/jsm/postprocessing/RenderPass.js';
import {BokehPass} from 'three/examples/jsm/postprocessing/BokehPass.js';
import {OutputPass} from 'three/examples/jsm/postprocessing/OutputPass.js';

// Remotion still owns every animation frame. This renderer only applies the
// optical pipeline to that frame; it has no clock or autonomous render loop.
export const createPaperRenderer = (defaults: THREE.WebGLRendererParameters) => {
 const renderer = new THREE.WebGLRenderer({...defaults,antialias:true,alpha:false});
 renderer.toneMapping=THREE.ACESFilmicToneMapping;
 renderer.toneMappingExposure=1.08;
 renderer.outputColorSpace=THREE.SRGBColorSpace;
 const nativeRender=renderer.render.bind(renderer);
 const nativeDispose=renderer.dispose.bind(renderer);
 let composer:EffectComposer|null=null;
 let bokeh:BokehPass|null=null;
 let oldScene:THREE.Object3D|null=null;
 let oldCamera:THREE.Camera|null=null;
 let busy=false,lastW=0,lastH=0,lastDpr=0;
 const size=new THREE.Vector2();
 const release=()=>{
  if(composer){for(const pass of composer.passes)pass.dispose();composer.dispose();}
  composer=null;bokeh=null;
 };
 renderer.render=(object:THREE.Object3D,camera:THREE.Camera)=>{
  if(busy){nativeRender(object,camera);return;}
  if(object!==oldScene||camera!==oldCamera){
   release();oldScene=object;oldCamera=camera;
   composer=new EffectComposer(renderer);
   composer.addPass(new RenderPass(object as THREE.Scene,camera));
   bokeh=new BokehPass(object as THREE.Scene,camera as THREE.PerspectiveCamera,{focus:6,aperture:.002,maxblur:.009});
   composer.addPass(bokeh);composer.addPass(new OutputPass());
   lastW=lastH=lastDpr=0;
  }
  renderer.getSize(size);const dpr=renderer.getPixelRatio();
  if(size.x!==lastW||size.y!==lastH||dpr!==lastDpr){
   composer!.setPixelRatio(dpr);composer!.setSize(size.x,size.y);
   lastW=size.x;lastH=size.y;lastDpr=dpr;
  }
  const focus=Number(camera.userData.focusDistance)||6;
  bokeh!.uniforms.focus.value=focus;
  bokeh!.uniforms.aperture.value=Number(camera.userData.aperture)||.002;
  bokeh!.uniforms.maxblur.value=Number(camera.userData.maxblur)||.009;
  busy=true;
  try{composer!.render(0);}finally{busy=false;}
 };
 renderer.dispose=()=>{release();nativeDispose();};
 return renderer;
};
