import { initializeApp } from 'https://www.gstatic.com/firebasejs/12.19.0/firebase-app.js';
import { getAuth, GoogleAuthProvider, browserLocalPersistence, setPersistence,
  signInWithPopup, signInWithRedirect, getRedirectResult } from 'https://www.gstatic.com/firebasejs/12.19.0/firebase-auth.js';

const message = document.querySelector('#message');
const login = document.querySelector('#login');
const cancel = document.querySelector('#cancel');
login.disabled = true;
cancel.disabled = true;
const params = new URLSearchParams(location.search);
const embedded = params.get('mode') === 'inapp' || window.flutter_inappwebview !== undefined;
function stored(key) { try { return sessionStorage.getItem(key) || ''; } catch { return ''; } }
const callbackString = params.get('callback') || stored('ot_cb');
const state = params.get('state') || stored('ot_st');
let callback;
try { callback = new URL(callbackString); } catch { /* Invalid callbacks remain disabled. */ }
const valid = !embedded && ['https://open-turath.web.app', 'https://open-turath.firebaseapp.com'].includes(location.origin) &&
  callback && callback.protocol === 'http:' && callback.hostname === '127.0.0.1' &&
  Number(callback.port) >= 1024 && Number(callback.port) <= 65535 &&
  callback.pathname === '/callback' && !callback.username && !callback.password &&
  !callback.search && !callback.hash && /^[A-Za-z0-9_-]{43}$/.test(state);
function status(text, error = false) {
  message.className = error ? 'status-msg error' : 'status-msg';
  message.textContent = text;
}
function clearAttempt() { try { sessionStorage.removeItem('ot_cb'); sessionStorage.removeItem('ot_st'); } catch {} }
function finish(fields) {
  if (!valid) return;
  clearAttempt();
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = callback.href;
  for (const [name, value] of Object.entries({ state, ...fields })) {
    const input = document.createElement('input');
    input.type = 'hidden'; input.name = name; input.value = value;
    form.appendChild(input);
  }
  document.body.appendChild(form);
  form.submit();
}
if (!valid) {
  status(embedded ? 'Login Google harus dibuka di browser utama. Gunakan ruang browser OpenTurath.' : 'Buka halaman ini dari aplikasi OpenTurath.', true);
} else {
  try {
    sessionStorage.setItem('ot_cb', callback.href);
    sessionStorage.setItem('ot_st', state);
    const app = initializeApp({
      apiKey: 'AIzaSyC9b5YVceixZZL6AkLnsroBC9qvSt06bQ0', authDomain: location.hostname,
      projectId: 'open-turath', appId: '1:255541559800:web:a1f71cf6ae35aa2ed2960d',
    });
    const auth = getAuth(app);
    await setPersistence(auth, browserLocalPersistence);
    function complete(result) {
      const credential = GoogleAuthProvider.credentialFromResult(result);
      if (!credential?.idToken) throw new Error('missing-credential');
      status('Mengirim hasil Google untuk diverifikasi oleh OpenTurath…');
      finish({ idToken: credential.idToken });
    }
    async function performLogin() {
      login.disabled = true; cancel.disabled = true;
      status('Menghubungkan ke Google…');
      const provider = new GoogleAuthProvider();
      provider.setCustomParameters({ prompt: 'select_account' });
      try {
        complete(await signInWithPopup(auth, provider));
      } catch (error) {
        if (['auth/popup-blocked', 'auth/operation-not-supported-in-this-environment'].includes(error.code)) {
          try { await signInWithRedirect(auth, provider); return; } catch { /* Show a bounded failure. */ }
        }
        status(error.code === 'auth/popup-closed-by-user' ? 'Masuk dibatalkan. Anda dapat mencoba lagi.' : 'Login belum berhasil. Periksa koneksi atau konfigurasi Google aplikasi.', true);
        login.disabled = false; cancel.disabled = false;
      }
    }
    login.onclick = performLogin;
    cancel.onclick = () => finish({ cancel: '1' });
    try {
      const result = await getRedirectResult(auth);
      if (result) complete(result);
      else { login.disabled = false; cancel.disabled = false; status('Lanjutkan dengan akun Google di browser ini.'); }
    } catch {
      status('Login belum selesai. Coba lagi atau batalkan.', true);
      login.disabled = false; cancel.disabled = false;
    }
  } catch {
    clearAttempt();
    status('Browser tidak dapat menyiapkan sesi login. Izinkan penyimpanan situs dan coba lagi.', true);
  }
}
