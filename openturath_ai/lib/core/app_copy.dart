import 'legal_copy.dart';

/// AppCopy: Sumber teks kanonik terpusat untuk OpenTurath.
/// Menjaga nada bahasa tetap tenang, ringkas, jelas, dan wajar untuk kajian keislaman.
abstract final class AppCopy {
  // ── Identitas & Merek ──────────────────────────────────────────
  static const appName = 'OpenTurath';
  static const appTagline = LegalCopy.aboutAppTagline;
  static const defaultFieldDesc =
      'Pelajari berbagai bidang ilmu dari kitab-kitab rujukan.';
  static const aboutTitle = LegalCopy.aboutAppTitle;
  static const aboutDescription = LegalCopy.aboutAppParagraph1;
  static const aboutScholarlyPrinciple = LegalCopy.aboutAppParagraph2;

  // ── Navigasi Utama ─────────────────────────────────────────────
  static const navHome = 'Beranda';
  static const navStudies = 'Asisten AI';
  static const navSaved = 'Catatan';
  static const navSettings = 'Pengaturan';

  // ── Istilah Ruang & Kajian ─────────────────────────────────────
  static const studySpace = 'Percakapan';
  static const openStudy = 'Membuka asisten…';
  static const studyOptions = 'Tampilan bacaan';
  static const referenceBooks = 'Kitab rujukan';
  static const savedCollection = 'Catatan';
  static const bookDetails = 'Tentang kitab';

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
  static const catalogLoadFailed = 'Daftar kitab belum bisa dimuat.';
  static const inputQuestionHint = 'Tulis pertanyaan seputar kitab ini…';
  static const viewSubscription = 'Lihat langganan';
  static const tryAgain = 'Coba lagi';

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
  static const answerCopied = 'Jawaban disalin dan disimpan ke Catatan.';
  static const copyFailed = 'Jawaban belum bisa disalin. Coba lagi.';
  static const noAnswerToSave = 'Belum ada jawaban untuk disimpan.';
  static const savedSuccess = 'Tersimpan ke Catatan.';
  static const saveFailed = 'Jawaban belum tersimpan. Coba lagi.';
  static const emptyAnswerCannotSave = 'Belum ada jawaban untuk disimpan.';

  // ── Catatan ───────────────────────────────────────────────────
  static const searchSavedHint = 'Cari catatan atau ibarah…';
  static const searchSavedTooltip = 'Cari catatan';
  static const noSavedTitle = 'Belum ada catatan';
  static const noSavedDescription =
      'Simpan jawaban atau ibarah penting di sini agar mudah dibaca kembali.';
  static const copyIbarahAction = 'Salin ibarah';
  static const viewReferenceAction = 'Lihat rujukan';
  static const shareReferenceTooltip = 'Bagikan catatan';
  static const saveAnswerMenu = 'Simpan ke Catatan';

  // ── Akun & Pengaturan ──────────────────────────────────────────
  static const profile = 'Profil';
  static const subscription = 'Langganan';
  static const activeSubscription = 'Langganan aktif';
  static const inactiveSubscription =
      'Pilih paket atau gunakan voucher untuk mulai berlangganan.';
  static const appearance = 'Tampilan';
  static const modeDark = 'Gelap';
  static const modeLight = 'Terang';
  static const modeSystem = 'Ikuti perangkat';
  static const language = 'Bahasa';
  static const languageIndonesian = 'Bahasa Indonesia';

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

  // ── Kebijakan, Hukum & Bantuan ─────────────────────────────────
  static const termsOfService = LegalCopy.termsTitle;
  static const privacyPolicy = LegalCopy.privacyTitle;
  static const paymentAndRefund = LegalCopy.refundTitle;
  static const aiGuideline = LegalCopy.aiGuidelineTitle;
  static const supportAndContact = LegalCopy.contactTitle;
  static const manualRenewalNotice =
      'Langganan diperpanjang secara manual tanpa penagihan berulang otomatis. Masa akses dihitung sejak pembayaran berhasil.';

  // ── Helper Interpolasi Dinamis ─────────────────────────────────
  static String preparingModule(String module) => '$module sedang disiapkan.';

  static String subscriptionRequiredFor(String module) =>
      'Berlangganan untuk membuka $module.';

  static String accessUnavailableFor(String module) =>
      'Akun ini belum mendapat akses ke $module. Aktifkan langganan untuk melanjutkan.';

  static String planWithAgent(String agentTitle, String duration) =>
      '$agentTitle — $duration';
}
