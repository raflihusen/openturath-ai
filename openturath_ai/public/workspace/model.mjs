export const WORKSPACE_VERSION = 'openturath-browser-workspace-v1';

// Only a notebook returned by the authenticated server may become a link.
export function notebookLink(value, email = '') {
  const url = new URL(value);
  if (url.protocol !== 'https:' || url.username || url.password || url.port ||
      !['notebooklm.google.com', 'notebook.google.com'].includes(url.hostname) ||
      !/^\/notebook\/[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}\/?$/i.test(url.pathname)) {
    throw new Error('invalid-notebook-url');
  }
  // Do not forward arbitrary query parameters, fragments or credentials.
  url.search = '';
  url.hash = '';
  if (email) url.searchParams.set('authuser', email);
  return url.href;
}

export function validAgentId(value) {
  return typeof value === 'string' && /^[a-z0-9_-]{1,80}$/.test(value);
}

export function canonicalWorkspace(value) {
  const current = new URL(value);
  if (current.hostname !== 'open-turath.web.app') return null;
  const target = new URL('https://open-turath.firebaseapp.com/workspace/');
  const agent = current.searchParams.get('agent');
  if (validAgentId(agent)) target.searchParams.set('agent', agent);
  return target.href;
}

export function readableError(error) {
  const code = error?.code || error?.message;
  // Callable messages come from the existing OpenTurath server and are rendered
  // as plain text, so voucher restrictions can be explained without changing them.
  if (typeof error?.code === 'string' && error.code.startsWith('functions/') &&
      typeof error.message === 'string' && error.message.length <= 500) {
    if (error.message.includes('Identitas perangkat')) {
      return 'Kode promo ini memerlukan aktivasi pada perangkat fisik sesuai ketentuannya. Hubungi pengelola untuk penggunaan melalui browser.';
    }
    return error.message;
  }
  const messages = {
    'auth/popup-closed-by-user': 'Masuk dibatalkan. Anda dapat mencoba lagi.',
    'auth/cancelled-popup-request': 'Permintaan masuk sebelumnya dibatalkan.',
    'auth/unauthorized-domain': 'Alamat ruang ini belum diizinkan untuk login Google. Hubungi pengelola OpenTurath.',
    'auth/operation-not-allowed': 'Login Google belum diaktifkan oleh pengelola OpenTurath.',
    'auth/network-request-failed': 'Koneksi terputus. Periksa internet lalu coba lagi.',
    'auth/web-storage-unsupported': 'Browser tidak mengizinkan penyimpanan sesi. Buka di browser biasa dan izinkan penyimpanan situs.',
    'functions/permission-denied': 'Akses bidang ini belum aktif. Tukarkan kode akses atau periksa langganan Anda.',
    'functions/unauthenticated': 'Sesi OpenTurath sudah berakhir. Silakan masuk kembali.',
    'functions/not-found': 'Bidang atau profil belum tersedia. Coba muat ulang atau hubungi pengelola.',
    'functions/deadline-exceeded': 'Server belum merespons. Coba lagi setelah memeriksa koneksi.',
    'functions/unavailable': 'Server belum tersedia. Silakan coba kembali nanti.',
    'invalid-notebook-url': 'Server mengembalikan alamat notebook yang tidak valid. Hubungi pengelola.',
  };
  return messages[code] || 'Permintaan belum berhasil. Coba lagi atau hubungi pengelola OpenTurath.';
}

export function redirectFallbackAllowed(error) {
  return ['auth/popup-blocked', 'auth/operation-not-supported-in-this-environment'].includes(error?.code);
}
