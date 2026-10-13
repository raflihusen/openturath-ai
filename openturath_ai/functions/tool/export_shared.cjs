// Writes the registries the Python automation reads. Run `npm run export-shared`
// after changing VIP_EMAILS or the product catalog; the drift test enforces it.
const fs = require("fs");
const path = require("path");
const {VIP_EMAILS} = require("../lib/access_control.js");
const {sharedCatalog} = require("../lib/access_catalog.js");

const target = path.join(__dirname, "../../../ecosystem/openturath_subscription/shared");
fs.mkdirSync(target, {recursive: true});
const write = (name, value) => fs.writeFileSync(path.join(target, name), JSON.stringify(value, null, 2) + "\n");
write("vip_emails.json", [...VIP_EMAILS].sort());
write("product_catalog.json", sharedCatalog());
console.log("Shared registries written to", target);
