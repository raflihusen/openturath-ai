import { initializeApp } from 'https://www.gstatic.com/firebasejs/12.19.0/firebase-app.js';
import { getAuth, GoogleAuthProvider, browserLocalPersistence, setPersistence,
  signInWithPopup, signInWithRedirect, getRedirectResult, signOut } from 'https://www.gstatic.com/firebasejs/12.19.0/firebase-auth.js';

const message = document.querySelector('#message');
const login = document.querySelector('#login');
const cancel = document.querySelector('#cancel');
const params = new URLSearchParams(location.search);
const state = params.get('state') ?? '';
const isInApp = params.get('mode') === 'inapp' || window.flutter_inappwebview !== undefined;

let callback;
try { callback = new URL(params.get('callback')); } catch { /* invalid link */ }

const validLoopback = location.origin === 'https://open-turath.web.app' && callback &&
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
// Use persistent session so that Google cookies and auth tokens are preserved in WKWebView
await setPersistence(auth, browserLocalPersistence);

function notifyFlutter(payload) {
  if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
    try {
      window.flutter_inappwebview.callHandler('onDesktopAuthSuccess', payload);
    } catch (_) {}
  }
  // Secondary fallback: update URL hash for interception
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
  message.textContent = 'Masuk berhasil! Menghubungkan sesi…';
  
  if (isInApp) {
    notifyFlutter({ idToken, email, name, status: 'success' });
  } else if (validLoopback) {
    finishLoopback({ idToken });
  }
}

// 1. Check if returning from a redirect flow
try {
  const redirectResult = await getRedirectResult(auth);
  if (redirectResult) {
    const credential = GoogleAuthProvider.credentialFromResult(redirectResult);
    if (credential?.idToken) {
      await handleAuthSuccess(credential, redirectResult.user);
    }
  }
} catch (err) {
  console.warn('Redirect result error:', err);
}

if (!isInApp && !validLoopback) {
  message.className = 'status-msg';
  message.textContent = 'Buka halaman ini melalui tombol Masuk di aplikasi OpenTurath AI.';
} else {
  message.className = 'status-msg';
  message.textContent = 'Siap menghubungkan akun Google Anda.';
  login.disabled = false;
  cancel.disabled = false;

  cancel.onclick = () => {
    if (isInApp) {
      notifyFlutter({ status: 'cancel' });
    } else if (validLoopback) {
      finishLoopback({ cancel: '1' });
    }
  };

  login.onclick = async () => {
    login.disabled = true;
    cancel.disabled = true;
    message.className = 'status-msg';
    message.innerHTML = '<span class="spinner"></span> Menghubungkan ke Google…';

    const provider = new GoogleAuthProvider();
    provider.setCustomParameters({ prompt: 'select_account' });
    provider.addScope('email');
    provider.addScope('profile');

    try {
      // First try popup
      const result = await signInWithPopup(auth, provider);
      const credential = GoogleAuthProvider.credentialFromResult(result);
      if (!credential?.idToken) throw new Error('Missing Google credential');
      await handleAuthSuccess(credential, result.user);
    } catch (popupErr) {
      console.warn('Popup failed or blocked, falling back to redirect:', popupErr);
      try {
        message.innerHTML = '<span class="spinner"></span> Mengarahkan ke Google…';
        await signInWithRedirect(auth, provider);
      } catch (redirectErr) {
        message.className = 'status-msg error';
        message.textContent = 'Gagal masuk dengan Google. Silakan coba kembali.';
        login.disabled = false;
        cancel.disabled = false;
      }
    }
  };
}
