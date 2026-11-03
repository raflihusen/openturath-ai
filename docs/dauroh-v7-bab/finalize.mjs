import fs from 'node:fs/promises';
import {finalizePresentation} from '/Users/apple/.codex/plugins/cache/openai-primary-runtime/presentations/26.1026.10807/skills/presentations/container_tools/artifact_tool_utils.mjs';
process.env.RUNTIME_NODE_MODULES='/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
process.env.RUNTIME_NODE='/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node';
const R='/Users/apple/Downloads/ramadhan/docs/dauroh-v7-bab';
const S='/Users/apple/.codex/plugins/cache/openai-primary-runtime/presentations/26.1026.10807/skills/presentations';
await fs.mkdir(R+'/output',{recursive:true});
const result=await finalizePresentation({
 workspaceDir:R,candidatePath:R+'/review/review-01.pptx',finalPath:R+'/output/Dauroh_AI_dan_Penelitian_Indonesia_Bab_v02.pptx',
 pythonExecutable:'/Users/apple/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3',
 integrityValidatorPath:S+'/container_tools/inspect_presentation_package_integrity.py',
 layoutValidatorPath:S+'/container_tools/inspect_presentation_layout_geometry.py',
 layoutArgs:['--expected-slide-size-emu','13716000,7715250','--validate-bullet-geometry','--validate-heading-fit'],
 explicitTotalSlideCount:106,requiredNativeTableOwnerSlides:[],requiredNativeChartOwnerSlides:[],
 fontPolicy:{basis:'user_request',families:['IBM Plex Sans Arabic']},verifyArtifactToolImport:true,
 receiptPath:R+'/.build/final-validation-v02.json'
});
console.log(JSON.stringify({finalPath:result.finalPath,sha256:result.finalSha256,slideCount:106}));
