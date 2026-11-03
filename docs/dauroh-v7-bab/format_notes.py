from zipfile import ZipFile,ZIP_DEFLATED
from pathlib import Path
import xml.etree.ElementTree as E
import re,sys,json,uuid
A='http://schemas.openxmlformats.org/drawingml/2006/main';P='http://schemas.openxmlformats.org/presentationml/2006/main'
E.register_namespace('a',A);E.register_namespace('p',P)
source,target=map(Path,sys.argv[1:3])
slides=json.loads((Path(__file__).parent/'slides.json').read_text())
P14='http://schemas.microsoft.com/office/powerpoint/2010/main'
E.register_namespace('p14',P14)
with ZipFile(source) as z,ZipFile(target,'w',ZIP_DEFLATED) as out:
 for info in z.infolist():
  data=z.read(info.filename)
  if re.fullmatch(r'ppt/notesSlides/notesSlide\d+\.xml',info.filename):
   root=E.fromstring(data)
   for para in root.findall('.//{%s}p'%A):
    prop=para.find('{%s}pPr'%A)
    if prop is None:prop=E.Element('{%s}pPr'%A);para.insert(0,prop)
    prop.set('algn','l');prop.set('rtl','0')
    for run in para.findall('{%s}r'%A):
     rp=run.find('{%s}rPr'%A)
     if rp is None:rp=E.Element('{%s}rPr'%A);run.insert(0,rp)
     rp.set('lang','id-ID');rp.set('sz','1200')
     for typ in ['latin','ea','cs']:
      f=rp.find('{%s}%s'%(A,typ))
      if f is None:f=E.SubElement(rp,'{%s}%s'%(A,typ))
      f.set('typeface','IBM Plex Sans Arabic')
   data=E.tostring(root,encoding='utf-8',xml_declaration=True)
  if info.filename=='ppt/presentation.xml':
   root=E.fromstring(data)
   ids=[e.get('id') for e in root.findall('{%s}sldIdLst/{%s}sldId'%(P,P))]
   extlist=root.find('{%s}extLst'%P)
   if extlist is None:extlist=E.SubElement(root,'{%s}extLst'%P)
   ext=E.SubElement(extlist,'{%s}ext'%P,{'uri':'{521415D9-36F7-43E2-AB2F-B90AF26B5E84}'})
   sections=E.SubElement(ext,'{%s}sectionLst'%P14)
   current=None;last=None
   for i,d in enumerate(slides):
    key=(d['day'],d['bab'])
    if key!=last:
     name=('Bab '+str(d['bab'])+' · '+d['chapter']) if d['bab'] else 'Hari '+str(d['day'])+' · Pembukaan'
     sec=E.SubElement(sections,'{%s}section'%P14,{'name':name,'id':'{'+str(uuid.uuid5(uuid.NAMESPACE_URL,name)).upper()+'}'})
     current=E.SubElement(sec,'{%s}sldIdLst'%P14);last=key
    E.SubElement(current,'{%s}sldId'%P14,{'id':ids[i]})
   data=E.tostring(root,encoding='utf-8',xml_declaration=True)
  out.writestr(info,data)
print(target)
