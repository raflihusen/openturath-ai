(function (root, factory) {
  "use strict";
  var api = factory();
  if (typeof module === "object" && module.exports) module.exports = api;
  root.OpenTurathNotebookProtocol = api;
})(typeof globalThis !== "undefined" ? globalThis : this, function () {
  "use strict";

  var ORIGINS = new Set(["https://notebooklm.google.com", "https://notebook.google.com"]);
  var MAX_RAW_BYTES = 8 * 1024 * 1024;
  var MAX_FRAMES = 512;
  var MAX_ANSWER_CHARS = 262144;
  var UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  var credentials = new WeakMap();
  var RPC_PATH = "/_/LabsTailwindUi/data/batchexecute";
  var CHAT_PATH = "/_/LabsTailwindUi/data/google.internal.labs.tailwind.orchestration.v1.LabsTailwindOrchestrationService/GenerateFreeFormStreamed";
  var RPC_IDS = new Set(["wXbhsf", "rLM1Ne", "hPTbtc"]);
  var messages = {
    INVALID_INPUT: "The NotebookLM request is invalid.",
    INVALID_ORIGIN: "The browser must be on an allowed NotebookLM origin.",
    BOOTSTRAP_INVALID: "The NotebookLM page bootstrap is unavailable or malformed.",
    ACCOUNT_UNVERIFIED: "The selected NotebookLM account cannot be verified.",
    ACCOUNT_MISMATCH: "The selected NotebookLM account differs from the app account.",
    SESSION_REQUIRED: "Open NotebookLM in the browser and reconnect the account.",
    RESPONSE_TOO_LARGE: "The NotebookLM response exceeds the supported size.",
    PROTOCOL_CHANGED: "The NotebookLM response does not match the supported protocol.",
    RPC_REJECTED: "NotebookLM rejected the request.",
    RATE_LIMITED: "NotebookLM has limited this request.",
    FOREIGN_REFERENCE: "A citation refers to a source outside the selected notebook.",
    EMPTY_ANSWER: "NotebookLM returned no answer.",
    NETWORK_FAILURE: "The browser could not reach NotebookLM.",
    REQUEST_CANCELLED: "The request was cancelled before it was sent.",
    REQUEST_UNCERTAIN: "The connection ended after sending; NotebookLM may have processed the question.",
    CONVERSATION_UNVERIFIED: "The answer was generated but its saved conversation could not be verified."
  };

  function ProtocolError(code, uncertain) {
    this.name = "NotebookProtocolError";
    this.code = code;
    this.message = messages[code] || messages.PROTOCOL_CHANGED;
    this.uncertain = Boolean(uncertain);
    if (Error.captureStackTrace) Error.captureStackTrace(this, ProtocolError);
  }
  ProtocolError.prototype = Object.create(Error.prototype);
  ProtocolError.prototype.constructor = ProtocolError;
  function fail(code, uncertain) { throw new ProtocolError(code, uncertain); }

  function originOf(value) {
    if (typeof value !== "string") fail("INVALID_ORIGIN");
    var url;
    try { url = new URL(value); } catch (_) { fail("INVALID_ORIGIN"); }
    if (!ORIGINS.has(url.origin) || url.username || url.password ||
        url.search || url.hash || url.pathname !== "/") fail("INVALID_ORIGIN");
    return url.origin;
  }
  function emailOf(value) {
    if (typeof value !== "string" || value.length > 254 ||
        !/^[A-Za-z0-9.!#$%&'*+/=?^_{}|~-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(value.trim())) {
      fail("INVALID_INPUT");
    }
    return value.trim().toLowerCase();
  }
  function idOf(value) {
    if (typeof value !== "string" || !UUID.test(value)) fail("INVALID_INPUT");
    return value.toLowerCase();
  }
  function boundText(value, max, code) {
    if (typeof value !== "string" || value.length > max) fail(code || "INVALID_INPUT");
    return value;
  }
  function encoded(text) {
    boundText(text, MAX_RAW_BYTES, "RESPONSE_TOO_LARGE");
    var bytes = new TextEncoder().encode(text);
    if (bytes.length > MAX_RAW_BYTES) fail("RESPONSE_TOO_LARGE");
    return bytes;
  }
  function parseJson(text, code) {
    try { return JSON.parse(text); } catch (_) { fail(code || "PROTOCOL_CHANGED"); }
  }

  // Only JSON object literals inside NotebookLM's bootstrap scripts are read.
  // No script execution, global-object access, or broad email search is used.
  function jsonObjectEnd(text, start) {
    var depth = 0, quoted = false, escaped = false;
    for (var i = start; i < text.length; i += 1) {
      var c = text[i];
      if (quoted) {
        if (escaped) escaped = false;
        else if (c === "\\") escaped = true;
        else if (c === '"') quoted = false;
      } else if (c === '"') quoted = true;
      else if (c === "{") depth += 1;
      else if (c === "}") {
        depth -= 1;
        if (depth === 0) return i + 1;
      }
    }
    fail("BOOTSTRAP_INVALID");
  }
  function parseBootstrap(html, expectedEmail, origin) {
    encoded(html);
    var expected = emailOf(expectedEmail), actualOrigin = originOf(origin);
    var scripts = /<script\b[^>]*>([\s\S]*?)<\/script\s*>/gi;
    var assignment = /^\s*(?:(?:var|let|const)\s+|window\s*\.\s*)?WIZ_global_data\s*=\s*/g;
    var script, match, blocks = [];
    while ((script = scripts.exec(html)) !== null) {
      assignment.lastIndex = 0;
      while ((match = assignment.exec(script[1])) !== null) {
        var start = assignment.lastIndex;
        if (script[1][start] !== "{") fail("BOOTSTRAP_INVALID");
        var end = jsonObjectEnd(script[1], start);
        if (/\b(?:window\s*\.\s*)?WIZ_global_data\s*=/.test(script[1].slice(end))) fail("ACCOUNT_UNVERIFIED");
        var wiz = parseJson(script[1].slice(start, end), "BOOTSTRAP_INVALID");
        if (!wiz || Array.isArray(wiz) || typeof wiz !== "object") fail("BOOTSTRAP_INVALID");
        blocks.push(wiz);
        if (blocks.length > 1) fail("ACCOUNT_UNVERIFIED");
        assignment.lastIndex = end;
      }
    }
    if (blocks.length !== 1) fail("BOOTSTRAP_INVALID");
    var data = blocks[0];
    // oPEP7c is a page account label, not a cryptographically signed subject.
    if (!Object.prototype.hasOwnProperty.call(data, "oPEP7c") ||
        typeof data.oPEP7c !== "string") fail("ACCOUNT_UNVERIFIED");
    var active;
    try { active = emailOf(data.oPEP7c); } catch (_) { fail("ACCOUNT_UNVERIFIED"); }
    if (active !== expected) fail("ACCOUNT_MISMATCH");
    var csrf = boundText(data.SNlM0e, 8192, "BOOTSTRAP_INVALID");
    var sid = boundText(data.FdrFJe, 8192, "BOOTSTRAP_INVALID");
    if (!csrf || !sid) fail("SESSION_REQUIRED");
    var builds = Object.keys(data).map(function (key) { return data[key]; }).filter(function (value) {
      return typeof value === "string" && /^boq_labs-tailwind-frontend_[A-Za-z0-9._-]+$/.test(value);
    });
    var build = data.cfb2h;
    if (build === undefined) {
      var unique = Array.from(new Set(builds));
      if (unique.length !== 1) fail("BOOTSTRAP_INVALID");
      build = unique[0];
    }
    if (typeof build !== "string" || build.length > 256 ||
        !/^boq_labs-tailwind-frontend_[A-Za-z0-9._-]+$/.test(build)) fail("BOOTSTRAP_INVALID");
    var handle = Object.freeze({ origin: actualOrigin, email: active });
    credentials.set(handle, { csrf: csrf, sid: sid, build: build });
    return handle;
  }

  function white(byte) { return byte === 10 || byte === 13 || byte === 32 || byte === 9; }
  function balancedEnd(bytes, start) {
    var stack = [], quoted = false, escaped = false;
    for (var i = start; i < bytes.length; i += 1) {
      var b = bytes[i];
      if (quoted) {
        if (escaped) escaped = false;
        else if (b === 92) escaped = true;
        else if (b === 34) quoted = false;
      } else if (b === 34) quoted = true;
      else if (b === 91 || b === 123) stack.push(b);
      else if (b === 93 || b === 125) {
        var opened = stack.pop();
        if ((b === 93 && opened !== 91) || (b === 125 && opened !== 123)) fail("PROTOCOL_CHANGED");
        if (stack.length === 0) return i + 1;
      }
    }
    fail("PROTOCOL_CHANGED");
  }
  function decodeFrames(text) {
    var bytes = encoded(text), cursor = 0, records = [], decoder = new TextDecoder("utf-8", { fatal: true });
    if (bytes[0] === 41 && bytes[1] === 93 && bytes[2] === 125 && bytes[3] === 39) cursor = 4;
    while (cursor < bytes.length) {
      while (cursor < bytes.length && white(bytes[cursor])) cursor += 1;
      if (cursor === bytes.length) break;
      var start, end;
      if (bytes[cursor] >= 48 && bytes[cursor] <= 57) {
        var countStart = cursor;
        while (cursor < bytes.length && bytes[cursor] >= 48 && bytes[cursor] <= 57) cursor += 1;
        if (cursor - countStart > 10 || (bytes[cursor] !== 10 && bytes[cursor] !== 13)) fail("PROTOCOL_CHANGED");
        var size = Number(decoder.decode(bytes.subarray(countStart, cursor)));
        if (!Number.isSafeInteger(size) || size < 1 || size > MAX_RAW_BYTES) fail("PROTOCOL_CHANGED");
        if (bytes[cursor] === 13) cursor += 1;
        if (bytes[cursor] !== 10) fail("PROTOCOL_CHANGED");
        cursor += 1;
        start = cursor; end = start + size;
        if (end > bytes.length) fail("PROTOCOL_CHANGED");
      } else {
        if (bytes[cursor] !== 91) fail("PROTOCOL_CHANGED");
        start = cursor; end = balancedEnd(bytes, start);
      }
      var value;
      try { value = parseJson(decoder.decode(bytes.subarray(start, end))); }
      catch (error) {
        if (error instanceof ProtocolError) throw error;
        fail("PROTOCOL_CHANGED");
      }
      if (!Array.isArray(value)) fail("PROTOCOL_CHANGED");
      if (typeof value[0] === "string") records.push(value);
      else value.forEach(function (frame) {
        if (!Array.isArray(frame)) fail("PROTOCOL_CHANGED");
        records.push(frame);
      });
      if (records.length > MAX_FRAMES) fail("RESPONSE_TOO_LARGE");
      cursor = end;
    }
    if (!records.length) fail("PROTOCOL_CHANGED");
    return records;
  }
  function rejectFrame(frame) {
    if (frame[0] === "er") fail(frame[2] === 8 ? "RATE_LIMITED" : "RPC_REJECTED");
    if (frame[0] === "wrb.fr" && frame[2] === null && Array.isArray(frame[5])) {
      var status = frame[5][0];
      fail(status === 8 ? "RATE_LIMITED" : status === 16 ? "SESSION_REQUIRED" : "RPC_REJECTED");
    }
  }
  function decodeRpc(text, rpcId) {
    if (!RPC_IDS.has(rpcId)) fail("INVALID_INPUT");
    var frames = decodeFrames(text), found = false, payload;
    frames.forEach(function (frame) {
      rejectFrame(frame);
      if (frame[0] !== "wrb.fr" || frame[1] !== rpcId) return;
      if (found || typeof frame[2] !== "string") fail("PROTOCOL_CHANGED");
      payload = parseJson(frame[2]); found = true;
    });
    if (!found || !Array.isArray(payload)) fail("PROTOCOL_CHANGED");
    return payload;
  }
  function sourceId(raw) {
    if (typeof raw === "string") return idOf(raw);
    if (!Array.isArray(raw)) fail("PROTOCOL_CHANGED");
    if (typeof raw[0] === "string") return idOf(raw[0]);
    if (raw[0] === null && raw[1] === true && Array.isArray(raw[2]) &&
        typeof raw[2][0] === "string") return idOf(raw[2][0]);
    fail("PROTOCOL_CHANGED");
  }
  function parseSources(payload) {
    if (!Array.isArray(payload) || !Array.isArray(payload[0]) ||
        !Array.isArray(payload[0][1])) fail("PROTOCOL_CHANGED");
    if (payload[0][1].length > 1024) fail("RESPONSE_TOO_LARGE");
    var seen = new Set();
    return payload[0][1].map(function (row) {
      if (!Array.isArray(row) || row.length < 2) fail("PROTOCOL_CHANGED");
      var id;
      try { id = sourceId(row[0]); } catch (_) { fail("PROTOCOL_CHANGED"); }
      if (seen.has(id)) fail("PROTOCOL_CHANGED");
      seen.add(id);
      var title = row[1] === null ? "" : boundText(row[1], 4096, "PROTOCOL_CHANGED");
      return { sourceId: id, title: title };
    });
  }
  function nestedId(value) {
    var ids = new Set();
    function walk(node, depth) {
      if (depth > 10) fail("PROTOCOL_CHANGED");
      if (typeof node === "string" && UUID.test(node)) ids.add(node.toLowerCase());
      else if (Array.isArray(node)) {
        if (node.length > 1024) fail("PROTOCOL_CHANGED");
        node.forEach(function (child) { walk(child, depth + 1); });
      }
    }
    walk(value, 0);
    if (ids.size !== 1) fail("PROTOCOL_CHANGED");
    return Array.from(ids)[0];
  }
  function excerptOf(detail) {
    var passages = detail[4];
    if (passages === undefined || passages === null) return "";
    if (!Array.isArray(passages) || passages.length > 1024) fail("PROTOCOL_CHANGED");
    var texts = [];
    passages.forEach(function (wrapper) {
      if (!Array.isArray(wrapper) || !Array.isArray(wrapper[0]) || wrapper[0].length < 3) fail("PROTOCOL_CHANGED");
      var passage = wrapper[0], text = passage[2];
      if ((passage[0] !== null || passage[1] !== null) &&
          (!Number.isSafeInteger(passage[0]) || !Number.isSafeInteger(passage[1]) ||
           passage[0] < 0 || passage[1] < passage[0])) fail("PROTOCOL_CHANGED");
      if (!Array.isArray(text)) fail("PROTOCOL_CHANGED");
      text.forEach(function (group) {
        if (!Array.isArray(group)) fail("PROTOCOL_CHANGED");
        group.forEach(function (leaf) {
          if (!Array.isArray(leaf) || leaf.length < 3) fail("PROTOCOL_CHANGED");
          var val = leaf[2];
          if (typeof val === "string") texts.push(val.trim());
          else if (Array.isArray(val) && val.every(function (item) { return typeof item === "string"; })) {
            val.forEach(function (item) { texts.push(item.trim()); });
          } else fail("PROTOCOL_CHANGED");
        });
      });
    });
    var excerpt = texts.filter(Boolean).join(" ");
    return boundText(excerpt, 131072, "RESPONSE_TOO_LARGE");
  }
  function citationsOf(row, allowed) {
    if (!Array.isArray(row[4])) fail("PROTOCOL_CHANGED");
    var container = row[4][3];
    if (container === undefined || container === null) return [];
    if (!Array.isArray(container) || container.length > 1024) fail("PROTOCOL_CHANGED");
    return container.map(function (cite, index) {
      if (!Array.isArray(cite) || cite.length < 2 || !Array.isArray(cite[1])) fail("PROTOCOL_CHANGED");
      var id = nestedId(cite[1][5]);
      if (!allowed.has(id)) fail("FOREIGN_REFERENCE");
      return { sourceId: id, citationNumber: index + 1, excerpt: excerptOf(cite[1]) };
    });
  }
  function parseAnswer(text, allowedSourceIds) {
    if (!Array.isArray(allowedSourceIds) || allowedSourceIds.length > 1024) fail("INVALID_INPUT");
    var allowed = new Set(allowedSourceIds.map(idOf)), best = null;
    decodeFrames(text).forEach(function (frame) {
      rejectFrame(frame);
      if (frame[0] !== "wrb.fr") return;
      if (typeof frame[2] !== "string") fail("PROTOCOL_CHANGED");
      var payload = parseJson(frame[2]);
      if (!Array.isArray(payload)) fail("PROTOCOL_CHANGED");
      if (!payload.length) return;
      var row = payload[0];
      if (!Array.isArray(row)) fail("PROTOCOL_CHANGED");
      if (!Array.isArray(row[4]) || row[4][row[4].length - 1] !== 1) return;
      var answer = boundText(row[0], MAX_ANSWER_CHARS, "PROTOCOL_CHANGED");
      var refs = citationsOf(row, allowed);
      if (!best || answer.length >= best.answer.length) best = { answer: answer, citations: refs };
    });
    if (!best) fail("PROTOCOL_CHANGED");
    if (!best.answer.trim()) fail("EMPTY_ANSWER");
    return best;
  }

  function bodyFor(id, params, secret) {
    return new URLSearchParams({
      "f.req": JSON.stringify([[[id, JSON.stringify(params), null, "generic"]]]),
      at: secret.csrf
    }).toString() + "&";
  }
  function rpcUrl(origin, id, notebookId, email, secret) {
    var url = new URL(RPC_PATH, origin);
    url.search = new URLSearchParams({
      rpcids: id, "source-path": "/notebook/" + notebookId,
      "f.sid": secret.sid, hl: "en", rt: "c", authuser: email
    }).toString();
    return url.href;
  }
  async function responseText(response, expectedUrl, uncertain) {
    if (!response || response.type === "opaqueredirect" || response.status === 0 ||
        (response.status >= 300 && response.status < 400) || response.redirected) fail("SESSION_REQUIRED", uncertain);
    if (typeof response.url === "string" && response.url) {
      var final;
      try { final = new URL(response.url); } catch (_) { fail("PROTOCOL_CHANGED", uncertain); }
      var expected = new URL(expectedUrl);
      if (final.origin !== expected.origin || final.pathname !== expected.pathname) fail("SESSION_REQUIRED", uncertain);
    }
    if (response.status === 401 || response.status === 403) fail("SESSION_REQUIRED");
    if (response.status === 429) fail("RATE_LIMITED");
    if (!response.ok) fail(uncertain && response.status >= 500 ? "REQUEST_UNCERTAIN" : "RPC_REJECTED", uncertain);
    var length = response.headers && response.headers.get && response.headers.get("Content-Length");
    if (length && Number(length) > MAX_RAW_BYTES) fail("RESPONSE_TOO_LARGE", uncertain);
    try {
      if (!response.body || typeof response.body.getReader !== "function") {
        var fallback = await response.text(); encoded(fallback); return fallback;
      }
      var reader = response.body.getReader(), bytes = 0, pieces = [];
      var decoder = new TextDecoder("utf-8", { fatal: true });
      while (true) {
        var item = await reader.read();
        if (item.done) break;
        bytes += item.value.byteLength;
        if (bytes > MAX_RAW_BYTES) {
          try { await reader.cancel(); } catch (_) {}
          fail("RESPONSE_TOO_LARGE", uncertain);
        }
        pieces.push(decoder.decode(item.value, { stream: true }));
      }
      pieces.push(decoder.decode());
      return pieces.join("");
    } catch (error) {
      if (error instanceof ProtocolError) throw error;
      fail(uncertain ? "REQUEST_UNCERTAIN" : "NETWORK_FAILURE", uncertain);
    }
  }
  async function request(fetchImpl, url, options, uncertain) {
    if (options.signal && options.signal.aborted) fail("REQUEST_CANCELLED");
    var response;
    try { response = await fetchImpl(url, options); }
    catch (_) { fail(uncertain ? "REQUEST_UNCERTAIN" : "NETWORK_FAILURE", uncertain); }
    return responseText(response, url, uncertain);
  }
  function conversationOf(payload) {
    var ids = [];
    if (!Array.isArray(payload)) fail("CONVERSATION_UNVERIFIED", true);
    payload.forEach(function (group) {
      if (!Array.isArray(group)) fail("CONVERSATION_UNVERIFIED", true);
      group.forEach(function (row) {
        if (!Array.isArray(row) || typeof row[0] !== "string" || !UUID.test(row[0])) fail("CONVERSATION_UNVERIFIED", true);
        ids.push(row[0].toLowerCase());
      });
    });
    if (new Set(ids).size !== 1) fail("CONVERSATION_UNVERIFIED", true);
    return ids[0];
  }
  async function performAsk(options) {
    if (!options || typeof options !== "object") fail("INVALID_INPUT");
    var origin = originOf(options.origin), notebookId = idOf(options.notebookId), email = emailOf(options.email);
    var question = boundText(options.question, 20000);
    if (!question.trim()) fail("INVALID_INPUT");
    var conversationId = options.conversationId == null ? null : idOf(options.conversationId);
    var history = options.history == null ? null : options.history;
    if (history !== null && (!Array.isArray(history) || history.length > 200 ||
        !history.every(function (row) {
          return Array.isArray(row) && row.length === 3 && typeof row[0] === "string" &&
            row[0].length <= MAX_ANSWER_CHARS && row[1] === null && (row[2] === 1 || row[2] === 2);
        }))) fail("INVALID_INPUT");
    if (history && history.reduce(function (total, row) { return total + row[0].length; }, 0) > 120000) fail("INVALID_INPUT");
    var fetchImpl = options.fetchImpl || (typeof fetch === "function" ? fetch : null);
    if (typeof fetchImpl !== "function") fail("INVALID_INPUT");
    var common = { credentials: "include", redirect: "manual", cache: "no-store", signal: options.signal };
    var home = new URL("/", origin);
    home.searchParams.set("authuser", email);
    var html = await request(fetchImpl, home.href, Object.assign({}, common, { method: "GET" }), false);
    var handle = parseBootstrap(html, email, origin), secret = credentials.get(handle);
    html = null;
    var template = [2, null, null, [1, null, null, null, null, null, null, null, null, null, [1]]];
    var sourcesUrl = rpcUrl(origin, "rLM1Ne", notebookId, email, secret);
    var headers = { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" };
    var sourceText = await request(fetchImpl, sourcesUrl, Object.assign({}, common, {
      method: "POST", headers: headers, body: bodyFor("rLM1Ne", [notebookId, null, template, null, 0], secret)
    }), false);
    var sourcePayload = decodeRpc(sourceText, "rLM1Ne");
    if (!Array.isArray(sourcePayload[0]) || sourcePayload[0][2] !== notebookId) fail("PROTOCOL_CHANGED");
    var sources = parseSources(sourcePayload);
    sourceText = null;
    var params = [
      sources.map(function (source) { return [[source.sourceId]]; }), question, history,
      [2, null, [1], [1]], conversationId, null, null, notebookId, 1
    ];
    var chat = new URL(CHAT_PATH, origin);
    chat.search = new URLSearchParams({
      bl: secret.build, hl: "en", _reqid: String(Date.now() % 1000000000),
      rt: "c", "f.sid": secret.sid, authuser: email
    }).toString();
    var raw = await request(fetchImpl, chat.href, Object.assign({}, common, {
      method: "POST", headers: headers,
      body: new URLSearchParams({ "f.req": JSON.stringify([null, JSON.stringify(params)]), at: secret.csrf }).toString() + "&"
    }), true);
    var parsed;
    try { parsed = parseAnswer(raw, sources.map(function (source) { return source.sourceId; })); }
    catch (error) {
      if (error instanceof ProtocolError) { error.uncertain = true; throw error; }
      fail("PROTOCOL_CHANGED", true);
    }
    raw = null;
    var actual;
    try {
      var lastUrl = rpcUrl(origin, "hPTbtc", notebookId, email, secret);
      var lastText = await request(fetchImpl, lastUrl, Object.assign({}, common, {
        method: "POST", headers: headers, body: bodyFor("hPTbtc", [[], null, notebookId, 1], secret)
      }), false);
      actual = conversationOf(decodeRpc(lastText, "hPTbtc"));
      if (conversationId !== null && conversationId !== actual) fail("CONVERSATION_UNVERIFIED", true);
    } catch (_) { fail("CONVERSATION_UNVERIFIED", true); }
    return { answer: parsed.answer, citations: parsed.citations, conversationId: actual, accountEmail: handle.email };
  }

  return Object.freeze({
    parseBootstrap: parseBootstrap, decodeRpc: decodeRpc,
    parseSources: parseSources, parseAnswer: parseAnswer, performAsk: performAsk
  });
});
