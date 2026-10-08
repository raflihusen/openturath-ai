// Pending archives can be published honestly; verified labels require source evidence.
export function publicationIntegrityIssues({config,proof,evidence,releases,appFacts}){
 const issues=[];
 const source=evidence.find(r=>r.id==='q001-e03');
 if(proof.reviewed===true&&!(source?.status==='matched'&&source.edition&&source.sourceUrl&&source.sourceText&&source.reviewer&&source.reviewDate))issues.push('proof.reviewed: source-edition evidence and reviewer record required');
 const offers=config.plans.map(p=>[p.price,p.months]);
 if(JSON.stringify(offers)!==JSON.stringify(appFacts.pricing.specialist.map(p=>[p.amount,p.months])))issues.push('prices: general-field offers differ from app facts');
 if(JSON.stringify((config.tahawwulatPlans||[]).map(p=>[p.amount,p.months]))!==JSON.stringify(appFacts.pricing.tahawwulat.map(p=>[p.amount,p.months])))issues.push('prices: Tahawwulat offers differ from app facts');
 for(const platform of releases.platforms){
  const release=config.downloads.find(r=>r.platform.toLowerCase()===platform.id);
  if(!release){issues.push('manifest: unknown platform '+platform.id);continue;}
  const active=!release.comingSoon&&!release.revoked;
  if(active&&(!platform.url||platform.url!==release.url||platform.sha256!==release.sha256||platform.sizeBytes!==release.sizeBytes))issues.push('manifest: active release metadata differs for '+platform.id);
  if(!active&&platform.url)issues.push('manifest: inactive release exposes a URL for '+platform.id);
 }
 for(const r of config.downloads)if(!releases.platforms.some(p=>p.id===r.platform.toLowerCase()))issues.push('manifest: missing platform '+r.platform);
 return issues;
}
export function releaseManifest(config){return {note:'Generated from site.config.json by app-fact sync or APK registration. Pending releases expose no download URL.',platforms:config.downloads.map(r=>{const active=!r.comingSoon&&!r.revoked;return {id:r.platform.toLowerCase(),name:r.platform,minimum:r.minimumOS,url:active?r.url:null,sizeBytes:active?r.sizeBytes??null:null,sha256:active?r.sha256??null:null,date:active?r.date:null};})};}
