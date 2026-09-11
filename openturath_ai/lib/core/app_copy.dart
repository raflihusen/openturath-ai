/// AppCopy: Sumber teks kanonik terpusat untuk OpenTurath.
/// Menjaga nada bahasa tetap tenang, ringkas, jelas, dan wajar untuk kajian keislaman.
abstract final class AppCopy {
  // ── Identitas & Merek ──────────────────────────────────────────
  static const appName = 'OpenTurath';
  static const appTagline = 'Membaca kitab, menelusuri ibarah.';
  static const defaultFieldDesc = 'Beragam kajian dari kitab-kitab Islam.';
  static const aboutTitle = 'Tentang OpenTurath';
  static const aboutDescription =
      'OpenTurath membantu Anda membaca, mencari, dan membandingkan keterangan dari kitab-kitab rujukan.';
  static const aboutScholarlyPrinciple =
      'Gunakan jawaban sebagai pintu masuk untuk menelusuri ibarah. Untuk memahami dan menetapkan hukum, tetaplah merujuk kepada guru dan ulama yang berkompeten.';

  // ── Navigasi Utama ─────────────────────────────────────────────
  static const navHome = 'Beranda';
  static const navStudies = 'Kajian';
  static const navSaved = 'Tersimpan';
  static const navSettings = 'Pengaturan';

  // ── Istilah Ruang & Kajian ─────────────────────────────────────
  static const studySpace = 'Ruang kajian';
  static const openStudy = 'Membuka kajian';
  static const studyOptions = 'Opsi kajian';
  static const referenceBooks = 'Kitab rujukan';
  static const savedCollection = 'Simpanan';
  static const bookDetails = 'Keterangan kitab';

  // ── Loading, Error & Akses ─────────────────────────────────────
  static const loadingReferences = 'Memuat kitab rujukan...';
  static const modulePreparing = 'sedang disiapkan.';
  static const moduleUnavailable = 'Modul ini belum dapat dibuka. Coba lagi nanti.';
  static const cannotLoad = 'Tidak dapat dimuat. Periksa koneksi, lalu coba lagi.';
  static const cannotLoadStudy = 'Tidak dapat memuat kajian';
  static const studyNotLoadedYet = 'Kajian belum bisa dimuat. Coba lagi sebentar.';
  static const subscriptionRequiredTitle = 'Langganan diperlukan';
  static const catalogLoadFailed = 'Daftar kitab belum bisa dimuat.';
  static const inputQuestionHint = 'Tanyakan sesuatu tentang kitab ini...';
  static const viewSubscription = 'Lihat langganan';
  static const tryAgain = 'Coba lagi';

  // Platform & Inisialisasi
  static const deviceNotSupportedTitle = 'Perangkat belum didukung';
  static const deviceNotSupportedMessage =
      'OpenTurath saat ini mendukung Android, macOS, dan Windows. Perangkat ini belum didukung.';
  static const cannotConnectTitle = 'Tidak dapat terhubung';
  static const cannotConnectMessage =
      'Tidak dapat terhubung ke layanan OpenTurath. Periksa koneksi, lalu coba lagi.';

  // ── Dialog Catatan Sebelum Mulai (Adab) ────────────────────────
  static const adabDialogTitle = 'Catatan sebelum mulai';
  static const adabAcknowledgeButton = 'Saya mengerti';

  static const adabHeading1 = 'Alat bantu, bukan pemberi fatwa';
  static const adabBody1 =
      'OpenTurath membantu mencari ibarah dan membandingkan keterangan dalam kitab. Aplikasi ini tidak menggantikan fatwa ulama.';

  static const adabHeading2 = 'Belajar tetap perlu bimbingan';
  static const adabBody2 =
      'Untuk memahami agama dengan baik, belajarlah kepada guru dan ulama yang berkompeten.';

  static const adabHeading3 = 'Periksa kembali rujukan';
  static const adabBody3 =
      'Periksa kembali dalil dan ibarah pada kitab rujukan sebelum menjadikannya pegangan.';

  // ── Umpan Balik Singkat (Toast & Snackbar) ─────────────────────
  static const noAnswerToCopy = 'Belum ada jawaban untuk disalin.';
  static const answerCopied = 'Jawaban tersalin.';
  static const copyFailed = 'Gagal menyalin. Coba lagi.';
  static const noAnswerToSave = 'Belum ada jawaban untuk disimpan.';
  static const savedSuccess = 'Tersimpan.';
  static const saveFailed = 'Gagal menyimpan. Coba lagi.';
  static const emptyAnswerCannotSave = 'Belum ada jawaban untuk disimpan.';

  // ── Simpanan / Bookmark ────────────────────────────────────────
  static const searchSavedHint = 'Cari kitab, topik, atau kutipan...';
  static const searchSavedTooltip = 'Cari simpanan';
  static const noSavedTitle = 'Belum ada simpanan';
  static const noSavedDescription =
      'Simpan jawaban atau ibarah agar mudah dibuka kembali.';
  static const copyIbarahAction = 'Salin ibarah';
  static const viewReferenceAction = 'Lihat rujukan';
  static const shareReferenceTooltip = 'Bagikan rujukan';
  static const saveAnswerMenu = 'Simpan jawaban';

  // ── Akun & Pengaturan ──────────────────────────────────────────
  static const profile = 'Profil';
  static const subscription = 'Langganan';
  static const activeSubscription = 'Langganan aktif';
  static const inactiveSubscription =
      'Belum berlangganan. Akses dibuka dengan voucher atau paket.';
  static const appearance = 'Tampilan';
  static const modeDark = 'Gelap';
  static const modeLight = 'Terang';
  static const modeSystem = 'Sistem';
  static const language = 'Bahasa';
  static const languageIndonesian = 'Bahasa Indonesia';

  static const logoutDialogTitle = 'Keluar dari akun?';
  static const logoutDialogBody = 'Anda akan keluar dari akun ini.';
  static const logoutButton = 'Keluar';

  static const deleteAccountTitle = 'Hapus akun?';
  static const deleteAccountBody =
      'Tindakan ini tidak dapat dibatalkan. Profil, simpanan, dan data akun Anda akan dihapus dari server.';
  static const deleteAccountButton = 'Hapus akun';
  static const deleteAccountSuccess = 'Akun Anda sudah dihapus.';
  static const recentLoginRequired =
      'Untuk menghapus akun, masuk ulang terlebih dahulu.';
  static const networkError = 'Koneksi bermasalah. Coba lagi.';

  // ── Helper Interpolasi Dinamis ─────────────────────────────────
  static String preparingModule(String module) => '$module sedang disiapkan.';

  static String subscriptionRequiredFor(String module) =>
      'Berlangganan untuk membuka $module.';

  static String accessUnavailableFor(String module) =>
      'Akun ini belum mendapat akses ke $module. Aktifkan langganan untuk melanjutkan.';

  static String planWithAgent(String agentTitle, String duration) =>
      '$agentTitle — $duration';
}
