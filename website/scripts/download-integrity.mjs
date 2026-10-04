import fs from 'node:fs/promises';
import path from 'node:path';
import {createHash} from 'node:crypto';

// Same-origin APK URLs are part of this artifact, not remote promises.
export async function downloadIntegrityIssues(config,root) {
  const issues=[];
  for(const release of config.downloads||[]){
    if(release.revoked||release.comingSoon||release.type!=='apk')continue;
    let url;
    try{url=new URL(release.url);}catch{continue;}
    if(url.origin!==new URL(config.canonicalUrl).origin){
      issues.push('Active APK must be bundled under the canonical origin for integrity verification.');continue;
    }
    const relative=decodeURIComponent(url.pathname).replace(/^\/+/, '');
    const publicRoot=path.resolve(root,'public');
    const file=path.resolve(publicRoot,relative);
    if(!file.startsWith(publicRoot+path.sep)){issues.push('APK path escapes public directory.');continue;}
    try{
      const bytes=await fs.readFile(file);
      const hash=createHash('sha256').update(bytes).digest('hex');
      if(hash!==release.sha256)issues.push(`APK SHA-256 mismatch: ${relative}`);
      if(bytes.length!==release.sizeBytes)issues.push(`APK byte size mismatch: ${relative}`);
      if(bytes.subarray(0,4).toString('hex')!=='504b0304')issues.push(`APK is not a ZIP container: ${relative}`);
    }catch(error){issues.push(`APK file unavailable: ${relative} (${error.code||error.message})`);}
  }
  return issues;
}
