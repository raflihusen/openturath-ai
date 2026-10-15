import {escapeHtml as e, pick} from './core.mjs';
import {tr} from './copy.mjs';

export const number = (value, locale, digits=0) => new Intl.NumberFormat(
  {id:'id-ID', en:'en-US', ar:'ar-EG'}[locale], {maximumFractionDigits:digits}
).format(value);

export const REKAMAN_DIPERIKSA = 46048;   // rekaman Hazmi + Maktabah Baru + Shamela 4 yang diperiksa (register V9.2)

export function collectionTotals(catalog) {
  return catalog.filter(c => c.status === 'active' && c.metadata).reduce((sum,c) => {
    sum.disciplines++;
    for (const key of ['books','words','lectures','partitions']) sum[key] += c.metadata[key] || 0;
    return sum;
  }, {disciplines:0,books:0,words:0,lectures:0,partitions:0,records:REKAMAN_DIPERIKSA});
}

// V7: kartu hanya menampilkan angka yang pasti: kitab, kata teks, muhadharah, dan rentang wafat pengarang.
export function collectionMetadata(l,c) {
  if (!c.metadata || c.status !== 'active') return '';
  const m=c.metadata;
  const values=[
    [number(m.books,l),'metaBooks'],
    [number(m.words/1e6,l,1)+' '+tr(l,'metaMillion'),'metaWords'],
    ...(m.lectures?[[number(m.lectures,l),'metaLectures']]:[])
  ];
  return `<ul class="collection-metrics" aria-label="${tr(l,'collectionMetrics')}">${values.map(([value,key],i)=>`<li class="${i===0?'metric-primary':''}"><bdi>${e(value)}</bdi><span>${tr(l,key)}</span></li>`).join('')}<li class="metric-period">${e(pick(m.period,l))}</li></ul>`;
}

export function collectionStats(l,catalog) {
  const totals=collectionTotals(catalog);
  const rows=[['books','metricBooks'],['words','metricWords'],['lectures','metricPages'],['records','metricVolumes'],['disciplines','metricDisciplines']];
  return `<section class="collection-scale" aria-labelledby="scale-title"><div class="container">
    <div class="editorial-heading"><h2 id="scale-title">${e(tr(l,'statsTitle')).replaceAll('\n','<br>')}</h2><p>${tr(l,'statsIntro')}</p></div>
    <dl class="scale-grid">${rows.map(([key,label])=>{
      const exact=number(totals[key],l);
      const prominent=key==='words'?number(Math.round(totals[key]/1e6),l):exact;
      const unit=key==='words'?tr(l,'metaMillion'):'';
      return `<div class="scale-tile" data-metric="${key}" data-value="${totals[key]}" data-reveal="number"><dt>${tr(l,label)}</dt><dd><span class="number-window"><bdi class="number-rise">${prominent}</bdi></span>${unit?`<span class="scale-unit">${unit}</span>`:''}${prominent!==exact?`<small><bdi>${exact}</bdi></small>`:''}</dd>${key==='books'?'<span class="scale-calligraphy" lang="ar" dir="rtl" aria-hidden="true">كتب</span>':''}</div>`;
    }).join('')}</dl>
    <div class="scale-index" data-metric="partitions" data-value="${totals.partitions}" data-reveal><p><bdi>${number(totals.partitions,l)}</bdi> ${tr(l,'metricPartitions')}</p><span>${tr(l,'statsEra')}</span></div>
    <p class="fine-print scale-source">${tr(l,'statsSource')}</p>
  </div></section>`;
}

// V7: angka katalog website wajib sama persis dengan info_ai.json aplikasi.
export function validateCatalogMetadata(catalog,infoAi) {
  const errors=[];
  const info=Object.fromEntries(infoAi.map(x=>[x.id,x]));
  for(const c of catalog){
    const x=info[c.appAgentId];
    if(!x){errors.push(`AI tidak ada di aplikasi: ${c.id}`);continue;}
    if(c.metadata.books!==x.isi.jumlah_kitab)errors.push(`Jumlah kitab beda: ${c.id}`);
    if(c.metadata.words!==x.isi.jumlah_kata)errors.push(`Jumlah kata beda: ${c.id}`);
    if((c.metadata.lectures||0)!==(x.isi.jumlah_muhadharah||0))errors.push(`Jumlah muhadharah beda: ${c.id}`);
    if(c.metadata.partitions!==x.cara_disusun.berkas_notebooklm)errors.push(`Jumlah berkas beda: ${c.id}`);
    if(c.name.id!==x.judul)errors.push(`Nama AI beda dengan aplikasi: ${c.id}`);
  }
  if(catalog.length!==infoAi.length)errors.push(`Jumlah AI website (${catalog.length}) beda dengan aplikasi (${infoAi.length})`);
  return errors;
}
