import { initializeApp } from 'https://www.gstatic.com/firebasejs/12.19.0/firebase-app.js';
import { getAuth, GoogleAuthProvider, browserLocalPersistence, setPersistence,
  signInWithPopup, signInWithRedirect, getRedirectResult } from 'https://www.gstatic.com/firebasejs/12.19.0/firebase-auth.js';

const message = document.querySelector('#message');
const login = document.querySelector('#login');
const cancel = document.querySelector('#cancel');
const params = new URLSearchParams(location.search);

// Preserve loopback callback & state in sessionStorage across redirects or reloads
const cbFromUrl = params.get('callback');
const stFromUrl = params.get('state');

if (cbFromUrl) {
  try { sessionStorage.setItem('ot_cb', cbFromUrl); } catch (_) {}
}
if (stFromUrl) {
  try { sessionStorage.setItem('ot_st', stFromUrl); } catch (_) {}
}

const cbStr = cbFromUrl || sessionStorage.getItem('ot_cb') || '';
const state = stFromUrl || sessionStorage.getItem('ot_st') || '';

const isInApp = params.get('mode') === 'inapp' || window.flutter_inappwebview !== undefined;
if (isInApp) {
  document.body.classList.add('in-app');
}

let callback;
try { callback = new URL(cbStr); } catch { /* invalid link */ }

const validLoopback = (location.origin === 'https://open-turath.web.app' || location.origin === 'https://open-turath.firebaseapp.com') &&
  callback &&
  callback.protocol === 'http:' && callback.hostname === '127.0.0.1' &&
  Number(callback.port) >= 1024 && Number(callback.port) <= 65535 &&
  callback.pathname === '/callback' && !callback.username && !callback.password &&
  !callback.search && !callback.hash && /^[A-Za-z0-9_-]{43}$/.test(state);

const app = initializeApp({
  apiKey: 'AIzaSyC9b5YVceixZZL6AkLnsroBC9qvSt06bQ0',
  authDomain: 'open-turath.firebaseapp.com',
  projectId: 'open-turath',
  appId: '1:255541559800:web:a1f71cf6ae35aa2ed2960d',
});
const auth = getAuth(app);
await setPersistence(auth, browserLocalPersistence);

function notifyFlutter(payload) {
  if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
    try {
      window.flutter_inappwebview.callHandler('onDesktopAuthSuccess', payload);
    } catch (_) {}
  }
  try {
    window.location.hash = '#auth=' + encodeURIComponent(JSON.stringify(payload));
  } catch (_) {}
}

function finishLoopback(fields) {
  if (!callback) return;
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = callback.href;
  for (const [name, value] of Object.entries({ state, ...fields })) {
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = name;
    input.value = value;
    form.appendChild(input);
  }
  document.body.appendChild(form);
  form.submit();
}

async function handleAuthSuccess(credential, user) {
  const idToken = credential?.idToken;
  const email = user?.email || '';
  const name = user?.displayName || 'Pengguna';
  
  message.className = 'status-msg success';
  message.textContent = 'Masuk berhasil! Mengalihkan ke aplikasi OpenTurath AI…';
  
  if (isInApp) {
    notifyFlutter({ idToken, email, name, status: 'success' });
  } else if (validLoopback) {
    try { sessionStorage.removeItem('ot_cb'); } catch (_) {}
    try { sessionStorage.removeItem('ot_st'); } catch (_) {}
    finishLoopback({ idToken });
  }
}

async function performLogin() {
  login.disabled = true;
  cancel.disabled = true;
  message.className = 'status-msg';
  message.innerHTML = '<span class="spinner"></span> Menghubungkan ke Google…';

  const provider = new GoogleAuthProvider();
  provider.setCustomParameters({ prompt: 'select_account' });
  provider.addScope('email');
  provider.addScope('profile');

  // Try popup first (seamless on desktop, no redirect, maintains state in memory)
  try {
    const result = await signInWithPopup(auth, provider);
    const credential = GoogleAuthProvider.credentialFromResult(result);
    if (credential?.idToken) {
      await handleAuthSuccess(credential, result.user);
      return;
    }
  } catch (popupErr) {
    console.warn('Popup interrupted or blocked:', popupErr);
    if (popupErr.code === 'auth/popup-closed-by-user') {
      message.className = 'status-msg';
      message.textContent = 'Masuk dibatalkan. Klik tombol di bawah untuk mencoba kembali.';
      login.disabled = false;
      cancel.disabled = false;
      return;
    }
  }

  // Fallback to redirect if popup was blocked by browser
  try {
    message.innerHTML = '<span class="spinner"></span> Mengarahkan ke Google…';
    await signInWithRedirect(auth, provider);
  } catch (redirectErr) {
    message.className = 'status-msg error';
    message.textContent = 'Gagal menghubungkan Google: ' + (redirectErr.message || 'Silakan coba lagi.');
    login.disabled = false;
    cancel.disabled = false;
  }
}

// 1. Check if returning from a redirect flow
let fromRedirect = false;
try {
  const redirectResult = await getRedirectResult(auth);
  if (redirectResult && redirectResult.user) {
    fromRedirect = true;
    const credential = GoogleAuthProvider.credentialFromResult(redirectResult);
    if (credential?.idToken) {
      await handleAuthSuccess(credential, redirectResult.user);
    }
  }
} catch (err) {
  console.warn('Redirect check error:', err);
}

if (!fromRedirect) {
  if (validLoopback) {
    // Desktop Loopback mode: Otomatis coba buka otentikasi Google tanpa memaksa klik berulang!
    login.onclick = performLogin;
    cancel.onclick = () => finishLoopback({ cancel: '1' });
    
    // Auto-trigger segera saat halaman dimuat
    performLogin();
  } else if (isInApp) {
    login.onclick = performLogin;
    performLogin();
  } else {
    message.className = 'status-msg';
    message.textContent = 'Buka halaman ini melalui tombol Masuk di aplikasi OpenTurath AI.';
  }
}
