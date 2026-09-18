import 'legal_copy.dart';

/// AppCopy: Sumber teks kanonik terpusat untuk OpenTurath.
/// Menjaga nada bahasa tetap tenang, ringkas, jelas, dan wajar untuk kajian keislaman (The Quiet Scholar).
abstract final class AppCopy {
  // ── Identitas & Merek ──────────────────────────────────────────
  static const appName = 'OpenTurath';
  static const appTagline = LegalCopy.aboutAppTagline;
  static const defaultFieldDesc = 'Pilih bidang untuk mulai menelusuri kitab.';
  static const aboutTitle = LegalCopy.aboutAppTitle;
  static const aboutDescription = LegalCopy.aboutAppParagraph1;
  static const aboutScholarlyPrinciple = LegalCopy.aboutAppParagraph2;
  static const academicSlogan = 'AI for Islamic Scholarship';

  // ── Navigasi Utama ─────────────────────────────────────────────
  static const navHome = 'Beranda';
  static const navStudies = 'Asisten';
  static const navSaved = 'Catatan';
  static const navSettings = 'Pengaturan';

  // ── Istilah Ruang & Kajian ─────────────────────────────────────
  static const studySpace = 'Ruang Telaah';
  static const openStudy = 'Membuka ruang telaah…';
  static const studyOptions = 'Opsi telaah';
  static const referenceBooks = 'Marja\' mu\'tamad';
  static const savedCollection = 'Perbendaharaan Catatan';
  static const bookDetails = 'Detail edisi';
  static const chooseField = 'Pilih bidang';
  static const allCategories = 'Semua bidang';
  static const searchResults = 'Hasil pencarian';
  static const continueStudy = 'Lanjutkan telaah';
  static const startStudy = 'Mulai telaah';
  static const dashboardSearchHint = 'Cari marja\', topik, atau ibarah…';
  static const ahlanDefault = 'Ahlan';
  static const studyBookCategory = 'TELAAH KITAB';
  static const studyEntryDefaultTitle = 'Ibarah & Istinbath Turats';
  static const studyEntryResumeSubtitle = 'Sesi telaah siap dibuka kembali.';
  static const studyEntryHistorySubtitle = 'Buka kembali marja\' dan catatan telaah sebelumnya.';
  static const studyEntryDefaultSubtitle =
      'Ajukan mas\'alah dan telusuri pembahasannya langsung dari naskah turats mu\'tamad.';

  // ── Loading, Error & Akses ─────────────────────────────────────
  static const loadingReferences = 'Menyiapkan ruang telaah…';
  static const modulePreparing = 'sedang disiapkan.';
  static const moduleUnavailable =
      'Ruang telaah ini belum tersedia. Coba lagi nanti.';
  static const cannotLoad = 'Data belum bisa dimuat. Coba lagi.';
  static const cannotLoadStudy = 'Ruang telaah belum bisa dibuka';
  static const studyNotLoadedYet =
      'Ruang telaah belum bisa dimuat. Coba lagi sebentar.';
  static const subscriptionRequiredTitle = 'Berlangganan untuk melanjutkan';
  static const subscriptionRequiredShort = 'Langganan diperlukan';
  static const catalogLoadFailed = 'Daftar kitab belum bisa dimuat.';
  static const catalogPreparing = 'Katalog kitab sedang disiapkan.';
  static const inputQuestionHint = 'Tuliskan mas\'alah atau ibarah yang ingin ditelaah…';
  static const viewSubscription = 'Lihat langganan';
  static const tryAgain = 'Coba lagi';
  static const sessionExpiredOrNoAccess =
      'Sesi Anda telah berakhir atau akses ke asisten ini belum aktif.';
  static const agentLoadFailed =
      'Asisten belum dapat dimuat. Coba lagi sebentar.';
  static const backToHome = 'Kembali ke beranda';
  static const noAssistantsFound =
      'Belum ada asisten atau kitab yang cocok. Coba kata kunci lain.';
  static const comingSoon = 'Segera hadir';

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
  static const adabDialogLead =
      'OpenTurath membantu mencari kutipan dan menelaah penjelasan dalam kitab. Periksa kembali rujukan pada kitab asal, dan tetaplah belajar kepada guru serta ulama yang berkompeten.';

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
  static const noConversationToCopy = 'Belum ada catatan telaah untuk disalin.';
  static const answerCopied = 'Jawaban disalin.';
  static const conversationCopied =
      'Catatan telaah disalin dan tersimpan ke Catatan.';
  static const copyFailed = 'Jawaban belum bisa disalin. Coba lagi.';
  static const noAnswerToSave = 'Belum ada jawaban untuk disimpan.';
  static const savedSuccess = 'Tersimpan ke Catatan.';
  static const saveFailed = 'Jawaban belum tersimpan. Coba lagi.';
  static const referenceCopied = 'Rujukan disalin.';
  static const ibarahCopied = 'Ibarah disalin.';
  static const noteContentCopied = 'Isi catatan disalin.';
  static const bookmarkDeleted = 'Catatan dihapus.';
  static const bookmarkDeleteFailed = 'Catatan belum bisa dihapus. Coba lagi.';
  static const cacheClearedSuccess = 'Cache berhasil dibersihkan.';

  // ── Catatan & Bacaan ───────────────────────────────────────────
  static const searchSavedHint = 'Cari catatan atau ibarah…';
  static const searchSavedTooltip = 'Cari catatan';
  static const noSavedTitle = 'Belum ada catatan';
  static const noSavedDescription =
      'Simpan jawaban atau ibarah penting di sini agar mudah dibaca kembali.';
  static const copyIbarahAction = 'Salin ibarah';
  static const viewReferenceAction = 'Lihat rujukan';
  static const shareReferenceTooltip = 'Bagikan catatan';
  static const copyAnswerAction = 'Salin jawaban';
  static const copyConversationAction = 'Salin catatan telaah';
  static const saveAnswerMenu = 'Simpan ke Catatan';
  static const copyContentTooltip = 'Salin isi';
  static const editNote = 'Edit catatan';
  static const deleteNote = 'Hapus catatan';
  static const deleteNoteTitle = 'Hapus catatan?';
  static const deleteNoteDesc = 'Catatan ini akan dihapus permanen.';
  static const addNote = 'Tambah catatan';
  static const closeSearch = 'Tutup pencarian';
  static const undo = 'Urungkan';
  static const bookReferenceLabel = 'Rujukan Kitab';

  // ── Sesi Akun Google & NotebookLM ──────────────────────────────
  static const googleSessionConnectTitle = 'Masuk ke akun Google';
  static const googleSessionConnectSubtitle =
      'Siapkan akun untuk ruang telaah Anda';
  static const googleSessionConnectDesc =
      'Setelah masuk, Anda akan kembali ke ruang telaah secara otomatis.';
  static const googleSessionSignInHint =
      'Gunakan akun Google yang sama agar Anda dapat langsung melanjutkan telaah tanpa perlu masuk ulang.';
  static const googleSessionSignInSameAccountDesc =
      'Masukan akun Google yang sama agar akses telaah dapat dibuka tanpa perlu masuk ulang.';
  static const googleSessionConnected = 'Akun Google terhubung';
  static const googleSessionPreparing = 'Menyiapkan ruang telaah…';
  static const cancelSignIn = 'Batalkan proses masuk';
  static const cancelSignInTitle = 'Batalkan proses masuk?';
  static const connectingGoogleAccount = 'Menghubungkan akun Google…';
  static const googleSessionFailed = 'Gagal menghubungkan akun Google.';
  static const googleSessionActive = 'Sesi Google aktif';

  // ── Autentikasi & Masuk ────────────────────────────────────────
  static const continueWithGoogle = 'Lanjutkan dengan Google';
  static const googleSignInFailed = 'Gagal masuk dengan Google. Coba lagi.';
  static const termsAgreementPrefix = 'Dengan masuk, Anda menyetujui';

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
  static const loggingOut = 'Sedang keluar…';

  static const deleteAccountTitle = 'Hapus akun';
  static const deleteAccountBody = LegalCopy.deleteAccountConfirmationBody;
  static const deleteAccountButton = LegalCopy.deleteAccountConfirmationConfirm;
  static const deleteAccountCancel = LegalCopy.deleteAccountConfirmationCancel;
  static const deleteAccountSuccess = 'Akun berhasil dihapus.';
  static const recentLoginRequired =
      'Masuk kembali untuk melanjutkan penghapusan akun.';
  static const networkError = 'Periksa koneksi internet, lalu coba lagi.';

  // ── Pengaturan Tambahan ───────────────────────────────────────
  static const accountSection = 'Akun';
  static const generalSettingsSection = 'Pengaturan umum';
  static const supportAndPolicySection = 'Bantuan & kebijakan';
  static const clearCache = 'Bersihkan cache';
  static const clearCacheSubtitle =
      'Hapus data sementara untuk meringankan penyimpanan';
  static const clearCacheDialogTitle = 'Bersihkan cache?';
  static const clearCacheDialogDesc =
      'Data unduhan dan cache sesi lokal akan dibersihkan. Anda tetap berada dalam akun.';
  static const clearAction = 'Bersihkan';
  static const chooseAppearance = 'Pilih tampilan';

  // ── Status Akses & Membership Pass ────────────────────────────
  static const accessStatus = 'Status akses';
  static const fullAccess = 'Akses Pustaka Lengkap';
  static const planSyafii = 'Fikih Syafi\'i';
  static const planTahawwulat = 'Fikih Tahawwulat';
  static const trialAccess = 'Akses uji coba';
  static const activeUntil = 'Aktif hingga';
  static const allAssistantsAvailable = 'Seluruh bidang telaah tersedia';
  static const accessExpiringSoon = 'Masa akses hampir berakhir';
  static const readyToUse = 'Siap digunakan';
  static const validUntil = 'Berlaku hingga';
  static const renewPro = 'Perpanjang Akses';
  static const manageSubscription = 'Kelola langganan';
  static const preparingProAccess = 'Menyiapkan akses pustaka';
  static const paymentBeingVerified = 'Pembayaran sedang diperiksa';
  static const viewPaymentStatus = 'Lihat status pembayaran';
  static const accessNotYetActive = 'Akses belum aktif';
  static const paymentNotSuccessful = 'Pembayaran belum berhasil';
  static const tryPaymentAgain = 'Coba pembayaran lagi';
  static const chooseAssistantAndPlan =
      'Pilih bidang kajian dan paket yang sesuai untuk mulai menelaah.';
  static const chooseProPlan = 'Pilih paket akses pustaka';
  static const permanentAccessLabel = 'Tanpa batas waktu';
  static const manageAccess = 'Kelola akses';

  // ── Tombol Umum & Aksi ─────────────────────────────────────────
  static const close = 'Tutup';
  static const cancel = 'Batal';
  static const exit = 'Keluar';
  static const reload = 'Muat ulang';
  static const delete = 'Hapus';
  static const seeAll = 'Lihat semua';
  static const openAction = 'Buka';
  static const stayHere = 'Tetap di sini';
  static const readMore = 'Baca selengkapnya';
  static const today = 'Hari ini';
  static const hijriCalendar = 'Kalender Hijriah';

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

  static String trialDaysLeft(int days) => 'Masa coba · $days hari';

  static String assistantsAvailableCount(int count) =>
      count == 1 ? '1 bidang telaah tersedia' : '$count bidang telaah tersedia';

  static String savedNotesCount(int count) => '$count catatan tersimpan';

  static String versionWithTagline(String version) =>
      'Versi $version · $appTagline';

  static String ahlanWithName(String name) => 'Ahlan, $name';
}
