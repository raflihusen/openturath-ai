"""Apply native DrawingML Arabic paragraph direction without changing word order."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import re
import sys
import hashlib
import xml.etree.ElementTree as ET

source, target = map(Path, sys.argv[1:3])
font_family = sys.argv[3] if len(sys.argv) > 3 else 'Arial'
A = 'http://schemas.openxmlformats.org/drawingml/2006/main'
P = 'http://schemas.openxmlformats.org/presentationml/2006/main'
ET.register_namespace('a', A)
ET.register_namespace('p', P)
ET.register_namespace('r', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')

with ZipFile(source) as src, ZipFile(target, 'w', ZIP_DEFLATED) as dst:
    canonical = {}
    duplicate = {}
    for name in src.namelist():
        if name.startswith('ppt/media/'):
            digest = hashlib.sha256(src.read(name)).hexdigest()
            if digest in canonical:
                duplicate[name] = canonical[digest]
            else:
                canonical[digest] = name
    for name in src.namelist():
        if name in duplicate:
            continue
        data = src.read(name)
        if name.endswith('.rels'):
            rels = data.decode('utf-8')
            def canonical_target(match):
                value = match.group(1)
                old = 'ppt/media/' + value.rsplit('/', 1)[-1]
                if old in duplicate:
                    value = value.rsplit('/', 1)[0] + '/' + Path(duplicate[old]).name
                return 'Target="' + value + '"'
            rels = re.sub(r'Target="([^"]+)"', canonical_target, rels)
            data = rels.encode('utf-8')
        is_slide = bool(re.fullmatch(r'ppt/slides/slide\d+\.xml', name))
        is_notes = bool(re.fullmatch(r'ppt/notesSlides/notesSlide\d+\.xml', name))
        if is_slide or is_notes:
            root = ET.fromstring(data)
            for paragraph in root.findall('.//{%s}p' % A):
                value = ''.join(paragraph.itertext())
                has_arabic = bool(re.search(r'[\u0600-\u06ff]', value))
                if not has_arabic and not is_notes:
                    continue
                props = paragraph.find('{%s}pPr' % A)
                if props is None:
                    props = ET.Element('{%s}pPr' % A)
                    paragraph.insert(0, props)
                if has_arabic:
                    props.set('rtl', '1')
                    if is_notes:
                        props.set('algn', 'r')
                if is_notes:
                    for run in paragraph.findall('{%s}r' % A):
                        if run.find('{%s}rPr' % A) is None:
                            run.insert(0, ET.Element('{%s}rPr' % A))
                for rpr in paragraph.findall('.//{%s}rPr' % A):
                    rpr.set('lang', 'ar-YE' if has_arabic else 'en-US')
                    if has_arabic:
                        rpr.set('altLang', 'ar-SA')
                    cs = rpr.find('{%s}cs' % A)
                    if cs is None:
                        cs = ET.SubElement(rpr, '{%s}cs' % A)
                    cs.set('typeface', font_family)
                    latin = rpr.find('{%s}latin' % A)
                    if latin is None:
                        latin = ET.SubElement(rpr, '{%s}latin' % A)
                    latin.set('typeface', font_family)
            if is_slide:
                transition = ET.Element('{%s}transition' % P, {'spd':'med'})
                ET.SubElement(transition, '{%s}fade' % P)
                at = len(root)
                for i, child in enumerate(root):
                    if child.tag in ('{%s}timing' % P, '{%s}extLst' % P):
                        at = i
                        break
                root.insert(at, transition)
            data = ET.tostring(root, encoding='utf-8', xml_declaration=True)
        dst.writestr(name, data)
print(target)
