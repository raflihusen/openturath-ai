import 'legal_copy.dart';

/// AppCopy: Sumber teks kanonik terpusat untuk OpenTurath.
/// Menjaga nada bahasa tetap tenang, ringkas, jelas, dan wajar untuk kajian keislaman.
abstract final class AppCopy {
  // ── Identitas & Merek ──────────────────────────────────────────
  static const appName = 'OpenTurath';
  static const appTagline = LegalCopy.aboutAppTagline;
  static const defaultFieldDesc = 'Pilih bidang untuk mulai menelusuri kitab.';
  static const aboutTitle = LegalCopy.aboutAppTitle;
  static const aboutDescription = LegalCopy.aboutAppParagraph1;
  static const aboutScholarlyPrinciple = LegalCopy.aboutAppParagraph2;
  static const scholarlyPrinciple = LegalCopy.aboutAppParagraph2;

  // ── Navigasi Utama ─────────────────────────────────────────────
  static const navHome = 'Beranda';
  static const navStudies = 'Asisten';
  static const navSaved = 'Catatan';
  static const navSettings = 'Pengaturan';

  // ── Istilah Ruang & Kajian ─────────────────────────────────────
  static const studySpace = 'Percakapan';
  static const openStudy = 'Membuka asisten…';
  static const studyOptions = 'Opsi percakapan';
  static const referenceBooks = 'Kitab rujukan';
  static const savedCollection = 'Catatan';
  static const bookDetails = 'Detail edisi';
  static const chooseField = 'Pilih bidang';
  static const searchResults = 'Hasil pencarian';

  // ── Loading, Error & Akses ─────────────────────────────────────
  static const loadingReferences = 'Menyiapkan asisten…';
  static const modulePreparing = 'sedang disiapkan.';
  static const moduleUnavailable =
      'Asisten ini belum tersedia. Coba lagi nanti.';
  static const cannotLoad = 'Data belum bisa dimuat. Coba lagi.';
  static const cannotLoadStudy = 'Asisten belum bisa dibuka';
  static const studyNotLoadedYet =
      'Percakapan belum bisa dimuat. Coba lagi sebentar.';
  static const subscriptionRequiredTitle = 'Berlangganan untuk melanjutkan';
  static const subscriptionRequiredShort = 'Langganan diperlukan';
  static const catalogLoadFailed = 'Daftar kitab belum bisa dimuat.';
  static const catalogPreparing = 'Katalog kitab sedang disiapkan.';
  static const inputQuestionHint = 'Tulis pertanyaan seputar kitab ini…';
  static const viewSubscription = 'Lihat langganan';
  static const tryAgain = 'Coba lagi';
  static const sessionExpiredOrNoAccess =
      'Sesi Anda telah berakhir atau akses ke asisten ini belum aktif.';
  static const agentLoadFailed =
      'Asisten belum dapat dimuat. Coba lagi sebentar.';

  // Platform & Inisialisasi
  static const deviceNotSupportedTitle = 'Perangkat belum didukung';
  static const deviceNotSupportedMessage =
      'OpenTurath saat ini mendukung Android, macOS, dan Windows. Perangkat ini belum didukung.';
  static const cannotConnectTitle = 'Tidak dapat terhubung';
  static const cannotConnectMessage =
      'Tidak dapat terhubung ke layanan OpenTurath. Periksa koneksi internet, lalu coba lagi.';

  // ── Dialog Catatan Sebelum Mulai (Adab) ────────────────────────
  static const adabDialogTitle = 'Catatan sebelum mulai';
  static const adabAcknowledgeButton = 'Saya mengerti';

  static const adabHeading1 = 'Bantuan untuk menelusuri kitab';
  static const adabBody1 =
      'Gunakan OpenTurath untuk mencari ibarah dan membandingkan penjelasan dalam kitab. Cocokkan hasilnya dengan sumber di Maktabah Syamilah atau kitab cetak.';

  static const adabHeading2 = 'Belajar tetap perlu bimbingan';
  static const adabBody2 =
      'Untuk memahami agama dengan baik, belajarlah kepada guru dan ulama yang berkompeten.';

  static const adabHeading3 = 'Periksa kembali rujukan';
  static const adabBody3 =
      'Periksa dalil dan ibarah pada kitab rujukan sebelum menjadikannya pegangan.';

  // ── Umpan Balik Singkat (Toast & Snackbar) ─────────────────────
  static const noAnswerToCopy = 'Belum ada jawaban untuk disalin.';
  static const noConversationToCopy = 'Belum ada percakapan untuk disalin.';
  static const answerCopied = 'Jawaban disalin.';
  static const conversationCopied =
      'Percakapan disalin dan tersimpan ke Catatan.';
  static const copyFailed = 'Jawaban belum bisa disalin. Coba lagi.';
  static const noAnswerToSave = 'Belum ada jawaban untuk disimpan.';
  static const savedSuccess = 'Tersimpan ke Catatan.';
  static const saveFailed = 'Jawaban belum tersimpan. Coba lagi.';
  static const emptyAnswerCannotSave = 'Belum ada jawaban untuk disimpan.';
  static const referenceCopied = 'Rujukan disalin.';

  // ── Catatan ───────────────────────────────────────────────────
  static const searchSavedHint = 'Cari catatan atau ibarah…';
  static const searchSavedTooltip = 'Cari catatan';
  static const noSavedTitle = 'Belum ada catatan';
  static const noSavedDescription =
      'Simpan jawaban atau ibarah penting di sini agar mudah dibaca kembali.';
  static const copyIbarahAction = 'Salin ibarah';
  static const viewReferenceAction = 'Lihat rujukan';
  static const shareReferenceTooltip = 'Bagikan catatan';
  static const copyAnswerAction = 'Salin jawaban';
  static const copyConversationAction = 'Salin percakapan';
  static const saveAnswerMenu = 'Simpan ke Catatan';

  // ── Sesi Akun Google & NotebookLM ──────────────────────────────
  static const googleSessionConnectTitle = 'Masuk ke akun Google';
  static const googleSessionConnectSubtitle =
      'Siapkan akun untuk ruang kajian Anda';
  static const googleSessionConnectDesc =
      'Setelah masuk, Anda akan kembali ke ruang kajian secara otomatis.';
  static const googleSessionSignInHint =
      'Gunakan akun Google yang sama agar Anda dapat langsung melanjutkan kajian tanpa perlu masuk ulang.';
  static const googleSessionConnected = 'Akun Google terhubung';
  static const googleSessionPreparing = 'Menyiapkan percakapan…';
  static const cancelSignIn = 'Batalkan proses masuk';

  // ── Akun & Pengaturan ──────────────────────────────────────────
  static const profile = 'Profil';
  static const subscription = 'Langganan';
  static const activeSubscription = 'Langganan aktif';
  static const inactiveSubscription =
      'Pilih paket atau gunakan voucher untuk mendapatkan akses.';
  static const appearance = 'Tampilan';
  static const modeDark = 'Gelap';
  static const modeLight = 'Terang';
  static const modeSystem = 'Ikuti perangkat';
  static const language = 'Bahasa';
  static const languageIndonesian = 'Bahasa Indonesia';
  static const languageDialogNotice =
      'Bahasa Arab dan Inggris sedang disiapkan.';
  static const languageDialogCurrent =
      'Antarmuka saat ini tersedia dalam Bahasa Indonesia.';

  static const logoutDialogTitle = 'Keluar dari akun';
  static const logoutDialogBody =
      'Anda perlu masuk kembali untuk menggunakan akun ini.';
  static const logoutButton = 'Keluar';

  static const deleteAccountTitle = 'Hapus akun';
  static const deleteAccountBody = LegalCopy.deleteAccountConfirmationBody;
  static const deleteAccountButton = LegalCopy.deleteAccountConfirmationConfirm;
  static const deleteAccountCancel = LegalCopy.deleteAccountConfirmationCancel;
  static const deleteAccountSuccess = 'Akun berhasil dihapus.';
  static const recentLoginRequired =
      'Masuk kembali untuk melanjutkan penghapusan akun.';
  static const networkError = 'Periksa koneksi internet, lalu coba lagi.';

  // ── Pembayaran & Status Langganan ─────────────────────────────
  static const paymentSuccessTitle = 'Pembayaran berhasil';
  static const paymentSuccessRedirect =
      'Akses sudah aktif. Membuka OpenTurath…';
  static const packagePerField = 'Paket per bidang';
  static const packageAllFields = 'Paket semua bidang';
  static const packageAllFieldsPreparing =
      'Paket semua bidang sedang disiapkan.';
  static const chooseFieldPlan = 'Pilih bidang';
  static const accessAllFields = 'Akses semua bidang';
  static const accessSingleField = 'Akses satu bidang';
  static const notSubscribed = 'Belum berlangganan';

  // ── Kebijakan, Hukum & Bantuan ─────────────────────────────────
  static const termsOfService = LegalCopy.termsTitle;
  static const privacyPolicy = LegalCopy.privacyTitle;
  static const paymentAndRefund = LegalCopy.refundTitle;
  static const aiGuideline = LegalCopy.aiGuidelineTitle;
  static const supportAndContact = LegalCopy.contactTitle;
  static const manualRenewalNotice =
      'Langganan tidak diperpanjang otomatis. Anda dapat memperpanjangnya saat masa akses berakhir.';

  // ── Helper Interpolasi Dinamis ─────────────────────────────────
  static String preparingModule(String module) => '$module sedang disiapkan.';

  static String subscriptionRequiredFor(String module) =>
      'Berlangganan untuk membuka $module.';

  static String accessUnavailableFor(String module) =>
      'Akses ke $module belum aktif. Pilih paket atau gunakan voucher untuk melanjutkan.';

  static String planWithAgent(String agentTitle, String duration) =>
      '$agentTitle — $duration';
}
