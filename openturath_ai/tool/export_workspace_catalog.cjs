// Export display metadata only. Notebook URLs remain behind getAgentUrl.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require('../functions/node_modules/typescript');
const source = fs.readFileSync(path.join(__dirname, '../functions/src/notebook_catalog.ts'), 'utf8');
const code = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.CommonJS } }).outputText;
const sandbox = { exports: {} };
vm.runInNewContext(code, sandbox);
const { NOTEBOOK_ENTITIES, AGENT_TO_ENTITY } = sandbox.exports;
const catalog = Object.values(NOTEBOOK_ENTITIES).map(entity => {
  const aliases = Object.keys(AGENT_TO_ENTITY).filter(id => AGENT_TO_ENTITY[id] === entity.code);
  if (!aliases.length) throw new Error(`Missing agent mapping for ${entity.code}`);
  return { id: aliases[0], title: entity.name, aliases };
}).sort((a, b) => a.title.localeCompare(b.title, 'id'));
fs.writeFileSync(path.join(__dirname, '../public/workspace/catalog.json'), JSON.stringify(catalog, null, 2) + '\n');
console.log(`Exported ${catalog.length} module labels; no notebook URLs.`);
