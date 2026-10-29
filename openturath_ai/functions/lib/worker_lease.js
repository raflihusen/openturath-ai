"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.WorkerLease = void 0;
const crypto_1 = require("crypto");
class WorkerLease {
    constructor(db, id, role, clock = Date.now, ttlMs = 60000, graceMs = 120000, 
    // Keyakinan lokal dipersingkat: setelah direbut, pemegang lama berhenti menulis dalam waktu ini.
    beliefMs = 20000) {
        this.db = db;
        this.id = id;
        this.role = role;
        this.clock = clock;
        this.ttlMs = ttlMs;
        this.graceMs = graceMs;
        this.beliefMs = beliefMs;
        this.token = "";
        this.heldUntil = 0;
        this.lastError = "";
    }
    ref() { return this.db.collection("access_control").doc("writer_lease"); }
    holds() { return this.token !== "" && this.clock() < this.heldUntil; }
    async renew() {
        const now = this.clock();
        try {
            const token = await this.db.runTransaction(async (t) => {
                const cur = (await t.get(this.ref())).data();
                const mine = (cur === null || cur === void 0 ? void 0 : cur.holder) === this.id;
                const free = !cur || cur.expires_ms <= now;
                const takeable = this.role === "primary"
                    ? free || (cur === null || cur === void 0 ? void 0 : cur.role) === "standby"
                    : !cur || cur.expires_ms + this.graceMs <= now;
                if (!mine && !takeable)
                    return "";
                const next = mine && cur.token ? cur.token : (0, crypto_1.randomUUID)();
                t.set(this.ref(), { holder: this.id, role: this.role, token: next, expires_ms: now + this.ttlMs, renewed_ms: now });
                return next;
            });
            this.token = token;
            this.heldUntil = token ? now + this.beliefMs : 0;
            this.lastError = "";
        }
        catch (e) {
            // Tanpa kepastian tidak ada hak menulis.
            this.token = "";
            this.heldUntil = 0;
            this.lastError = String((e === null || e === void 0 ? void 0 : e.code) || "lease_unavailable");
        }
        return this.holds();
    }
    async release() {
        if (!this.token)
            return;
        try {
            await this.db.runTransaction(async (t) => {
                const cur = (await t.get(this.ref())).data();
                if ((cur === null || cur === void 0 ? void 0 : cur.holder) === this.id)
                    t.set(this.ref(), Object.assign(Object.assign({}, cur), { expires_ms: 0 }));
            });
        }
        catch (_) { /* sewa akan kedaluwarsa sendiri */ }
        this.token = "";
        this.heldUntil = 0;
    }
}
exports.WorkerLease = WorkerLease;
//# sourceMappingURL=worker_lease.js.map