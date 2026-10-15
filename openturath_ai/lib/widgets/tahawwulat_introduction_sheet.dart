import 'package:flutter/material.dart';

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

/// Pengantar Fikih Tahawwulat untuk orang yang baru pertama kali mendengarnya.
///
/// Setiap kutipan diambil dari kitab Al-Habib Abu Bakar al-'Adni bin Ali
/// al-Masyhur dalam notebook 06 (OUTPUT_V9_2) dan dicek kitab serta
/// halamannya pada 15 Oktober 2026. Teks penjelasan adalah ringkasan dari
/// kutipan-kutipan itu, bukan pendapat baru.
class TahawwulatIntroductionSheet extends StatefulWidget {
  final AgentModel? agent;
  final void Function(SubAgentModel subAgent)? onSelectSubAgent;
  final VoidCallback? onOpenMain;

  /// Halaman baca penuh dengan AppBar; false = lembar bawah.
  final bool asPage;

  /// Bab yang dibuka pertama; 0 menampilkan semua bab.
  final int initialSection;

  const TahawwulatIntroductionSheet({
    super.key,
    this.agent,
    this.onSelectSubAgent,
    this.onOpenMain,
    this.asPage = true,
    this.initialSection = 0,
  });

  /// Desktop: halaman baca penuh. Ponsel: lembar bawah.
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

class _Kutipan {
  const _Kutipan(this.arab, this.makna, this.sumber);
  final String arab;
  final String makna;
  final String sumber;
}

class _Butir {
  const _Butir(this.judul, this.isi, {this.arab = ''});
  final String judul;
  final String arab;
  final String isi;
}

class _Bab {
  const _Bab({
    required this.tab,
    required this.judul,
    required this.inti,
    this.paragraf = const [],
    this.butir = const [],
    this.kutipan = const [],
    this.catatan = '',
    this.lima = false,
  });
  final String tab;
  final String judul;
  final String inti;
  final List<String> paragraf;
  final List<_Butir> butir;
  final List<_Kutipan> kutipan;
  final String catatan;
  final bool lima;
}

const _asas = 'الأسس والمنطلقات';
const _iqlid = 'الإقليد في فتح أبواب العلوم الخمسة المرتبطة بفقه التحولات التليد';
const _ihya = 'إحياء لغة الإسلام العالمية';

const List<_Bab> _bab = [
  _Bab(
    tab: 'Pengertian',
    judul: 'Apa itu Fikih Tahawwulat?',
    inti:
        'Ilmu untuk memahami perubahan zaman dengan petunjuk Al-Qur\'an dan Sunnah.',
    paragraf: [
      'Fiqh artinya pemahaman yang mendalam. Tahawwulat artinya perubahan-perubahan. Jadi Fikih Tahawwulat adalah pemahaman yang mendalam tentang perubahan yang dialami manusia, sejak Nabi Adam sampai hari kiamat.',
      'Ilmu ini disusun oleh Al-Habib Abu Bakar al-\'Adni bin Ali al-Masyhur (w. 1443 H). Bahan pokoknya adalah ayat dan hadis tentang tanda-tanda kiamat, ditambah cara para ulama mengelompokkan tanda-tanda itu.',
    ],
    kutipan: [
      _Kutipan(
        'فقه التحولات هو الفقه المؤصل من الكتاب والسنة لدراسة كافة شؤون التحول في الحياة البشرية من عهد آدم إلى يوم البعث والنشور',
        'Fikih Tahawwulat adalah fikih yang berpijak pada Al-Qur\'an dan Sunnah untuk mempelajari seluruh perubahan dalam kehidupan manusia, sejak masa Nabi Adam hingga hari kebangkitan.',
        '$_asas، ص ٣١',
      ),
    ],
  ),
  _Bab(
    tab: 'Kenapa penting',
    judul: 'Kenapa ilmu ini dibutuhkan?',
    inti:
        'Agar yang tetap dalam agama terjaga, dan yang berubah di zaman ini dipahami dengan benar.',
    paragraf: [
      'Ada ajaran agama yang tetap, seperti salat dan akidah. Ada juga keadaan yang terus berubah: cara orang hidup, berkuasa, dan berinteraksi. Menurut Al-Habib Abu Bakar, umat sering menangani keadaan yang berubah itu hanya dengan dalil-dalil tentang hal yang tetap, sehingga jawabannya sering tidak tepat sasaran.',
      'Fikih Tahawwulat hadir untuk mengisi celah itu: memperbarui cara berdakwah, sambil menjaga ajaran yang tetap tidak ikut goyah.',
    ],
    kutipan: [
      _Kutipan(
        'ظل المسلمون يعالجون قضايا المتغيرات بنصوص الثوابت وما تفرع عنها',
        'Kaum muslimin terus menangani persoalan yang berubah dengan dalil-dalil tentang hal yang tetap beserta turunannya.',
        '$_iqlid، ص ١٨',
      ),
      _Kutipan(
        'العلم الذي يعنى بتجديد لغة الدعوة إلى الله وبصيانة فقه الثوابت',
        'Ilmu yang memperbarui bahasa dakwah kepada Allah dan menjaga fikih tentang hal-hal yang tetap.',
        '$_iqlid، ص ٩',
      ),
    ],
  ),
  _Bab(
    tab: 'Dasarnya',
    judul: 'Dasarnya: rukun agama yang keempat',
    inti:
        'Hadis Jibril menyebut Islam, iman, ihsan, lalu tanda-tanda kiamat. Yang keempat inilah wilayah Fikih Tahawwulat.',
    paragraf: [
      'Dalam hadis Jibril yang masyhur, Malaikat Jibril bertanya kepada Nabi saw. tentang Islam, iman, ihsan, lalu tentang hari kiamat dan tanda-tandanya. Al-Habib Abu Bakar menyebut ilmu tentang tanda-tanda kiamat ini sebagai rukun agama yang keempat.',
      'Isi rukun keempat adalah hadis-hadis Nabi saw. tentang tanda-tanda kiamat. Beliau membaginya menjadi tiga jenis: tanda-tanda (al-\'alamat), pertanda besar dan peperangan (al-asyrath wal-malahim), serta fitnah-fitnah yang menyesatkan (al-fitan).',
    ],
    kutipan: [
      _Kutipan(
        'الركن الرابع يحمل فقها خاصا به يسمى «فقه التحولات» ومادته العلمية هي مجموع الأحاديث الشريفة التي نطق بها خير الورى صلى الله عليه وآله وصحبه وسلم عن مظاهر علامات الساعة',
        'Rukun keempat memiliki fikih tersendiri bernama Fikih Tahawwulat. Bahannya adalah kumpulan hadis Nabi saw. tentang tanda-tanda kiamat.',
        '$_ihya، ص ٨٢',
      ),
    ],
  ),
  _Bab(
    tab: 'Dua keruntuhan',
    judul: 'Dua hal yang runtuh lebih dulu',
    inti:
        'Dua tanda dalam hadis Jibril dibaca sebagai runtuhnya otoritas ilmu dan otoritas kekuasaan.',
    paragraf: [
      'Ketika ditanya tentang tanda-tanda kiamat, Nabi saw. menyebut dua hal. Al-Habib Abu Bakar menghubungkan masing-masing dengan sebuah keruntuhan dan dengan hadis lain yang menjelaskannya:',
    ],
    butir: [
      _Butir(
        'Runtuhnya otoritas ilmu dan akidah',
        'Tanda: «budak perempuan melahirkan tuannya». Hadis penjelasnya: «apabila amanah disia-siakan».',
        arab: 'نقض قرار العلم والاعتقاد',
      ),
      _Butir(
        'Runtuhnya otoritas kekuasaan dan ekonomi',
        'Tanda: «para penggembala yang tak beralas kaki saling meninggikan bangunan». Hadis penjelasnya: «apabila urusan diserahkan kepada yang bukan ahlinya».',
        arab: 'نقض قرار الحكم والاقتصاد',
      ),
    ],
    kutipan: [
      _Kutipan(
        'لتنقضن عرى الإسلام عروة عروة، كلما نقضت عروة تمسك الناس بالتي تليها، أولهن نقضا الحكم وآخرهن الصلاة',
        'Ikatan-ikatan Islam akan terlepas satu demi satu. Setiap kali satu terlepas, orang berpegang pada yang berikutnya. Yang pertama terlepas adalah urusan pemerintahan, dan yang terakhir adalah salat.',
        '$_iqlid، ص ١٢',
      ),
    ],
  ),
  _Bab(
    tab: 'Peta zaman',
    judul: 'Peta perjalanan zaman',
    inti:
        'Sejak runtuhnya kepemimpinan umat, beliau memetakan lima marhalah zaman buih (al-ghutsa\'iyyah).',
    paragraf: [
      'Al-Ghutsa\'iyyah berasal dari kata ghutsa\', yaitu buih: tampak banyak, tetapi ringan dan mudah terbawa arus. Nabi saw. menggambarkan umat di akhir zaman seperti buih, banyak jumlahnya tetapi lemah. Dalam diagram kitab al-Asas wal-Munthalaqat, masa ini dibagi menjadi lima marhalah:',
    ],
    butir: [
      _Butir('1. Al-Istikbar wal-Istizhhar',
          'Kekuatan besar dunia menguasai sebab-sebab revolusi industri, dan gerakan orientalisme menyebar.',
          arab: 'مرحلة الاستكبار والاستظهار'),
      _Butir('2. Al-Isti\'mar', 'Masa penjajahan, disertai paham sekularisme.',
          arab: 'مرحلة الاستعمار'),
      _Butir('3. Al-Istihtar',
          'Masa ketika nilai agama diremehkan dan kehidupan dijauhkan dari agama.',
          arab: 'مرحلة الاستهتار'),
      _Butir('4. Al-Istitsmar', 'Masa globalisasi.', arab: 'مرحلة الاستثمار'),
      _Butir('5. Al-Istinfar: Ash-Shaylam',
          'Puncak masa buih: pertentangan penguasa dengan rakyat, lalu rakyat dengan musuh agama.',
          arab: 'مرحلة الاستنفار: الصيلمة'),
    ],
    catatan:
        'Sesudah lima marhalah itu, diagram yang sama menyebut masa Imam Mahdi, masa Dajjal, masa Nabi Isa, masa Ya\'juj dan Ma\'juj, terputusnya tauhid, lalu hari kiamat. Beliau mengingatkan agar kita tidak sibuk menebak waktu dan menunjuk orang.',
    kutipan: [
      _Kutipan(
        'مراحل الغثائية الموعودة منذ سقوط القرار العالمي حتى نهاية الحياة',
        'Marhalah-marhalah zaman buih yang dijanjikan, sejak runtuhnya kepemimpinan umat di dunia sampai akhir kehidupan.',
        '$_asas، ص ٢٠٧',
      ),
      _Kutipan(
        'عدم انشغالنا بالزمن وتحديده، ولا بالأفراد والشخوص وذكرهم؛ فإننا نلاحق المراحل من خلال الاستقراء العام عن التحولات',
        'Kami tidak menyibukkan diri dengan menentukan waktu, atau dengan menyebut individu dan tokoh. Kami mengikuti marhalah-marhalah itu melalui pengamatan umum atas perubahan.',
        '$_asas، ص ٢٤٨',
      ),
    ],
  ),
  _Bab(
    tab: 'Istilah kunci',
    judul: 'Istilah yang akan sering Anda temui',
    inti: 'Beberapa istilah ini menjadi pintu untuk membaca kitab-kitab beliau.',
    butir: [
      _Butir('Al-Wahn',
          'Kelemahan jiwa umat. Nabi saw. menjelaskannya: «cinta dunia dan benci kematian» (Ihya\' Lughat al-Islam al-\'Alamiyyah, hlm. 98).',
          arab: 'الوهن'),
      _Butir('At-Tahrisy',
          'Adu domba di antara sesama. Menurut beliau, bahannya adalah ghibah, namimah, dusta, fitnah, buruk sangka, memata-matai, dan saling memberi julukan buruk (al-Iqlid, hlm. 23).',
          arab: 'التحريش'),
      _Butir('An-Nawaqidh wan-Naqa\'idh',
          'Hal-hal yang meruntuhkan tatanan Islam dari dalam, beserta pertentangan yang menyesatkan; cabang pertama ilmu ini membahasnya bersama cara menjaga diri darinya (al-Iqlid, hlm. 11).',
          arab: 'النواقض والنقائض'),
      _Butir('Sunnah ad-Dalalah',
          'Sunnah yang menjadi petunjuk untuk menetapkan hukum hal-hal baru yang belum ada di masa Nabi saw. dan para sahabat (Ihya\' Lughat al-Islam al-\'Alamiyyah, hlm. 83).',
          arab: 'سنة الدلالة'),
      _Butir('Sunnah al-Mawaqif',
          'Sunnah dalam bersikap: penerapan akhlak dalam berdakwah, termasuk cara para ulama bergaul dengan yang berbeda pendapat (al-Asas wal-Munthalaqat, hlm. 94).',
          arab: 'سنة المواقف'),
      _Butir('An-Namath al-Awsath',
          'Jalan tengah, yaitu sikap para imam yang mulia dan orang-orang yang mengikuti jejak serta adab mereka (Ihya\' Manhajiyyat an-Namath al-Awsath, hlm. 78).',
          arab: 'النمط الأوسط'),
      _Butir('Al-Abuwwah asy-Syar\'iyyah',
          'Kebapakan syar\'i: ikatan murid dengan para nabi dan ulama. Syaratnya mengikuti manhaj dan menunaikan janji (Ihya\' Lughat al-Islam al-\'Alamiyyah, hlm. 66).',
          arab: 'الأبوة الشرعية'),
      _Butir('Al-Khuwaishah',
          'Dari sabda Nabi saw. «hendaklah engkau menjaga dirimu sendiri». Maknanya, menjaga diri dan lingkaran terdekat, serta mencari tempat berlindung dari fitnah (al-Asas wal-Munthalaqat, hlm. 81).',
          arab: 'الخويصة'),
    ],
  ),
  _Bab(
    tab: 'Lima cabang',
    judul: 'Lima cabang ilmunya',
    inti: 'Dalam kitab al-Iqlid, beliau membagi Fikih Tahawwulat menjadi lima cabang ilmu.',
    butir: [
      _Butir('1. Fikih an-Nawaqidh wan-Naqa\'idh',
          'Hal-hal yang meruntuhkan, fitnah yang menyesatkan, dan sebab-sebab terjaga darinya.'),
      _Butir('2. Fikih al-Isyarat wal-Bisyarat',
          'Isyarat, kabar gembira, peringatan, perlindungan, serta kemuliaan keadilan dan sanad.'),
      _Butir('3. Fikih al-Mustajaddat',
          'Ilmu dan budaya baru, baik teori maupun penerapannya, yang bermanfaat maupun yang merugikan.'),
      _Butir('4. Fikih al-Asyrath al-Kauniyyah wal-Malahim',
          'Tanda-tanda kiamat yang bersifat alam semesta dan peperangan besar.'),
      _Butir('5. Fikih ar-Rabth asy-Syar\'i',
          'Menghubungkan agama dengan sejarah secara syar\'i.'),
    ],
    kutipan: [
      _Kutipan(
        'فقه النواقض والنقائض ومضلات الفتن وأسباب الوقاية منها',
        'Fikih tentang hal-hal yang meruntuhkan, pertentangan, fitnah yang menyesatkan, dan sebab-sebab terjaga darinya.',
        '$_iqlid، ص ١١',
      ),
    ],
  ),
  _Bab(
    tab: 'Sikap',
    judul: 'Sikap yang diajarkan',
    inti: 'Ilmu ini bukan untuk menakut-nakuti, tetapi untuk bersikap tenang dan tepat.',
    paragraf: [
      'Dari penjelasan-penjelasan di atas, ada beberapa sikap yang beliau tekankan:',
    ],
    butir: [
      _Butir('Tidak menebak waktu dan menunjuk orang',
          'Perhatikan pola perubahan secara umum, bukan meramal tanggal atau mencocokkan tokoh tertentu.'),
      _Butir('Menjauhi adu domba',
          'Ghibah, namimah, dusta, dan buruk sangka adalah bahan bakar perpecahan.'),
      _Butir('Menjaga diri dan keluarga',
          'Ketika fitnah merata, mulailah dari lingkaran terdekat: diri sendiri, keluarga, dan komunitas kecil.'),
      _Butir('Mengikuti jalan tengah',
          'Berpegang pada sikap para imam dan ulama yang beradab, serta santun kepada yang berbeda pendapat.'),
    ],
  ),
  _Bab(
    tab: 'Mulai belajar',
    judul: 'Mulai dari mana?',
    inti: 'Saran urutan membaca dari OpenTurath, dari yang paling ringkas.',
    butir: [
      _Butir('1. An-Nubdzah ash-Shughra',
          'Ringkasan bertahap dalam bentuk pelajaran: definisi, lima cabang ilmu, dan peta strukturnya.',
          arab: 'النبذة الصغرى'),
      _Butir('2. Al-Asas wal-Munthalaqat',
          'Definisi, dasar, dan peta marhalah zaman.',
          arab: 'الأسس والمنطلقات'),
      _Butir('3. Al-Iqlid', 'Lima cabang ilmu Fikih Tahawwulat.',
          arab: 'الإقليد'),
      _Butir('4. Ihya\' Lughat al-Islam al-\'Alamiyyah',
          'Rukun keempat, sunnah ad-dalalah, dan sunnah al-mawaqif.',
          arab: 'إحياء لغة الإسلام العالمية'),
      _Butir('5. Al-Marshad an-Nabawi', 'Pembahasan yang lebih luas, dalam empat juz.',
          arab: 'المرصد النبوي'),
    ],
    catatan:
        'Urutan ini saran dari tim OpenTurath, bukan ketetapan penyusun kitab. Untuk mendengar langsung penjelasan beliau, gunakan Al-Habib, yang menelusuri ribuan muhadharah beliau.',
  ),
  _Bab(
    tab: 'Lima AI',
    judul: 'Belajar bersama lima AI',
    inti: 'Kelimanya membaca sumber yang sama, dengan cara membantu yang berbeda.',
    lima: true,
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
      'Untuk yang baru mulai. Menjelaskan istilah dengan bahasa sederhana dan perumpamaan.'),
  _Ruang('fiqh_tahawwulat_muhaqqiq', 'Al-Muhaqqiq', 'المحقق',
      'Untuk riset. Menunjukkan ibarah asli lengkap dengan kitab dan halamannya.'),
  _Ruang('fiqh_tahawwulat_habib', 'Al-Habib', 'الحبيب',
      'Menelusuri muhadharah beliau: judul, kutipan, dan tautan ke menit yang tepat.'),
  _Ruang('fiqh_tahawwulat_mukhtabir', 'Al-Mukhtabir', 'المختبر',
      'Menguji pemahaman Anda dengan soal dan pembahasan yang bersumber.'),
  _Ruang('fiqh_tahawwulat_khatib', 'Al-Khatib', 'الخطيب',
      'Membantu menyusun khutbah, ceramah, dan materi dakwah yang bersumber.'),
];

class _TahawwulatIntroductionSheetState
    extends State<TahawwulatIntroductionSheet> {
  late int _pilih = widget.initialSection.clamp(0, _bab.length);
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _pilihBab(int i) {
    setState(() => _pilih = i);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daftar = _pilih == 0 ? _bab : [_bab[_pilih - 1]];
    final isi = Column(children: [
      _chips(isDark),
      Expanded(
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(
              OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, OTSpacing.huge),
          children: [
            if (_pilih == 0) _pembuka(isDark),
            for (final b in daftar) _babWidget(context, b, isDark),
          ],
        ),
      ),
    ]);
    if (widget.asPage) {
      return Scaffold(
        backgroundColor: OTColors.canvas(isDark),
        appBar: AppBar(
          backgroundColor: OTColors.canvas(isDark),
          title: const Text('Mengenal Fikih Tahawwulat'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720), child: isi),
          ),
        ),
      );
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
          color: OTColors.canvas(isDark), borderRadius: OTRadius.sheetBorder),
      child: Column(children: [
        const SizedBox(height: OTSpacing.md),
        Text('Mengenal Fikih Tahawwulat',
            style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s16,
                fontWeight: FontWeight.w600,
                color: OTColors.textPrimary(isDark))),
        const SizedBox(height: OTSpacing.sm),
        Expanded(child: isi),
      ]),
    );
  }

  Widget _chips(bool isDark) {
    final label = ['Semua', for (final b in _bab) b.tab];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
        itemCount: label.length,
        separatorBuilder: (_, __) => const SizedBox(width: OTSpacing.sm),
        itemBuilder: (_, i) => Center(
          child: ChoiceChip(
            label: Text(label[i]),
            selected: _pilih == i,
            onSelected: (_) => _pilihBab(i),
          ),
        ),
      ),
    );
  }

  Widget _pembuka(bool isDark) => Padding(
        padding: const EdgeInsets.only(top: OTSpacing.base),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('فقه التحولات',
              textDirection: TextDirection.rtl,
              style: ScholarlyFonts.scheherazadeNew(
                  fontSize: OTFontSize.s36,
                  color: OTColors.textPrimary(isDark))),
          const SizedBox(height: OTSpacing.sm),
          Text(
              'Pengantar singkat untuk Anda yang baru pertama kali mendengar ilmu ini. Bacalah berurutan, atau pilih bab di atas.',
              style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s16,
                  height: 1.6,
                  color: OTColors.textSecondary(isDark))),
        ]),
      );

  Widget _babWidget(BuildContext context, _Bab b, bool isDark) {
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final body = ScholarlyFonts.outfit(
        fontSize: OTFontSize.s16, height: 1.7, color: ink);
    return Padding(
      padding: const EdgeInsets.only(top: OTSpacing.xxl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(b.judul,
            style: ScholarlyFonts.newsreader(
                fontSize: OTFontSize.s26, color: ink)),
        const SizedBox(height: OTSpacing.sm),
        Text(b.inti,
            style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s16,
                fontWeight: FontWeight.w600,
                height: 1.55,
                color: ink)),
        for (final p in b.paragraf) ...[
          const SizedBox(height: OTSpacing.md),
          Text(p, style: body),
        ],
        if (b.butir.isNotEmpty) ...[
          const SizedBox(height: OTSpacing.base),
          for (final x in b.butir) _butirWidget(x, isDark),
        ],
        if (b.catatan.isNotEmpty) ...[
          const SizedBox(height: OTSpacing.sm),
          Text(b.catatan,
              style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14, height: 1.6, color: muted)),
        ],
        for (final k in b.kutipan) _kutipanWidget(k, isDark),
        if (b.lima) _limaAi(context, isDark),
      ]),
    );
  }

  Widget _butirWidget(_Butir x, bool isDark) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: OTSpacing.sm),
        padding: const EdgeInsets.all(OTSpacing.base),
        decoration: BoxDecoration(
            color: OTColors.surfaceSubtle(isDark),
            borderRadius: OTRadius.xsBorder),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text(x.judul,
                  style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s16,
                      fontWeight: FontWeight.w600,
                      color: OTColors.textPrimary(isDark))),
            ),
            if (x.arab.isNotEmpty) ...[
              const SizedBox(width: OTSpacing.sm),
              Text(x.arab,
                  textDirection: TextDirection.rtl,
                  style: ScholarlyFonts.scheherazadeNew(
                      fontSize: OTFontSize.s18,
                      color: OTColors.textSecondary(isDark))),
            ],
          ]),
          const SizedBox(height: OTSpacing.xs),
          Text(x.isi,
              style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  height: 1.6,
                  color: OTColors.textPrimary(isDark))),
        ]),
      );

  Widget _kutipanWidget(_Kutipan k, bool isDark) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: OTSpacing.base),
        padding: const EdgeInsets.all(OTSpacing.lg),
        decoration: BoxDecoration(
            border: Border.all(color: OTColors.border(isDark)),
            borderRadius: OTRadius.cardBorder),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('«${k.arab}»',
              textDirection: TextDirection.rtl,
              style: ScholarlyFonts.scheherazadeNew(
                  fontSize: OTFontSize.s22,
                  color: OTColors.textPrimary(isDark))),
          const SizedBox(height: OTSpacing.sm),
          Text(k.makna,
              style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  height: 1.6,
                  color: OTColors.textSecondary(isDark))),
          const SizedBox(height: OTSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('(${k.sumber})',
                textDirection: TextDirection.rtl,
                style: ScholarlyFonts.scheherazadeNew(
                    fontSize: OTFontSize.s16,
                    color: OTColors.textTertiary(isDark))),
          ),
        ]),
      );

  Widget _limaAi(BuildContext context, bool isDark) {
    final subs = widget.agent?.subAgents ?? const <SubAgentModel>[];
    return Padding(
      padding: const EdgeInsets.only(top: OTSpacing.base),
      child: Column(children: [
        for (final r in _ruang)
          Padding(
            padding: const EdgeInsets.only(bottom: OTSpacing.sm),
            child: Material(
              color: OTColors.surfaceSubtle(isDark),
              borderRadius: OTRadius.cardBorder,
              child: InkWell(
                borderRadius: OTRadius.cardBorder,
                onTap: widget.onSelectSubAgent == null
                    ? null
                    : () {
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
                  padding: const EdgeInsets.all(OTSpacing.lg),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Loc.isArabic ? r.arab : r.nama,
                                style: ScholarlyFonts.outfit(
                                    fontSize: OTFontSize.s18,
                                    fontWeight: FontWeight.w600,
                                    color: OTColors.textPrimary(isDark))),
                            const SizedBox(height: OTSpacing.xs),
                            Text(r.untuk,
                                style: ScholarlyFonts.outfit(
                                    fontSize: OTFontSize.s14,
                                    height: 1.5,
                                    color: OTColors.textSecondary(isDark))),
                          ]),
                    ),
                    if (widget.onSelectSubAgent != null)
                      Icon(Icons.arrow_forward_rounded,
                          color: OTColors.textPrimary(isDark)),
                  ]),
                ),
              ),
            ),
          ),
        if (widget.onOpenMain != null) ...[
          const SizedBox(height: OTSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onOpenMain!();
              },
              child: const Text('Mulai bertanya'),
            ),
          ),
        ],
      ]),
    );
  }
}
