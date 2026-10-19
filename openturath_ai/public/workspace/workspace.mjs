import { WorkspaceController } from './controller.mjs';
import { canonicalWorkspace, readableError, redirectFallbackAllowed, validAgentId } from './model.mjs';

const elements = Object.fromEntries(['welcome', 'account', 'email', 'login', 'logout', 'workspace', 'status', 'catalog', 'search', 'empty', 'ready-link', 'notebook-link', 'selected-title', 'redeem-form', 'redeem', 'code', 'retry-profile'].map(id => [id, document.getElementById(id)]));
let catalog = [];
let controller;
let pendingAgent = new URLSearchParams(location.search).get('agent');
let authAvailable = false;

function render(state) {
  const ready = state.phase === 'ready';
  elements.welcome.hidden = !!state.user;
  elements.account.hidden = !state.user;
  elements.email.textContent = state.user?.email || '';
  elements.workspace.hidden = !ready;
  elements.login.disabled = !authAvailable || state.busy || state.phase === 'loading';
  elements.logout.disabled = state.busy && state.phase === 'signing-out';
  elements.redeem.disabled = state.busy;
  elements['retry-profile'].hidden = state.phase !== 'profile-error';
  elements['ready-link'].hidden = !ready || !state.link;
  elements['notebook-link'].removeAttribute('href');
  if (ready && state.link) {
    elements['notebook-link'].href = state.link;
    const module = catalog.find(item => item.aliases.includes(state.agentId));
    elements['selected-title'].textContent = module?.title || 'Kajian siap dibuka';
  }
  elements.status.className = state.error ? 'error' : '';
  elements.status.textContent = state.error ? readableError(state.error) : state.notice ||
    (state.busy ? 'Memeriksa permintaan…' : state.phase === 'loading' ? 'Menyiapkan ruang kajian…' :
      ready ? 'Akun OpenTurath aktif. Pilih bidang kajian.' : 'Masuk untuk menggunakan ruang kajian.');
  for (const button of elements.catalog.querySelectorAll('button')) button.disabled = !ready || state.busy;
  if (ready && pendingAgent && !state.busy) {
    const id = pendingAgent;
    pendingAgent = null;
    queueMicrotask(() => controller.openAgent(id));
  }
}

function renderCatalog() {
  const term = elements.search.value.trim().toLocaleLowerCase('id');
  elements.catalog.replaceChildren();
  let count = 0;
  for (const item of catalog) {
    if (!`${item.title} ${item.aliases.join(' ')}`.toLocaleLowerCase('id').includes(term)) continue;
    count++;
    const article = document.createElement('article');
    article.className = 'module';
    const title = document.createElement('h2');
    title.textContent = item.title;
    const description = document.createElement('p');
    description.textContent = 'Telaah sumber dan ajukan pertanyaan melalui ruang kajian interaktif Google.';
    const button = document.createElement('button');
    button.type = 'button';
    button.textContent = 'Buka kajian';
    button.disabled = !controller || controller.state.phase !== 'ready' || controller.state.busy;
    button.addEventListener('click', () => controller.openAgent(item.id));
    article.append(title, description, button);
    elements.catalog.append(article);
  }
  elements.empty.hidden = count !== 0;
}

// Keep redirect OAuth and its Firebase helper on one origin. The web.app alias
// must not require a second OAuth redirect-domain configuration.
const canonical = canonicalWorkspace(location.href);
if (canonical) {
  elements.status.textContent = 'Membuka ruang kajian utama…';
  location.replace(canonical);
} else try {
  const sdk = 'https://www.gstatic.com/firebasejs/12.19.0/';
  const [core, authSdk, dbSdk, functionsSdk, response] = await Promise.all([
    import(`${sdk}firebase-app.js`), import(`${sdk}firebase-auth.js`),
    import(`${sdk}firebase-firestore.js`), import(`${sdk}firebase-functions.js`),
    fetch('./catalog.json', { cache: 'no-cache' }),
  ]);
  if (!response.ok) throw new Error('catalog-unavailable');
  catalog = await response.json();
  if (!Array.isArray(catalog) || !catalog.length || catalog.some(item => !validAgentId(item.id) || !Array.isArray(item.aliases))) throw new Error('invalid-catalog');
  if (!catalog.some(item => item.aliases.includes(pendingAgent))) pendingAgent = null;
  const hosted = ['openturath.id', 'www.openturath.id', 'open-turath.firebaseapp.com'].includes(location.hostname);
  const app = core.initializeApp({
    apiKey: 'AIzaSyC9b5YVceixZZL6AkLnsroBC9qvSt06bQ0',
    authDomain: hosted ? location.hostname : 'open-turath.firebaseapp.com',
    projectId: 'open-turath',
    appId: '1:255541559800:web:a1f71cf6ae35aa2ed2960d',
  });
  const auth = authSdk.getAuth(app);
  const db = dbSdk.getFirestore(app);
  const functions = functionsSdk.getFunctions(app, 'us-central1');
  await authSdk.setPersistence(auth, authSdk.browserLocalPersistence);
  const getAgentUrl = functionsSdk.httpsCallable(functions, 'getAgentUrl', { timeout: 30000 });
  const redeemCode = functionsSdk.httpsCallable(functions, 'redeemCode', { timeout: 120000 });
  const adapter = {
    async signIn() {
      const provider = new authSdk.GoogleAuthProvider();
      provider.setCustomParameters({ prompt: 'select_account' });
      // Redirect on mobile requires a same-origin Firebase auth helper.
      if (hosted && /Android|iPhone|iPad|iPod/i.test(navigator.userAgent)) {
        await authSdk.signInWithRedirect(auth, provider);
        return;
      }
      try {
        await authSdk.signInWithPopup(auth, provider);
      } catch (error) {
        // Cancellation, denied access and configuration errors must not start
        // a second login. Only a blocked popup can use redirect fallback.
        if (!hosted || !redirectFallbackAllowed(error)) throw error;
        await authSdk.signInWithRedirect(auth, provider);
      }
    },
    async ensureProfile(user) {
      const task = dbSdk.runTransaction(db, async transaction => {
        const reference = dbSdk.doc(db, 'users', user.uid);
        const snapshot = await transaction.get(reference);
        if (!snapshot.exists()) {
          transaction.set(reference, {
            name: user.displayName || 'Pengguna', email: user.email || '',
            photo_url: (user.photoURL || '').slice(0, 1000),
            plan: 'trial', questions_used: 0, subscription_expiry: null,
          });
        }
      });
      let timer;
      try {
        await Promise.race([task, new Promise((_, reject) => {
          timer = setTimeout(() => reject({ code: 'functions/deadline-exceeded' }), 20000);
        })]);
      } finally { clearTimeout(timer); }
    },
    async getAgentUrl(agentId) { return (await getAgentUrl({ agentId })).data; },
    async redeemCode(code) { return (await redeemCode({ code })).data; },
    async signOut() { await authSdk.signOut(auth); },
  };
  controller = new WorkspaceController(adapter, render);
  elements.login.addEventListener('click', () => controller.signIn());
  elements.logout.addEventListener('click', () => controller.signOut());
  elements.search.addEventListener('input', renderCatalog);
  elements['retry-profile'].addEventListener('click', () => controller.sessionChanged(auth.currentUser));
  elements['redeem-form'].addEventListener('submit', event => {
    event.preventDefault();
    controller.redeem(elements.code.value);
  });
  renderCatalog();
  // Complete a redirect before subscribing; never start login automatically.
  let redirectError;
  try { await authSdk.getRedirectResult(auth); } catch (error) { redirectError = error; }
  authAvailable = true;
  authSdk.onAuthStateChanged(auth, async user => {
    await controller.sessionChanged(user);
    if (redirectError) {
      controller.update({ error: redirectError });
      redirectError = null;
    }
  }, error => controller.update({ phase: 'signed-out', error }));
  if ('serviceWorker' in navigator && hosted) {
    navigator.serviceWorker.register('./sw.js').catch(() => { /* Login does not depend on offline shell caching. */ });
  }
} catch (error) {
  elements.status.className = 'error';
  elements.status.textContent = 'Ruang kajian belum dapat dimuat. Periksa internet, lalu muat ulang halaman. Jika berulang, hubungi pengelola.';
  elements.login.disabled = true;
}
