// Prototype boundary: Firebase identity is independent of the operator's Google session.
export type ChatCode = "unauthenticated" | "invalid-argument" | "permission-denied" | "failed-precondition" | "unavailable";

export class NativeChatError extends Error {
  constructor(public readonly code: ChatCode, message: string) { super(message); }
}

export interface ChatRequest { agentId: string; question: string; requestId: string; }
export interface ChatCitation { sourceId: string; citationNumber: number; excerpt: string | null; }
export interface ChatReply { requestId: string; answer: string; citations: ChatCitation[]; }
export interface NativeChatDependencies {
  testUid: string | undefined;
  authorize(uid: string, agentId: string): Promise<boolean>;
  rateLimit(uid: string): Promise<void>;
  ask(request: ChatRequest & { uid: string }): Promise<unknown>;
}

const requestPattern = /^[a-f0-9]{32}$/;
const uuidPattern = /^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i;

export function parseChatRequest(value: unknown): ChatRequest {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new NativeChatError("invalid-argument", "Pertanyaan tidak valid.");
  }
  const data = value as Record<string, unknown>;
  if (Object.keys(data).some(key => !["agentId", "question", "requestId"].includes(key)) ||
      typeof data.agentId !== "string" || !/^[a-z][a-z0-9_]{0,79}$/.test(data.agentId) ||
      typeof data.question !== "string" || !data.question.trim() || data.question.length > 8000 ||
      typeof data.requestId !== "string" || !requestPattern.test(data.requestId)) {
    throw new NativeChatError("invalid-argument", "Pertanyaan tidak valid atau terlalu panjang.");
  }
  return {agentId: data.agentId, question: data.question.trim(), requestId: data.requestId};
}

export function parseChatReply(value: unknown, requestId: string): ChatReply {
  const invalid = () => new NativeChatError("unavailable", "Jawaban asisten belum dapat dibaca.");
  if (!value || typeof value !== "object" || Array.isArray(value)) throw invalid();
  const data = value as Record<string, unknown>;
  if (data.requestId !== requestId || typeof data.answer !== "string" ||
      !data.answer.trim() || data.answer.length > 128000 ||
      !Array.isArray(data.citations) || data.citations.length > 100) throw invalid();
  const citations = data.citations.map((item: unknown): ChatCitation => {
    if (!item || typeof item !== "object" || Array.isArray(item)) throw invalid();
    const ref = item as Record<string, unknown>;
    if (typeof ref.sourceId !== "string" || !uuidPattern.test(ref.sourceId) ||
        typeof ref.citationNumber !== "number" || !Number.isInteger(ref.citationNumber) ||
        ref.citationNumber < 1 || ref.citationNumber > 1000 ||
        (ref.excerpt !== null && (typeof ref.excerpt !== "string" || ref.excerpt.length > 4000))) throw invalid();
    return {sourceId: ref.sourceId, citationNumber: ref.citationNumber, excerpt: ref.excerpt as string | null};
  });
  // Deliberately return only display data; discard cookies, URLs, conversation IDs and debug blobs.
  return {requestId, answer: data.answer.trim(), citations};
}

export async function handleNativeChat(data: unknown, uid: string | undefined, deps: NativeChatDependencies): Promise<ChatReply> {
  if (!uid) throw new NativeChatError("unauthenticated", "Silakan masuk ke OpenTurath.");
  const request = parseChatRequest(data);
  // No production rollout: initially permit only the explicitly configured prototype user.
  if (!deps.testUid) throw new NativeChatError("failed-precondition", "Koneksi asisten di aplikasi belum diaktifkan.");
  if (uid !== deps.testUid) throw new NativeChatError("permission-denied", "Akses pengujian asisten belum tersedia untuk akun ini.");
  if (!await deps.authorize(uid, request.agentId)) {
    throw new NativeChatError("permission-denied", "Akses kajian ini belum aktif.");
  }
  await deps.rateLimit(uid);
  try {
    return parseChatReply(await deps.ask({...request, uid}), request.requestId);
  } catch (error) {
    if (error instanceof NativeChatError) throw error;
    // Never return/log upstream errors: they can include request headers or account/session data.
    throw new NativeChatError("unavailable", "Asisten belum dapat menjawab. Pertanyaan tidak dikirim ulang otomatis.");
  }
}
