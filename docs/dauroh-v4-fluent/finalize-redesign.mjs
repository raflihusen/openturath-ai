import fs from 'node:fs/promises';
import { finalizePresentation } from '/Users/apple/.codex/plugins/cache/openai-primary-runtime/presentations/26.1026.10807/skills/presentations/container_tools/artifact_tool_utils.mjs';

process.env.RUNTIME_NODE_MODULES='/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
process.env.RUNTIME_NODE='/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node';
const workspaceDir='/Users/apple/Downloads/ramadhan/docs/dauroh-v4-fluent';
const skill='/Users/apple/.codex/plugins/cache/openai-primary-runtime/presentations/26.1026.10807/skills/presentations';
const finalPath=workspaceDir+'/output/دورة_الذكاء_الاصطناعي_والبحث_العلمي_تصميم_منقح.pptx';
await fs.mkdir(workspaceDir+'/output',{recursive:true});
const result=await finalizePresentation({
 workspaceDir,
 candidatePath:workspaceDir+'/.build/redesign/review-03.pptx',
 finalPath,
 pythonExecutable:'/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3',
 integrityValidatorPath:skill+'/container_tools/inspect_presentation_package_integrity.py',
 layoutValidatorPath:skill+'/container_tools/inspect_presentation_layout_geometry.py',
 layoutArgs:['--expected-slide-size-emu','13716000,7715250','--validate-bullet-geometry','--validate-heading-fit'],
 explicitTotalSlideCount:52,
 requiredNativeTableOwnerSlides:[],
 requiredNativeChartOwnerSlides:[],
 fontPolicy:{basis:'user_request',families:['IBM Plex Sans Arabic']},
 verifyArtifactToolImport:true,
 receiptPath:workspaceDir+'/.build/redesign/final-validation.json'
});
console.log(JSON.stringify({finalPath:result.finalPath,receiptPath:result.receiptPath}));
