"""Penyaji HTML slide dauroh: monokrom + kedalaman (3D CSS, ilustrasi SVG, animasi)."""
import html
import re

AR_DIGITS = str.maketrans('0123456789', '٠١٢٣٤٥٦٧٨٩')


def ar(n):
    return str(n).translate(AR_DIGITS)


def fmt(s):
    s = html.escape(s, quote=False)
    s = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', s)
    s = re.sub(r'`(.+?)`', r'<bdi class="lat">\1</bdi>', s)
    return s


# ── ikon garis 24x24 ──────────────────────────────────────────
ICONS = {
    'brain': '<path d="M9.5 4A3 3 0 0 0 6.5 7a3 3 0 0 0-2 5 3 3 0 0 0 2 4.5A3 3 0 0 0 9.5 20H12V4z"/><path d="M14.5 4a3 3 0 0 1 3 3 3 3 0 0 1 2 5 3 3 0 0 1-2 4.5 3 3 0 0 1-3 3.5H12"/><path d="M8 10h2M14 10h2M8 14h2M14 14h2"/>',
    'cog': '<circle cx="12" cy="12" r="3.2"/><path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3M5.3 5.3l2.1 2.1M16.6 16.6l2.1 2.1M18.7 5.3l-2.1 2.1M7.4 16.6l-2.1 2.1"/><circle cx="12" cy="12" r="7"/>',
    'robot': '<rect x="5" y="8" width="14" height="11" rx="3"/><path d="M12 4v4M9 13v.01M15 13v.01M9.5 16h5M3 12.5v3M21 12.5v3"/><circle cx="12" cy="3.5" r="1.2"/>',
    'search': '<circle cx="10.5" cy="10.5" r="6.5"/><path d="M20 20l-4.9-4.9"/>',
    'alert': '<path d="M12 3.5l9.5 16.5h-19z"/><path d="M12 10v4.5M12 17.5v.01"/>',
    'heart': '<path d="M12 20s-8-5-8-11a4.5 4.5 0 0 1 8-2.7A4.5 4.5 0 0 1 20 9c0 6-8 11-8 11z"/>',
    'cycle': '<path d="M20 11a8 8 0 0 0-14-4L4 9"/><path d="M4 4v5h5"/><path d="M4 13a8 8 0 0 0 14 4l2-2"/><path d="M20 20v-5h-5"/>',
    'layers': '<path d="M12 3l9 5-9 5-9-5z"/><path d="M3 12.5l9 5 9-5"/><path d="M3 16.5l9 5 9-5"/>',
    'scale': '<path d="M12 3v18M7 21h10M5 7h14"/><path d="M5 7l-3 7a3 3 0 0 0 6 0z"/><path d="M19 7l-3 7a3 3 0 0 0 6 0z"/>',
    'chat': '<path d="M4 5h16v11H10l-5 4v-4H4z"/><path d="M8 9h8M8 12h5"/>',
    'question': '<circle cx="12" cy="12" r="9"/><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.7.4-1 1-1 1.7M12 17v.01"/>',
    'doc': '<path d="M6 3h8l4 4v14H6z"/><path d="M14 3v4h4M9 12h6M9 16h6"/>',
    'lock': '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3M12 15v2"/>',
    'shield': '<path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/><path d="M8.5 12l2.5 2.5 4.5-5"/>',
    'flag': '<path d="M5 21V4M5 4h12l-2 4 2 4H5"/>',
    'ban': '<circle cx="12" cy="12" r="9"/><path d="M5.6 5.6l12.8 12.8"/>',
    'cap': '<path d="M2 9l10-5 10 5-10 5z"/><path d="M6 11.5V16c0 1.5 3 3 6 3s6-1.5 6-3v-4.5M22 9v6"/>',
    'list': '<path d="M9 6h12M9 12h12M9 18h12"/><path d="M3.5 6l1 1 2-2M3.5 12l1 1 2-2M3.5 18l1 1 2-2"/>',
    'target': '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1.2"/>',
    'bulb': '<path d="M9 18h6M10 21h4"/><path d="M12 3a6 6 0 0 0-4 10.5c.8.8 1 1.5 1 2.5h6c0-1 .2-1.7 1-2.5A6 6 0 0 0 12 3z"/>',
    'check': '<circle cx="12" cy="12" r="9"/><path d="M8 12.5l3 3 5-6"/>',
    'map': '<path d="M3 6l6-2 6 2 6-2v14l-6 2-6-2-6 2z"/><path d="M9 4v14M15 6v14"/>',
    'book': '<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20V3H6.5A2.5 2.5 0 0 0 4 5.5z"/><path d="M6.5 17A2.5 2.5 0 0 0 4 19.5V21h16v-4M8 7h8"/>',
    'plane': '<path d="M21 3L3 11l7 3 3 7z"/><path d="M10 14L21 3"/>',
    'translate': '<path d="M4 5h9M8.5 3v2M6 5c.5 4 3 7 7 8M12 5c-.5 4-3 7-7 8"/><path d="M12 21l4.5-10L21 21M13.5 17.5h6"/>',
    'cards': '<rect x="3" y="7" width="14" height="13" rx="2"/><path d="M7 7V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2h-2M7 12h6M7 15.5h4"/>',
    'pen': '<path d="M4 20l4-1 11-11-3-3L5 16z"/><path d="M14 6l3 3"/>',
    'link': '<path d="M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1"/><path d="M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1"/>',
    'eye': '<path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
    'calendar': '<rect x="4" y="6" width="16" height="15" rx="2"/><path d="M4 10h16M8 3v4M16 3v4M8 14h2M12 14h2M8 17.5h2"/>',
    'star': '<path d="M12 3l2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z"/>',
    'users': '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20a6.5 6.5 0 0 1 13 0M16 4.5a3.5 3.5 0 0 1 0 7M18 14a6.5 6.5 0 0 1 3.5 6"/>',
    'scroll': '<path d="M6 3h11a2 2 0 0 1 2 2v13a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3V5"/><path d="M9 8h7M9 12h7M9 16h4"/>',
    'hourglass': '<path d="M6 3h12M6 21h12M7 3c0 5 5 6 5 9s-5 4-5 9M17 3c0 5-5 6-5 9s5 4 5 9"/>',
    'quote': '',
}

# كلمة في العنوان ← أيقونة (الأول يغلب)
KEYS = [
    ('محرك البحث', 'search'), ('LLM', 'brain'), ('Harness', 'cog'), ('Agent', 'robot'),
    ('OpenTurath AI', 'chat'), ('مكتوطات', 'scroll'), ('تخريج الحديث', 'book'),
    ('الهلوسة', 'alert'), ('النبرة', 'alert'), ('إرضاء', 'heart'), ('كل مرة', 'cycle'),
    ('مرتان', 'cycle'), ('المذاهب', 'layers'), ('الشرعي', 'scale'), ('الأمر', 'chat'),
    ('أربعة عناصر', 'layers'), ('ذاكرة', 'brain'), ('أسئلة المتابعة', 'question'),
    ('المراجع والعبارة', 'doc'), ('لاءات', 'lock'), ('حقوق', 'shield'), ('اذكر', 'flag'),
    ('لا يُترك', 'ban'), ('ليس شيخًا', 'cap'), ('بطاقتي', 'list'), ('أفكار مواضيع', 'bulb'),
    ('المحاوِر', 'chat'), ('يجمعه', 'list'), ('اختبار', 'check'), ('الإشكالية', 'question'),
    ('العنوان', 'target'), ('خطة', 'map'), ('مراحل', 'map'), ('المكتبات', 'book'),
    ('الحديث', 'book'), ('المجلات', 'doc'), ('تيليغرام', 'plane'), ('طبعة', 'book'),
    ('أدب', 'shield'), ('قائمة مصادر', 'list'), ('تلخيص', 'doc'), ('ترجمة', 'translate'),
    ('بطاقة الفائدة', 'cards'), ('التخريج', 'search'), ('عملان', 'scale'),
    ('المقارنة', 'scale'), ('معاني', 'book'), ('الخط الفاصل', 'pen'), ('الحاشية', 'link'),
    ('النقول', 'check'), ('الإعراب', 'pen'), ('المصحّح', 'translate'), ('نقرأ', 'eye'),
    ('الأخطاء', 'cycle'), ('حدود', 'ban'), ('ممتحن', 'scale'), ('المدح', 'shield'),
    ('النقد', 'eye'), ('حفظ القلب', 'heart'), ('دورة', 'cycle'), ('الملخص', 'doc'),
    ('لماذا صنعناها', 'bulb'), ('أوامر', 'chat'), ('الواجب', 'calendar'), ('القواعد', 'star'),
    ('بعد الدورة', 'users'), ('التقويم', 'check'), ('فحص', 'check'), ('قواعد العمل', 'users'),
    ('نحمل', 'target'), ('الأستاذ الشديد', 'scale'), ('المحاوِر', 'chat'),
    ('الاستخدام الآمن', 'shield'), ('الذكاء الاصطناعي المصحّح', 'translate'),
    ('النموذج', 'brain'), ('نتعلم', 'bulb'), ('دون أن ننتبه', 'eye'), ('يتردد', 'question'),
]
SESS = {'١': 'brain', '٢': 'alert', '٣': 'chat', '٤': 'shield', '٥': 'target', '٦': 'map',
        '٧': 'search', '٨': 'book', '٩': 'pen', '١٠': 'translate', '١١': 'scale',
        '١٢': 'flag', '١٣': 'robot'}

STAGES_FALLBACK = 'layers'


def pick_icon(sl):
    if sl.get('icon'):
        return sl['icon']
    t = sl.get('title', '') + ' ' + sl.get('eyebrow', '')
    for k, v in KEYS:
        if k in t:
            return v
    m = re.search(r'ج([٠-٩]+)', sl.get('eyebrow', ''))
    if m and m.group(1) in SESS:
        return SESS[m.group(1)]
    return STAGES_FALLBACK


def svg(name, cls='ico', sw=1.4):
    return (f'<svg class="{cls}" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
            f'stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round">{ICONS[name]}</svg>')


def scene(icon, kind='plain', timer=None, v=0):
    if timer is not None:
        return (f'<div class="viz timer"><svg viewBox="0 0 200 200"><circle class="track" cx="100" cy="100" r="86"/>'
                f'<circle class="ring" cx="100" cy="100" r="86"/></svg>'
                f'<div class="t"><b>{ar(timer)}</b><span>دقيقة</span></div></div>')
    if kind == 'quote':
        glyph = '<div class="qg">&#8220;</div>'
        body = glyph
    else:
        body = svg(icon, 'bigico', 1.1)
    if v == 1 and kind != 'quote':
        return f'''<div class="viz vb"><div class="sphere"><i class="rg g1"></i><i class="rg g2"></i><div class="ic3">{svg(icon, 'bigico', 1.2)}</div></div><div class="gshadow"></div></div>'''
    if v == 2 and kind != 'quote':
        return f'''<div class="viz vc"><div class="fan"><i class="cd c1"></i><i class="cd c2"></i><div class="cd c3">{svg(icon, 'bigico', 1.2)}</div></div><div class="gshadow"></div></div>'''
    return f'''<div class="viz"><div class="stack"><i class="l l1"></i><i class="l l2"></i><i class="l l3"></i>
<b class="orb o1"></b><b class="orb o2"></b><b class="orb o3"></b></div><div class="ic2">{body}</div><div class="gshadow"></div></div>'''


def stage_strip(idx):
    if idx is None:
        return ''
    dots = ''.join(
        f'<i class="{"on" if i == idx else ("done" if i < idx else "")}"></i>' for i in range(10))
    return (f'<div class="strip"><span>{ar(idx + 1)} / ١٠ | {html.escape(STAGES_G[idx])}</span>'
            f'<div>{dots}</div></div>')


STAGES_G = []


def body(sl, n):
    k = sl['kind']
    note = sl.get('note', '')
    icon = pick_icon(sl)
    cls = 'slide k-' + k
    dark = k == 'divider' or (k in ('quote',) and sl.get('brand'))
    if dark:
        cls += ' dark'
    if k == 'divider' and sl.get('small'):
        cls += ' small'
    st = stage_strip(sl.get('stage')) if k not in ('cover', 'closing') else ''
    inner = ''
    deco = ''
    if k in ('cover', 'closing'):
        cls += ' cover'
        title = ('<h1>استخدام الذكاء الاصطناعي<br>في مجال البحث العلمي</h1>'
                 '<p class="lede">للمبتدئين من طلبة العلم: من فكرة البحث إلى المناقشة</p>') if k == 'cover' else \
            ('<h1>شكرًا لكم</h1><p class="lede">الذكاء الاصطناعي يعين، والحق يُتحقَّق منه في الكتب، '
             'والعلم يُؤخذ عن الشيوخ.</p>')
        eyebrow = '<div class="eyebrow">دورة تدريبية | يومان</div>' if k == 'cover' else ''
        inner = f'''<div class="hero3d"><div class="ring3 r1"></div><div class="ring3 r2"></div>
<img class="mk" src="assets/openturath_dark.svg" alt=""></div>
<div class="logos"><img class="ot" src="assets/openturath_dark.svg" alt="OpenTurath"><span class="sep"></span><img class="ruqi" src="assets/logo_ruqi_transparan.png" alt="معهد رقي للتدريب والتأهيل المهني"></div>
{eyebrow}{title}
<div class="presenter"><b>رفلي حسين</b><span>خبير الذكاء الاصطناعي</span><span>و <bdi class="lat">Founder of OpenTurath AI</bdi></span></div>'''
    elif k == 'divider':
        m = re.search(r'الجلسة\s+([٠-٩]+)', sl['eyebrow'])
        big = m.group(1) if m else ''
        if not big and 'اليوم الأول' in sl['eyebrow']:
            big = '١'
        if not big and 'اليوم الثاني' in sl['eyebrow']:
            big = '٢'
        deco = f'''<div class="floor"></div><div class="glow"></div>
<div class="bignum">{big}</div>
<div class="mark3d"><img src="assets/openturath_light.svg" alt=""></div>'''
        inner = f'''<div class="eyebrow">{fmt(sl['eyebrow'])}</div><h2>{fmt(sl['title'])}</h2><p class="lede">{fmt(sl.get('sub', ''))}</p>'''
        if sl.get('stage') is not None:
            st = stage_strip(sl['stage'])
    elif k in ('points', 'demo', 'product'):
        cc = f'c{min(len(sl["items"]), 6)}'
        li = ''.join(f'<li style="--i:{i}">{fmt(x)}</li>' for i, x in enumerate(sl['items']))
        h2c = ' class="prod"' if k == 'product' else ''
        inner = f'''<div class="split"><div class="txt"><div class="eyebrow">{fmt(sl['eyebrow'])}</div>
<h2{h2c}>{fmt(sl['title'])}</h2><ul class="body {cc}">{li}</ul></div>{scene(icon, v=n % 3)}</div>'''
    elif k == 'quote':
        t = '<br>'.join(fmt(x) for x in sl['text'].split('\n'))
        inner = f'''<div class="split"><div class="txt"><div class="eyebrow">{fmt(sl['eyebrow'])}</div>
<blockquote class="body">{t}</blockquote></div>{scene(icon, 'quote')}</div>'''
    elif k == 'compare':
        inner = f'''<div class="eyebrow">{fmt(sl['eyebrow'])}</div><h2>{fmt(sl['title'])}</h2>
<div class="two body"><div><h3>{fmt(sl['a_title'])}</h3><p>{fmt(sl['a'])}</p></div><div class="vs"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M11 6l-6 6 6 6"/></svg></div><div class="alt"><h3>{fmt(sl['b_title'])}</h3><p>{fmt(sl['b'])}</p></div></div>'''
        deco = f'<div class="wm">{svg(icon, "ico", 0.6)}</div>'
    elif k == 'task':
        li = ''.join(f'<li style="--i:{i}">{fmt(x)}</li>' for i, x in enumerate(sl['items']))
        inner = f'''<div class="split"><div class="txt"><div class="eyebrow">تكليف | {fmt(sl['eyebrow'])}</div>
<h2>{fmt(sl['title'])} <span class="chip">{fmt(sl.get('mode', ''))}</span></h2>
<ol class="body">{li}</ol></div>{scene(icon, timer=sl['minutes'])}</div>'''
    elif k in ('four', 'three'):
        cells = ''.join(f'<div style="--i:{i}"><h3>{fmt(a)}</h3><p>{fmt(b)}</p></div>' for i, (a, b) in enumerate(sl['items']))
        foot = f'<p class="foot">{fmt(sl["foot"])}</p>' if sl.get('foot') else ''
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><div class="grid{len(sl["items"])} body">{cells}</div>{foot}'
        deco = f'<div class="wm">{svg(icon, "ico", 0.6)}</div>'
    elif k == 'table':
        th = ''.join(f'<th>{fmt(h)}</th>' for h in sl['head'])
        tr = ''.join('<tr style="--i:%d">' % i + ''.join(f'<td>{fmt(c)}</td>' for c in r) + '</tr>' for i, r in enumerate(sl['rows']))
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><div class="tcard"><table class="body"><thead><tr>{th}</tr></thead><tbody>{tr}</tbody></table></div>'
        deco = f'<div class="wm">{svg("calendar", "ico", 0.6)}</div>'
    elif k == 'stages':
        cells = ''.join(f'<div style="--i:{i}"><b>{ar(i + 1)}</b><span>{fmt(s)}</span></div>' for i, s in enumerate(STAGES_G))
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><div class="stages body">{cells}</div>'
        deco = f'<div class="wm">{svg("map", "ico", 0.6)}</div>'
    elif k == 'pause':
        inner = f'<div class="eyebrow">{ar(sl["minutes"])} دقيقة</div><h2>{fmt(sl["title"])}</h2><div class="cup">{svg("hourglass", "bigico", 0.9)}</div>'
    elif k == 'sources':
        cells = ''.join(f'<div style="--i:{i}"><h3>{fmt(a)}</h3><p class="url" dir="ltr">{html.escape(b)}</p></div>' for i, (a, b) in enumerate(sl['items']))
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><div class="srcs body">{cells}</div><p class="foot">{fmt(sl["foot"])}</p>'
        deco = f'<div class="wm">{svg(icon, "ico", 0.6)}</div>'
    elif k == 'five':
        rules = ['الذكاء الاصطناعي **معين**، لا يحلّ محل أحد', 'اطلب **المراجع** والعبارة الأصلية',
                 '**تحقق** من الكتب', 'احفظ **البيانات** والحقوق', '**لازم** الشيوخ']
        li = ''.join(f'<li style="--i:{i}">{fmt(x)}</li>' for i, x in enumerate(rules))
        inner = f'''<div class="split"><div class="txt"><div class="eyebrow">{fmt(sl['eyebrow'])}</div>
<h2>{fmt(sl['title'])}</h2><ol class="body five">{li}</ol></div>{scene('star')}</div>'''
    elif k == 'homework':
        rows = ''.join(f'<li style="--i:{i}"><i class="no">{a}</i><span>{fmt(t)}</span><em>{m}</em></li>' for i, (a, t, m) in enumerate(sl['items']))
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><ul class="hw body">{rows}</ul>'
        deco = f'<div class="wm">{svg("calendar", "ico", 0.6)}</div>'
    elif k == 'prompt':
        inner = f'''<div class="eyebrow">{fmt(sl['eyebrow'])}</div><h2>{fmt(sl['title'])}</h2>
<div class="prompt body"><div class="pbar"><i></i><i></i><i></i><span>Prompt</span></div><p>{fmt(sl['text'])}</p></div>'''
        deco = f'<div class="wm">{svg("chat", "ico", 0.6)}</div>'
    else:
        raise SystemExit('kind?' + k)
    notes = f'<aside class="notes">{fmt(note)}</aside>' if note else ''
    num = '' if k in ('cover', 'closing') else f'<div class="num">{ar(n)}</div>'
    tm = '' if (dark or k in ('cover', 'closing')) else '<img class="tm" src="assets/openturath_dark.svg" alt="">'
    return f'<section class="{cls}" data-n="{n}">{deco}{tm}{inner}{st}{num}{notes}</section>'


CSS = '''
@font-face{font-family:'Scheherazade New';src:url('assets/fonts/scheherazade-new-arabic-400-normal.woff2') format('woff2');font-weight:400}
@font-face{font-family:'Scheherazade New';src:url('assets/fonts/scheherazade-new-arabic-700-normal.woff2') format('woff2');font-weight:700}
@font-face{font-family:'Outfit';src:url('assets/fonts/outfit-latin-400-normal.woff2') format('woff2');font-weight:400}
@font-face{font-family:'Outfit';src:url('assets/fonts/outfit-latin-500-normal.woff2') format('woff2');font-weight:500}
@font-face{font-family:'Outfit';src:url('assets/fonts/outfit-latin-600-normal.woff2') format('woff2');font-weight:600}
@font-face{font-family:'Outfit';src:url('assets/fonts/outfit-latin-700-normal.woff2') format('woff2');font-weight:700}
:root{--paper:#fff;--ink:#18181b;--muted:#71717a;--faint:#a1a1aa;--line:#e5e7eb;--line2:#d4d4d8;--surface:#f4f4f5;--obsidian:#0e0e10;--obs2:#18181b;--obs3:#27272a;--fog:#fafafa}
*{box-sizing:border-box;margin:0;padding:0}
html,body{height:100%;background:#d4d4d8;overflow:hidden}
body{font-family:Outfit,'Scheherazade New',serif;color:var(--ink);direction:rtl}
#viewport{position:fixed;inset:0;display:grid;place-items:center}
#stage{width:1920px;height:1080px;position:relative;transform-origin:center center;flex:none}
.slide{position:absolute;inset:0;display:none;isolation:isolate;padding:110px 150px 150px;overflow:hidden;
  background:
    radial-gradient(1200px 700px at 8% 100%,rgba(24,24,27,.07),transparent 60%),
    radial-gradient(900px 600px at 100% 0%,rgba(24,24,27,.05),transparent 60%),
    radial-gradient(circle at 1px 1px,rgba(24,24,27,.10) 1.6px,transparent 0) 0 0/38px 38px,
    var(--paper)}
.slide.on{display:block}
.slide.dark{background:var(--obsidian);color:var(--fog)}
.eyebrow{font-size:30px;font-weight:600;color:var(--muted);margin-bottom:22px;display:inline-flex;align-items:center;gap:14px}
.eyebrow::before{content:'';width:46px;height:4px;border-radius:2px;background:var(--ink)}
.dark .eyebrow{color:var(--faint)}.dark .eyebrow::before{background:var(--fog)}
h1{font-size:104px;line-height:1.3;font-weight:700}
h2{font-size:84px;line-height:1.3;font-weight:700;margin-bottom:34px}
h2.prod{font-family:Outfit,'Scheherazade New';direction:ltr;text-align:right;letter-spacing:-.01em}
h3{font-size:50px;font-weight:700;margin-bottom:14px}
.lede{font-size:44px;color:var(--muted);line-height:1.6;margin-top:22px}
.dark .lede{color:var(--faint)}
.lat{font-family:Outfit,sans-serif;font-weight:500;direction:ltr;unicode-bidi:isolate}
b{font-weight:700}
.tm{position:absolute;top:92px;inset-inline-end:150px;height:58px;display:none}

/* ── تخطيط: نص + مشهد ثلاثي الأبعاد ── */
.split{display:grid;grid-template-columns:minmax(0,1fr) 470px;gap:50px;align-items:start}
.body{font-size:58px;line-height:1.55}
ul.body,ol.body{list-style:none}
ul.body li,ol.body li{position:relative;background:var(--paper);border:2px solid var(--line);border-radius:24px;
  padding:14px 34px;padding-inline-start:92px;margin-bottom:16px;box-shadow:0 6px 0 var(--line2),0 18px 30px -18px rgba(0,0,0,.35)}
ul.body li::before{content:'';position:absolute;inset-inline-start:30px;top:50%;width:26px;height:26px;margin-top:-13px;border-radius:8px;background:var(--ink);transform:rotate(45deg)}
ol.body{counter-reset:o}
ol.body li{counter-increment:o}
ol.body li::before{content:counter(o,arabic-indic);position:absolute;inset-inline-start:22px;top:50%;margin-top:-30px;width:60px;height:60px;border-radius:50%;background:var(--ink);color:var(--paper);display:grid;place-items:center;font-size:32px;font-weight:700;line-height:1}
ul.body.c1{font-size:80px}ul.body.c2{font-size:74px}ul.body.c3{font-size:66px}ul.body.c4{font-size:60px}ul.body.c5{font-size:54px}ul.body.c6{font-size:48px}
ul.body.c5 li,ul.body.c6 li{padding-top:8px;padding-bottom:8px;margin-bottom:12px}
.split ul.body li,.split ol.body li{animation:rise .6s cubic-bezier(.2,.8,.2,1) both;animation-delay:calc(var(--i)*.09s + .12s)}
@keyframes rise{from{opacity:0;transform:translateY(26px) scale(.98)}to{opacity:1;transform:none}}
@keyframes floaty{0%,100%{transform:rotateX(58deg) rotateZ(-38deg) translateZ(0)}50%{transform:rotateX(58deg) rotateZ(-38deg) translateZ(26px)}}
@keyframes spin{to{transform:rotateY(360deg)}}
@keyframes orbit{0%,100%{transform:translateZ(0)}50%{transform:translateZ(36px)}}
@keyframes draw{from{stroke-dashoffset:540}}

.viz{position:relative;height:640px;perspective:1500px;display:grid;place-items:center;margin-top:30px}
.stack{position:relative;top:90px;width:340px;height:340px;transform-style:preserve-3d;transform:rotateX(58deg) rotateZ(-38deg);animation:floaty 6s ease-in-out infinite}
.stack .l{position:absolute;inset:0;border-radius:46px;border:2px solid var(--ink)}
.stack .l1{background:var(--ink);transform:translateZ(0)}
.stack .l2{background:linear-gradient(135deg,#d4d4d8,#a1a1aa);transform:translateZ(28px)}
.stack .l3{background:repeating-linear-gradient(45deg,#fff 0 14px,#f4f4f5 14px 28px);transform:translateZ(56px);box-shadow:0 0 0 10px rgba(255,255,255,.7)}
.ic2{position:absolute;top:10px;left:50%;margin-left:-125px;width:250px;height:250px;display:grid;place-items:center;color:var(--ink);z-index:3;animation:bob 6s ease-in-out infinite}
@keyframes bob{50%{transform:translateY(-22px)}}
.bigico{width:230px;height:230px;filter:drop-shadow(0 22px 14px rgba(0,0,0,.22))}
.orb{position:absolute;border-radius:50%;background:radial-gradient(circle at 30% 28%,#fff,#a1a1aa 55%,#27272a);animation:orbit 5s ease-in-out infinite}
.o1{width:54px;height:54px;left:-40px;top:30px;transform:translateZ(110px)}
.o2{width:34px;height:34px;right:-26px;bottom:60px;transform:translateZ(150px);animation-delay:-2s}
.o3{width:22px;height:22px;left:70px;bottom:-30px;transform:translateZ(90px);animation-delay:-3.4s}
.gshadow{position:absolute;bottom:16px;width:340px;height:60px;border-radius:50%;background:radial-gradient(closest-side,rgba(0,0,0,.28),transparent)}
.qg{font:700 330px/1 'Scheherazade New',serif;color:var(--ink);padding-top:90px;filter:drop-shadow(0 22px 14px rgba(0,0,0,.22))}
.dark .qg{color:var(--fog)}
blockquote.body{font-size:74px;line-height:1.5;font-weight:700;border-inline-start:10px solid var(--ink);padding-inline-start:56px;margin-top:20px}
.dark blockquote.body{border-color:var(--fog)}
.vb .sphere{position:relative;width:400px;height:400px;margin-top:70px;border-radius:50%;background:radial-gradient(circle at 32% 28%,#52525b,#18181b 55%,#000);box-shadow:inset -30px -40px 70px rgba(0,0,0,.6),0 40px 60px -20px rgba(0,0,0,.45);display:grid;place-items:center;animation:bob 6s ease-in-out infinite;transform-style:preserve-3d}
.vb .ic3{color:var(--fog);z-index:3}.vb .ic3 .bigico{filter:drop-shadow(0 10px 10px rgba(0,0,0,.5))}
.vb .rg{position:absolute;inset:-60px;border-radius:50%;border:3px solid var(--ink);transform:rotateX(74deg) rotateY(-12deg);animation:spinr 9s linear infinite}
.vb .rg.g2{inset:-110px;border-style:dashed;border-color:var(--faint);animation-duration:14s;animation-direction:reverse}
@keyframes spinr{to{transform:rotateX(74deg) rotateY(-12deg) rotateZ(360deg)}}
.vc .fan{position:relative;width:300px;height:380px;margin-top:70px}
.vc .cd{position:absolute;inset:0;border-radius:34px;border:2px solid var(--ink);background:var(--paper);box-shadow:0 30px 40px -18px rgba(0,0,0,.4)}
.vc .c1{background:var(--ink);transform:rotate(-16deg) translateX(-70px)}
.vc .c2{background:linear-gradient(160deg,#e4e4e7,#a1a1aa);transform:rotate(-7deg) translateX(-34px)}
.vc .c3{display:grid;place-items:center;transform:rotate(4deg);animation:bob 6s ease-in-out infinite;color:var(--ink);background:repeating-linear-gradient(45deg,#fff 0 14px,#f4f4f5 14px 28px)}
.vc .c3 .bigico{width:190px;height:190px}
.viz.timer{margin-top:20px}
.viz.timer svg{width:430px;height:430px;transform:rotate(-90deg);filter:drop-shadow(0 22px 20px rgba(0,0,0,.2))}
.viz.timer .track{fill:var(--paper);stroke:var(--line);stroke-width:14}
.viz.timer .ring{fill:none;stroke:var(--ink);stroke-width:14;stroke-linecap:round;stroke-dasharray:540;stroke-dashoffset:0;animation:draw 1.6s cubic-bezier(.2,.8,.2,1) both}
.viz.timer .t{position:absolute;text-align:center}
.viz.timer .t b{display:block;font-size:170px;line-height:1}
.viz.timer .t span{font-size:44px;color:var(--muted)}
.chip{display:inline-block;vertical-align:middle;border:2px solid var(--ink);border-radius:999px;padding:0 26px;font-size:34px;font-weight:600;margin-inline-start:18px;line-height:1.7}
.task h2{margin-bottom:26px}

/* ── بطاقات ── */
.wm{position:absolute;left:-60px;bottom:-80px;width:760px;height:760px;color:var(--ink);opacity:.07;pointer-events:none;z-index:-1}
.wm .ico{width:100%;height:100%}
.two{display:grid;grid-template-columns:1fr 92px 1fr;gap:0;align-items:center;margin-top:20px;perspective:1800px}
.two>div:not(.vs){border:2px solid var(--ink);border-radius:32px;padding:50px;background:var(--paper);min-height:480px;
  box-shadow:12px 14px 0 var(--ink)}
.two>div:first-child{transform:rotateY(7deg)}
.two>div.alt{transform:rotateY(-7deg);background:var(--surface)}
.vs{width:84px;height:84px;border-radius:50%;background:var(--ink);color:var(--paper);display:grid;place-items:center;margin:auto;z-index:2}
.vs .ico{width:46px;height:46px}
.two p{font-size:54px;line-height:1.6}
.grid4{display:grid;grid-template-columns:1fr 1fr;gap:34px}
.grid3{display:grid;grid-template-columns:repeat(3,1fr);gap:34px}
.grid4>div,.grid3>div{border:2px solid var(--ink);border-radius:28px;padding:40px 46px;background:var(--paper);box-shadow:9px 11px 0 var(--ink);animation:rise .6s both;animation-delay:calc(var(--i)*.1s + .1s)}
.grid4>div:nth-child(even),.grid3>div:nth-child(even){background:var(--surface)}
.grid4 p,.grid3 p{font-size:44px;color:var(--muted)}
.foot{font-size:38px;color:var(--muted);margin-top:30px}
.tcard{border:2px solid var(--ink);border-radius:30px;background:var(--paper);padding:10px 34px;box-shadow:12px 14px 0 var(--ink)}
table.body{border-collapse:collapse;width:100%;font-size:44px;line-height:1.3}
th,td{padding:14px 20px;text-align:right;border-bottom:2px solid var(--line)}
tbody tr:last-child td{border-bottom:none}
th{font-size:34px;color:var(--muted);font-weight:600}
td:last-child,th:last-child{text-align:center;width:150px}
td:first-child{width:170px;color:var(--muted)}
tbody tr:nth-child(odd){background:rgba(24,24,27,.035)}
.stages{display:grid;grid-template-columns:repeat(5,1fr);gap:26px}
.stages div{border:2px solid var(--ink);border-radius:26px;padding:30px 22px;background:var(--paper);text-align:center;
  box-shadow:0 1px 0 var(--ink),0 2px 0 var(--ink),0 3px 0 var(--ink),0 4px 0 var(--ink),0 5px 0 var(--ink),0 6px 0 var(--ink),0 7px 0 var(--ink),0 8px 0 var(--ink),0 9px 0 var(--ink),0 10px 0 var(--ink),0 22px 26px -10px rgba(0,0,0,.4);animation:rise .6s both;animation-delay:calc(var(--i)*.07s)}
.stages div:nth-child(even){background:var(--surface)}
.stages b{display:block;font-size:76px;line-height:1.1}
.stages span{font-size:40px;font-weight:600}
.srcs{display:grid;grid-template-columns:1fr 1fr;gap:34px}
.srcs>div{border:2px solid var(--ink);border-radius:28px;padding:26px 40px;background:var(--paper);box-shadow:9px 11px 0 var(--ink);animation:rise .6s both;animation-delay:calc(var(--i)*.1s)}
.srcs h3{font-size:46px;margin-bottom:6px}
.url{font-family:Outfit,sans-serif;font-size:38px;color:var(--muted);text-align:right;direction:ltr}
.five li{font-size:60px}
.hw{font-size:44px}
ul.body.hw li{display:grid;grid-template-columns:64px 1fr 110px;gap:26px;align-items:center;padding:12px 28px;margin-bottom:14px;animation:rise .6s both;animation-delay:calc(var(--i)*.09s)}
ul.body.hw li::before{display:none}
.hw .no{font-style:normal;width:56px;height:56px;border-radius:50%;background:var(--ink);color:var(--paper);display:grid;place-items:center;font-size:30px;line-height:1}
.hw em{font-style:normal;color:var(--muted);font-size:30px;text-align:center}
.hw span{line-height:1.45}
.prompt{border:2px solid var(--ink);border-radius:28px;background:var(--obsidian);color:var(--fog);box-shadow:12px 14px 0 var(--line2);overflow:hidden}
.pbar{display:flex;gap:12px;align-items:center;background:var(--obs3);padding:16px 26px}
.pbar i{width:20px;height:20px;border-radius:50%;background:#52525b;display:block}
.pbar span{margin-inline-start:auto;font:500 28px Outfit;color:var(--faint);direction:ltr}
.prompt p{font-size:42px;line-height:1.8;padding:40px 54px}
.pause{background:var(--surface)}
.pause h2{font-size:130px;margin-bottom:0}
.pause .eyebrow{font-size:44px}
.cup{position:absolute;left:210px;top:260px;width:520px;height:520px;color:var(--ink);opacity:.9;animation:floaty2 5s ease-in-out infinite}
.cup .bigico{width:100%;height:100%}
@keyframes floaty2{50%{transform:translateY(-24px) rotate(6deg)}}

/* ── حركة مظلمة: أرضية منظورية + شعار ثلاثي الأبعاد + رقم عملاق ── */
.slide.dark{padding-top:240px}
.slide.dark h2{font-size:100px;margin-bottom:10px}
.slide.dark.small h2{font-size:92px}
.slide.dark .tm{display:none}
.floor{position:absolute;left:-10%;right:-10%;bottom:-6%;height:52%;
  background:linear-gradient(#52525b 2px,transparent 2px) 0 0/100% 70px,linear-gradient(90deg,#52525b 2px,transparent 2px) 0 0/90px 100%;
  transform:perspective(520px) rotateX(64deg);transform-origin:center bottom;
  -webkit-mask-image:linear-gradient(transparent,#000 70%);mask-image:linear-gradient(transparent,#000 70%);opacity:.9}
.glow{position:absolute;left:-5%;top:10%;width:900px;height:900px;background:radial-gradient(closest-side,rgba(250,250,250,.14),transparent)}
.bignum{position:absolute;left:150px;top:90px;font:700 760px/1 'Scheherazade New',serif;color:transparent;-webkit-text-stroke:3px rgba(250,250,250,.28);transform:perspective(1200px) rotateY(24deg) rotateX(6deg);transform-origin:left center}
.mark3d{position:absolute;right:150px;top:84px;width:110px;height:110px;perspective:600px}
.mark3d img{width:100%;height:100%;animation:spin 9s linear infinite}
.dark .num{color:#52525b}

.cover{padding-top:70px;text-align:right}
.cover .logos{display:flex;align-items:center;gap:56px;margin-bottom:40px;direction:ltr;justify-content:flex-end;position:relative;z-index:2}
.cover .logos .ot{height:150px}
.cover .logos .ruqi{height:190px}
.cover .logos .sep{width:2px;height:150px;background:var(--line2)}
.cover .eyebrow{font-size:34px}
.cover h1,.cover .lede{position:relative;z-index:2}
.hero3d{position:absolute;left:30px;top:250px;width:560px;height:560px;perspective:1400px;transform-style:preserve-3d}
.hero3d .mk{position:absolute;inset:105px;width:350px;height:350px;filter:drop-shadow(0 40px 26px rgba(0,0,0,.28));animation:spin 14s linear infinite}
.ring3{position:absolute;inset:0;border-radius:50%;border:3px solid var(--ink);transform:rotateX(72deg)}
.ring3.r2{inset:60px;border-style:dashed;border-color:var(--faint);transform:rotateX(72deg) rotateY(22deg)}
.presenter{position:absolute;inset-inline-start:150px;bottom:64px;display:flex;flex-direction:column;gap:2px;font-size:34px;color:var(--muted);
  border-inline-start:6px solid var(--ink);padding-inline-start:26px;z-index:2}
.presenter b{font-size:56px;color:var(--ink)}
.strip{position:absolute;bottom:56px;inset-inline-start:150px;inset-inline-end:260px;display:flex;align-items:center;gap:30px;font-size:26px;color:var(--muted)}
.strip div{display:flex;gap:10px;flex:1}
.strip i{flex:1;height:10px;border-radius:5px;background:var(--line);display:block}
.strip i.done{background:var(--faint)}
.strip i.on{background:var(--ink);box-shadow:0 0 0 4px rgba(24,24,27,.15)}
.dark .strip{color:var(--faint)}
.dark .strip i{background:var(--obs3)}
.dark .strip i.done{background:#52525b}
.dark .strip i.on{background:var(--fog);box-shadow:0 0 0 4px rgba(250,250,250,.15)}
.num{position:absolute;bottom:48px;inset-inline-end:150px;font-size:30px;color:var(--faint)}
.notes{display:none}
#bar{position:fixed;top:0;inset-inline-start:0;height:4px;background:var(--ink);width:0;z-index:5;transition:width .2s}
#hud{position:fixed;bottom:12px;inset-inline-end:16px;font:500 13px Outfit,sans-serif;color:#52525b;background:rgba(255,255,255,.8);padding:6px 12px;border-radius:999px;z-index:5;opacity:0;transition:opacity .3s}
body:hover #hud{opacity:1}
#notebox{position:fixed;left:0;right:0;bottom:0;background:var(--obsidian);color:var(--fog);font-size:22px;line-height:1.6;padding:16px 28px;display:none;z-index:6;direction:rtl}
body.shownotes #notebox{display:block}
@media print{
  @page{size:1920px 1080px;margin:0}
  html,body{overflow:visible;background:#fff;height:auto}
  #viewport{position:static;display:block}
  #stage{transform:none!important;width:1920px;height:auto}
  .slide{display:block!important;position:relative;inset:auto;height:1080px;page-break-after:always;break-after:page}
  #bar,#hud,#notebox{display:none!important}
  *{-webkit-print-color-adjust:exact;print-color-adjust:exact;animation:none!important}
  .viz.timer .ring{stroke-dashoffset:0}
}
'''

JS = '''
(function(){
var slides=[].slice.call(document.querySelectorAll('.slide'));
var stage=document.getElementById('stage'),bar=document.getElementById('bar'),nb=document.getElementById('notebox'),hud=document.getElementById('hud');
var cur=0;
var AR='٠١٢٣٤٥٦٧٨٩';function ar(n){return String(n).replace(/\\d/g,function(d){return AR[d]})}
function fit(){var s=Math.min(innerWidth/1920,innerHeight/1080);stage.style.transform='scale('+s+')';}
function fitText(sl){
  var strip=sl.querySelector('.strip'),bottom=strip?930:975;
  sl.querySelectorAll('.body').forEach(function(el){el.style.fontSize='';
    var fs=parseFloat(getComputedStyle(el).fontSize),lim=bottom-el.offsetTop,guard=60;
    var top=el.getBoundingClientRect();
    while(guard-->0&&el.scrollHeight>lim&&fs>24){fs-=2;el.style.fontSize=fs+'px';}});
}
function fitAll(){slides.forEach(function(s){var on=s.classList.contains('on');if(!on)s.style.display='block';fitText(s);if(!on)s.style.display='';});}
function go(n){cur=Math.max(0,Math.min(slides.length-1,n));slides.forEach(function(s,i){s.classList.toggle('on',i===cur)});
  bar.style.width=((cur+1)/slides.length*100)+'%';
  var no=slides[cur].querySelector('.notes');nb.textContent=no?no.textContent:'';hud.textContent=ar(cur+1)+' / '+ar(slides.length);
  try{history.replaceState(null,'','#'+(cur+1))}catch(e){}}
addEventListener('resize',fit);
addEventListener('keydown',function(e){var k=e.key;
  if(k==='ArrowLeft'||k==='PageDown'||k===' '||k==='Enter'){e.preventDefault();go(cur+1)}
  else if(k==='ArrowRight'||k==='PageUp'||k==='Backspace'){e.preventDefault();go(cur-1)}
  else if(k==='Home'){go(0)}else if(k==='End'){go(slides.length-1)}
  else if(k==='f'||k==='F'){document.fullscreenElement?document.exitFullscreen():document.documentElement.requestFullscreen()}
  else if(k==='n'||k==='N'){document.body.classList.toggle('shownotes')}});
var x0=null;addEventListener('touchstart',function(e){x0=e.touches[0].clientX},{passive:true});
addEventListener('touchend',function(e){if(x0===null)return;var dx=e.changedTouches[0].clientX-x0;if(Math.abs(dx)>50){go(cur+(dx<0?1:-1))}x0=null});
document.getElementById('viewport').addEventListener('click',function(e){if(e.clientX<innerWidth/2)go(cur+1);else go(cur-1)});
fit();var h=parseInt(location.hash.slice(1),10);go(isNaN(h)?0:h-1);
document.fonts.ready.then(function(){fitAll();go(isNaN(h)?0:h-1)});
})();
'''


def render(slides, stages, here):
    STAGES_G[:] = stages
    parts = [body(sl, i + 1) for i, sl in enumerate(slides)]
    doc = f'''<!doctype html>
<html lang="ar" dir="rtl">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>استخدام الذكاء الاصطناعي في مجال البحث العلمي</title>
<style>{CSS}</style></head>
<body>
<div id="bar"></div>
<div id="viewport"><div id="stage">
{chr(10).join(parts)}
</div></div>
<div id="notebox"></div><div id="hud"></div>
<script>{JS}</script>
</body></html>'''
    out = here / 'slides_ar.html'
    out.write_text(doc, encoding='utf-8')
    print(f'{len(slides)} slides -> {out}')
