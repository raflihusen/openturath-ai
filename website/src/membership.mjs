import {escapeHtml as e,pathFor,safeExternal} from './core.mjs';
import {tr,localized} from './copy.mjs';
import {arrow,link,eyebrow} from './render.mjs';
import {number} from './metadata.mjs';

export function membership(l,config,{compact=false}={}) {
 const entry=config.plans.find(p=>p.id==='tholib')||config.plans[0];
 const price=entry?number(entry.price,l):'';
 const href=config.appLinksVerified&&safeExternal(config.appDeepLinkBase)
  ?new URL('access',config.appDeepLinkBase.replace(/\/?$/,'/')).href:pathFor(l,'contact');
 return `<div class="membership-banner"><div class="membership-message">${eyebrow(tr(l,'memberEyebrow'))}<h2>${tr(l,'accessTitle')}</h2><p class="membership-price"><span>${tr(l,'memberFrom')}</span><bdi>${l==='id'?'Rp ':''}${price}${l!=='id'?' IDR':''}</bdi><span>${tr(l,'memberPerMonth')}</span></p><p class="membership-description">${tr(l,'accessSub')}</p><p class="membership-payments"><bdi>Midtrans</bdi><span>QRIS</span><span>${tr(l,'paymentVA')}</span><span>${tr(l,'paymentWallet')}</span></p></div><div class="membership-action"><a class="button" href="${e(href)}">${tr(l,'chooseMembership')}${arrow}</a><p>${tr(l,'memberManual')}</p>${link(l,'billing',tr(l,'memberReview'))}</div></div>${compact?'':`${priceTable(l,config)}<p class="fine-print membership-detail">${tr(l,'memberMethods')}</p><div class="refund-panel">${eyebrow(tr(l,'billing'))}<p>${tr(l,'memberRefund')}</p>${link(l,'billing',tr(l,'billing'))}</div>`}`;
}
function priceTable(l,config){
 const groups=[{label:['Asisten bidang umum','General-field assistant','مساعد المجال العام'],scope:['Per asisten yang dipilih','Per selected assistant','لكل مساعد مختار'],offers:config.plans.map(p=>({amount:p.price,months:p.months}))},{label:['AI Fikih Tahawwulat','Fiqh Tahawwulat AI','الذكاء الاصطناعي لفقه التحولات'],scope:['Paket kajian Tahawwulat','Tahawwulat study package','باقة دراسة فقه التحولات'],offers:config.tahawwulatPlans||[]}];
 return `<section class="price-section"><h2>${localized(['Pilih bidang, kenali biayanya.','Choose a field. Know the price.','اختر المجال وتعرّف على السعر.'],l)}</h2><div class="price-grid">${groups.map(g=>`<article><h3>${localized(g.label,l)}</h3><p>${localized(g.scope,l)}</p><dl>${g.offers.map(o=>`<div><dt>${o.months} ${localized(['bulan','months','أشهر'],l)}</dt><dd><bdi>Rp ${number(o.amount,'id')}</bdi></dd></div>`).join('')}</dl></article>`).join('')}</div><p class="fine-print">${localized(['Harga total per periode, bukan tagihan bulanan untuk paket 6/12 bulan. Harga mengikuti kode aplikasi; pastikan rincian dan ketersediaan akses pada checkout sebelum membayar.','Totals are per period, rather than monthly charges for the 6/12-month packages. Prices follow app code; confirm details and access availability at checkout before paying.','الأسعار إجمالية لكل مدة، وليست أقساطًا شهرية لباقتي ٦ و١٢ شهرًا. تتبع كود التطبيق؛ تأكّد من التفاصيل وإتاحة الوصول قبل الدفع.'],l)}</p></section>`;
}
