"use strict";
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NativeChatError = void 0;
exports.parseChatRequest = parseChatRequest;
exports.parseChatReply = parseChatReply;
exports.handleNativeChat = handleNativeChat;
class NativeChatError extends Error {
    constructor(code, message) {
        super(message);
        this.code = code;
    }
}
exports.NativeChatError = NativeChatError;
const requestPattern = /^[a-f0-9]{32}$/;
const uuidPattern = /^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i;
function parseChatRequest(value) {
    if (!value || typeof value !== "object" || Array.isArray(value)) {
        throw new NativeChatError("invalid-argument", "Pertanyaan tidak valid.");
    }
    const data = value;
    if (Object.keys(data).some(key => !["agentId", "question", "requestId", "expectedUid"].includes(key)) ||
        typeof data.agentId !== "string" || !/^[a-z][a-z0-9_]{0,79}$/.test(data.agentId) ||
        typeof data.question !== "string" || !data.question.trim() || data.question.length > 8000 ||
        typeof data.requestId !== "string" || !requestPattern.test(data.requestId) ||
        typeof data.expectedUid !== "string" || !data.expectedUid || data.expectedUid.length > 128) {
        throw new NativeChatError("invalid-argument", "Pertanyaan tidak valid atau terlalu panjang.");
    }
    return { agentId: data.agentId, question: data.question.trim(), requestId: data.requestId, expectedUid: data.expectedUid };
}
function parseChatReply(value, requestId) {
    const invalid = () => new NativeChatError("unavailable", "Jawaban asisten belum dapat dibaca.");
    if (!value || typeof value !== "object" || Array.isArray(value))
        throw invalid();
    const data = value;
    if (data.requestId !== requestId || typeof data.answer !== "string" ||
        !data.answer.trim() || data.answer.length > 128000 ||
        !Array.isArray(data.citations) || data.citations.length > 100)
        throw invalid();
    const citations = data.citations.map((item) => {
        if (!item || typeof item !== "object" || Array.isArray(item))
            throw invalid();
        const ref = item;
        if (typeof ref.sourceId !== "string" || !uuidPattern.test(ref.sourceId) ||
            typeof ref.citationNumber !== "number" || !Number.isInteger(ref.citationNumber) ||
            ref.citationNumber < 1 || ref.citationNumber > 1000 ||
            (ref.excerpt !== null && (typeof ref.excerpt !== "string" || ref.excerpt.length > 4000)))
            throw invalid();
        return { sourceId: ref.sourceId, citationNumber: ref.citationNumber, excerpt: ref.excerpt };
    });
    // Deliberately return only display data; discard cookies, URLs, conversation IDs and debug blobs.
    return { requestId, answer: data.answer.trim(), citations };
}
async function handleNativeChat(data, uid, deps) {
    if (!uid)
        throw new NativeChatError("unauthenticated", "Silakan masuk ke OpenTurath.");
    const request = parseChatRequest(data);
    if (request.expectedUid !== uid)
        throw new NativeChatError("unauthenticated", "Akun berubah. Silakan kirim pertanyaan dari akun aktif.");
    // No production rollout: initially permit only the explicitly configured prototype user.
    if (!deps.testUid)
        throw new NativeChatError("failed-precondition", "Koneksi asisten di aplikasi belum diaktifkan.");
    if (uid !== deps.testUid)
        throw new NativeChatError("permission-denied", "Akses pengujian asisten belum tersedia untuk akun ini.");
    if (!await deps.authorize(uid, request.agentId)) {
        throw new NativeChatError("permission-denied", "Akses kajian ini belum aktif.");
    }
    await deps.rateLimit(uid);
    try {
        const { expectedUid: _ } = request, payload = __rest(request, ["expectedUid"]);
        return parseChatReply(await deps.ask(Object.assign(Object.assign({}, payload), { uid })), request.requestId);
    }
    catch (error) {
        if (error instanceof NativeChatError)
            throw error;
        // Never return/log upstream errors: they can include request headers or account/session data.
        throw new NativeChatError("unavailable", "Asisten belum dapat menjawab. Pertanyaan tidak dikirim ulang otomatis.");
    }
}
//# sourceMappingURL=native_chat.js.map