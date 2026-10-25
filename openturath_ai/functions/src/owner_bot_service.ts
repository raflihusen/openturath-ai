import * as admin from "firebase-admin";
import {OwnerBot, Llm, LlmMessage} from "./owner_bot";
import {OwnerOps} from "./owner_ops";
import {NOTEBOOK_ENTITIES} from "./notebook_catalog";
import {ENTITY_SCOPES, SCOPE_LABELS} from "./access_catalog";

// VPS service: `node lib/owner_bot_service.js` (systemd unit openturath-owner-bot).
// Environment (secrets/owner_bot.env):
//   TELEGRAM_BOT_TOKEN, OWNER_TELEGRAM_IDS=123,456
//   LLM_BASE_URL=http://127.0.0.1:<port>/v1   (OpenAI-compatible router, optional)
//   LLM_MODEL, LLM_API_KEY (optional)
//   OWNER_BOT_TAKE_OVER_WEBHOOK=1   delete an existing webhook once so long polling can start

admin.initializeApp({projectId: process.env.GOOGLE_CLOUD_PROJECT || "open-turath"});
const db = admin.firestore();
const token = process.env.TELEGRAM_BOT_TOKEN || "";
const owners = new Set(String(process.env.OWNER_TELEGRAM_IDS || "").split(",").map(s => s.trim()).filter(s => /^\d+$/.test(s)));

async function telegram(method: string, body: any, timeoutMs = 20000): Promise<any> {
  const res = await fetch(`https://api.telegram.org/bot${token}/${method}`, {method: "POST",
    headers: {"Content-Type": "application/json"}, body: JSON.stringify(body), signal: AbortSignal.timeout(timeoutMs)});
  const data: any = await res.json().catch(() => ({ok: false}));
  if (!data.ok) throw Object.assign(new Error(`Telegram ${method} failed (${data.error_code || res.status})`), {code: data.error_code || res.status});
  return data.result;
}

// OpenAI-compatible chat completions with function tools.
function openAiCompatible(base: string, model: string, key: string): Llm {
  return async ({system, messages, tools}) => {
    const wire = [{role: "system", content: system}, ...messages.map((m: LlmMessage) => m.role === "tool"
      ? {role: "tool", tool_call_id: m.tool_call_id, content: m.content}
      : m.role === "assistant" && m.tool_calls?.length
        ? {role: "assistant", content: m.content || null, tool_calls: m.tool_calls.map(c => ({id: c.id, type: "function",
          function: {name: c.name, arguments: typeof c.arguments === "string" ? c.arguments : JSON.stringify(c.arguments)}}))}
        : {role: m.role, content: m.content})];
    const res = await fetch(`${base.replace(/\/$/, "")}/chat/completions`, {method: "POST",
      headers: {"Content-Type": "application/json", ...(key ? {Authorization: `Bearer ${key}`} : {})},
      body: JSON.stringify({model, messages: wire, tools: tools.map(t => ({type: "function", function: t})), tool_choice: "auto"}),
      signal: AbortSignal.timeout(120000)});
    if (!res.ok) throw new Error(`LLM router HTTP ${res.status}`);
    const data: any = await res.json();
    const msg = data.choices?.[0]?.message || {};
    return {text: msg.content || "", tool_calls: (msg.tool_calls || []).map((c: any) => ({id: c.id, name: c.function?.name, arguments: c.function?.arguments}))};
  };
}

async function main(): Promise<void> {
  if (!token || !owners.size) throw new Error("TELEGRAM_BOT_TOKEN and OWNER_TELEGRAM_IDS are required");
  const llm = process.env.LLM_BASE_URL ? openAiCompatible(process.env.LLM_BASE_URL, process.env.LLM_MODEL || "auto", process.env.LLM_API_KEY || "") : undefined;
  const ops = new OwnerOps(db, NOTEBOOK_ENTITIES, ENTITY_SCOPES, SCOPE_LABELS, Date.now,
    (ms: number) => admin.firestore.Timestamp.fromMillis(ms));
  const bot = new OwnerBot({db, ops, owners, telegram, llm});
  const state = db.collection("owner_bot").doc("state");
  if (process.env.OWNER_BOT_TAKE_OVER_WEBHOOK === "1") await telegram("deleteWebhook", {drop_pending_updates: false});
  let offset = Number((await state.get()).data()?.offset) || 0;
  console.log(JSON.stringify({event: "owner_bot_started", owners: owners.size, llm: !!llm}));
  while (true) {
    try {
      const updates: any[] = await telegram("getUpdates", {offset, timeout: 50, allowed_updates: ["message", "callback_query"]}, 60000);
      for (const update of updates) {
        // Advance first: an update that crashes the handler must not loop forever.
        offset = update.update_id + 1;
        await state.set({offset, updated_ms: Date.now()}, {merge: true});
        try { await bot.handleUpdate(update); } catch (_) { console.error("Owner bot update failed"); }
      }
      await db.collection("owner_bot").doc("heartbeat").set({last_poll_ms: Date.now(), llm: !!llm}, {merge: true});
    } catch (e: any) {
      // 409: a webhook is still registered; set OWNER_BOT_TAKE_OVER_WEBHOOK=1 once.
      console.error(JSON.stringify({event: "owner_bot_poll_failed", code: e.code || null}));
      await new Promise(r => setTimeout(r, e.code === 409 ? 60000 : 5000));
    }
  }
}

main().catch(e => { console.error(`Owner bot stopped: ${e.message}`); process.exitCode = 1; });
