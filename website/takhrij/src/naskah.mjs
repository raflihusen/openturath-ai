// Tahap 2 identitas Naskah: hero saja, tiga bahasa.
export const naskahText = {
  id: { dir: 'ltr', title: 'Dari matan sampai ke sumbernya.', lede: 'Telusuri sanad, periksa rujukan, dan susun takhrij dari satu hadis.', cta: 'Lihat cara kerjanya', note: 'Pratinjau hero. Belum terbit.' },
  en: { dir: 'ltr', title: 'From the text to its source.', lede: 'Trace the isnad, check the references, and compose a takhrij from one hadith.', cta: 'See how it works', note: 'Hero preview. Not published.' },
  ar: { dir: 'rtl', title: 'من المتن إلى المصدر', lede: 'تتبع الأسانيد، وراجع الإحالات، وأعد التخريج انطلاقاً من حديث واحد.', cta: 'شاهد طريقة العمل', note: 'معاينة الواجهة، غير منشورة.' },
};
const rawi = [['عمر بن الخطاب', 'صحابي'], ['علقمة بن وقاص', 'الثانية'], ['محمد بن إبراهيم التيمي', 'الرابعة'], ['يحيى بن سعيد الأنصاري', 'الخامسة']];
const kutub = ['صحيح البخاري', 'صحيح مسلم', 'سنن أبي داود', 'جامع الترمذي'];

export function naskahPage(lang, takhrij) {
  const t = naskahText[lang];
  const langs = Object.keys(naskahText).map((l) => `<a href="/naskah/${l}.html"${l === lang ? ' aria-current="true"' : ''}>${l.toUpperCase()}</a>`).join('');
  const notes = takhrij.split('\n').slice(0, 2);
  return `<!doctype html><html lang="${lang}" dir="${t.dir}"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>تخريج الحديث</title><link rel="stylesheet" href="/assets/naskah/naskah.css"><link rel="icon" href="/assets/takhrij_mark_light.svg"></head><body>
<header class="top"><img class="l" src="/assets/takhrij_mark_light.svg" alt=""><img class="d" src="/assets/takhrij_mark_dark.svg" alt=""><span class="name" lang="ar">تخريج الحديث</span><span class="sp"></span>${langs}<button data-theme-toggle aria-label="Tema">◐</button></header>
<main class="page"><div class="frame"><svg id="line" aria-hidden="true"></svg><p class="run" lang="ar">بدء الوحي · صحيح البخاري</p>
<ol class="sanad" lang="ar" aria-label="السند">${rawi.map(([n, s], i) => `<li style="--t:${(1.95 + i * .25).toFixed(2)}s">${n}<small>${s}</small></li>`).join('')}</ol>
<div class="matn"><h1 lang="ar" dir="rtl"><span class="ink">إنما الأعمال بالنيات</span></h1><p class="lat">${t.title}</p><p class="lede">${t.lede}</p><a class="go" href="#">${t.cta}</a></div>
<ul class="kutub" lang="ar" aria-label="الكتب">${kutub.map((k, i) => `<li style="--t:${(3.7 + i * .1).toFixed(2)}s">${k}</li>`).join('')}</ul>
<div class="foot" lang="ar">${notes.map((n, i) => `<p><sup>${i + 1}</sup><span class="ink" style="--t:${(3.9 + i * .35).toFixed(2)}s;--dur:1s">${n.replace(/</g, '&lt;').slice(0, 118)}${n.length > 118 ? '…' : ''}</span></p>`).join('')}</div>
</div></main><p class="ribbon">${t.note}</p><script src="/assets/naskah/naskah.js"></script></body></html>`;
}
