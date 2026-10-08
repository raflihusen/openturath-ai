import {escapeHtml as e, pick} from './core.mjs';
import {tr,localized} from './copy.mjs';
import {link} from './render.mjs';

export const number = (value, locale, digits=0) => new Intl.NumberFormat(
  {id:'id-ID', en:'en-US', ar:'ar-EG'}[locale], {maximumFractionDigits:digits}
).format(value);

export function collectionTotals(catalog) {
  return catalog.filter(c => c.status === 'active' && c.metadata).reduce((sum,c) => {
    sum.disciplines++;
    for (const key of ['books','volumes','pages','words','partitions']) sum[key] += c.metadata[key];
    sum.volumesLowerBound ||= c.metadata.volumesLowerBound;
    return sum;
  }, {disciplines:0,books:0,volumes:0,pages:0,words:0,partitions:0,volumesLowerBound:false});
}

export function collectionMetadata(l,c) {
  if (!c.metadata || c.status !== 'active') return '';
  const m=c.metadata;
  const values=[
    [number(m.books,l),'metaBooks'],
    [number(m.volumes,l)+(m.volumesLowerBound?'+':''),'metaVolumes'],
    [number(m.pages,l),'metaPages'],
    [number(m.words/1e6,l,1)+' '+tr(l,'metaMillion'),'metaWords'],
    ...(m.lectures?[[number(m.lectures,l),'metaLectures']]:[])
  ];
  return `<ul class="collection-metrics" aria-label="${tr(l,'collectionMetrics')}">${values.map(([value,key],i)=>`<li class="${i===0?'metric-primary':''}"><bdi>${e(value)}</bdi><span>${tr(l,key)}</span></li>`).join('')}<li class="metric-period">${e(pick(m.period,l))}</li></ul>${c.countReview?`<p class="corpus-status">${localized(['Jumlah kitab pada dua metadata:','Book counts across two metadata records:','أعداد الكتب في سجلّين:'],l)} <bdi>${c.metadata.books} / ${c.countReview.trainingBooks}</bdi>. ${link(l,'research/corpus',tr(l,'corpusNotes'))}</p>`:''}`;
}

export function collectionStats(l,catalog) {
  const totals=collectionTotals(catalog);
  const rows=[['books','metricBooks'],['words','metricWords'],['pages','metricPages'],['volumes','metricVolumes'],['disciplines','metricDisciplines']];
  return `<section class="collection-scale" aria-labelledby="scale-title"><div class="container">
    <div class="editorial-heading"><h2 id="scale-title">${e(tr(l,'statsTitle')).replaceAll('\n','<br>')}</h2><p>${tr(l,'statsIntro')}</p></div>
    <dl class="scale-grid">${rows.map(([key,label])=>{
      const exact=number(totals[key],l)+(key==='volumes'&&totals.volumesLowerBound?'+':'');
      const prominent=key==='pages'?number(Math.floor(totals[key]/1e5)/10,l,1)+'+':key==='words'?number(Math.floor(totals[key]/1e7)/100,l,2)+'+':exact;
      const unit=key==='pages'?tr(l,'metaMillion'):key==='words'?tr(l,'metaBillion'):'';
      return `<div class="scale-tile" data-metric="${key}" data-value="${totals[key]}" data-reveal="number"><dt>${tr(l,label)}</dt><dd><span class="number-window"><bdi class="number-rise">${prominent}</bdi></span>${unit?`<span class="scale-unit">${unit}</span>`:''}${prominent!==exact?`<small><bdi>${exact}</bdi></small>`:''}</dd>${key==='books'?'<span class="scale-calligraphy" lang="ar" dir="rtl" aria-hidden="true">كتب</span>':''}</div>`;
    }).join('')}</dl>
    <div class="scale-index" data-metric="partitions" data-value="${totals.partitions}" data-reveal><p><bdi>${number(totals.partitions,l)}</bdi> ${tr(l,'metricPartitions')}</p><span>${tr(l,'statsEra')}</span></div>
    <p class="fine-print scale-source">${tr(l,'statsSource')} ${link(l,'research/corpus',tr(l,'corpusNotes'))}</p>
  </div></section>`;
}

export function validateCatalogMetadata(catalog,modules,training) {
  const errors=[],seen=new Set();
  for(const c of catalog.filter(c=>c.status==='active')){
    const source=modules[c.metadataKey],partitions=training[c.metadataKey];
    if(!source||!partitions){errors.push(`Metadata source missing: ${c.id}`);continue;}
    if(seen.has(c.metadataKey))errors.push(`Duplicate module: ${c.metadataKey}`);
    seen.add(c.metadataKey);
    const expected={books:source.total_kitab,volumes:Number(String(source.total_jilid).replace(/\D/g,'')),pages:source.total_halaman,words:source.total_kata,lectures:source.total_dars||0,partitions:partitions.total_partisi_notebooklm};
    for(const [key,value] of Object.entries(expected)){
      if(!Number.isSafeInteger(value)||value<0||c.metadata?.[key]!==value)errors.push(`Metadata mismatch: ${c.id}.${key}`);
    }
    if(c.metadata?.volumesLowerBound!==String(source.total_jilid).includes('+'))errors.push(`Volume precision mismatch: ${c.id}`);
    if(c.metadata?.period?.id!==source.rentang_masa)errors.push(`Period mismatch: ${c.id}`);
    for(const locale of ['id','en','ar'])if(!c.metadata?.period?.[locale]?.trim())errors.push(`Period translation missing: ${c.id}.${locale}`);
  }
  if(seen.size!==Object.keys(modules).length)errors.push('Active catalogue does not cover all source modules.');
  return errors;
}
