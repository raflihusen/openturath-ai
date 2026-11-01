#!/usr/bin/env python3
"""Membangun slide dauroh (HTML tunggal, RTL) dari data di bawah.

Pakai:  python3 build_slides.py   ->  slides_ar.html
Bahasa desain: situs OpenTurath (monokrom, Outfit + Scheherazade New).
"""
import html
import re
from pathlib import Path

HERE = Path(__file__).parent
AR_DIGITS = str.maketrans('0123456789', '٠١٢٣٤٥٦٧٨٩')


def ar(n):
    return str(n).translate(AR_DIGITS)


def fmt(s):
    s = html.escape(s, quote=False)
    s = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', s)
    s = re.sub(r'`(.+?)`', r'<bdi class="lat">\1</bdi>', s)
    return s


STAGES = ['العنوان', 'الإشكالية', 'الخطة', 'المصادر', 'القراءة والتخريج',
          'الكتابة', 'العربية', 'الأستاذ الشديد', 'المراجعة', 'المناقشة']

S = []  # list of slides


def add(kind, **kw):
    kw['kind'] = kind
    S.append(kw)


# ───────────────────────── الافتتاح ─────────────────────────
add('cover')
add('points', eyebrow='الدورة', title='ماذا سنحمل معنا في نهاية اليومين؟', stage=None,
    items=['**عنوان** بحث واضح مكتوب بالعربية',
           '**إشكالية** وأهداف وحدود محددة',
           '**خطة أبواب** مترابطة',
           '**قائمة مصادر** حقيقية تم التحقق منها',
           '**طريقة** نفحص بها كل ما يقوله الذكاء الاصطناعي'],
    note='يُقال في أول الدورة. هذه هي النتائج التي يُقاس بها نجاح اليومين.')
add('quote', eyebrow='قاعدة الدورة',
    text='الذكاء الاصطناعي يعين،\nوالحق يُتحقَّق منه في الكتب،\nوالعلم يُؤخذ عن الشيوخ.',
    note='تتكرر هذه الجملة في بداية كل جلسة.')
add('points', eyebrow='قواعد العمل', title='كيف نعمل معًا؟',
    items=['اسأل في أي وقت، ولا يوجد سؤال سخيف',
           'نعمل غالبًا في **أزواج**',
           'كل جلسة تنتهي بـ**تكليف** نعمله فعلًا',
           'في آخر اليوم الأول **واجب منزلي** لليوم الثاني',
           'موضوع بحث **واحد** يرافقنا من أول الدورة إلى آخرها',
           'الناتج النهائي **بالعربية**'])
add('points', eyebrow='قبل أن نبدأ', title='اختبار قبلي بلا درجات',
    items=['هل استخدمتَ الذكاء الاصطناعي من قبل؟',
           'هل تثق بإجاباته؟',
           'ما أكثر ما تخشاه منه؟'],
    note='تُجمع الأجوبة ثم تُقارن بالاختبار البعدي في آخر اليوم الثاني.')
add('points', eyebrow='قبل أن نبدأ', title='فحص الحساب والاتصال',
    items=['ادخل إلى أداة الذكاء الاصطناعي المستخدمة في الدورة',
           'تأكد من الاتصال بالإنترنت ومن لوحة المفاتيح العربية',
           'من لم يستطع الدخول يساعده المنظمون أثناء الجلسة'])
add('stages', eyebrow='خريطة الدورة', title='مراحل البحث العشر',
    note='تُعرض هنا ثم تظهر في كل انتقال بين الجلسات مع تمييز المرحلة الجارية.')
add('table', eyebrow='الجدول', title='اليوم الأول (١/٢)',
    head=['الوقت', 'الجلسة', 'دقائق'],
    rows=[['٠:٠٠', 'الافتتاح وفحص الأجهزة', '١٥'],
          ['٠:١٥', 'ج١ | التعرف على الذكاء الاصطناعي', '٢٥'],
          ['٠:٤٠', 'ج٢ | كيف يعمل ولماذا يخطئ', '٣٠'],
          ['١:١٠', 'استراحة', '١٥'],
          ['١:٢٥', 'ج٣ | كيف نسأل الذكاء الاصطناعي', '٣٥'],
          ['٢:٠٠', 'ج٤ | الاستخدام الآمن والأدب', '٢٠']],
    note='٢٤٠ دقيقة يوميًا تشمل الاستراحات والصلاة. غيّر الأوقات بحسب برنامج المكان.')
add('table', eyebrow='الجدول', title='اليوم الأول (٢/٢)',
    head=['الوقت', 'الجلسة', 'دقائق'],
    rows=[['٢:٢٠', 'استراحة / صلاة', '١٥'],
          ['٢:٣٥', 'ج٥ | العنوان والإشكالية', '٤٥'],
          ['٣:٢٠', 'ج٦ | خطة الأبواب', '٣٠'],
          ['٣:٥٠', 'الختام وتسليم الواجب', '١٠']])
add('table', eyebrow='الجدول', title='اليوم الثاني (١/٢)',
    head=['الوقت', 'الجلسة', 'دقائق'],
    rows=[['٠:٠٠', 'الافتتاح: مراجعة الواجب', '١٠'],
          ['٠:١٠', 'ج٧ | البحث عن المصادر', '٤٥'],
          ['٠:٥٥', 'ج٨ | القراءة والتدوين والتخريج', '٣٥'],
          ['١:٣٠', 'استراحة', '١٥'],
          ['١:٤٥', 'ج٩ | الكتابة وفحص النقول', '٢٥'],
          ['٢:١٠', 'ج١٠ | تصحيح العربية', '٣٠']],
    note='عند ضيق الوقت يُحذف بالترتيب: (١) تكليف ج٩ وج١٢، (٢) شريحتا الوكيل الذكي ومعاني المصطلحات، (٣) إعادة العرض في ج٢، (٤) فقرة التعلم من الأخطاء في ج١٠. لا يُحذف: ج٢، وفحص النقول في ج٩، وج١١، وج١٣.')
add('table', eyebrow='الجدول', title='اليوم الثاني (٢/٢)',
    head=['الوقت', 'الجلسة', 'دقائق'],
    rows=[['٢:٤٠', 'استراحة / صلاة', '١٥'],
          ['٢:٥٥', 'ج١١ | الأستاذ الشديد', '٣٠'],
          ['٣:٢٥', 'ج١٢ | اللمسات الأخيرة', '٥'],
          ['٣:٣٠', 'ج١٣ | التعريف بـ OpenTurath', '٢٠'],
          ['٣:٥٠', 'الختام والتقويم', '١٠']])

# ───────────────────────── اليوم الأول ─────────────────────────
add('divider', eyebrow='اليوم الأول', title='فهم الذكاء الاصطناعي ثم تصميم البحث',
    sub='ج١ إلى ج٦')

# ج١
add('divider', eyebrow='الجلسة ١ | ٢٥ دقيقة', title='التعرف على الذكاء الاصطناعي',
    sub='الهدف: ألا نراه سحرًا ولا عالِمًا رقميًا', small=True)
add('points', eyebrow='ج١', title='ذكاء اصطناعي نستخدمه دون أن ننتبه',
    items=['الترجمة الآلية', 'اقتراح الكلمات أثناء الكتابة', 'المساعد الصوتي في الهاتف'])
add('points', eyebrow='ج١', title='لماذا يتردد كثيرون؟',
    items=['غالبًا لأنهم تلقّوا جوابًا **خاطئًا بنبرة واثقة**',
           'نتحدث بصدق: من منا مرّ بهذا؟'],
    note='يُشجَّع الحضور على الحكي. لا يُعلَّق بالسخرية.')
add('points', eyebrow='ج١ | مصطلح', title='النموذج اللغوي الكبير (`LLM`)',
    items=['برنامج دُرّب على كمٍّ هائل من النصوص',
           'فبرع في **إكمال الكلام** إكمالًا معقولًا',
           'مثاله: شخص قرأ كثيرًا جدًا، لكنه لا يتذكر دائمًا **أين قرأ**'],
    note='تبسيط يكفي للمبتدئ.')
add('points', eyebrow='ج١ | مصطلح', title='الإطار المحيط (`Harness`)',
    items=['ما يحيط بالنموذج من **تعليمات** وأدوات مسموح له بها (كالبحث وفتح الملفات) و**قيود**',
           'النموذج **محرك**، والإطار **السيارة كاملةً**: مقود وفرامل وإشارات',
           'المحرك الواحد يتصرف بشكل مختلف في تطبيقات مختلفة',
           'فجودة الذكاء الاصطناعي ليست من النموذج وحده، بل من **إطاره** أيضًا'])
add('points', eyebrow='ج١ | مصطلح', title='الوكيل الذكي (`Agent`)',
    items=['نموذج أُعطي **أدوات** لينفذ عدة خطوات متتابعة'],
    note='يكفي معرفة الاسم. جملة واحدة.')
add('compare', eyebrow='ج١', title='الفرق عن محرك البحث',
    a_title='محرك البحث', a='يدلّك على **مكان** النص',
    b_title='الذكاء الاصطناعي', b='**يؤلّف** جوابًا جديدًا، ولذلك قد يبدو صحيحًا وهو خطأ')
add('task', minutes=5, eyebrow='ج١', title='اسأل، ثم ميّز',
    items=['افتح أداة الذكاء الاصطناعي واكتب: «ما هو بيع السلَم؟»',
           'دوّن في الورقة: **ماذا أجاب**؟ وما الذي **تتيقن** صحته؟ وما الذي **لا تتيقنه**؟',
           'يعرض زوج واحد نتيجته'],
    mode='ثنائي')

# ج٢
add('divider', eyebrow='الجلسة ٢ | ٣٠ دقيقة', title='كيف يعمل ولماذا يخطئ',
    sub='الهدف: أن نفهم سبب الخطأ، ولماذا هو أخطر في العلوم الشرعية', small=True)
add('points', eyebrow='ج٢ | لماذا يخطئ', title='الهلوسة',
    items=['قد **يخترع** كتابًا أو مؤلفًا أو جزءًا أو صفحة', 'بل قد يخترع حديثًا'])
add('points', eyebrow='ج٢ | لماذا يخطئ', title='النبرة الواثقة ليست دليل الصواب',
    items=['الجواب الخاطئ يبدو بالثقة نفسها التي يبدو بها الجواب الصحيح'])
add('points', eyebrow='ج٢ | لماذا يخطئ', title='يميل إلى إرضائك',
    items=['إن استدرجتَه **وافق**', 'وإن اعترضتَ عليه **تراجع**',
           'فلا تصغ الأسئلة صياغةً موحية'])
add('points', eyebrow='ج٢ | لماذا يخطئ', title='جوابه يختلف في كل مرة',
    items=['جواب واحد **ليس حكمًا**', 'أعد السؤال وقارن'])
add('points', eyebrow='ج٢ | لماذا يخطئ', title='يخلط المذاهب والعصور والسياقات',
    items=['ينسب قول مذهب إلى مذهب آخر', 'يقتطع النقل فيتغير معناه'])
add('points', eyebrow='ج٢', title='لماذا الأمر أشدّ في العلم الشرعي؟',
    items=['الخطأ الصغير يصير **نسبةً** أو **حكمًا** خاطئًا', 'وهنا يأتي مبدأ **التثبّت**'],
    note='يُربط بقوله تعالى: «فتبيّنوا».')
add('demo', eyebrow='ج٢ | عرض ٥ دقائق', title='سؤال واحد… مرتان',
    items=['نطرح السؤال نفسه مرتين', 'نقارن الجوابين', 'ونبحث عن مرجع لا وجود له'],
    note='يُعدّ تسجيل شاشة احتياطيًا إن تعطل الاتصال. تُجرَّب الأسئلة قبل الدورة؛ جواب الذكاء الاصطناعي لا يتكرر بحروفه.')
add('quote', eyebrow='ج٢ | القاعدة الذهبية',
    text='الذكاء الاصطناعي **معين في البحث**\nليس مصدرًا، ولا شيخًا، ولا مفتيًا')
add('task', minutes=7, eyebrow='ج٢', title='اختبر المراجع بنفسك',
    items=['اطرح على الذكاء الاصطناعي مسألة فقهية **تعرف جوابها**',
           'اطلب الكتاب والجزء والصفحة',
           'ضع على كل مرجع علامة: **تأكدتُ** / **لم أتحقق** / **ثبت خطؤه**',
           'عُدّ ما ثبت خطؤه أو لم يوجد'],
    mode='فردي')
add('pause', title='استراحة', minutes=15)

# ج٣
add('divider', eyebrow='الجلسة ٣ | ٣٥ دقيقة', title='كيف نسأل الذكاء الاصطناعي',
    sub='الهدف: أن نكتب أمرًا يعطي جوابًا مفيدًا', small=True)
add('points', eyebrow='ج٣', title='ما هو «الأمر» (`Prompt`)؟',
    items=['هو ما نكتبه للذكاء الاصطناعي', 'وجودة الجواب تتبع جودته كثيرًا'])
add('four', eyebrow='ج٣', title='أربعة عناصر لأمر جيد',
    items=[('الدور', 'من أنت؟'), ('المهمة', 'ماذا نريد؟'),
           ('المادة', 'ما السياق الذي نعطيه؟'), ('الصيغة', 'كيف يكون الجواب؟ وما قيوده؟')])
add('compare', eyebrow='ج٣ | مثال', title='أمر رديء وأمر جيد',
    a_title='رديء', a='اكتب لي عن الربا.',
    b_title='جيد',
    b='أنت مرشد لطالب علم مبتدئ. اشرح تعريف الربا في ثلاث نقاط موجزة، واذكر الكتاب والجزء والصفحة لكل نقطة. وإن لم تكن متأكدًا فقل: لا أعلم.',
    note='المثالان للتوضيح فقط. يُستبدلان بمثالين من موضوع الحضور.')
add('points', eyebrow='ج٣', title='السياق = ذاكرة المحادثة',
    items=['لا يعرف إلا ما في **هذه المحادثة**',
           'المحادثة الطويلة **تُنسّيه** أولها',
           'الحل: **لخّص** ثم ابدأ محادثة جديدة بالملخص'])
add('quote', eyebrow='ج٣ | اطلب منه أن يسألك',
    text='قبل أن تجيب،\nاسألني عمّا تحتاج معرفته.',
    note='هذه الجملة هي أساس الجلسة ٥.')
add('points', eyebrow='ج٣', title='اطلب المراجع والعبارة الأصلية',
    items=['اطلب الكتاب والجزء والصفحة', 'اطلب **العبارة العربية كما وردت**',
           'ثم ضع علامة: هذا كله **يُتحقَّق منه**'])
add('points', eyebrow='ج٣', title='أسئلة المتابعة أدوات اختبار',
    items=['«من أين هذا؟»', '«ما القول المخالف؟»', '«أرني العبارة العربية.»',
           '«أي جزء لست متأكدًا منه؟»'])
add('task', minutes=12, eyebrow='ج٣', title='صحّح الأمر الخام',
    items=['خذ الأمر الخام من ورقة العمل', 'أعد كتابته بالعناصر الأربعة',
           'جرّب الأمرين وقارن الجوابين'],
    mode='ثنائي')

# ج٤
add('divider', eyebrow='الجلسة ٤ | ٢٠ دقيقة', title='الاستخدام الآمن والأدب',
    sub='الهدف: عادات سليمة منذ البداية', small=True)
add('points', eyebrow='ج٤', title='ثلاث «لاءات»',
    items=['**لا** تُدخل بيانات شخصية',
           '**لا** تُدخل بيانات أشخاص آخرين أو مستفتين',
           '**لا** تُدخل مخطوطات سرية',
           'في أداة **لا تفهم سياسة بياناتها**. اقرأ إعدادات البيانات مرة واحدة في البداية'])
add('points', eyebrow='ج٤', title='حقوق التأليف وأدب المصدر',
    items=['انسب كل نقل إلى مصدره', 'لا تُعد نشر ما له حقوق'])
add('points', eyebrow='ج٤', title='اذكر استخدامك للذكاء الاصطناعي',
    items=['بصدق، ووفق لوائح الجامعة أو الجهة'])
add('points', eyebrow='ج٤', title='ما لا يُترك للذكاء الاصطناعي',
    items=['الحكم الشرعي', 'الفتوى', 'الحكم على درجة الحديث', 'الاستنتاج دون فتح الكتاب'])
add('quote', eyebrow='ج٤', text='الذكاء الاصطناعي **ليس شيخًا**\nالسند وتوجيه الشيوخ هما طريق العلم',
    note='هو يسرّع العمل في البحث فقط.')
add('task', minutes=3, eyebrow='ج٤', title='بطاقتي الشخصية',
    items=['اكتب على بطاقة ثلاث قواعد شخصية لاستخدامك:',
           'قاعدة في **البيانات**', 'قاعدة في **التحقق**', 'قاعدة في **الشيخ**',
           'احتفظ بالبطاقة؛ نعود إليها في ختام اليوم الثاني'],
    mode='فردي')
add('pause', title='استراحة / صلاة', minutes=15)

# ج٥
add('divider', eyebrow='الجلسة ٥ | ٤٥ دقيقة', title='العنوان والإشكالية',
    sub='الهدف: عنوان وإشكالية وأهداف وحدود', small=True, stage=0)
add('points', eyebrow='ج٥', title='أشيع الأخطاء: كتابة العنوان أولًا',
    items=['العنوان الجيد **نتيجة** لفهم المشكلة، لا نقطة بداية'], stage=0)
add('points', eyebrow='ج٥ | الفكرة', title='الذكاء الاصطناعي «المحاوِر»',
    items=['بخلاف الدردشة العادية: **يسأل أولًا**', 'ثم يبني على أجوبتك',
           'فتُبنى الخطة على **سياقك** وعلى **النتيجة التي تريدها**'], stage=0)
add('points', eyebrow='ج٥ | أسئلة المحاوِر', title='ماذا يسألك؟',
    items=['ما الذي يشغلك؟ وفي أي فن؟', 'لأي مرحلة؟ وبأي لغة تكتب؟',
           'أي كتب تألفها؟', 'كم الوقت المتاح؟', 'ماذا يريد مشرفك؟'], stage=0)
add('points', eyebrow='ج٥', title='ما الذي يجمعه المحاوِر؟',
    items=['الفن والمشكلة', 'النطاق', 'نوع البحث: مكتبي، مقارن، تحليل موضوعي، تخريج',
           'المصادر الأولية المحتملة', 'النتيجة المرجوة'], stage=0)
add('points', eyebrow='ج٥', title='من الأجوبة إلى خيارات العنوان',
    items=['كل خيار معه **سببه** و**مخاطره**:', 'واسع جدًا؟ مُشبع بحثًا؟ مصادره قليلة؟'], stage=0)
add('points', eyebrow='ج٥', title='ثلاثة أسئلة لاختبار العنوان',
    items=['هل يمكن الإجابة عنه **بالمصادر المتاحة**؟', 'ما **الجديد** فيه؟', 'هل **حدوده** واضحة؟'], stage=0)
add('points', eyebrow='ج٥', title='الإشكالية والأهداف والحدود',
    items=['تُبنى من أجوبتك، وأنت من **يحرّرها**',
           '**يُكتب العنوان والإشكالية النهائيان بالعربية**',
           'اكتب نسختك العربية أولًا، ثم اطلب التصحيح (نعود إليه في ج١٠)'], stage=1)
add('task', minutes=25, eyebrow='ج٥', title='حاور، اختر، اكتب',
    items=['حاور الذكاء الاصطناعي المحاوِر', 'اختر **عنوانًا واحدًا**',
           'اكتب **الإشكالية بالعربية**', 'من ليس له موضوع: يختار من «أفكار مواضيع»'],
    mode='فردي', stage=1)
add('points', eyebrow='ج٥ | للاستئناس', title='أفكار مواضيع (١)',
    items=['أحكام بيع السلم عند الشافعية', 'زكاة الحلي بين المذاهب الأربعة',
           'أحكام التعامل بالعملات الرقمية عند المعاصرين',
           'دلالة الأمر عند الأصوليين', 'قاعدة «المشقة تجلب التيسير» وتطبيقاتها',
           'مراحل تدوين المذهب الشافعي'],
    note='أمثلة للاستئناس فقط. لمن ليس له موضوع.', stage=1)
add('points', eyebrow='ج٥ | للاستئناس', title='أفكار مواضيع (٢)',
    items=['تخريج أحاديث كتاب الطهارة في كتاب فقهي', 'آيات الأحكام في سورة البقرة',
           'أساليب الشرط في القرآن الكريم', 'ألفاظ المعاملات المالية في كتب الفقه: دراسة دلالية',
           'أدب طالب العلم في كتب التراجم', 'دراسة مخطوط فقهي: وصف وتحقيق موجز'],
    note='أمثلة للاستئناس فقط. لمن ليس له موضوع.', stage=1)

# ج٦
add('divider', eyebrow='الجلسة ٦ | ٣٠ دقيقة', title='خطة الأبواب',
    sub='الهدف: خطة أبواب وفصول مترابطة', small=True, stage=2)
add('points', eyebrow='ج٦', title='الخطة خريطة لا سجن',
    items=['يجوز تغييرها، لكن **يجب أن توجد**', 'تُبنى على **سياقك** كله من الجلسة ٥'], stage=2)
add('compare', eyebrow='ج٦', title='النمط المعتاد',
    a_title='البحث الأكاديمي', a='مقدمة | إطار نظري | منهج | مناقشة | خاتمة',
    b_title='ترتيب الفقهاء', b='التعريف | الدليل | الأقوال | الترجيح', stage=2)
add('points', eyebrow='ج٦', title='اختبر خطتك',
    items=['هل كل باب يجيب عن جزء من الإشكالية؟', 'هل فيه **تداخل**؟', 'هل فيه **قفزة**؟'], stage=2)
add('points', eyebrow='ج٦', title='اربط الخطة بالمصادر',
    items=['لكل فصل قائمة بما **يلزم البحث عنه**', 'وهذا جسر إلى اليوم الثاني'], stage=2)
add('task', minutes=15, eyebrow='ج٦', title='ابنِ خطة الأبواب',
    items=['ابنِ خطة الأبواب والفصول **بالعربية**',
           'ضع **نجمة** على ثلاثة فصول أحوج ما تكون إلى مصادر'],
    mode='فردي', stage=2)

# ختام اليوم الأول
add('five', eyebrow='ختام اليوم الأول', title='القواعد الخمس')
add('homework', eyebrow='الواجب المنزلي', title='واجب لليوم الثاني',
    note='نحو ٦٠ إلى ٩٠ دقيقة، يُسلَّم مكتوبًا.',
    items=[('١', 'العنوان والإشكالية **بالعربية**، بعد إعادة المحاورة في البيت', '٢٠ د'),
           ('٢', 'خطة الأبواب بعد ترتيبها، مع علامة على ثلاثة فصول أحوج للمصادر', '١٠ د'),
           ('٣', '**ثلاثة مصادر حقيقية**: العنوان، المؤلف، الناشر أو الطبعة، ومكان الملف. تبحث عنها **بنفسك** لا بالذكاء الاصطناعي', '٣٠ د'),
           ('٤', '**فقرة عربية من كتابتك**، ٥ إلى ٨ أسطر عن موضوعك. لم يصححها أحد ولم يلمسها الذكاء الاصطناعي', '١٥ د'),
           ('٥', 'ورقة اختبار: اسأل السؤال نفسه مرتين في وقتين مختلفين، واكتب ما اختلف', '٥ د')])
add('points', eyebrow='الواجب المنزلي', title='تنظيم التسليم',
    items=['**الحد الأدنى** عند ضيق الوقت: البندان ١ و٤ فقط',
           'تُسلَّم ورقة الواجب مطبوعة',
           'يُرسل نموذج تسليم قصير (صورة أو ملف) **قبل اليوم الثاني بيوم**',
           'يراجعه المنظمون سريعًا ويجهزون المساعدة لمن لم يكمل',
           'البند ٤ يُستعمل مباشرة في الجلستين ١٠ و١١'])

# ───────────────────────── اليوم الثاني ─────────────────────────
add('divider', eyebrow='اليوم الثاني', title='تنفيذ البحث حتى النهاية',
    sub='ج٧ إلى ج١٣')
add('points', eyebrow='الافتتاح | ١٠ دقائق', title='مراجعة اليوم الأول وفحص الواجب',
    items=['من أنجز البنود **الخمسة**؟', 'يحكي اثنان ما وجداه في **ورقة الاختبار** (البند ٥)',
           'من لم ينجز البند ٣ أو ٤ يُمنح وقتًا قصيرًا بين الجلسات',
           'الواجب يُستعمل مباشرة في ج٧ وج١٠ وج١١'])

# ج٧
add('divider', eyebrow='الجلسة ٧ | ٤٥ دقيقة', title='البحث عن المصادر',
    sub='الهدف: أين نبحث؟ وكيف نصفّي؟ وما الجائز أخذه؟', small=True, stage=3)
add('compare', eyebrow='ج٧', title='المصادر الأولية والثانوية',
    a_title='أولية', a='**الكتب الأصلية** التي تُبنى عليها الدعوى',
    b_title='ثانوية', b='ما كُتب **عنها**: كتب ورسائل ومقالات. الرسائل تدلّ على الطريق ولا يُنقل منها', stage=3)
add('sources', eyebrow='ج٧', title='المكتبات الرقمية للكتب',
    items=[('المكتبة الشاملة', 'shamela.ws'), ('وقفية', 'waqfeya.net'),
           ('تراث', 'turath.io'), ('الأرشيف العام', 'archive.org')],
    foot='حقوق التأليف تختلف من مجموعة لأخرى', stage=3,
    note='استجابت المواقع الأربعة وقت الفحص في ١ نوفمبر ٢٠٢٦م. تُراجع الروابط قبل الطباعة.')
add('sources', eyebrow='ج٧', title='الحديث والفتوى',
    items=[('الدرر السنية', 'dorar.net'), ('إسلام ويب', 'islamweb.net')],
    foot='يُفتح كل موقع يدويًا قبل الاعتماد عليه', stage=3,
    note='رفض dorar.net فحصًا آليًا وقت الإعداد؛ يُتأكد منه يدويًا.')
add('sources', eyebrow='ج٧', title='المجلات والرسائل العلمية',
    items=[('Google Scholar', 'scholar.google.com'), ('بوابات المجلات الوطنية', 'Garuda | SINTA')],
    foot='عناوين البوابات الحكومية تتغير؛ تعلّم **طريقة البحث** عنها ولا تحفظ العنوان', stage=3,
    note='لم يستجب Garuda وقت الفحص، ورفض SINTA الفحص الآلي. يُراجَع العنوان قبل الدورة.')
add('points', eyebrow='ج٧', title='تيليغرام ومجموعات تبادل الكتب',
    items=['عملي، لكن **الجودة متفاوتة**',
           'ملفات ممسوحة بلا تحقيق، وطبعات مجهولة', 'أسماء ملفات مضللة، وإشكال الحقوق',
           'نتعلم **طريقة تقييمها** لا قائمة قنوات'], stage=3)
add('points', eyebrow='ج٧', title='كيف نقيّم طبعة الكتاب؟',
    items=['الناشر والسنة ورقم الطبعة', 'المحقق', 'اكتمال الأجزاء', 'جودة النص',
           'وتُطابَق مع طبعة الجامعة أو المشرف'], stage=3)
add('points', eyebrow='ج٧', title='أدب الأخذ',
    items=['احترم الحقوق', 'الطبعة الرسمية إن وُجدت', 'سجّل مصدر التحميل'], stage=3)
add('points', eyebrow='ج٧', title='الذكاء الاصطناعي يعين على البحث ولا يكون مصدرًا',
    items=['يوسّع الكلمات المفتاحية (مرادفات المصطلح الفقهي)', 'يقترح اتجاهات',
           'ثم **تفتح أنت** المصدر وتفحصه', 'ما لم يوجد في مصدر حقيقي **يُشطب**'], stage=3)
add('points', eyebrow='ج٧', title='قائمة مصادر مرتبة',
    items=['**لازمة**', '**مهمة**', '**مكملة**'], stage=3)
add('task', minutes=15, eyebrow='ج٧', title='ثلاثة مصادر لفصل واحد',
    items=['ابحث عن ثلاثة مصادر لفصل واحد', 'قيّم طبعاتها',
           'سجّل المرجع كاملًا', 'ابدأ من مصادر الواجب (البند ٣)'],
    mode='فردي', stage=3)

# ج٨
add('divider', eyebrow='الجلسة ٨ | ٣٥ دقيقة', title='القراءة والتدوين والتخريج',
    sub='الهدف: تسريع القراءة دون فقد الدقة', small=True, stage=4)
add('points', eyebrow='ج٨', title='تلخيص الكتاب الضخم بتوجيه',
    items=['اطلب تلخيصًا **حسب سؤال البحث**، لا تلخيصًا عامًا', 'واطلب دائمًا **رقم الصفحة**'], stage=4)
add('points', eyebrow='ج٨', title='ترجمة العبارات',
    items=['الذكاء الاصطناعي لـ**مسودة أولية**', 'تُراجع المصطلحات الفقهية والنحوية',
           'يُحفظ **النص العربي بجانب الترجمة** دائمًا'], stage=4)
add('points', eyebrow='ج٨', title='بطاقة الفائدة',
    items=['نقل واحد في بطاقة واحدة:', 'العبارة | الترجمة | المرجع كاملًا | تعليقك',
           'يرتبها الذكاء الاصطناعي ويضيف **أنت** التحليل'], stage=4)
add('compare', eyebrow='ج٨ | التخريج', title='عملان مختلفان',
    a_title='عزو الحديث إلى مصادره', a='في أي كتاب؟ وأي باب؟ وبأي لفظ؟ **الأدوات تعين على هذا**',
    b_title='الحكم على درجته', b='**عمل أهل الحديث.** مرده إلى مراجع المختصين', stage=4,
    note='من التطبيقات المساعدة: تطبيق تخريج الحديث من OpenTurath (يُعرَّف به في ج١٣).')
add('points', eyebrow='ج٨', title='المقارنة بين المذاهب',
    items=['جدول بأعمدة: القول | الدليل | المرجع',
           'كثيرًا ما يبدّل الذكاء الاصطناعي المذاهب، فتُفحص **كل خانة**'], stage=4)
add('points', eyebrow='ج٨', title='معاني المصطلحات',
    items=['ابحث عنها في **المعاجم الكلاسيكية**', 'لا في جواب الذكاء الاصطناعي وحده'], stage=4)
add('task', minutes=10, eyebrow='ج٨', title='نقل واحد ← بطاقة كاملة',
    items=['خذ نقلًا واحدًا من أحد مصادرك', 'حوّله إلى **بطاقة فائدة كاملة**'], mode='فردي', stage=4)
add('pause', title='استراحة', minutes=15)

# ج٩
add('divider', eyebrow='الجلسة ٩ | ٢٥ دقيقة', title='الكتابة وفحص النقول',
    sub='الهدف: أن نكتب بصوتنا، لا أن ننسخ من الذكاء الاصطناعي', small=True, stage=5)
add('points', eyebrow='ج٩', title='الخط الفاصل',
    items=['**الفكرة والتحليل** لك', 'الذكاء الاصطناعي يعين في ترتيب السياق وتنويع الجمل',
           'الناتج عربي، فـ**اكتب الجملة العربية بنفسك أولًا** مهما كانت بسيطة، ثم تُصحَّح',
           'النص العربي المولَّد المسلَّم خامًا ينكشف أمام اللجنة ولا يُدافع عنه'], stage=5)
add('points', eyebrow='ج٩', title='من البطاقات إلى فقرة',
    items=['رتّب بطاقات الفائدة', 'اكتب فقرة بصوتك', 'ثم اطلب الملاحظات لا البديل الكامل'], stage=5)
add('compare', eyebrow='ج٩', title='النقل الحرفي والتلخيص',
    a_title='نقل حرفي', a='حين تكون **العبارة نفسها** هي المقصودة',
    b_title='تلخيص', b='حين يكفي المعنى. وفي الحالتين **تُذكر المرجع**', stage=5)
add('points', eyebrow='ج٩', title='الحاشية',
    items=['المؤلف | الكتاب | الجزء | الصفحة | الناشر | السنة',
           'يوحّد الذكاء الاصطناعي **الشكل**', 'ويُفحص **مضمون** المرجع يدويًا'], stage=5)
add('points', eyebrow='ج٩ | الأهم', title='فحص النقول',
    items=['قارن **كل نقل** بمصدره', 'أخطاء الذكاء الاصطناعي المعتادة:',
           'صفحات مبدَّلة | أجزاء غير موجودة | نقول مبتورة'], stage=5)
add('task', minutes=8, eyebrow='ج٩', title='فقرة بمرجعها',
    items=['اكتب فقرة عربية واحدة بمرجعها', 'بادلها مع زميل ليفحص النقل'], mode='ثنائي', stage=5)

# ج١٠
add('divider', eyebrow='الجلسة ١٠ | ٣٠ دقيقة', title='تصحيح العربية',
    sub='الهدف: أن نكتشف أخطاء عربيتنا ونصلحها', small=True, stage=6)
add('points', eyebrow='ج١٠', title='لماذا يحتاج كاتب العلم إلى مصحّح؟',
    items=['أخطاء الإعراب', 'المطابقة (تذكير وتأنيث، إفراد وجمع)', 'حروف الجر وصيغ الأفعال',
           'الأسلوب'], stage=6)
add('points', eyebrow='ج١٠ | الفكرة', title='الذكاء الاصطناعي المصحّح',
    items=['لا **يصلح** فقط', 'بل **يضع علامة** على الخطأ', 'ويذكر **قاعدته**',
           'ويقدم **عدة صيغ** أحسن، مع الفرق في الدلالة'], stage=6)
add('four', eyebrow='ج١٠', title='كيف نقرأ نتيجة التصحيح؟',
    items=[('خطأ نحوي', 'قطعي، يُصلَح'), ('خطأ صرفي', 'يُصلَح'),
           ('اختيار أسلوبي', 'ذوق، تختار أنت'), ('كلمة أدق', 'تنظر وتختار')],
    foot='تختار ولا تقبل الكل', stage=6)
add('points', eyebrow='ج١٠', title='التعلم من الأخطاء',
    items=['دوّن **أكثر ثلاثة أخطاء** تتكرر عندك', 'فهي مادة تعلّمك الشخصي'], stage=6)
add('points', eyebrow='ج١٠', title='حدود الذكاء الاصطناعي',
    items=['غالبًا أقوى في العربية **الحديثة** منه في **الكلاسيكية**',
           'قد يخطئ في الكتابة ذات الطابع التراثي',
           'المخطوط المهم يراجعه **أستاذ النحو**',
           'النصوص المنقولة من الكتب **لا تُغيَّر**'], stage=6)
add('task', minutes=12, eyebrow='ج١٠', title='صحّح فقرتك العربية',
    items=['خذ الفقرة التي كتبتها في الواجب (البند ٤)', 'صحّحها مع الذكاء الاصطناعي',
           'سجّل **ثلاثة أخطاء متكررة** وقاعدة كل منها'], mode='فردي', stage=6)
add('pause', title='استراحة / صلاة', minutes=15)

# ج١١
add('divider', eyebrow='الجلسة ١١ | ٣٠ دقيقة', title='الأستاذ الشديد',
    sub='الهدف: أن نكتشف نقاط ضعفنا قبل أن يكتشفها الممتحن', small=True, stage=7)
add('points', eyebrow='ج١١', title='لماذا ننقد قبل المناقشة؟',
    items=['يصعب على الكاتب أن يرى **نقص كتابته**', 'الأفضل أن نسمعه الآن لا أمام اللجنة'], stage=7)
add('points', eyebrow='ج١١ | الفكرة', title='ممتحن شديد… لكنه عادل',
    items=['قفزات المنطق', 'التناقض بين الأجزاء', 'دعاوى بلا مصدر', 'أدلة لا تسند الدعوى',
           'أقوال المخالفين التي لم تُناقش', 'أجزاء لا تجيب عن الإشكالية'], stage=7)
add('quote', eyebrow='ج١١ | لنقاوم ميله إلى الإرضاء',
    text='لا تبالغ في المدح،\nورتّب من الأشد إلى الأخف.', stage=7,
    note='يُكتب هذا صراحة في الأمر، لأن الذكاء الاصطناعي يميل إلى الإرضاء.')
add('three', eyebrow='ج١١', title='كيف نقرأ النقد؟',
    items=[('نقد صحيح', 'يُصلَح'), ('سوء فهم من الذكاء الاصطناعي', 'نعيد التوضيح'),
           ('نقد يفتح سؤالًا جديدًا', 'ننظر فيه')], stage=7)
add('points', eyebrow='ج١١', title='حفظ القلب',
    items=['النقد الشديد **أداة**', 'وليس حكمًا على الذات'], stage=7)
add('points', eyebrow='ج١١', title='دورة المراجعة',
    items=['نقد ← مراجعة ← نقد ثانٍ', 'نتوقف بعد **دورتين أو ثلاث**'], stage=7)
add('task', minutes=12, eyebrow='ج١١', title='سلّم جزءًا للنقد',
    items=['سلّم الذكاء الاصطناعي فقرة الواجب (بعد تصحيحها) أو الإشكالية',
           'دوّن **أهم ثلاث ملاحظات**', 'حدّد أيها **صحيح** وأيها **سوء فهم**'], mode='فردي', stage=7)

# ج١٢
add('divider', eyebrow='الجلسة ١٢ | ٥ دقائق', title='اللمسات الأخيرة',
    sub='الملخص | قائمة المراجع | محاكاة المناقشة', small=True, stage=8)
add('points', eyebrow='ج١٢', title='الملخص وقائمة المراجع والمناقشة',
    items=['يعين الذكاء الاصطناعي في **الملخص** (بالإندونيسية والإنجليزية والعربية)',
           'ويقوم بدور **الممتحن**', 'تُراجَع الأرقام والأسماء والدعاوى',
           'تُجرى محاكاة المناقشة **في البيت**'], stage=8)
add('task', minutes=3, eyebrow='ج١٢', title='ملخص من ثلاث جمل',
    items=['اكتب ملخصًا **بالعربية** من ثلاث جمل:', 'المشكلة | المنهج | النتيجة المرجوة',
           'يُصحَّح في البيت'], mode='فردي', stage=8)

# ج١٣
add('divider', eyebrow='الجلسة ١٣ | ٢٠ دقيقة', title='التعريف بـ OpenTurath',
    sub='أدوات صُنعت لخدمة طلبة العلم', small=True, brand=True)
add('points', eyebrow='ج١٣', title='لماذا صنعناها؟',
    items=['البحث عن عبارة واحدة بين **آلاف الصفحات** يأخذ ساعات',
           'والذكاء الاصطناعي العام كثيرًا ما **يخلط المذاهب** أو **يخترع المراجع**',
           'هذا **منتجنا**، ونقولها بصراحة'])
add('product', eyebrow='ج١٣', title='OpenTurath AI',
    items=['يجيب من **كتب التراث**', 'يعرض **العبارة الأصلية** مع المرجع (الكتاب والجزء والصفحة عند توفرها)',
           'موزَّع على **الفنون**', 'مادة تعلّم، **لا فتوى**'],
    note='عرض سؤال واحد. يُجرَّب قبل الدورة.')
add('product', eyebrow='ج١٣', title='مكتوطات (`AI Manuskrip`)',
    items=['يعين على **قراءة المخطوطات** وفهمها', 'وهي مما لا تصل إليه محركات البحث العادية',
           'الحالة: **قريبًا**، وهو في مرحلة التجربة',
           'الخط اليدوي صعب، فتُطابَق النتيجة بالمخطوط وبالشيخ'],
    note='لا نعد بدقة القراءة. نعرض فقط إن كانت النتائج مستقرة، وإلا نعرض مثالًا صادقًا من التجارب.')
add('product', eyebrow='ج١٣', title='تطبيق تخريج الحديث',
    items=['يعين على **تتبع مصادر الحديث** في الكتب المرجعية',
           'حدّه: يعين على **الوصول إلى المصادر**',
           'أما الحكم على الدرجة فـ**للمختصين**'],
    note='عرض حديث واحد. لا يُقال «دقيق جدًا» إلا إن وُجدت نتائج اختبار تُعرض.')
add('stages', eyebrow='ج١٣', title='في أي مرحلة تنفع هذه الأدوات؟',
    note='نعود إلى المراحل العشر ونحدد أين تنفع كل أداة.')
add('quote', eyebrow='تعهّدنا',
    text='OpenTurath تخدم طلبة العلم\nولا تحلّ محل الشيخ', brand=True,
    note='تُعرض وسيلة الدعم وطريقة التجربة (قرار صاحب المشروع).')
add('task', minutes=4, eyebrow='ج١٣', title='أين أحتاج العون؟',
    items=['خذ بطاقة المراحل', 'اكتب المرحلة التي تأخذ **أطول وقت** في بحثك',
           'وأي أداة قد تنفعك فيها (OpenTurath AI | مكتوطات | تطبيق التخريج)',
           'الجواب الصادق «**لا شيء**» مقبول'], mode='فردي')

# الختام
add('five', eyebrow='الختام', title='القواعد الخمس')
add('points', eyebrow='الختام', title='بعد الدورة',
    items=['**تمرين أسبوع** تطبّق فيه ما تعلمت على بحثك', 'مجموعة الخريجين',
           'مكان للسؤال والمتابعة', 'أخرج **بطاقتك الشخصية** وراجعها'])
add('points', eyebrow='التقويم', title='الاختبار البعدي واستمارة التقويم',
    items=['الأسئلة الثلاثة نفسها التي بدأنا بها', 'ثم استمارة التقويم: ماذا أعجبك؟ وماذا نحسّن؟'])

# الملاحق
add('divider', eyebrow='ملحق', title='أوامر أساسية', sub='نصوص للتجربة قبل الدورة وللاستعمال فيها', small=True)
add('prompt', eyebrow='أمر ١', title='المحاوِر: العنوان والإشكالية',
    text='أنت مشرف بحث صبور. ساعدني على اختيار عنوان وإشكالية. لا تقترح عنوانًا فورًا. اسألني سؤالًا سؤالًا: الفن، والمشكلة التي تشغلني، والمرحلة، ونوع البحث، ولغة الكتابة، والمصادر التي أحسنها، والمدة. وحين تكتفي لخّص فهمك واطلب مني تصحيحه، ثم اقترح ثلاثة عناوين مع مزاياها ومخاطرها.',
    note='نص للتجربة، وليس نهائيًا.')
add('prompt', eyebrow='أمر ٢', title='المصحّح اللغوي (العربية)',
    text='افحص النص العربي الآتي. لكل خطأ اكتب: الجملة الأصلية، ونوع الخطأ (نحو، صرف، أسلوب)، والقاعدة، وصيغتين أو ثلاثًا للتصحيح مع الفرق بينها. لا تغيّر ما هو نقل من كتاب. وإن لم تكن متأكدًا فقل إنك لست متأكدًا.')
add('prompt', eyebrow='أمر ٣', title='الأستاذ الشديد',
    text='قم بدور أستاذ ممتحن شديد لكنه عادل. اقرأ الجزء الآتي وابحث عن: قفزات المنطق، والتناقض بين الأجزاء، والدعاوى بلا مصدر، والأدلة التي لا تسند الدعوى، وأقوال المخالفين التي لم تُناقش، والأجزاء التي لا تجيب عن الإشكالية. رتّبها من الأشد إلى الأخف. لا تبالغ في المدح ولا تعِد كتابة جزئي.')
add('closing')


# ───────────────────────── العرض ─────────────────────────
def stage_strip(idx):
    if idx is None:
        return ''
    dots = ''.join(
        f'<i class="{"on" if i == idx else ("done" if i < idx else "")}"></i>'
        for i in range(10))
    return f'<div class="strip" title="{html.escape(STAGES[idx])}"><span>{ar(idx + 1)} / ١٠ | {html.escape(STAGES[idx])}</span><div>{dots}</div></div>'


def body(sl, n):
    k = sl['kind']
    note = sl.get('note', '')
    cls = 'slide'
    if k in ('divider', 'quote') and sl.get('brand'):
        cls += ' dark'
    if k == 'divider':
        cls += ' dark' + (' small' if sl.get('small') else '')
    st = stage_strip(sl.get('stage')) if k not in ('cover', 'closing') else ''
    inner = ''
    if k == 'cover':
        cls += ' cover'
        inner = f'''
<div class="logos"><img class="ot" src="assets/openturath_dark.svg" alt="OpenTurath"><span class="sep"></span><img class="ruqi" src="assets/logo_ruqi_transparan.png" alt="معهد رقي للتدريب والتأهيل المهني"></div>
<div class="eyebrow">دورة تدريبية | يومان</div>
<h1>استخدام الذكاء الاصطناعي<br>في مجال البحث العلمي</h1>
<p class="lede">للمبتدئين من طلبة العلم: من فكرة البحث إلى المناقشة</p>
<div class="presenter"><b>رفلي حسين</b><span>خبير الذكاء الاصطناعي</span><span>و <bdi class="lat">Founder of OpenTurath AI</bdi></span></div>'''
    elif k == 'closing':
        cls += ' cover'
        inner = f'''
<div class="logos"><img class="ot" src="assets/openturath_dark.svg" alt="OpenTurath"><span class="sep"></span><img class="ruqi" src="assets/logo_ruqi_transparan.png" alt="معهد رقي للتدريب والتأهيل المهني"></div>
<h1>شكرًا لكم</h1>
<p class="lede">الذكاء الاصطناعي يعين، والحق يُتحقَّق منه في الكتب، والعلم يُؤخذ عن الشيوخ.</p>
<div class="presenter"><b>رفلي حسين</b><span>خبير الذكاء الاصطناعي</span><span>و <bdi class="lat">Founder of OpenTurath AI</bdi></span></div>'''
    elif k == 'divider':
        mark = '<img class="mark" src="assets/openturath_light.svg" alt="">'
        inner = f'''{mark}<div class="eyebrow">{fmt(sl['eyebrow'])}</div><h2>{fmt(sl['title'])}</h2><p class="lede">{fmt(sl.get('sub', ''))}</p>'''
        if sl.get('stage') is not None:
            st = stage_strip(sl['stage'])
    elif k == 'points':
        li = ''.join(f'<li>{fmt(x)}</li>' for x in sl['items'])
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><ul class="body c{min(len(sl["items"]), 6)}">{li}</ul>'
    elif k == 'quote':
        t = '<br>'.join(fmt(x) for x in sl['text'].split('\n'))
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><blockquote class="body">{t}</blockquote>'
    elif k == 'compare':
        inner = f'''<div class="eyebrow">{fmt(sl['eyebrow'])}</div><h2>{fmt(sl['title'])}</h2>
<div class="two body"><div><h3>{fmt(sl['a_title'])}</h3><p>{fmt(sl['a'])}</p></div><div class="alt"><h3>{fmt(sl['b_title'])}</h3><p>{fmt(sl['b'])}</p></div></div>'''
    elif k == 'task':
        li = ''.join(f'<li>{fmt(x)}</li>' for x in sl['items'])
        inner = f'''<div class="eyebrow">تكليف | {fmt(sl['eyebrow'])}</div>
<div class="taskhead"><div class="timer"><b>{ar(sl['minutes'])}</b><span>دقيقة</span></div><div><h2>{fmt(sl['title'])}</h2><span class="chip">{fmt(sl.get('mode', ''))}</span></div></div>
<ol class="body">{li}</ol>'''
        cls += ' task'
    elif k == 'four' or k == 'three':
        cells = ''.join(f'<div><h3>{fmt(a)}</h3><p>{fmt(b)}</p></div>' for a, b in sl['items'])
        foot = f'<p class="foot">{fmt(sl["foot"])}</p>' if sl.get('foot') else ''
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><div class="grid{len(sl["items"])} body">{cells}</div>{foot}'
    elif k == 'table':
        th = ''.join(f'<th>{fmt(h)}</th>' for h in sl['head'])
        tr = ''.join('<tr>' + ''.join(f'<td>{fmt(c)}</td>' for c in r) + '</tr>' for r in sl['rows'])
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><table class="body"><thead><tr>{th}</tr></thead><tbody>{tr}</tbody></table>'
    elif k == 'stages':
        cells = ''.join(f'<div><b>{ar(i + 1)}</b><span>{fmt(s)}</span></div>' for i, s in enumerate(STAGES))
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><div class="stages body">{cells}</div>'
    elif k == 'pause':
        cls += ' pause'
        inner = f'<div class="eyebrow">{ar(sl["minutes"])} دقيقة</div><h2>{fmt(sl["title"])}</h2>'
    elif k == 'demo':
        li = ''.join(f'<li>{fmt(x)}</li>' for x in sl['items'])
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><ul class="body">{li}</ul>'
    elif k == 'sources':
        cells = ''.join(f'<div><h3>{fmt(a)}</h3><p class="url" dir="ltr">{html.escape(b)}</p></div>' for a, b in sl['items'])
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><div class="srcs body">{cells}</div><p class="foot">{fmt(sl["foot"])}</p>'
    elif k == 'five':
        rules = ['الذكاء الاصطناعي **معين**، لا يحلّ محل أحد', 'اطلب **المراجع** والعبارة الأصلية',
                 '**تحقق** من الكتب', 'احفظ **البيانات** والحقوق', '**لازم** الشيوخ']
        li = ''.join(f'<li>{fmt(x)}</li>' for x in rules)
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><ol class="body five">{li}</ol>'
    elif k == 'homework':
        rows = ''.join(f'<li><i class="no">{a}</i><span>{fmt(t)}</span><em>{m}</em></li>' for a, t, m in sl['items'])
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><ul class="hw body">{rows}</ul>'
    elif k == 'product':
        li = ''.join(f'<li>{fmt(x)}</li>' for x in sl['items'])
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2 class="prod">{fmt(sl["title"])}</h2><ul class="body">{li}</ul>'
    elif k == 'prompt':
        inner = f'<div class="eyebrow">{fmt(sl["eyebrow"])}</div><h2>{fmt(sl["title"])}</h2><div class="prompt body">{fmt(sl["text"])}</div>'
    else:
        raise SystemExit('kind?' + k)
    tm = '' if (cls.find('dark') >= 0 or k in ('cover', 'closing')) else '<img class="tm" src="assets/openturath_dark.svg" alt="">'
    inner = tm + inner
    notes = f'<aside class="notes">{fmt(note)}</aside>' if note else ''
    num = '' if k in ('cover', 'closing') else f'<div class="num">{ar(n)}</div>'
    return f'<section class="{cls}" data-n="{n}">{inner}{st}{num}{notes}</section>'


CSS = '''
@font-face{font-family:'Scheherazade New';src:url('assets/fonts/scheherazade-new-arabic-400-normal.woff2') format('woff2');font-weight:400}
@font-face{font-family:'Scheherazade New';src:url('assets/fonts/scheherazade-new-arabic-700-normal.woff2') format('woff2');font-weight:700}
@font-face{font-family:'Outfit';src:url('assets/fonts/outfit-latin-400-normal.woff2') format('woff2');font-weight:400}
@font-face{font-family:'Outfit';src:url('assets/fonts/outfit-latin-500-normal.woff2') format('woff2');font-weight:500}
@font-face{font-family:'Outfit';src:url('assets/fonts/outfit-latin-600-normal.woff2') format('woff2');font-weight:600}
@font-face{font-family:'Outfit';src:url('assets/fonts/outfit-latin-700-normal.woff2') format('woff2');font-weight:700}
:root{--paper:#fff;--ink:#18181b;--muted:#71717a;--faint:#a1a1aa;--line:#e5e7eb;--surface:#f4f4f5;--obsidian:#0e0e10;--obs2:#18181b;--obs3:#27272a;--fog:#fafafa}
*{box-sizing:border-box;margin:0;padding:0}
html,body{height:100%;background:#d4d4d8;overflow:hidden}
body{font-family:Outfit,'Scheherazade New',serif;color:var(--ink);direction:rtl}
#viewport{position:fixed;inset:0;display:grid;place-items:center}
#stage{width:1920px;height:1080px;position:relative;transform-origin:center center;flex:none}
.slide{position:absolute;inset:0;background:var(--paper);display:none;padding:120px 150px 150px;overflow:hidden}
.slide.on{display:block}
.slide.dark{background:var(--obsidian);color:var(--fog)}
.eyebrow{font-size:30px;font-weight:600;color:var(--muted);letter-spacing:.02em;margin-bottom:26px}
.dark .eyebrow{color:var(--faint)}
h1{font-size:104px;line-height:1.3;font-weight:700}
h2{font-size:84px;line-height:1.3;font-weight:700;margin-bottom:46px}
h2.prod{font-family:Outfit,'Scheherazade New';direction:ltr;text-align:right;letter-spacing:-.01em}
h3{font-size:50px;font-weight:700;margin-bottom:14px}
.lede{font-size:44px;color:var(--muted);line-height:1.6;margin-top:22px}
.dark .lede{color:var(--faint)}
.lat{font-family:Outfit,sans-serif;font-weight:500;direction:ltr;unicode-bidi:isolate}
.body{font-size:58px;line-height:1.6}
ul.body.c1{font-size:84px}ul.body.c2{font-size:78px}ul.body.c3{font-size:70px}ul.body.c4{font-size:64px}ul.body.c5{font-size:58px}ul.body.c6{font-size:54px}
ul.body.c1 li,ul.body.c2 li,ul.body.c3 li{margin-bottom:34px}
.tm{position:absolute;top:96px;inset-inline-end:150px;height:58px}
h2{border-bottom:2px solid var(--line);padding-bottom:30px}
.dark h2{border-bottom:none;padding-bottom:0}
ul.body,ol.body{list-style:none}
ul.body li{position:relative;padding-inline-start:46px;margin-bottom:18px}
ul.body li::before{content:'';position:absolute;inset-inline-start:0;top:.78em;width:18px;height:18px;border-radius:50%;background:var(--ink)}
ol.body{counter-reset:o}
ol.body li{counter-increment:o;position:relative;padding-inline-start:84px;margin-bottom:18px}
ol.body li::before{content:counter(o,arabic-indic);position:absolute;inset-inline-start:0;top:.05em;width:56px;height:56px;border-radius:50%;border:2px solid var(--ink);display:grid;place-items:center;font-size:30px;font-weight:700;line-height:1}
b{font-weight:700}
blockquote.body{font-size:92px;line-height:1.5;font-weight:700;border-inline-start:8px solid var(--ink);padding-inline-start:60px;margin-top:40px}
.dark blockquote.body{border-color:var(--fog)}
.two{display:grid;grid-template-columns:1fr 1fr;gap:60px}
.two>div{border:2px solid var(--line);border-radius:28px;padding:50px;background:var(--paper)}
.two>div.alt{background:var(--surface)}
.two p{font-size:56px;line-height:1.6}
.two>div{min-height:480px}
.grid4{display:grid;grid-template-columns:1fr 1fr;gap:34px}
.grid3{display:grid;grid-template-columns:repeat(3,1fr);gap:34px}
.grid4>div,.grid3>div{border:2px solid var(--line);border-radius:28px;padding:40px 46px;background:var(--surface)}
.grid4 p,.grid3 p{font-size:44px;color:var(--muted)}
.foot{font-size:38px;color:var(--muted);margin-top:26px}
.divider h2,.dark h2{color:var(--fog)}
.slide.dark{padding-top:230px}
.slide.dark .mark{position:absolute;top:90px;inset-inline-start:150px;width:110px;height:110px}
.slide.dark h2{font-size:100px;margin-bottom:10px}
.slide.dark.small h2{font-size:92px}
.cover{padding-top:70px;text-align:right}
.cover .logos{display:flex;align-items:center;gap:56px;margin-bottom:40px;direction:ltr;justify-content:flex-end}
.cover .logos .ot{height:150px}
.cover .logos .ruqi{height:190px}
.cover .logos .sep{width:2px;height:150px;background:var(--line)}
.cover h1{margin-top:6px}
.presenter{position:absolute;inset-inline-start:150px;bottom:64px;display:flex;flex-direction:column;gap:2px;font-size:34px;color:var(--muted)}
.presenter b{font-size:56px;color:var(--ink);font-weight:700}
.cover .eyebrow{font-size:34px}
.task{background:var(--paper)}
.task .taskhead{display:flex;gap:44px;align-items:center;margin-bottom:34px}
.timer{width:200px;height:200px;border-radius:50%;background:var(--obsidian);color:var(--fog);display:grid;place-items:center;text-align:center;flex:none;padding-top:20px}
.timer b{font-size:92px;line-height:1}
.timer span{font-size:32px;display:block;margin-top:-34px;color:var(--faint)}
.task h2{margin-bottom:12px;border-bottom:none;padding-bottom:0}
.chip{display:inline-block;border:2px solid var(--ink);border-radius:999px;padding:2px 26px;font-size:34px;font-weight:600}
.task .eyebrow{color:var(--ink)}
table.body{border-collapse:collapse;width:100%;font-size:44px;line-height:1.3}
th,td{padding:14px 20px;text-align:right;border-bottom:2px solid var(--line)}
th{font-size:34px;color:var(--muted);font-weight:600}
td:last-child,th:last-child{text-align:center;width:150px}
td:first-child{width:170px;font-variant-numeric:tabular-nums;color:var(--muted)}
.stages{display:grid;grid-template-columns:repeat(5,1fr);gap:26px}
.stages div{border:2px solid var(--line);border-radius:26px;padding:30px 22px;background:var(--surface);text-align:center}
.stages b{display:block;font-size:76px;line-height:1.1}
.stages span{font-size:40px;font-weight:600}
.pause{background:var(--surface);text-align:center;padding-top:340px}
.pause h2{border:none;font-size:120px}
.pause .eyebrow{font-size:44px}
.srcs{display:grid;grid-template-columns:1fr 1fr;gap:34px}
.srcs>div{border:2px solid var(--line);border-radius:28px;padding:26px 40px;background:var(--surface)}
.srcs h3{font-size:46px;margin-bottom:6px}
.url{font-family:Outfit,sans-serif;font-size:38px;color:var(--muted);text-align:right;direction:ltr}
.five li{font-size:60px}
.hw{font-size:44px}
ul.body.hw li{display:grid;grid-template-columns:64px 1fr 110px;gap:26px;align-items:center;border-bottom:2px solid var(--line);padding:12px 0;margin:0}
ul.body.hw li::before{display:none}
.hw .no{font-style:normal;width:56px;height:56px;border-radius:50%;background:var(--ink);color:var(--paper);display:grid;place-items:center;font-size:30px;line-height:1}
.hw em{font-style:normal;color:var(--muted);font-size:30px;text-align:center}
.hw span{line-height:1.45}
.prompt{font-size:44px;line-height:1.75;border:2px solid var(--line);border-radius:28px;background:var(--surface);padding:46px 56px}
.strip{position:absolute;bottom:56px;inset-inline-start:150px;inset-inline-end:260px;display:flex;align-items:center;gap:30px;font-size:26px;color:var(--muted)}
.strip div{display:flex;gap:10px;flex:1}
.strip i{flex:1;height:8px;border-radius:4px;background:var(--line);display:block}
.strip i.done{background:var(--faint)}
.strip i.on{background:var(--ink)}
.dark .strip{color:var(--faint)}
.dark .strip i{background:var(--obs3)}
.dark .strip i.done{background:#52525b}
.dark .strip i.on{background:var(--fog)}
.num{position:absolute;bottom:50px;inset-inline-end:150px;font-size:30px;color:var(--faint);font-variant-numeric:tabular-nums}
.notes{display:none}
#bar{position:fixed;top:0;inset-inline-start:0;height:4px;background:var(--ink);width:0;z-index:5;transition:width .2s}
#hud{position:fixed;bottom:12px;inset-inline-end:16px;font:500 13px Outfit,sans-serif;color:#52525b;background:rgba(255,255,255,.8);padding:6px 12px;border-radius:999px;z-index:5;opacity:.0;transition:opacity .3s}
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
  *{-webkit-print-color-adjust:exact;print-color-adjust:exact}
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
    while(guard-->0&&el.scrollHeight>lim&&fs>24){fs-=2;el.style.fontSize=fs+'px';}});
}
function fitAll(){slides.forEach(function(s){var on=s.classList.contains('on');if(!on)s.style.display='block';fitText(s);if(!on)s.style.display='';});}
function go(n){cur=Math.max(0,Math.min(slides.length-1,n));slides.forEach(function(s,i){s.classList.toggle('on',i===cur)});
  bar.style.width=((cur+1)/slides.length*100)+'%';
  var no=slides[cur].querySelector('.notes');nb.textContent=no?no.textContent:'';hud.textContent=ar(cur+1)+' / '+ar(slides.length);
  try{history.replaceState(null,'','#'+(cur+1))}catch(e){}}
addEventListener('resize',function(){fit()});
addEventListener('keydown',function(e){var k=e.key;
  if(k==='ArrowLeft'||k==='PageDown'||k===' '||k==='Enter'){e.preventDefault();go(cur+1)}
  else if(k==='ArrowRight'||k==='PageUp'||k==='Backspace'){e.preventDefault();go(cur-1)}
  else if(k==='Home'){go(0)}else if(k==='End'){go(slides.length-1)}
  else if(k==='f'||k==='F'){document.fullscreenElement?document.exitFullscreen():document.documentElement.requestFullscreen()}
  else if(k==='n'||k==='N'){document.body.classList.toggle('shownotes')}});
var x0=null;addEventListener('touchstart',function(e){x0=e.touches[0].clientX},{passive:true});
addEventListener('touchend',function(e){if(x0===null)return;var dx=e.changedTouches[0].clientX-x0;if(Math.abs(dx)>50){go(cur+(dx<0?1:-1))}x0=null});
document.getElementById('viewport').addEventListener('click',function(e){if(e.clientX<innerWidth/2)go(cur+1);else go(cur-1)});
fit();var h=parseInt(location.hash.slice(1),10);go(isNaN(h)?0:h-1);document.fonts.ready.then(function(){fitAll();go(isNaN(h)?0:h-1)});
})();
'''


def main():
    parts = [body(sl, i + 1) for i, sl in enumerate(S)]
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
    out = HERE / 'slides_ar.html'
    out.write_text(doc, encoding='utf-8')
    print(f'{len(S)} slides -> {out}')


main()
