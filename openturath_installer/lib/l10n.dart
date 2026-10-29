/// Teks installer dalam tiga bahasa. Kunci tunggal, tiga nilai: id, en, ar.
class Strings {
  const Strings(this.code);
  final String code;

  static const codes = ['id', 'en', 'ar'];
  bool get rtl => code == 'ar';

  static String detect(String deviceLanguage) => switch (deviceLanguage) {
    'ar' => 'ar',
    'id' || 'in' => 'id',
    _ => 'en',
  };

  String _(String id, String en, String ar) => switch (code) {
    'en' => en,
    'ar' => ar,
    _ => id,
  };

  String get tagline => _(
    'AI untuk penuntut ilmu, bersumber dari kitab.',
    'AI for students of knowledge, grounded in the books.',
    'ذكاء اصطناعي لطلبة العلم، مستند إلى الكتب.',
  );
  String get install => _('Pasang', 'Install', 'تثبيت');
  String get options =>
      _('Opsi pemasangan', 'Install options', 'خيارات التثبيت');
  String get location => _('Lokasi', 'Location', 'المكان');
  String get shortcut =>
      _('Pintasan di desktop', 'Desktop shortcut', 'اختصار على سطح المكتب');
  String get installing => _(
    'Memasang OpenTurath AI',
    'Installing OpenTurath AI',
    'جارٍ تثبيت OpenTurath AI',
  );
  String phase(String key) => switch (key) {
    'copy' => _('Memasang berkas', 'Copying files', 'نسخ الملفات'),
    'finish' => _('Merapikan', 'Finishing up', 'اللمسات الأخيرة'),
    _ => _('Menyiapkan', 'Getting ready', 'التحضير'),
  };
  String get doneTitle =>
      _('Siap digunakan.', "You're all set.", 'أصبح جاهزًا.');
  String get doneSub => _(
    'OpenTurath AI sudah terpasang.',
    'OpenTurath AI is installed.',
    'تم تثبيت OpenTurath AI.',
  );
  String get open => _('Buka OpenTurath', 'Open OpenTurath', 'فتح OpenTurath');
  String get close => _('Tutup', 'Close', 'إغلاق');
  String get errorTitle =>
      _('Pemasangan terhenti.', 'Installation stopped.', 'توقف التثبيت.');
  String get errorSub => _(
    'Tidak ada yang berubah pada komputer Anda. Coba lagi.',
    'Nothing was changed on your computer. Try again.',
    'لم يتغير شيء على جهازك. حاول مرة أخرى.',
  );
  String get retry => _('Coba lagi', 'Try again', 'حاول مرة أخرى');
  String get pathHint =>
      _('Folder pemasangan', 'Install folder', 'مجلد التثبيت');
  String get privacy => _(
    'Tanpa iklan, tanpa pelacak pemasangan.',
    'No ads, no install tracking.',
    'بلا إعلانات ولا تتبّع للتثبيت.',
  );
  String get closeTip => _('Tutup', 'Close', 'إغلاق');
}
