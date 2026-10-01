"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const protocol = require("./extension/notebook_protocol.js");

const ORIGIN = "https://notebooklm.google.com";
const EMAIL = "reader@example.com";
const NOTEBOOK = "11111111-1111-4111-8111-111111111111";
const SOURCE = "22222222-2222-4222-8222-222222222222";
const OTHER = "33333333-3333-4333-8333-333333333333";
const CONVERSATION = "44444444-4444-4444-8444-444444444444";
const STREAM = "55555555-5555-4555-8555-555555555555";

function bootstrap(extra = {}, prefix = "") {
  return prefix + '<html><script nonce="fixture">window.WIZ_global_data = ' +
    JSON.stringify(Object.assign({
      oPEP7c: EMAIL,
      SNlM0e: "test-csrf-not-a-real-token",
      FdrFJe: "test-session-not-a-real-session",
      cfb2h: "boq_labs-tailwind-frontend_fixture.01_p0"
    }, extra)) + ";</script></html>";
}
function frame(id, payload) {
  return [["wrb.fr", id, JSON.stringify(payload), null, null, null]];
}
function framed(records) {
  return ")]}'\n" + records.map(record => {
    const value = JSON.stringify(record);
    return Buffer.byteLength(value, "utf8") + "\n" + value + "\n";
  }).join("\n");
}
function citation(source = SOURCE, excerpt = "A documented source passage.") {
  return [
    ["a-source-chunk"],
    [null, null, 0.7, [[null, 0, 8]],
      [[[0, excerpt.length, [[[null, null, excerpt]]]]]],
      [[source]]]
  ];
}
function answer(text = "An answer [1].", citations = [citation()], streamId = STREAM) {
  return [[text, null, [streamId], null, [null, null, null, citations, 1]]];
}
function sources(notebookId = NOTEBOOK) {
  return [["Research notebook", [[[SOURCE], "Primary source"]], notebookId]];
}
function hasCode(code, uncertain) {
  return error => error && error.code === code &&
    (uncertain === undefined || error.uncertain === uncertain) &&
    typeof error.message === "string";
}
function response(text, url, status = 200, options = {}) {
  return Object.assign({
    url,
    status,
    ok: status >= 200 && status < 300,
    redirected: false,
    type: "basic",
    headers: new Headers(),
    text: async () => text
  }, options);
}
function harness(overrides = {}) {
  const requests = [];
  const fetchImpl = async (url, options) => {
    requests.push({ url, options });
    const index = requests.length - 1;
    if (overrides[index]) return overrides[index](url, options);
    const values = [
      bootstrap(),
      framed([frame("rLM1Ne", sources())]),
      framed([frame(null, answer())]),
      framed([frame("hPTbtc", [[[CONVERSATION]]])])
    ];
    if (index >= values.length) throw new Error("Unexpected retry");
    return response(values[index], url);
  };
  return { requests, fetchImpl };
}
function ask(fetchImpl, extra = {}) {
  return protocol.performAsk(Object.assign({
    origin: ORIGIN, notebookId: NOTEBOOK, email: EMAIL,
    question: "What does this source say?", fetchImpl
  }, extra));
}

test("bootstrap identity is scoped to WIZ and exposes no page credentials", () => {
  const handle = protocol.parseBootstrap(bootstrap({}, '<p>"someone-else@example.com"</p>'), EMAIL, ORIGIN);
  assert.deepEqual(handle, { origin: ORIGIN, email: EMAIL });
  assert.ok(Object.isFrozen(handle));
  const serialized = JSON.stringify(handle);
  assert.ok(!serialized.includes("test-csrf"));
  assert.ok(!serialized.includes("test-session"));
  assert.ok(!serialized.includes("boq_"));
});

test("a quoted email elsewhere cannot replace missing account identity", () => {
  const html = bootstrap({ oPEP7c: undefined }, '<p>"reader@example.com"</p>');
  assert.throws(() => protocol.parseBootstrap(html, EMAIL, ORIGIN), hasCode("ACCOUNT_UNVERIFIED"));
});

test("account mismatch, duplicate bootstraps and executable expressions fail closed", () => {
  assert.throws(() => protocol.parseBootstrap(bootstrap({ oPEP7c: "other@example.com" }), EMAIL, ORIGIN),
    hasCode("ACCOUNT_MISMATCH"));
  assert.throws(() => protocol.parseBootstrap(bootstrap() + bootstrap(), EMAIL, ORIGIN),
    hasCode("ACCOUNT_UNVERIFIED"));
  const executable = '<script>window.WIZ_global_data = (function(){throw "no";})()</script>';
  assert.throws(() => protocol.parseBootstrap(executable, EMAIL, ORIGIN), hasCode("BOOTSTRAP_INVALID"));
  const quoted = '<script>var text = ' + JSON.stringify("WIZ_global_data = " + JSON.stringify({ oPEP7c: EMAIL })) + ";</script>";
  assert.throws(() => protocol.parseBootstrap(quoted, EMAIL, ORIGIN), hasCode("BOOTSTRAP_INVALID"));
});

test("bootstrap accepts only NotebookLM origins and a currently observed build", () => {
  assert.deepEqual(protocol.parseBootstrap(bootstrap(), EMAIL, "https://notebook.google.com"), {
    origin: "https://notebook.google.com", email: EMAIL
  });
  assert.throws(() => protocol.parseBootstrap(bootstrap(), EMAIL, "https://accounts.google.com"),
    hasCode("INVALID_ORIGIN"));
  assert.throws(() => protocol.parseBootstrap(bootstrap({ cfb2h: "invalid" }), EMAIL, ORIGIN),
    hasCode("BOOTSTRAP_INVALID"));
  assert.throws(() => protocol.parseBootstrap(bootstrap({ SNlM0e: "" }), EMAIL, ORIGIN),
    hasCode("SESSION_REQUIRED"));
});

test("length-prefixed frames count UTF-8 bytes for Arabic text and citations", () => {
  const result = protocol.parseAnswer(framed([frame(null, answer("الجواب الموثّق [1].", [citation(SOURCE, "نص المصدر العربي.")]))]), [SOURCE]);
  assert.equal(result.answer, "الجواب الموثّق [1].");
  assert.deepEqual(result.citations, [{ sourceId: SOURCE, citationNumber: 1, excerpt: "نص المصدر العربي." }]);
});

test("plain JSON frames are accepted without treating metadata counts as errors", () => {
  const raw = ")]}'\n" + JSON.stringify(frame("rLM1Ne", sources())) + "\n" + JSON.stringify([["e", 12345]]);
  assert.deepEqual(protocol.parseSources(protocol.decodeRpc(raw, "rLM1Ne")),
    [{ sourceId: SOURCE, title: "Primary source" }]);
});

test("truncated, invalid byte counts, HTML and oversized responses are rejected", () => {
  const valid = framed([frame(null, answer())]);
  assert.throws(() => protocol.parseAnswer(valid.slice(0, -15), [SOURCE]), hasCode("PROTOCOL_CHANGED"));
  const json = JSON.stringify(frame(null, answer("جواب")));
  const incorrect = ")]}'\n" + json.length + "\n" + json;
  assert.throws(() => protocol.parseAnswer(incorrect, [SOURCE]), hasCode("PROTOCOL_CHANGED"));
  assert.throws(() => protocol.decodeRpc("<html>Sign in</html>", "rLM1Ne"), hasCode("PROTOCOL_CHANGED"));
  assert.throws(() => protocol.decodeRpc("x".repeat(8 * 1024 * 1024 + 1), "rLM1Ne"),
    hasCode("RESPONSE_TOO_LARGE"));
});

test("RPC method mismatch and server error frames are not empty successful results", () => {
  assert.throws(() => protocol.decodeRpc(framed([frame("wXbhsf", [])]), "rLM1Ne"),
    hasCode("PROTOCOL_CHANGED"));
  assert.throws(() => protocol.decodeRpc(framed([[["er", "rLM1Ne", 7]]]), "rLM1Ne"),
    hasCode("RPC_REJECTED"));
  assert.throws(() => protocol.parseAnswer(framed([[["wrb.fr", null, null, null, null, [8]]]]), [SOURCE]),
    hasCode("RATE_LIMITED"));
});

test("source normalization handles Drive-backed identifiers and rejects duplicates", () => {
  const payload = [["Notebook", [
    [[SOURCE], "Normal source"],
    [[null, true, [OTHER]], "Drive source"]
  ], NOTEBOOK]];
  assert.deepEqual(protocol.parseSources(payload), [
    { sourceId: SOURCE, title: "Normal source" },
    { sourceId: OTHER, title: "Drive source" }
  ]);
  payload[0][1].push([[SOURCE], "Duplicate"]);
  assert.throws(() => protocol.parseSources(payload), hasCode("PROTOCOL_CHANGED"));
});

test("citations retain original numbers and never re-anchor foreign or malformed entries", () => {
  const refs = [citation(SOURCE, "First passage"), citation(OTHER, "Second passage")];
  const parsed = protocol.parseAnswer(framed([frame(null, answer("Both [1] and [2].", refs))]), [SOURCE, OTHER]);
  assert.deepEqual(parsed.citations.map(ref => [ref.citationNumber, ref.sourceId]),
    [[1, SOURCE], [2, OTHER]]);
  assert.throws(() => protocol.parseAnswer(framed([frame(null, answer("Both", refs))]), [SOURCE]),
    hasCode("FOREIGN_REFERENCE"));
  assert.throws(() => protocol.parseAnswer(framed([frame(null, answer("Bad", [citation(), [null]]))]), [SOURCE]),
    hasCode("PROTOCOL_CHANGED"));
});

test("the final marked answer carries its own citation set, rather than concatenated chunks", () => {
  const raw = framed([
    frame(null, answer("Short [1].")),
    frame(null, answer("A longer final answer [1].", [citation(SOURCE, "Final passage")])),
    frame(null, [])
  ]);
  const parsed = protocol.parseAnswer(raw, [SOURCE]);
  assert.equal(parsed.answer, "A longer final answer [1].");
  assert.equal(parsed.citations[0].excerpt, "Final passage");
});

test("a structural citation with no text does not invent a source excerpt", () => {
  const ref = citation();
  ref[1][4] = [];
  const parsed = protocol.parseAnswer(framed([frame(null, answer("A cited answer [1].", [ref]))]), [SOURCE]);
  assert.equal(parsed.citations[0].excerpt, "");
});

test("performAsk leaves credentials in browser requests and returns the actual saved conversation", async () => {
  const h = harness();
  const result = await ask(h.fetchImpl);
  assert.deepEqual(result, {
    answer: "An answer [1].",
    citations: [{ sourceId: SOURCE, citationNumber: 1, excerpt: "A documented source passage." }],
    conversationId: CONVERSATION,
    accountEmail: EMAIL
  });
  assert.notEqual(result.conversationId, STREAM);
  assert.equal(h.requests.length, 4);
  for (const request of h.requests) {
    const url = new URL(request.url);
    assert.equal(url.origin, ORIGIN);
    assert.equal(url.searchParams.get("authuser"), EMAIL);
    assert.equal(request.options.credentials, "include");
    assert.equal(request.options.redirect, "manual");
    assert.ok(!request.options.headers || Object.keys(request.options.headers).every(key => key === "Content-Type"));
  }
  const chat = h.requests[2];
  const envelope = JSON.parse(new URLSearchParams(chat.options.body).get("f.req"));
  const params = JSON.parse(envelope[1]);
  assert.deepEqual(params[0], [[[SOURCE]]]);
  assert.equal(params[7], NOTEBOOK);
  assert.equal(params[4], null);
  assert.ok(!JSON.stringify(result).includes("test-csrf"));
  assert.ok(!JSON.stringify(result).includes("test-session"));
});

test("read-response streaming may split UTF-8 characters and frame headers", async () => {
  const h = harness({
    2: (url) => {
      const data = new TextEncoder().encode(framed([frame(null, answer("جواب عربي [1]."))]));
      const stream = new ReadableStream({
        start(controller) {
          for (let index = 0; index < data.length; index += 3) controller.enqueue(data.slice(index, index + 3));
          controller.close();
        }
      });
      return response("", url, 200, { body: stream });
    }
  });
  assert.equal((await ask(h.fetchImpl)).answer, "جواب عربي [1].");
});

test("account mismatch and authentication redirects stop before a question is sent", async () => {
  const mismatch = harness({ 0: url => response(bootstrap({ oPEP7c: "other@example.com" }), url) });
  await assert.rejects(ask(mismatch.fetchImpl), hasCode("ACCOUNT_MISMATCH", false));
  assert.equal(mismatch.requests.length, 1);
  const redirect = harness({ 0: url => response("", url, 0, { type: "opaqueredirect" }) });
  await assert.rejects(ask(redirect.fetchImpl), hasCode("SESSION_REQUIRED", false));
  assert.equal(redirect.requests.length, 1);
});

test("a failed chat connection is uncertain and is never retried", async () => {
  const h = harness({ 2: () => { throw new Error("simulated private transport details"); } });
  await assert.rejects(ask(h.fetchImpl), error => {
    assert.ok(!error.message.includes("private transport"));
    return hasCode("REQUEST_UNCERTAIN", true)(error);
  });
  assert.equal(h.requests.length, 3);
});

test("cancellation before dispatch sends nothing; cancellation after dispatch remains uncertain", async () => {
  const controller = new AbortController();
  controller.abort();
  const before = harness();
  await assert.rejects(ask(before.fetchImpl, { signal: controller.signal }), hasCode("REQUEST_CANCELLED", false));
  assert.equal(before.requests.length, 0);
  const running = new AbortController();
  const after = harness({ 2: () => { running.abort(); throw new DOMException("Aborted", "AbortError"); } });
  await assert.rejects(ask(after.fetchImpl, { signal: running.signal }), hasCode("REQUEST_UNCERTAIN", true));
  assert.equal(after.requests.length, 3);
});

test("wrong notebook data and oversized history fail before dispatching chat", async () => {
  const h = harness({ 1: url => response(framed([frame("rLM1Ne", sources(OTHER))]), url) });
  await assert.rejects(ask(h.fetchImpl), hasCode("PROTOCOL_CHANGED"));
  assert.equal(h.requests.length, 2);
  const oversized = harness();
  await assert.rejects(ask(oversized.fetchImpl, { history: [["x".repeat(120001), null, 2]] }), hasCode("INVALID_INPUT"));
  assert.equal(oversized.requests.length, 0);
});

test("successful generation with missing conversation metadata is not replaced with the stream id", async () => {
  const h = harness({ 3: url => response(framed([frame("hPTbtc", [])]), url) });
  await assert.rejects(ask(h.fetchImpl), hasCode("CONVERSATION_UNVERIFIED", true));
  assert.equal(h.requests.length, 4);
});

test("follow-up history uses recorded triplets and verifies the saved conversation", async () => {
  const h = harness();
  await ask(h.fetchImpl, {
    conversationId: CONVERSATION,
    history: [["Previous answer", null, 2], ["Previous question", null, 1]]
  });
  const envelope = JSON.parse(new URLSearchParams(h.requests[2].options.body).get("f.req"));
  const params = JSON.parse(envelope[1]);
  assert.equal(params[4], CONVERSATION);
  assert.deepEqual(params[2], [["Previous answer", null, 2], ["Previous question", null, 1]]);
});
