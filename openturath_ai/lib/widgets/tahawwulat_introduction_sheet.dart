import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_platform.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'adaptive_sheet.dart';

/// Pengantar Fikih Tahawwulat untuk orang yang baru pertama kali mendengarnya,
/// disajikan per bab yang bersambung seperti slide.
///
/// Isinya disusun dari jawaban AI Fikih Tahawwulat (Al-Muhaqqiq dan Al-Bayan),
/// lalu setiap klaim dicek ke kitab dan muhadharah Al-Habib Abu Bakar al-'Adni
/// bin Ali al-Masyhur di notebook 06 (OUTPUT_V9_2) pada 15–16 Oktober 2026.
/// Klaim yang tidak ditemukan di sumber tidak dipakai.
class TahawwulatIntroductionSheet extends StatefulWidget {
  final AgentModel? agent;
  final void Function(SubAgentModel subAgent)? onSelectSubAgent;
  final VoidCallback? onOpenMain;

  /// Halaman penuh dengan AppBar; false = lembar bawah.
  final bool asPage;

  /// Bab yang dibuka pertama (0 = pembuka).
  final int initialSection;

  const TahawwulatIntroductionSheet({
    super.key,
    this.agent,
    this.onSelectSubAgent,
    this.onOpenMain,
    this.asPage = true,
    this.initialSection = 0,
  });

  /// Desktop: halaman penuh. Ponsel: lembar bawah.
  static Future<void> show(
    BuildContext context, {
    AgentModel? agent,
    void Function(SubAgentModel subAgent)? onSelectSubAgent,
    VoidCallback? onOpenMain,
  }) {
    if (AppPlatform.isDesktop) {
      return Navigator.of(context).push<void>(PageRouteBuilder<void>(
        transitionDuration: OTMotion.normal,
        reverseTransitionDuration: OTMotion.fast,
        pageBuilder: (ctx, _, __) => TahawwulatIntroductionSheet(
          agent: agent,
          onSelectSubAgent: onSelectSubAgent,
          onOpenMain: onOpenMain,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: OTMotion.curve),
          child: child,
        ),
      ));
    }
    return showAdaptiveSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctx) => TahawwulatIntroductionSheet(
        agent: agent,
        onSelectSubAgent: onSelectSubAgent,
        onOpenMain: onOpenMain,
        asPage: false,
      ),
    );
  }

  @override
  State<TahawwulatIntroductionSheet> createState() =>
      _TahawwulatIntroductionSheetState();
}

// ── Isi ────────────────────────────────────────────────────────────────────

/// Satu baris dalam panel: judul, keterangan, dan istilah Arab.
class _Baris {
  const _Baris(this.judul, [this.ket = '', this.arab = '']);
  final String judul;
  final String ket;
  final String arab;
}

sealed class _Panel {
  const _Panel(this.kepala);
  final String kepala;
}

/// Daftar bernomor, seperti daftar lima AI di halaman langganan.
class _Daftar extends _Panel {
  const _Daftar(super.kepala, this.isi, {this.sorot = -1});
  final List<_Baris> isi;
  final int sorot;
}

/// Dua kolom yang dibandingkan.
class _Dua extends _Panel {
  const _Dua(super.kepala, this.kiri, this.kanan);
  final _Baris kiri;
  final _Baris kanan;
}

/// Kutipan Arab beserta maknanya.
class _Kutip extends _Panel {
  const _Kutip(super.kepala, this.arab, this.makna);
  final String arab;
  final String makna;
}

/// Alur sebab-akibat dari atas ke bawah.
class _Alur extends _Panel {
  const _Alur(super.kepala, this.isi);
  final List<String> isi;
}

class _Bab {
  const _Bab({
    required this.label,
    required this.judul,
    required this.paragraf,
    this.panel,
    this.penutup = const [],
    this.jembatan = '',
    this.limaAi = false,
  });
  final String label;
  final String judul;
  final List<String> paragraf;
  final _Panel? panel;
  final List<String> penutup;
  final String jembatan;
  final bool limaAi;
}

const _bab = [
  _Bab(
    label: 'Pembuka',
    judul: 'Mengenal Fikih Tahawwulat',
    paragraf: [
      'Pernahkah Anda merasa dunia bergerak terlalu cepat? Berita datang silih berganti, teknologi terus berubah, dan perdebatan seolah tidak pernah selesai. Wajar kalau kita bertanya: bagaimana seorang muslim semestinya membaca zaman seperti ini?',
      "Fikih Tahawwulat hadir untuk menjawab pertanyaan itu. Ilmu ini dirintis oleh Al-Habib Abu Bakar al-'Adni bin Ali al-Masyhur (w. 1443 H). Bahan utamanya adalah hadis-hadis Nabi saw. tentang tanda-tanda zaman, yang beliau baca dengan cara yang tertata.",
    ],
    panel: _Daftar('Yang akan kita bahas', [
      _Baris('Arti namanya', 'Apa yang dipelajari, dan apa yang bukan'),
      _Baris('Asal-usulnya', 'Hadis Jibril dan rukun agama yang keempat'),
      _Baris('Isyarat zaman', 'Dua hal yang goyah dan lima babak sejarah'),
      _Baris('Sikap kita', 'Teladan Nabi saw. ketika fitnah ramai'),
      _Baris('Mulai belajar', 'Kitab untuk pemula dan lima AI'),
    ]),
    jembatan: 'Kita mulai dari namanya.',
  ),
  _Bab(
    label: 'Arti nama',
    judul: 'Ilmu untuk memahami perubahan',
    paragraf: [
      'Fikih berarti pemahaman yang dalam, bukan sekadar tahu di permukaan. Tahawwulat adalah bentuk jamak dari tahawwul, yang berarti perubahan. Jadi secara sederhana, Fikih Tahawwulat adalah ilmu untuk memahami perubahan-perubahan.',
      "Cakupannya luas. Beliau menyebutnya fikih yang berdasar Al-Qur'an dan Sunnah untuk mempelajari seluruh perubahan dalam kehidupan manusia, sejak masa Nabi Adam sampai hari kebangkitan.",
    ],
    panel: _Dua(
      'Dua kata',
      _Baris('Fikih', 'Pemahaman yang dalam', 'فقه'),
      _Baris('Tahawwulat', 'Perubahan-perubahan', 'التحولات'),
    ),
    penutup: [
      'Satu hal perlu diluruskan sejak awal: ilmu ini bukan ramalan. Beliau menegaskan bahwa kita tidak menyibukkan diri dengan menentukan waktu, dan tidak pula dengan menyebut nama orang atau tokoh. Yang dipelajari adalah pola perubahannya.',
    ],
    jembatan: 'Lalu, dari mana ilmu ini berasal?',
  ),
  _Bab(
    label: 'Asal-usul',
    judul: 'Bermula dari hadis Jibril',
    paragraf: [
      'Suatu hari Malaikat Jibril datang dalam rupa seorang laki-laki dan duduk di hadapan Nabi saw. Ia bertanya tentang empat hal: Islam, iman, ihsan, lalu tentang hari kiamat dan tanda-tandanya.',
      'Setelah ia pergi, Nabi saw. bersabda bahwa itu adalah Jibril yang datang untuk mengajarkan agama. Kata "agama" di sini mencakup keempat pertanyaan tadi, termasuk yang terakhir.',
      'Dari sinilah beliau menyimpulkan bahwa agama memiliki empat rukun. Tiga yang pertama sudah lama dibukukan para ulama. Rukun keempat, yaitu ilmu tentang tanda-tanda kiamat, memiliki fikihnya sendiri: Fikih Tahawwulat.',
    ],
    panel: _Daftar(
      'Empat rukun agama',
      [
        _Baris('Islam', 'Dibukukan dalam ilmu fikih', 'الإسلام'),
        _Baris('Iman', 'Dibukukan dalam ilmu akidah', 'الإيمان'),
        _Baris('Ihsan', 'Dibukukan dalam ilmu tasawuf', 'الإحسان'),
        _Baris(
            'Tanda-tanda kiamat', 'Wilayah Fikih Tahawwulat', 'علامات الساعة'),
      ],
      sorot: 3,
    ),
    jembatan:
        'Kalau tiga rukun sudah lama dipelajari, mengapa rukun keempat perlu perhatian khusus?',
  ),
  _Bab(
    label: 'Tetap dan berubah',
    judul: 'Ada yang tetap, ada yang berubah',
    paragraf: [
      'Beliau membagi ilmu tentang rukun agama menjadi dua. Islam, iman, dan ihsan adalah perkara yang tetap: tata cara salat, pokok akidah, dan halal-haram tidak berubah sampai kiamat.',
      'Rukun keempat berbicara tentang perkara yang berubah: keadaan manusia, kekuasaan, ilmu pengetahuan, dan peristiwa dari masa ke masa.',
    ],
    panel: _Dua(
      'Dua wilayah ilmu',
      _Baris('Yang tetap',
          'Islam, iman, dan ihsan. Tidak berubah sampai kiamat.', 'الثوابت'),
      _Baris('Yang berubah',
          'Rukun keempat. Membaca keadaan dari zaman ke zaman.', 'المتغيرات'),
    ),
    penutup: [
      'Masalahnya, menurut beliau, selama ini persoalan yang berubah sering dijawab dengan dalil-dalil untuk perkara yang tetap. Jawabannya pun kerap tidak tepat sasaran. Di celah inilah Fikih Tahawwulat bekerja.',
    ],
    jembatan: 'Lalu, bagaimana hubungan keduanya?',
  ),
  _Bab(
    label: 'Fungsinya',
    judul: 'Wadah yang menjaga isinya',
    paragraf: [
      'Beliau memakai perumpamaan yang mudah diingat. Tiga rukun pertama adalah isinya, yaitu amal dan ketaatan. Rukun keempat adalah wadahnya.',
      'Isi yang baik bisa rusak bila wadahnya bocor. Beliau mengingatkan, ada orang yang tampak membawa Islam, iman, dan ihsan, padahal tidak sungguh-sungguh berpegang padanya: sekadar basa-basi, berpura-pura, atau memakai agama untuk kepentingan politik.',
      'Karena itu ilmu ini memikul dua tugas.',
    ],
    panel: _Daftar('Dua tugas Fikih Tahawwulat', [
      _Baris(
          'Menjaga yang tetap',
          'Dari pengubahan orang yang berlebihan, klaim orang yang batil, dan tafsiran orang yang tidak paham',
          'صيانة الثوابت'),
      _Baris(
          'Memperbarui bahasa dakwah',
          'Agar pesan agama sampai kepada manusia di zamannya',
          'تجديد لغة الدعوة'),
    ]),
    jembatan: 'Sekarang, apa yang sebenarnya diisyaratkan rukun keempat itu?',
  ),
  _Bab(
    label: 'Dua isyarat',
    judul: 'Dua hal yang akan goyah',
    paragraf: [
      'Dalam hadis Jibril, Nabi saw. menyebut dua tanda kiamat: seorang budak perempuan melahirkan tuannya, dan para penggembala miskin tanpa alas kaki berlomba meninggikan bangunan.',
      'Beliau membaca dua tanda ini sebagai isyarat yang disampaikan jauh sebelum terjadi. Tanda pertama mengisyaratkan goyahnya urusan ilmu dan akidah. Tanda kedua mengisyaratkan rusaknya urusan kekuasaan dan ekonomi.',
    ],
    panel: _Dua(
      'Dua tanda, dua isyarat',
      _Baris('Ilmu dan akidah', '"Budak perempuan melahirkan tuannya"',
          'قرار العلم والاعتقاد'),
      _Baris(
          'Kekuasaan dan ekonomi',
          '"Penggembala berlomba meninggikan bangunan"',
          'قرار الحكم والاقتصاد'),
    ),
    penutup: [
      'Seluruh pembahasan tanda-tanda zaman, kata beliau, bermuara pada dua hal ini: bagaimana otoritas ilmu dan otoritas kekuasaan bergeser dari masa ke masa.',
    ],
    jembatan: 'Bagaimana pergeseran itu tampak dalam sejarah?',
  ),
  _Bab(
    label: 'Zaman buih',
    judul: 'Banyak, tetapi seperti buih',
    paragraf: [
      'Nabi saw. pernah mengabarkan bahwa bangsa-bangsa akan mengerumuni umat ini seperti orang-orang mengerumuni hidangan. Para sahabat bertanya, apakah karena jumlah kita sedikit?',
    ],
    panel: _Kutip(
      'Jawaban Nabi saw.',
      'لَا، أَنْتُمْ يَوْمَئِذٍ كَثِيرٌ، وَلَكِنَّكُمْ غُثَاءٌ كَغُثَاءِ السَّيْلِ',
      'Tidak. Jumlah kalian ketika itu banyak, tetapi kalian seperti buih di aliran banjir.',
    ),
    penutup: [
      'Penyebabnya adalah penyakit al-wahn: cinta dunia dan takut mati.',
      "Habib Abu Bakar menamai masa ini zaman buih (al-ghutsa'iyyah): masa ketika keputusan umat berpindah ke tangan bangsa lain melalui rangkaian perubahan yang panjang.",
    ],
    jembatan: 'Beliau membagi zaman buih ini menjadi lima babak.',
  ),
  _Bab(
    label: 'Peta sejarah',
    judul: 'Lima babak zaman buih',
    paragraf: [
      'Menurut beliau, zaman buih dimulai sejak umat kehilangan kepemimpinannya di panggung dunia. Setelah itu sejarah bergerak melalui lima babak yang saling menyambung.',
    ],
    panel: _Daftar('Lima babak', [
      _Baris(
          'Dominasi',
          'Bangsa besar menguasai revolusi industri; orientalisme menyebar',
          'الاستكبار'),
      _Baris('Penjajahan', 'Negeri muslim dijajah; sekularisme masuk',
          'الاستعمار'),
      _Baris('Sekularisasi', 'Agama makin disingkirkan dari kehidupan',
          'الاستهتار'),
      _Baris('Globalisasi', 'Dunia dipersatukan oleh pasar', 'الاستثمار'),
      _Baris(
          'Benturan',
          'Penguasa berbenturan dengan rakyat, rakyat dengan musuh dari luar',
          'الاستنفار'),
    ]),
    penutup: [
      'Peta ini dipakai untuk memahami arah, bukan untuk menebak kapan babak berikutnya tiba.',
    ],
    jembatan:
        'Di sepanjang babak itu, ada satu penyakit yang merusak dari dalam.',
  ),
  _Bab(
    label: 'Dari dalam',
    judul: 'Retak karena hal-hal kecil',
    paragraf: [
      'Kerusakan umat tidak selalu datang dari luar. Beliau menyebut bahan bakar perpecahan adalah at-tahrisy, yaitu adu domba. Ia tumbuh dari kebiasaan sehari-hari yang sering dianggap ringan.',
    ],
    panel: _Alur('Jalan menuju perpecahan', [
      'Menggunjing',
      'Membawa omongan',
      'Berdusta dan menuduh',
      'Berprasangka buruk',
      'Umat terpecah',
    ]),
    penutup: [
      'Lewat celah inilah setan mengadu domba sesama orang yang salat, sampai ilmu para ulama pun dijadikan bahan pertikaian.',
      'Karena itu beliau berkata, hari ini kita membutuhkan ilmu ini lebih dari kebutuhan kita akan air, makanan, dan obat. Sebab ilmu ini menutup celah-celah tersebut.',
    ],
    jembatan: 'Lalu, bagaimana seharusnya kita bersikap?',
  ),
  _Bab(
    label: 'Sikap',
    judul: 'Meneladani Nabi saw. dalam bersikap',
    paragraf: [
      'Beliau menunjukkan dua sunnah sebagai pegangan. Pertama, sunnah ad-dalalah: patokan syariat untuk menimbang apakah suatu sarana dakwah, termasuk yang baru, layak dipakai atau ditinggalkan. Kedua, sunnah al-mawaqif: teladan akhlak dalam mengambil sikap, terutama ketika terjadi perselisihan.',
      'Contohnya Sayyidina Hasan bin Ali. Ia melepaskan kekuasaan yang sebenarnya menjadi haknya, dan berkata bahwa ia meninggalkannya demi menjaga darah kaum muslimin.',
      'Semua itu bermuara pada satu pegangan sederhana.',
    ],
    panel: _Kutip(
      'Pegangan keselamatan',
      'سَالِمًا بِاللِّسَانِ مِنَ الذَّمِّ، وَسَالِمًا بِالْأَرْكَانِ مِنَ الدَّمِّ',
      'Lisannya selamat dari mencela, dan anggota badannya selamat dari menumpahkan darah.',
    ),
    jembatan: 'Di mana posisi kita di tengah berbagai kelompok?',
  ),
  _Bab(
    label: 'Posisi',
    judul: 'Jalan tengah dan lingkaran terdekat',
    paragraf: [
      'Beliau mengajak kita berdiri di an-namath al-awsath, jalan tengah: jalan para imam yang mulia dan orang-orang yang mengikuti adab mereka. Istilah ini diambil dari ucapan Sayyidina Ali.',
    ],
    panel: _Kutip(
      'Ucapan Sayyidina Ali',
      'خَيْرُ النَّاسِ هَذَا النَّمَطُ الْأَوْسَطُ، يَلْحَقُ بِهِمُ التَّالِي، وَيَرْجِعُ إِلَيْهِمُ الْغَالِي',
      'Sebaik-baik manusia adalah kelompok yang di tengah ini. Yang tertinggal akan menyusul mereka, dan yang berlebihan akan kembali kepada mereka.',
    ),
    penutup: [
      'Ketika fitnah sudah merata, Nabi saw. berpesan: jagalah dirimu sendiri dan tinggalkan urusan orang banyak. Dari pesan ini beliau mengajarkan al-khuwaishah: merawat lingkaran yang paling dekat dengan kita ketika keadaan umum sudah sulit diperbaiki.',
    ],
    jembatan: 'Bagaimana cara mulai mempelajarinya?',
  ),
  _Bab(
    label: 'Mulai belajar',
    judul: 'Naik setahap demi setahap',
    paragraf: [
      'Cara terbaik adalah bertahap. Mulailah dari kitab yang ringkas, lalu naik perlahan ke pembahasan yang lebih luas. Berikut urutan baca yang kami sarankan.',
    ],
    panel: _Daftar('Urutan baca', [
      _Baris('An-Nubdzah ash-Shughra', 'Ringkas, disusun beliau untuk pemula',
          'النبذة الصغرى'),
      _Baris('Al-Usus wal-Munthalaqat', 'Definisi, dasar-dasar, dan peta zaman',
          'الأسس والمنطلقات'),
      _Baris('Al-Iqlid', 'Lima cabang ilmu ini', 'الإقليد'),
      _Baris('Al-Marshad an-Nabawi', 'Pembahasan yang luas, empat juz',
          'المرصد النبوي'),
    ]),
    jembatan: 'Anda juga bisa belajar sambil bertanya.',
  ),
  _Bab(
    label: 'Belajar bersama AI',
    judul: 'Lima AI, satu sumber',
    paragraf: [
      'Kelima AI Fikih Tahawwulat membaca kitab dan muhadharah beliau yang sama. Bedanya ada pada cara membantu. Kalau baru mulai, cobalah Al-Bayan.',
    ],
    limaAi: true,
  ),
];

class _Ruang {
  const _Ruang(this.id, this.nama, this.arab, this.untuk);
  final String id;
  final String nama;
  final String arab;
  final String untuk;
}

const _ruang = [
  _Ruang('fiqh_tahawwulat_bayan', 'Al-Bayan', 'البيان',
      'Penjelasan sederhana dan perumpamaan'),
  _Ruang('fiqh_tahawwulat_muhaqqiq', 'Al-Muhaqqiq', 'المحقق',
      'Ibarah asli lengkap dengan kitab dan halaman'),
  _Ruang('fiqh_tahawwulat_mukhtabir', 'Al-Mukhtabir', 'المختبر',
      'Menguji pemahaman lewat tanya jawab'),
  _Ruang('fiqh_tahawwulat_habib', 'Al-Habib', 'الحبيب',
      'Menelusuri muhadharah beliau'),
  _Ruang('fiqh_tahawwulat_khatib', 'Al-Khatib', 'الخطيب',
      'Menyusun khutbah dan materi dakwah'),
];

// ── Layar ──────────────────────────────────────────────────────────────────

class _TahawwulatIntroductionSheetState
    extends State<TahawwulatIntroductionSheet> {
  late int _i = widget.initialSection.clamp(0, _bab.length - 1);
  late final PageController _page = PageController(initialPage: _i);
  final FocusNode _fokus = FocusNode();

  @override
  void dispose() {
    _page.dispose();
    _fokus.dispose();
    super.dispose();
  }

  void _ke(int i) {
    if (i < 0 || i >= _bab.length) return;
    _page.animateToPage(i,
        duration: OTMotion.transition, curve: OTMotion.curve);
  }

  KeyEventResult _tombol(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
      _ke(_i + 1);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _ke(_i - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isi = Focus(
      focusNode: _fokus,
      autofocus: true,
      onKeyEvent: _tombol,
      child: Column(children: [
        _kemajuan(isDark),
        Expanded(
          child: PageView.builder(
            controller: _page,
            itemCount: _bab.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (ctx, i) => _halaman(ctx, i, isDark),
          ),
        ),
        _bawah(isDark),
      ]),
    );
    final badan = Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640), child: isi),
    );
    if (widget.asPage) {
      return Scaffold(
        backgroundColor: OTColors.canvas(isDark),
        appBar: AppBar(
          backgroundColor: OTColors.canvas(isDark),
          title: const Text('Mengenal Fikih Tahawwulat'),
        ),
        body: SafeArea(child: badan),
      );
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
          color: OTColors.canvas(isDark), borderRadius: OTRadius.sheetBorder),
      child: SafeArea(top: false, child: badan),
    );
  }

  Widget _kemajuan(bool isDark) => Padding(
        padding: const EdgeInsets.fromLTRB(
            OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.xs),
        child: Row(children: [
          for (var k = 0; k < _bab.length; k++)
            Expanded(
              child: Semantics(
                label: 'Bab ${k + 1}: ${_bab[k].label}',
                button: true,
                selected: k == _i,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _ke(k),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.xxs, vertical: OTSpacing.sm),
                    child: AnimatedContainer(
                      duration: OTMotion.normal,
                      height: 2,
                      color: k <= _i
                          ? OTColors.textPrimary(isDark)
                          : OTColors.border(isDark),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      );

  TextStyle _kepala(bool isDark) => ScholarlyFonts.outfit(
      fontSize: OTFontSize.s11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
      color: OTColors.textSecondary(isDark));

  Widget _halaman(BuildContext context, int i, bool isDark) {
    final b = _bab[i];
    final ink = OTColors.textPrimary(isDark);
    final teks = ScholarlyFonts.outfit(
        fontSize: OTFontSize.s16, height: 1.7, color: ink);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.lg, OTSpacing.base, OTSpacing.lg, OTSpacing.xxl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (i == 0)
          _sampul(isDark)
        else ...[
          Text(
              'BAB ${i.toString().padLeft(2, '0')}  ·  ${b.label.toUpperCase()}',
              style: _kepala(isDark)),
          const SizedBox(height: OTSpacing.sm),
          Text(b.judul,
              style: ScholarlyFonts.newsreader(
                  fontSize: OTFontSize.s26, height: 1.2, color: ink)),
        ],
        const SizedBox(height: OTSpacing.base),
        for (final p in b.paragraf) ...[
          Text(p, style: teks),
          const SizedBox(height: OTSpacing.md),
        ],
        if (b.panel != null) ...[
          const SizedBox(height: OTSpacing.xs),
          _panel(b.panel!, isDark),
          const SizedBox(height: OTSpacing.base),
        ],
        for (final p in b.penutup) ...[
          Text(p, style: teks),
          const SizedBox(height: OTSpacing.md),
        ],
        if (b.limaAi) ...[
          const SizedBox(height: OTSpacing.xs),
          _limaAi(context, isDark),
        ],
        if (b.jembatan.isNotEmpty) ...[
          const SizedBox(height: OTSpacing.sm),
          Divider(height: 1, color: OTColors.borderSubtle(isDark)),
          InkWell(
            onTap: () => _ke(i + 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: OTSpacing.base),
              child: Row(children: [
                Expanded(
                  child: Text(b.jembatan,
                      style: ScholarlyFonts.newsreader(
                          fontSize: OTFontSize.s18,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          color: OTColors.textSecondary(isDark))),
                ),
                const SizedBox(width: OTSpacing.md),
                Icon(Icons.arrow_forward_rounded,
                    size: OTFontSize.s18, color: ink),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  /// Kartu pembuka bergaya kartu koleksi utama: permukaan terbalik.
  Widget _sampul(bool isDark) {
    const fg = OTColors.onInverseSurface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OTSpacing.xl),
      decoration: BoxDecoration(
          color: OTColors.inverseSurface(isDark),
          borderRadius: OTRadius.cardBorder),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: OTSpacing.md, vertical: OTSpacing.xs),
          decoration:
              BoxDecoration(color: fg, borderRadius: OTRadius.chipBorder),
          child: Text('Pengantar · ${_bab.length - 1} bab',
              style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s11,
                  fontWeight: FontWeight.w600,
                  color: OTColors.inverseSurface(isDark))),
        ),
        const SizedBox(height: OTSpacing.lg),
        Text('Mengenal\nFikih Tahawwulat',
            style: ScholarlyFonts.newsreader(
                fontSize: OTFontSize.s36, height: 1.1, color: fg)),
        const SizedBox(height: OTSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: Text('فقه التحولات',
              textDirection: TextDirection.rtl,
              style: ScholarlyFonts.scheherazadeNew(
                  fontSize: OTFontSize.s26, color: fg.withValues(alpha: 0.72))),
        ),
      ]),
    );
  }

  Widget _wadahPanel(String kepala, Widget isi, bool isDark) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: OTColors.surface(isDark),
            border: Border.all(color: OTColors.border(isDark)),
            borderRadius: OTRadius.cardBorder),
        padding: const EdgeInsets.fromLTRB(
            OTSpacing.base, OTSpacing.base, OTSpacing.base, OTSpacing.sm),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(kepala.toUpperCase(), style: _kepala(isDark)),
          const SizedBox(height: OTSpacing.sm),
          isi,
        ]),
      );

  Widget _nomor(int n, bool isDark, {bool sorot = false}) => Container(
        width: OTSpacing.xxl,
        height: OTSpacing.xxl,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: sorot
                ? OTColors.textPrimary(isDark)
                : OTColors.surfaceSubtle(isDark),
            borderRadius: OTRadius.xsBorder),
        child: Text(n.toString().padLeft(2, '0'),
            style: ScholarlyFonts.outfit(
                textStyle: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()]),
                fontSize: OTFontSize.s12,
                fontWeight: FontWeight.w600,
                color: sorot
                    ? OTColors.onAccent(isDark)
                    : OTColors.textPrimary(isDark))),
      );

  Widget _arab(String s, bool isDark, {double ukuran = OTFontSize.s18}) =>
      Text(s,
          textDirection: TextDirection.rtl,
          style: ScholarlyFonts.scheherazadeNew(
              fontSize: ukuran, color: OTColors.textPrimary(isDark)));

  Widget _panel(_Panel p, bool isDark) {
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    switch (p) {
      case _Daftar():
        return _wadahPanel(
            p.kepala,
            Column(children: [
              for (var k = 0; k < p.isi.length; k++) ...[
                if (k > 0)
                  Divider(height: 1, color: OTColors.borderSubtle(isDark)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
                  child: Row(children: [
                    _nomor(k + 1, isDark, sorot: k == p.sorot),
                    const SizedBox(width: OTSpacing.md),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.isi[k].judul,
                                style: ScholarlyFonts.outfit(
                                    fontSize: OTFontSize.s14,
                                    fontWeight: FontWeight.w600,
                                    color: ink)),
                            if (p.isi[k].ket.isNotEmpty) ...[
                              const SizedBox(height: OTSpacing.xxs),
                              Text(p.isi[k].ket,
                                  style: ScholarlyFonts.outfit(
                                      fontSize: OTFontSize.s12,
                                      height: 1.45,
                                      color: muted)),
                            ],
                          ]),
                    ),
                    if (p.isi[k].arab.isNotEmpty) ...[
                      const SizedBox(width: OTSpacing.md),
                      _arab(p.isi[k].arab, isDark),
                    ],
                  ]),
                ),
              ],
            ]),
            isDark);
      case _Dua():
        Widget kolom(_Baris b) => Expanded(
              child: Container(
                padding: const EdgeInsets.all(OTSpacing.md),
                decoration: BoxDecoration(
                    color: OTColors.surfaceSubtle(isDark),
                    borderRadius: OTRadius.xsBorder),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.centerRight,
                          child: _arab(b.arab, isDark, ukuran: OTFontSize.s20)),
                      const SizedBox(height: OTSpacing.sm),
                      Text(b.judul,
                          style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s14,
                              fontWeight: FontWeight.w600,
                              color: ink)),
                      const SizedBox(height: OTSpacing.xxs),
                      Text(b.ket,
                          style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s12,
                              height: 1.45,
                              color: muted)),
                    ]),
              ),
            );
        return _wadahPanel(
            p.kepala,
            Padding(
              padding: const EdgeInsets.only(bottom: OTSpacing.sm),
              child: IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      kolom(p.kiri),
                      const SizedBox(width: OTSpacing.sm),
                      kolom(p.kanan),
                    ]),
              ),
            ),
            isDark);
      case _Kutip():
        return _wadahPanel(
            p.kepala,
            Padding(
              padding: const EdgeInsets.only(bottom: OTSpacing.sm),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _arab(p.arab, isDark, ukuran: OTFontSize.s22),
                    const SizedBox(height: OTSpacing.sm),
                    Divider(height: 1, color: OTColors.borderSubtle(isDark)),
                    const SizedBox(height: OTSpacing.sm),
                    Text(p.makna,
                        style: ScholarlyFonts.newsreader(
                            fontSize: OTFontSize.s16,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                            color: ink)),
                  ]),
            ),
            isDark);
      case _Alur():
        final akhir = p.isi.length - 1;
        return _wadahPanel(
            p.kepala,
            Padding(
              padding: const EdgeInsets.only(bottom: OTSpacing.sm),
              child: Column(children: [
                for (var k = 0; k < p.isi.length; k++) ...[
                  if (k > 0)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: OTSpacing.xxs),
                      child: Icon(Icons.south_rounded,
                          size: OTFontSize.s14,
                          color: OTColors.textTertiary(isDark)),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.md, vertical: OTSpacing.sm),
                    decoration: BoxDecoration(
                        color: k == akhir
                            ? OTColors.textPrimary(isDark)
                            : OTColors.surfaceSubtle(isDark),
                        borderRadius: OTRadius.xsBorder),
                    child: Text(p.isi[k],
                        textAlign: TextAlign.center,
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s14,
                            fontWeight:
                                k == akhir ? FontWeight.w600 : FontWeight.w400,
                            color:
                                k == akhir ? OTColors.onAccent(isDark) : ink)),
                  ),
                ],
              ]),
            ),
            isDark);
    }
  }

  Widget _bawah(bool isDark) {
    final akhir = _i == _bab.length - 1;
    return Container(
      decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: OTColors.borderSubtle(isDark)))),
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, OTSpacing.md),
      child: Row(children: [
        IconButton(
          tooltip: 'Sebelumnya',
          onPressed: _i == 0 ? null : () => _ke(_i - 1),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: OTSpacing.xs),
        Text('${_i + 1} / ${_bab.length}',
            style: ScholarlyFonts.outfit(
                textStyle: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()]),
                fontSize: OTFontSize.s12,
                color: OTColors.textSecondary(isDark))),
        const Spacer(),
        FilledButton(
          onPressed: akhir
              ? () => Navigator.of(context).maybePop()
              : () => _ke(_i + 1),
          child: Text(akhir
              ? 'Selesai'
              : _i == 0
                  ? 'Mulai membaca'
                  : 'Lanjut'),
        ),
      ]),
    );
  }

  Widget _limaAi(BuildContext context, bool isDark) {
    final subs = widget.agent?.subAgents ?? const <SubAgentModel>[];
    final ink = OTColors.textPrimary(isDark);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _wadahPanel(
          '5 AI dalam satu paket',
          Column(children: [
            for (var k = 0; k < _ruang.length; k++) ...[
              if (k > 0)
                Divider(height: 1, color: OTColors.borderSubtle(isDark)),
              InkWell(
                onTap: widget.onSelectSubAgent == null
                    ? null
                    : () {
                        final r = _ruang[k];
                        final sub = subs.firstWhere((s) => s.id == r.id,
                            orElse: () => SubAgentModel(
                                id: r.id,
                                name: r.nama,
                                nameArabic: r.arab,
                                description: r.untuk,
                                descriptionArabic: r.arab,
                                emoji: '📖',
                                badge: r.nama));
                        Navigator.of(context).pop();
                        widget.onSelectSubAgent!(sub);
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
                  child: Row(children: [
                    _nomor(k + 1, isDark),
                    const SizedBox(width: OTSpacing.md),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Loc.isArabic ? _ruang[k].arab : _ruang[k].nama,
                                style: ScholarlyFonts.outfit(
                                    fontSize: OTFontSize.s14,
                                    fontWeight: FontWeight.w600,
                                    color: ink)),
                            const SizedBox(height: OTSpacing.xxs),
                            Text(_ruang[k].untuk,
                                style: ScholarlyFonts.outfit(
                                    fontSize: OTFontSize.s12,
                                    color: OTColors.textSecondary(isDark))),
                          ]),
                    ),
                    const SizedBox(width: OTSpacing.md),
                    _arab(_ruang[k].arab, isDark),
                  ]),
                ),
              ),
            ],
          ]),
          isDark),
      if (widget.onOpenMain != null) ...[
        const SizedBox(height: OTSpacing.base),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onOpenMain!();
          },
          child: const Text('Mulai bertanya'),
        ),
      ],
    ]);
  }
}
