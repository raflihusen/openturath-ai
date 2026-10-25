"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const admin = require("firebase-admin");
const owner_bot_1 = require("./owner_bot");
const owner_ops_1 = require("./owner_ops");
const notebook_catalog_1 = require("./notebook_catalog");
const access_catalog_1 = require("./access_catalog");
// VPS service: `node lib/owner_bot_service.js` (systemd unit openturath-owner-bot).
// Environment (secrets/owner_bot.env):
//   TELEGRAM_BOT_TOKEN, OWNER_TELEGRAM_IDS=123,456
//   LLM_BASE_URL=http://127.0.0.1:<port>/v1   (OpenAI-compatible router, optional)
//   LLM_MODEL, LLM_API_KEY (optional)
//   OWNER_BOT_TAKE_OVER_WEBHOOK=1   delete an existing webhook once so long polling can start
admin.initializeApp({ projectId: process.env.GOOGLE_CLOUD_PROJECT || "open-turath" });
const db = admin.firestore();
const token = process.env.TELEGRAM_BOT_TOKEN || "";
const owners = new Set(String(process.env.OWNER_TELEGRAM_IDS || "").split(",").map(s => s.trim()).filter(s => /^\d+$/.test(s)));
async function telegram(method, body, timeoutMs = 20000) {
    const res = await fetch(`https://api.telegram.org/bot${token}/${method}`, { method: "POST",
        headers: { "Content-Type": "application/json" }, body: JSON.stringify(body), signal: AbortSignal.timeout(timeoutMs) });
    const data = await res.json().catch(() => ({ ok: false }));
    if (!data.ok)
        throw Object.assign(new Error(`Telegram ${method} failed (${data.error_code || res.status})`), { code: data.error_code || res.status });
    return data.result;
}
// OpenAI-compatible chat completions with function tools.
function openAiCompatible(base, model, key) {
    return async ({ system, messages, tools }) => {
        var _a, _b;
        const wire = [{ role: "system", content: system }, ...messages.map((m) => {
                var _a;
                return m.role === "tool"
                    ? { role: "tool", tool_call_id: m.tool_call_id, content: m.content }
                    : m.role === "assistant" && ((_a = m.tool_calls) === null || _a === void 0 ? void 0 : _a.length)
                        ? { role: "assistant", content: m.content || null, tool_calls: m.tool_calls.map(c => ({ id: c.id, type: "function",
                                function: { name: c.name, arguments: typeof c.arguments === "string" ? c.arguments : JSON.stringify(c.arguments) } })) }
                        : { role: m.role, content: m.content };
            })];
        const res = await fetch(`${base.replace(/\/$/, "")}/chat/completions`, { method: "POST",
            headers: Object.assign({ "Content-Type": "application/json" }, (key ? { Authorization: `Bearer ${key}` } : {})),
            body: JSON.stringify({ model, messages: wire, tools: tools.map(t => ({ type: "function", function: t })), tool_choice: "auto" }),
            signal: AbortSignal.timeout(120000) });
        if (!res.ok)
            throw new Error(`LLM router HTTP ${res.status}`);
        const data = await res.json();
        const msg = ((_b = (_a = data.choices) === null || _a === void 0 ? void 0 : _a[0]) === null || _b === void 0 ? void 0 : _b.message) || {};
        return { text: msg.content || "", tool_calls: (msg.tool_calls || []).map((c) => { var _a, _b; return ({ id: c.id, name: (_a = c.function) === null || _a === void 0 ? void 0 : _a.name, arguments: (_b = c.function) === null || _b === void 0 ? void 0 : _b.arguments }); }) };
    };
}
async function main() {
    var _a;
    if (!token || !owners.size)
        throw new Error("TELEGRAM_BOT_TOKEN and OWNER_TELEGRAM_IDS are required");
    const llm = process.env.LLM_BASE_URL ? openAiCompatible(process.env.LLM_BASE_URL, process.env.LLM_MODEL || "auto", process.env.LLM_API_KEY || "") : undefined;
    const ops = new owner_ops_1.OwnerOps(db, notebook_catalog_1.NOTEBOOK_ENTITIES, access_catalog_1.ENTITY_SCOPES, access_catalog_1.SCOPE_LABELS, Date.now, (ms) => admin.firestore.Timestamp.fromMillis(ms));
    const bot = new owner_bot_1.OwnerBot({ db, ops, owners, telegram, llm });
    const state = db.collection("owner_bot").doc("state");
    if (process.env.OWNER_BOT_TAKE_OVER_WEBHOOK === "1")
        await telegram("deleteWebhook", { drop_pending_updates: false });
    let offset = Number((_a = (await state.get()).data()) === null || _a === void 0 ? void 0 : _a.offset) || 0;
    console.log(JSON.stringify({ event: "owner_bot_started", owners: owners.size, llm: !!llm }));
    while (true) {
        try {
            const updates = await telegram("getUpdates", { offset, timeout: 50, allowed_updates: ["message", "callback_query"] }, 60000);
            for (const update of updates) {
                // Advance first: an update that crashes the handler must not loop forever.
                offset = update.update_id + 1;
                await state.set({ offset, updated_ms: Date.now() }, { merge: true });
                try {
                    await bot.handleUpdate(update);
                }
                catch (_) {
                    console.error("Owner bot update failed");
                }
            }
            await db.collection("owner_bot").doc("heartbeat").set({ last_poll_ms: Date.now(), llm: !!llm }, { merge: true });
        }
        catch (e) {
            // 409: a webhook is still registered; set OWNER_BOT_TAKE_OVER_WEBHOOK=1 once.
            console.error(JSON.stringify({ event: "owner_bot_poll_failed", code: e.code || null }));
            await new Promise(r => setTimeout(r, e.code === 409 ? 60000 : 5000));
        }
    }
}
main().catch(e => { console.error(`Owner bot stopped: ${e.message}`); process.exitCode = 1; });
//# sourceMappingURL=owner_bot_service.js.map