import {escapeHtml as e,pathFor,safeExternal} from './core.mjs';
import {tr} from './copy.mjs';
import {arrow,link,eyebrow} from './render.mjs';
import {number} from './metadata.mjs';

export function membership(l,config,{compact=false}={}) {
  const entry=config.plans.find(p=>p.id==='tholib')||config.plans[0];
  const price=entry?number(entry.price,l):'';
  const href=config.appLinksVerified&&safeExternal(config.appDeepLinkBase)
    ?new URL('access',config.appDeepLinkBase.replace(/\/?$/,'/')).href:pathFor(l,'download');
  return `<div class="membership-banner">
    <div class="membership-message">${eyebrow(tr(l,'memberEyebrow'))}
      <h2>${tr(l,'accessTitle')}</h2>
      <p class="membership-price"><span>${tr(l,'memberFrom')}</span> <bdi>${l==='id'?'Rp ':''}${price}${l!=='id'?' IDR':''}</bdi> <span>${tr(l,'memberPerMonth')}</span></p>
      <p class="membership-description">${tr(l,'accessSub')}</p>
      <p class="membership-payments"><bdi>Midtrans</bdi><span>QRIS</span><span>${tr(l,'paymentVA')}</span><span>${tr(l,'paymentWallet')}</span></p>
    </div>
    <div class="membership-action"><a class="button" href="${e(href)}">${tr(l,'chooseMembership')}${arrow}</a><p>${tr(l,'memberManual')}</p>${link(l,'billing',tr(l,'memberReview'))}</div>
  </div>
  ${compact?'':`<p class="fine-print membership-detail">${tr(l,'memberMethods')}</p><div class="refund-panel">${eyebrow(tr(l,'billing'))}<p>${tr(l,'memberRefund')}</p>${link(l,'billing',tr(l,'billing'))}</div>`}`;
}
