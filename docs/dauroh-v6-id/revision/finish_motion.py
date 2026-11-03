"""Native PowerPoint chapter sections, restrained builds, and click transitions.

The existing workspace timing helper supplies PresentationML effects. Public
schema references: Microsoft Learn, Working with animation; MS-PPTX Sections.
No slide advances automatically and no remote media or macros are introduced.
"""
from pathlib import Path
from zipfile import ZipFile
from defusedxml.minidom import parseString
import json,re,subprocess,sys,uuid

ROOT=Path('/Users/apple/Downloads/ramadhan/docs/dauroh-v6-id')
BUILD=ROOT/'revision/.build'
P='http://schemas.openxmlformats.org/presentationml/2006/main'
A='http://schemas.openxmlformats.org/drawingml/2006/main'
P14='http://schemas.microsoft.com/office/powerpoint/2010/main'
XMLNS='http://www.w3.org/2000/xmlns/'
specs=json.loads((ROOT/'revision/deck-spec.json').read_text())

def children(node,ns,local):
    return [n for n in node.childNodes if n.nodeType==n.ELEMENT_NODE and n.namespaceURI==ns and n.localName==local]

def append(doc,parent,ns,name,**attrs):
    node=doc.createElementNS(ns,name)
    for key,value in attrs.items():node.setAttribute(key,str(value))
    parent.appendChild(node)
    return node

manifest=[]
with ZipFile(BUILD/'draft.pptx') as z:
    for num,d in enumerate(specs,1):
        doc=parseString(z.read(f'ppt/slides/slide{num}.xml'))
        names=[n.getAttribute('name') for n in doc.getElementsByTagNameNS(P,'cNvPr')]
        stages=[]
        title={'cover':'cover-title','chapter':'chapter-name','closing':'closing-title','break':'break-title'}.get(d['kind'],'slide-title')
        effects=[]
        if title in names:effects.append({'targets':[title],'effect':'floatUp','durationMs':450})
        for n in ['cover-subtitle','presenter-name-ar','chapter-description','chapter-outcome','closing-detail','closing-presenter','break-duration','break-return']:
            if n in names:effects.append({'targets':[n],'effect':'fade','durationMs':420,'delayMs':120})
        if effects:stages.append({'trigger':'auto','effects':effects})
        groups=sorted({int(m.group(1)) for name in names if (m:=re.match(r'reveal-(\d+)-',name))})
        for j,g in enumerate(groups):
            controlled=d['kind'] in {'formula','sequence','comparison','screenshot'} and j>0
            stages.append({'trigger':'click' if controlled else 'auto','effects':[{'targets':[f'reveal-{g}-*'],'effect':'fade' if d['kind']=='screenshot' else 'floatUp','durationMs':350,'delayMs':0 if controlled else 100}]})
        if stages:manifest.append({'slide':num,'stages':stages})
(ROOT/'revision/animation-manifest.json').write_text(json.dumps({'slides':manifest},ensure_ascii=False,indent=2))
subprocess.run([sys.executable,str(ROOT.parent/'dauroh-v5/animate_pptx.py'),str(BUILD/'draft.pptx'),str(BUILD/'motion.pptx'),str(ROOT/'revision/animation-manifest.json'),'--report',str(BUILD/'animation-audit.json')],check=True)

with ZipFile(BUILD/'motion.pptx') as source,ZipFile(BUILD/'candidate-ready.pptx','w') as target:
    for info in source.infolist():
        data=source.read(info.filename)
        if re.fullmatch(r'ppt/slides/slide\d+\.xml',info.filename):
            doc=parseString(data);root=doc.documentElement
            for old in children(root,P,'transition'):root.removeChild(old)
            transition=doc.createElementNS(P,'p:transition');transition.setAttribute('spd','med');transition.setAttribute('advClick','1')
            append(doc,transition,P,'p:fade')
            before=(children(root,P,'timing')+children(root,P,'extLst'))
            if before:root.insertBefore(transition,before[0])
            else:root.appendChild(transition)
            for n in doc.getElementsByTagNameNS(P,'cNvPr'):
                if n.getAttribute('name') not in {'presenter-name-ar','closing-presenter'}:continue
                shape=n.parentNode.parentNode
                for para in shape.getElementsByTagNameNS(A,'p'):
                    pr=children(para,A,'pPr')
                    if not pr:
                        pp=doc.createElementNS(A,'a:pPr');para.insertBefore(pp,para.firstChild)
                    else:pp=pr[0]
                    pp.setAttribute('rtl','1');pp.setAttribute('algn','r')
                for pr in shape.getElementsByTagNameNS(A,'rPr'):pr.setAttribute('lang','ar-SA')
            data=doc.toxml(encoding='UTF-8')
        elif info.filename=='ppt/presentation.xml':
            doc=parseString(data);root=doc.documentElement;root.setAttributeNS(XMLNS,'xmlns:p14',P14)
            extlst=children(root,P,'extLst')
            extlst=extlst[0] if extlst else append(doc,root,P,'p:extLst')
            for old in children(extlst,P,'ext'):
                if old.getAttribute('uri')=='{521415D9-36F7-43E2-AB2F-B90AF26B5E84}':extlst.removeChild(old)
            ext=append(doc,extlst,P,'p:ext',uri='{521415D9-36F7-43E2-AB2F-B90AF26B5E84}')
            sections=append(doc,ext,P14,'p14:sectionLst')
            ids=[n.getAttribute('id') for n in children(children(root,P,'sldIdLst')[0],P,'sldId')]
            current=None
            for d,slideid in zip(specs,ids):
                key=f"Hari {d['day']} / {d['chapter']}"
                if key!=current:
                    sec=append(doc,sections,P14,'p14:section',name=key,id='{'+str(uuid.uuid5(uuid.NAMESPACE_URL,key)).upper()+'}')
                    members=append(doc,sec,P14,'p14:sldIdLst');current=key
                append(doc,members,P14,'p14:sldId',id=slideid)
            data=doc.toxml(encoding='UTF-8')
        target.writestr(info,data)
print(json.dumps({'candidate':str(BUILD/'candidate-ready.pptx'),'slides':len(specs),'animatedSlides':len(manifest),'transitions':len(specs)}))
