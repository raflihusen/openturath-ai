import {randomUUID} from "crypto";

// Sewa penulis tunggal. Hanya pemegang sewa yang boleh menulis ke NotebookLM,
// sehingga VPS (primary) dan komputer cadangan (standby) tidak pernah saling
// menimpa. Primary merebut kembali sewa dari standby; standby hanya mengambil
// alih bila sewa primary sudah mati lebih dari `graceMs`.
export type LeaseRole = "primary" | "standby";

export class WorkerLease {
  private token = "";
  private heldUntil = 0;
  lastError = "";

  constructor(
    private readonly db: any,
    readonly id: string,
    readonly role: LeaseRole,
    private readonly clock: () => number = Date.now,
    private readonly ttlMs = 60000,
    private readonly graceMs = 120000,
    // Keyakinan lokal dipersingkat: setelah direbut, pemegang lama berhenti menulis dalam waktu ini.
    private readonly beliefMs = 20000,
  ) {}

  private ref() { return this.db.collection("access_control").doc("writer_lease"); }

  holds(): boolean { return this.token !== "" && this.clock() < this.heldUntil; }

  async renew(): Promise<boolean> {
    const now = this.clock();
    try {
      const token: string = await this.db.runTransaction(async (t: any) => {
        const cur = (await t.get(this.ref())).data();
        const mine = cur?.holder === this.id;
        const free = !cur || cur.expires_ms <= now;
        const takeable = this.role === "primary"
          ? free || cur?.role === "standby"
          : !cur || cur.expires_ms + this.graceMs <= now;
        if (!mine && !takeable) return "";
        const next = mine && cur.token ? cur.token : randomUUID();
        t.set(this.ref(), {holder: this.id, role: this.role, token: next, expires_ms: now + this.ttlMs, renewed_ms: now});
        return next;
      });
      this.token = token;
      this.heldUntil = token ? now + this.beliefMs : 0;
      this.lastError = "";
    } catch (e: any) {
      // Tanpa kepastian tidak ada hak menulis.
      this.token = ""; this.heldUntil = 0; this.lastError = String(e?.code || "lease_unavailable");
    }
    return this.holds();
  }

  async release(): Promise<void> {
    if (!this.token) return;
    try {
      await this.db.runTransaction(async (t: any) => {
        const cur = (await t.get(this.ref())).data();
        if (cur?.holder === this.id) t.set(this.ref(), {...cur, expires_ms: 0});
      });
    } catch (_) { /* sewa akan kedaluwarsa sendiri */ }
    this.token = ""; this.heldUntil = 0;
  }
}
