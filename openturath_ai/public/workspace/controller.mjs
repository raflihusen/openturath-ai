import { notebookLink, validAgentId } from './model.mjs';

// Firebase owns OAuth, credential validation and persistence. This controller
// never reads Google login pages, cookies or manually stored tokens.
export class WorkspaceController {
  constructor(adapter, render) {
    this.adapter = adapter;
    this.render = render;
    this.epoch = 0;
    this.state = { phase: 'loading', user: null, error: null, link: null, busy: false };
  }

  update(patch) {
    Object.assign(this.state, patch);
    this.render({ ...this.state });
  }

  async sessionChanged(user) {
    const epoch = ++this.epoch;
    this.update({ user, phase: user ? 'loading' : 'signed-out', error: null, link: null, busy: false });
    if (!user) return;
    try {
      await this.adapter.ensureProfile(user);
      if (epoch !== this.epoch) return;
      this.update({ phase: 'ready' });
    } catch (error) {
      if (epoch === this.epoch) this.update({ phase: 'profile-error', error });
    }
  }

  async signIn() {
    if (this.state.busy || this.state.user) return;
    const epoch = this.epoch;
    this.update({ busy: true, error: null, link: null });
    try {
      await this.adapter.signIn();
      // Auth observer, rather than popup metadata, establishes the session.
    } catch (error) {
      if (epoch === this.epoch) this.update({ error });
    } finally {
      if (epoch === this.epoch) this.update({ busy: false });
    }
  }

  async openAgent(agentId) {
    if (this.state.phase !== 'ready' || this.state.busy || !validAgentId(agentId)) return;
    const epoch = this.epoch;
    const user = this.state.user;
    this.update({ busy: true, error: null, link: null });
    try {
      const result = await this.adapter.getAgentUrl(agentId);
      if (epoch !== this.epoch || this.state.user?.uid !== user.uid) return;
      this.update({ link: notebookLink(result.url, user.email || ''), agentId });
    } catch (error) {
      if (epoch === this.epoch) this.update({ error });
    } finally {
      if (epoch === this.epoch) this.update({ busy: false });
    }
  }

  async redeem(code) {
    if (this.state.phase !== 'ready' || this.state.busy) return;
    const epoch = this.epoch;
    this.update({ busy: true, error: null, link: null, notice: null });
    try {
      const result = await this.adapter.redeemCode(code);
      if (epoch === this.epoch) this.update({ notice: result.message || 'Kode akses sudah diterima.' });
    } catch (error) {
      if (epoch === this.epoch) this.update({ error });
    } finally {
      if (epoch === this.epoch) this.update({ busy: false });
    }
  }

  async signOut() {
    // Invalidate links and in-flight requests immediately, even if logout fails.
    ++this.epoch;
    this.update({ busy: true, link: null, error: null, notice: null, phase: 'signing-out' });
    try {
      await this.adapter.signOut();
      await this.sessionChanged(null);
    } catch (error) {
      this.update({ busy: false, phase: 'logout-error', error });
    }
  }
}
