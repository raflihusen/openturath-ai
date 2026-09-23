import { initializeApp } from 'https://www.gstatic.com/firebasejs/12.19.0/firebase-app.js';
import { getAuth, GoogleAuthProvider, inMemoryPersistence, setPersistence,
  signInWithPopup, signOut } from 'https://www.gstatic.com/firebasejs/12.19.0/firebase-auth.js';

const message = document.querySelector('#message');
const login = document.querySelector('#login');
const cancel = document.querySelector('#cancel');
const params = new URLSearchParams(location.search);
const state = params.get('state') ?? '';
let callback;
try { callback = new URL(params.get('callback')); } catch { /* invalid link */ }
const valid = location.origin === 'https://open-turath.web.app' && callback &&
  callback.protocol === 'http:' && callback.hostname === '127.0.0.1' &&
  Number(callback.port) >= 1024 && Number(callback.port) <= 65535 &&
  callback.pathname === '/callback' && !callback.username && !callback.password &&
  !callback.search && !callback.hash && /^[A-Za-z0-9_-]{43}$/.test(state);

function finish(fields) {
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
  message.textContent = 'Buka halaman ini melalui tombol Masuk di aplikasi OpenTurath AI.';
} else {
  const app = initializeApp({
    apiKey: 'AIzaSyC9b5YVceixZZL6AkLnsroBC9qvSt06bQ0',
    authDomain: 'open-turath.firebaseapp.com',
    projectId: 'open-turath', appId: '1:255541559800:web:a1f71cf6ae35aa2ed2960d',
  });
  const auth = getAuth(app);
  await setPersistence(auth, inMemoryPersistence);
  message.textContent = 'Akun Anda hanya dipakai untuk masuk ke aplikasi.';
  login.disabled = false; cancel.disabled = false;
  cancel.onclick = () => finish({ cancel: '1' });
  login.onclick = async () => {
    login.disabled = true; cancel.disabled = true;
    try {
      const provider = new GoogleAuthProvider();
      provider.setCustomParameters({ prompt: 'select_account' });
      const result = await signInWithPopup(auth, provider);
      const credential = GoogleAuthProvider.credentialFromResult(result);
      if (!credential?.idToken) throw new Error('Missing Google credential');
      const idToken = credential.idToken;
      await signOut(auth);
      message.textContent = 'Masuk berhasil. Kembali ke aplikasi…';
      finish({ idToken });
    } catch {
      message.textContent = 'Proses masuk belum selesai. Izinkan jendela Google, lalu coba kembali.';
      login.disabled = false; cancel.disabled = false;
    }
  };
}
