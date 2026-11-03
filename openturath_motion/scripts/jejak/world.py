"""Jejak Ilmu: original animated paper, ink, architectural leaves and open book.
Run with Blender 4.5: blender -b -t 4 -P world.py -- --frames 0,180,780
All surfaces are original geometry. No Apple footage or generated still is used.
"""
import bpy, math, os, sys, argparse
from mathutils import Vector

ap=argparse.ArgumentParser()
ap.add_argument('--outdir',default='/tmp/jejak-world-frames')
ap.add_argument('--frames',default='')
ap.add_argument('--start',type=int,default=0)
ap.add_argument('--end',type=int,default=899)
ap.add_argument('--preview',action='store_true')
args=ap.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
os.makedirs(args.outdir,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
for d in list(bpy.data.materials): bpy.data.materials.remove(d)
sc=bpy.context.scene
sc.render.engine='BLENDER_EEVEE_NEXT'
sc.render.resolution_x=1080;sc.render.resolution_y=1920
sc.render.resolution_percentage=50 if args.preview else 100
sc.render.image_settings.file_format='JPEG';sc.render.image_settings.quality=94
sc.render.film_transparent=False
sc.render.fps=30
sc.eevee.taa_render_samples=16 if args.preview else 32
sc.eevee.use_raytracing=True
sc.eevee.use_fast_gi=True
sc.render.threads_mode='FIXED';sc.render.threads=4
sc.view_settings.view_transform='AgX'
sc.view_settings.look='AgX - Medium High Contrast'
sc.view_settings.exposure=.3
sc.world.use_nodes=True
sc.world.node_tree.nodes['Background'].inputs['Color'].default_value=(.68,.68,.68,1)
sc.world.node_tree.nodes['Background'].inputs['Strength'].default_value=.22

# Neutral fiber-scale material. Two frequencies give visible fibers in macro,
# and small roughness variation in the wider shots.
def material(name,color,texture=False):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 n=m.node_tree.nodes;l=m.node_tree.links;p=n.get('Principled BSDF')
 p.inputs['Base Color'].default_value=(*color,1);p.inputs['Roughness'].default_value=.84
 p.inputs['Specular IOR Level'].default_value=.22
 if texture:
  tex=n.new('ShaderNodeTexNoise');tex.inputs['Scale'].default_value=160;tex.inputs['Detail'].default_value=2.3;tex.inputs['Roughness'].default_value=.68
  coord=n.new('ShaderNodeTexCoord');l.new(coord.outputs['Object'],tex.inputs['Vector'])
  bump=n.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.24;bump.inputs['Distance'].default_value=.018
  l.new(tex.outputs['Fac'],bump.inputs['Height']);l.new(bump.outputs['Normal'],p.inputs['Normal'])
  ramp=n.new('ShaderNodeValToRGB');ramp.color_ramp.elements[0].position=.15;ramp.color_ramp.elements[0].color=tuple(v*.86 for v in color)+(1,)
  ramp.color_ramp.elements[1].position=.85;ramp.color_ramp.elements[1].color=(*color,1)
  l.new(tex.outputs['Fac'],ramp.inputs[0]);l.new(ramp.outputs['Color'],p.inputs['Base Color'])
 return m
paper=material('Cotton paper | neutral fibers',(.86,.86,.86),True)
edge=material('Page edge',(.66,.66,.66),True)
ink=material('Matte obsidian ink',(.008,.008,.009))
black=material('Obsidian studio',(.012,.012,.014),True)

collections=[]
def collection(name):
 c=bpy.data.collections.new(name);sc.collection.children.link(c);collections.append(c);return c

def relink(obj,c):
 for old in list(obj.users_collection):old.objects.unlink(obj)
 c.objects.link(obj)
 return obj

def mesh(name,verts,faces,mat,c,solid=0):
 data=bpy.data.meshes.new(name);data.from_pydata(verts,[],faces);data.update()
 o=bpy.data.objects.new(name,data);c.objects.link(o);o.data.materials.append(mat)
 for p in data.polygons:p.use_smooth=True
 if solid:
  mod=o.modifiers.new('Intact physical paper thickness','SOLIDIFY');mod.thickness=solid;mod.offset=0
 return o

def grid(name,nx,ny,fn,mat,c,solid=.008):
 verts=[fn(i/nx,j/ny) for j in range(ny+1) for i in range(nx+1)]
 faces=[]
 for j in range(ny):
  for i in range(nx):
   k=j*(nx+1)+i;faces.append((k,k+1,k+nx+2,k+nx+1))
 return mesh(name,verts,faces,mat,c,solid)

def deform(o,nx,ny,fn):
 co=[]
 for j in range(ny+1):
  for i in range(nx+1):co.extend(fn(i/nx,j/ny))
 o.data.vertices.foreach_set('co',co);o.data.update()

def plane(name,size,mat,c,z=0):
 return mesh(name,[(-size,-size,z),(size,-size,z),(size,size,z),(-size,size,z)],[(0,1,2,3)],mat,c)

def path(name,points,c,depth=.009):
 data=bpy.data.curves.new(name,'CURVE');data.dimensions='3D';data.resolution_u=2
 sp=data.splines.new('POLY');sp.points.add(len(points)-1)
 for p,co in zip(sp.points,points):p.co=(*co,1)
 data.bevel_depth=depth;data.bevel_resolution=3;data.resolution_u=4
 o=bpy.data.objects.new(name,data);c.objects.link(o);data.materials.append(ink);return o

def setpath(o,points):
 for p,co in zip(o.data.splines[0].points,points):p.co=(*co,1)

def ease(v):v=max(0,min(1,v));return v*v*(3-2*v)
def mix(a,b,p):return tuple(x+(y-x)*p for x,y in zip(a,b))

# Shot 1: line is physically drawn and the paper lifts independently of camera.
c0=collection('01 macro paper and growing ink')
plane('Macro backdrop',80,paper,c0,-.09)
def sheetfn(u,v,lift=0):
 x=(u-.5)*5;y=(v-.5)*8
 z=.025*math.sin(y*1.2)+lift*max(0,(abs(x)-.9)/1.6)**2 + .018*math.sin(x*1.8+y*.6)
 return x,y,z
sheet=grid('Single uncut flexible sheet',64,96,lambda u,v:sheetfn(u,v),paper,c0,.012)
def inkcoords(lift):
 arr=[]
 for i in range(241):
  s=i/240;y=-1.7+5.2*s;x=.32*math.sin(s*math.pi*2-.3)
  z=sheetfn(x/5+.5,y/8+.5,lift)[2]+.012
  arr.append((x,y,z))
 return arr
line0=path('Question trace | growing stroke',inkcoords(0),c0,.007)

# Shot 2: serial full paper arches with a real walk-through and changing curvature.
c1=collection('02 architectural leaves')
plane('Continuous paper ground',50,paper,c1,-.04)
arches=[]
for k in range(10):
 def fn(u,v,k=k,phase=0):
  a=math.pi*u;r=2.0+.06*k
  x=-r*math.cos(a);z=(4.4+.08*k)*math.sin(a)**.85
  x+=.14*math.sin(z*.8+k*.35+phase)*math.sin(a)
  y=k*1.32+(v-.5)*.32+.20*math.sin(a*2+k*.3+phase)
  return x,y,z
 o=grid('Intact paper arch %02d'%k,90,5,fn,paper,c1,.022)
 arches.append(o)
line1=path('Trace through the field',[(.32*math.sin(y*.65),y,.008) for y in [(-6+i*.085) for i in range(260)]],c1,.009)

# Shot 3: paper unfurls into a still plane for the actual product fragment.
c2=collection('03 question surface')
plane('Question room',70,paper,c2,-.13)
question=grid('Question leaf flattening',48,64,lambda u,v:((u-.5)*3.8,(v-.5)*6.0,.2),paper,c2,.018)
# Wider leaves on either side give depth without competing with the product crop.
sideleaves=[]
for k in range(6):
 side= -1 if k<3 else 1;j=k%3
 o=grid('Side leaf %d'%k,12,40,lambda u,v,side=side,j=j:(side*(2.5+j*.26+.4*math.sin(v*math.pi)),(u-.5)*4.0+.3*j,v*5.5-.05),paper,c2,.018)
 sideleaves.append(o)

# Shot 4: an intact page turns above a sculpted stack. Text remains in the
# separately authored editorial layer; no invented sacred or bibliographic text.
c3=collection('04 explanation and source leaves')
plane('Reading room',60,paper,c3,-.12)
sourcepages=[]
for j in range(22):
 def fn(u,v,j=j):
  x=(u-.5)*4.6;y=(v-.5)*6.4
  return x,y,j*.014+.11*abs(x/2.3)**1.6
 o=grid('Source leaf %02d'%j,36,28,fn,paper if j%3 else edge,c3,.008)
 sourcepages.append(o)
turnpage=grid('One page being opened',56,36,lambda u,v:(u*4.5-2.25,(v-.5)*6.4,.5),paper,c3,.012)

# Shot 5: paper bookmark leaves the reading plane and settles into a note.
c4=collection('05 note and continuous trace')
plane('Note room',60,paper,c4,-.14)
notepages=[]
for j in range(5):
 o=grid('Note support leaf %d'%j,32,40,lambda u,v,j=j:((u-.5)*4.2,(v-.5)*5.5,j*.045+.08*math.sin(u*math.pi)),paper,c4,.012)
 notepages.append(o)
bookmark=grid('Intact paper bookmark',8,32,lambda u,v:((u-.5)*.48-.7,(v-.5)*5,.65),ink,c4,.009)
line4=path('Trace preserved as a note',[(.4*math.sin(i*.02),-2.5+i*.025,.31) for i in range(200)],c4,.008)

# Shot 6: the whole book opens and its leaves fan into a quiet dimensional hero.
c5=collection('06 open book in obsidian studio')
plane('Obsidian cyclorama',80,black,c5,-.055)
bookpages=[]
for side in [-1,1]:
 for j in range(30):
  o=grid('Book leaf %s %02d'%(side,j),32,18,lambda u,v,side=side,j=j:(side*u*2.45,(v-.5)*3.35,.2+j*.008),paper if j%4 else edge,c5,.006)
  bookpages.append((o,side,j))
cover=grid('Whole uncut binding',64,8,lambda u,v:((u-.5)*5.08,(v-.5)*3.46,.11+.08*(1-abs(u-.5)*2)),black,c5,.09)
line5=path('Trace arrives at the book',[(.18*math.sin(i*.018),-5+i*.022,-.026) for i in range(210)],c5,.008)
line5.data.materials.clear();line5.data.materials.append(edge)

# Camera and shaped neutral studio lighting.
bpy.ops.object.camera_add();cam=bpy.context.object;sc.camera=cam
cam.name='Authored cinematic camera';cam.data.sensor_fit='VERTICAL';cam.data.sensor_height=36
cam.data.dof.use_dof=True;cam.data.dof.aperture_blades=8
lights=[]
def area(name,loc,energy,size,target):
 data=bpy.data.lights.new(name,'AREA');data.energy=energy;data.shape='DISK';data.size=size
 o=bpy.data.objects.new(name,data);sc.collection.objects.link(o);o.location=loc;o.rotation_euler=(Vector(target)-o.location).to_track_quat('-Z','Y').to_euler();lights.append(o);return o
key=area('Large grazing key',(-4,-3,7),1400,5,(0,1,0))
rim=area('Neutral paper edge rim',(4,5,6),1800,4,(0,2,1))
fill=area('Soft front fill',(1,-6,5),350,6,(0,0,1))

def camera(loc,target,lens,fstop=4):
 cam.location=loc;cam.rotation_euler=(Vector(target)-cam.location).to_track_quat('-Z','Y').to_euler()
 cam.data.lens=lens;cam.data.dof.focus_distance=(Vector(target)-cam.location).length;cam.data.dof.aperture_fstop=fstop

def update(frame):
 t=frame/30
 idx=0 if t<4 else 1 if t<9 else 2 if t<14.8 else 3 if t<19 else 4 if t<24 else 5
 for i,c in enumerate(collections):c.hide_render=(i!=idx)
 for o,e in [(key,1400),(rim,1800),(fill,350)]:o.data.energy=e
 sc.world.node_tree.nodes['Background'].inputs['Strength'].default_value=.22
 if idx==0:
  p=ease(t/4);lift=.1+.55*ease((t-1.2)/2.8)
  deform(sheet,64,96,lambda u,v:sheetfn(u,v,lift));setpath(line0,inkcoords(lift));line0.data.bevel_factor_end=ease((t-.05)/2.95)
  camera(mix((.16,-1.4,.6),(.38,-1.9,1.28),p),mix((.0,.04,.03),(.06,.8,.04),p),80,2.5)
  key.data.energy=1100;rim.data.energy=800
 elif idx==1:
  s=(t-4)/5;p=ease(s)
  for k,o in enumerate(arches):
   def fn(u,v,k=k):
    a=math.pi*u;r=2.0+.06*k;phase=s*1.5
    x=-r*math.cos(a);z=(4.4+.08*k)*math.sin(a)**.85
    x+=.14*math.sin(z*.8+k*.35+phase)*math.sin(a)
    y=k*1.32+(v-.5)*.32+.20*math.sin(a*2+k*.3+phase)
    return x,y,z
   deform(o,90,5,fn)
  camera(mix((-.22,-6.7,1.35),(.2,-.15,1.7),p),(0,6+p*3,2.1),34,5.6)
  line1.data.bevel_factor_end=min(1,.5+s*.6)
 elif idx==2:
  s=(t-9)/5.8;p=ease(s)
  curl=(1-ease(s*2.5))*.65
  deform(question,48,64,lambda u,v:((u-.5)*3.8,(v-.5)*6,.18+curl*math.sin(u*math.pi)*math.sin(v*math.pi)))
  camera(mix((.5,-4.8,9),(0,-1,10.5),p),(0,.2,.2),45,7)
 elif idx==3:
  s=(t-14.8)/4.2;p=ease(s)
  theta=.12+math.pi*.8*ease((s-.05)/.8)
  def turn(u,v):
   r=u*4.5;x=-2.25+r*math.cos(theta);z=.52+r*math.sin(theta)+.14*math.sin(u*math.pi)
   return x,(v-.5)*6.4,z
  deform(turnpage,56,36,turn)
  camera(mix((3.4,-4.9,6.5),(-.4,-4.2,8.4),p),(0,.1,.3),48,5.6)
 elif idx==4:
  s=(t-19)/5;p=ease(s)
  lift=.7*math.sin(math.pi*p)
  deform(bookmark,8,32,lambda u,v:((u-.5)*.48-.7+1.4*p,(v-.5)*5,.37+lift*math.sin(v*math.pi)))
  for j,o in enumerate(notepages):
   o.location.x=.1*math.sin(p*math.pi)*j*.3;o.rotation_euler[2]=.025*j*math.sin(p*math.pi)
  camera(mix((1.6,-3.2,8.4),(-.25,-1.1,10.6),p),(0,.05,.2),48,7)
  line4.data.bevel_factor_end=ease(s*1.7)
 else:
  s=(t-24)/6;p=ease(s)
  for o,side,j in bookpages:
   ang=(.16+.22*math.sin(j/29*math.pi))*(1-.4*p)+.48*(1-ease(s*2))*(j/29)
   def page(u,v,side=side,j=j,ang=ang):
    r=u*2.45;x=side*r*math.cos(ang);z=.20+j*.008+r*math.sin(ang)+.13*math.sin(u*math.pi)
    y=(v-.5)*3.35+.025*math.sin(u*math.pi)*math.sin(s*2+j*.1)
    return x,y,z
   deform(o,32,18,page)
  camera(mix((4.1,-6.4,4.5),(2.1,-8.5,5.2),p),(0,.1,1.2+p*.6),47,5.6)
  key.data.energy=950;rim.data.energy=1700;fill.data.energy=100
  sc.world.node_tree.nodes['Background'].inputs['Strength'].default_value=.045
 sc.frame_set(frame)

frames=[int(x) for x in args.frames.split(',') if x] if args.frames else range(args.start,args.end+1)
for f in frames:
 update(f);sc.render.filepath=os.path.join(args.outdir,f'{f:04d}.jpg')
 if os.path.exists(sc.render.filepath) and not args.frames:continue
 bpy.ops.render.render(write_still=True)
 print('JEJAK_FRAME',f,flush=True)
