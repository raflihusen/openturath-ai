export function escapeHtml(value='') { return String(value).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
export function normalizeSearch(value='') { return String(value).normalize('NFKD').replace(/[\u0300-\u036f\u064b-\u065f\u0670\u0640]/g,'').replace(/[أإآٱ]/g,'ا').replace(/ى/g,'ي').toLowerCase().trim(); }
export function safeExternal(value) { try { const u=new URL(value);return u.protocol==='https:'&&!u.username&&!u.password?u.href:null; }catch{return null;} }
export function releaseIssues(c) {
 const errors=[];
 if(!safeExternal(c.canonicalUrl)||(new URL(c.canonicalUrl).pathname!=='/'||new URL(c.canonicalUrl).search||new URL(c.canonicalUrl).hash))errors.push('canonicalUrl: HTTPS origin required');
 for(const k of ['name','email','jurisdiction','privacyEmail','securityEmail'])if(!c.operator?.[k])errors.push(`operator.${k}: required`);
 const websiteOnly=c.distribution?.mode==='website-only'&&c.distribution?.reason==='awaiting-release-artifact';
 if(websiteOnly&&(c.downloads||[]).some(d=>!d.revoked&&!d.comingSoon))errors.push('distribution: website-only cannot expose an active release');
 if(!websiteOnly&&!(c.downloads||[]).some(d=>!d.revoked&&!d.comingSoon))errors.push('downloads: at least one real app release required');
 for(const d of c.downloads||[]){for(const k of ['platform','version','date','minimumOS','url'])if(!d[k])errors.push(`downloads.${k}: required`);if(!safeExternal(d.url))errors.push('downloads.url: HTTPS required');if(d.type==='apk'&&!d.comingSoon&&!d.revoked&&!/^[a-f0-9]{64}$/i.test(d.sha256||''))errors.push('downloads.sha256: real APK hash required');}
 if(!c.plans?.length)errors.push('plans: approved access information required');
 for(const p of c.plans||[]){
  for(const k of ['name','period','coverage','renewal','refund','taxes','cancellation','paymentLocation'])for(const l of ['id','en','ar'])if(!p[k]?.[l]?.trim())errors.push(`plans.${k}.${l}: approved translation required`);
  if(!Number.isInteger(p.months)||p.months<1)errors.push('plans.months: positive integer period required');
  if(typeof p.price!=='number'||!Number.isFinite(p.price)||p.price<0||p.price===''||p.price==null)errors.push('plans.price: nonnegative price required');
  if(!/^[A-Z]{3}$/.test(p.currency||''))errors.push('plans.currency: ISO currency required');
 }
 for(const k of ['email','privacyEmail','securityEmail'])if(c.operator?.[k]&&!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(c.operator[k]))errors.push(`operator.${k}: valid email required`);
 for(const r of c.releaseNotes||[]){if(!/^[a-zA-Z0-9][a-zA-Z0-9.-]*$/.test(r.version||'')||r.version.includes('..'))errors.push('releaseNotes.version: safe version required');for(const l of ['id','en','ar'])if(!r.summary?.[l]||!r.body?.[l])errors.push(`releaseNotes: ${l} summary and body required`);}
 if(!Number.isInteger(c.reports?.retentionDays)||c.reports.retentionDays<1||c.reports.retentionDays>365)errors.push('reports.retentionDays: integer 1–365 required');
 if(c.analytics?.enabled)errors.push('analytics: no external analytics provider is implemented; keep disabled');
 if(c.appDeepLinkBase&&(!safeExternal(c.appDeepLinkBase)||c.appLinksVerified!==true))errors.push('appDeepLinkBase: HTTPS and device verification required');
 for(const d of c.downloads||[]){if(!d.revoked&&!(c.releaseNotes||[]).some(r=>r.version===d.version))errors.push(`releaseNotes: missing notes for ${d.version||'download version'}`);if(d.type==='apk'&&!d.comingSoon&&!d.revoked&&!d.size)errors.push('downloads.size: APK size required');if(!['apk','store','web'].includes(d.type))errors.push('downloads.type: apk, store or web required');if(!/^\d{4}-\d{2}-\d{2}$/.test(d.date||'')||Number.isNaN(Date.parse(d.date)))errors.push('downloads.date: ISO date required');}
 for(const k of ['policiesApproved','catalogReviewed','comparisonRightsConfirmed'])if(c[k]!==true)errors.push(`${k}: confirmation required`);
 return errors;
}
export const locales=['id','en','ar'];
export const pick=(value,locale)=>typeof value==='string'?value:value?.[locale]??'';
export const pathFor=(locale,route='')=>`/${locale}/${route.replace(/^\/+|\/+$/g,'')}${route?'/':''}`;
export function markdown(text) {
 const inline=s=>escapeHtml(s).replace(/\*\*(.+?)\*\*/g,'<strong>$1</strong>').replace(/`([^`]+)`/g,'<code>$1</code>').replace(/(?<!\*)\*([^*]+)\*(?!\*)/g,'<em>$1</em>');
 return text.split(/\n\s*\n/).map(b=>{
  if(/^#{1,6} /.test(b)){const n=Math.min(5,Math.max(3,b.match(/^#+/)[0].length));return `<h${n}>${inline(b.replace(/^#{1,6} /,''))}</h${n}>`;}
  if(/^---+$/.test(b.trim()))return '<hr>';
  const lines=b.split('\n');
  if(lines.length>1&&/^\|/.test(lines[0])&&/^\|[ :|\-]+$/.test(lines[1])){const cells=line=>line.replace(/^\||\|$/g,'').split('|').map(x=>x.trim());return `<div class="answer-table" role="region" tabindex="0" aria-label="Table"><table><thead><tr>${cells(lines[0]).map(c=>`<th scope="col">${inline(c)}</th>`).join('')}</tr></thead><tbody>${lines.slice(2).map(row=>`<tr>${cells(row).map(c=>`<td>${inline(c)}</td>`).join('')}</tr>`).join('')}</tbody></table></div>`;}
  const listAt=lines.findIndex(line=>/^\s*(?:\d+\.|[-*]) /.test(line));
  if(listAt>=0&&lines.slice(listAt).every(line=>/^\s*(?:\d+\.|[-*]) /.test(line))){const tag=/^\d+\./.test(lines[listAt])?'ol':'ul';return `${listAt?`<p dir="auto">${inline(lines.slice(0,listAt).join(' '))}</p>`:''}<${tag}>${lines.slice(listAt).map(line=>`<li dir="auto">${inline(line.replace(/^\s*(?:\d+\.|[-*]) /,''))}</li>`).join('')}</${tag}>`;}
  return `<p dir="auto">${inline(b).replace(/\n/g,'<br>')}</p>`;
 }).join('\n');
}
