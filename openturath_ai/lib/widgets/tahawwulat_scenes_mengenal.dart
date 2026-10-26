// ignore_for_file: non_constant_identifier_names, prefer_const_constructors
import 'dart:math' as math;

import 'tahawwulat_scene.dart';
import 'tahawwulat_scene_kit.dart';

Op _seg(int i, double x, double y, double r, double w,
        {double t = 0,
        double d = 0.35,
        double tone = 1,
        bool fill = true,
        double dx = 0,
        double dy = 0,
        bool dash = false,
        double out = -1}) =>
    Op(Sk.seg, x, y,
        r: r,
        w: w,
        idx: i,
        t: t,
        d: d,
        tone: tone,
        fill: fill,
        draw: !fill,
        dx: dx,
        dy: dy,
        dash: dash,
        out: out);

/// Adegan deck ringkas "Mengenal Fikih Tahawwulat" (32 slide, kunci m01..m32).
/// Tiap adegan menjelaskan isi slidenya; tidak ada hiasan abstrak tanpa makna.
Map<String, SceneDef> scenesMengenal() => {
      // Satu garis -> gelombang -> tangga -> Lengkung Empat Bagian.
      'm01': SceneDef(
          2.2,
          () => [
                L(20, 28, 80, 28, t: 0, d: 0.5, out: 0.5),
                W(20, 80, 28, 5, 3, t: 0.5, d: 0.7, out: 1.2),
                for (var i = 0; i < 4; i++)
                  Col(32.0 + i * 12, 50, 8, [8.0, 14.0, 20.0, 26.0][i],
                      t: 1.2 + i * 0.1, d: 0.4, out: 1.75, tone: 0.8),
                ...arch(x: 50, y: 46, r: 28, w: 9, t: 1.7, stag: 0.1, d: 0.35),
              ],
          alt:
              'Satu garis menjadi gelombang, tangga, lalu Lengkung Empat Bagian'),
      // Tujuh pertanyaan: kisi rapi -> kacau -> kabar datang -> cincin arah -> cabang.
      'm02': SceneDef(3.6, () {
        final ops = <Op>[];
        for (var r = 0; r < 4; r++) {
          for (var c = 0; c < 4; c++) {
            final i = r * 4 + c;
            ops.add(D(38.0 + c * 8, 16.0 + r * 8,
                r: 1,
                t: i * 0.025,
                d: 0.3,
                mx: jit(i, 1, 14),
                my: jit(i, 2, 10),
                mt: 0.5,
                md: 0.7,
                sh: 1.3,
                st: 0.5,
                sd: 0.7,
                i: i,
                out: 1.9));
          }
        }
        ops.addAll([
          L(0, 28, 44, 28, t: 1.2, d: 0.6, tone: 0.7),
          D(2, 28, r: 1.6, t: 1.2, d: 0.2, mx: 42, mt: 1.2, md: 0.7),
          G(46, 28, 8, t: 1.5, d: 0.4),
          D(50, 28, r: 1.8, t: 1.9, d: 0.3),
          R(50, 28, 9, t: 2.0, d: 0.5, tone: 0.7),
          for (var k = 0; k < 4; k++)
            L(
                50 + math.cos(k * math.pi / 2) * 9,
                28 + math.sin(k * math.pi / 2) * 9,
                50 + math.cos(k * math.pi / 2) * 12,
                28 + math.sin(k * math.pi / 2) * 12,
                t: 2.3,
                d: 0.2),
          // baris 5: banyak jalur dakwah yang bercabang
          for (var k = 0; k < 3; k++) ...[
            L(50, 28, 50 + (k - 1) * 22.0, 8,
                t: 2.6 + k * 0.1, d: 0.35, tone: 0.6, out: 3.1),
            D(50 + (k - 1) * 22.0, 8,
                r: 1.2, t: 2.9 + k * 0.1, d: 0.2, out: 3.1),
          ],
          // baris 6-7: satu langkah menuju kabar Nabi
          L(50, 40, 50, 52, t: 3.1, d: 0.3),
          D(50, 52, r: 1.4, t: 3.3, d: 0.2),
          Op(Sk.spark, 50, 28, r: 5, t: 3.3, d: 0.3),
        ]);
        return ops;
      }, alt: 'Kisi titik yang kacau lalu ditenangkan oleh kabar wahyu'),
      // Gerbang lengkung terbuka memperlihatkan cahaya.
      'm03': SceneDef(
          2.0,
          () => [
                G(50, 30, 20, t: 0.4, d: 0.9),
                Op(Sk.gate, 50, 30,
                    w: 28, h: 40, t: 0, d: 0.3, mt: 0.3, md: 1.4),
              ],
          alt: 'Gerbang lengkung terbuka'),
      // Bab 1: empat petak kosong bergaris putus-putus.
      'm04': SceneDef(1.2, () => petak4(filled: 0, t: 0, stag: 0.15),
          alt: 'Empat petak kosong menunggu diisi'),
      // Tamu asing masuk ke majelis, duduk berhadapan: lutut menyentuh lutut.
      'm05': SceneDef(
          3.0,
          () => [
                ...majlis(t: 0, d: 0.4, stag: 0.06),
                D(100, 38, r: 1.8, t: 0.5, d: 0.2, mx: -40.2, mt: 0.5, md: 1.5),
                Op(Sk.arc, 100, 36,
                    r: 2.8,
                    a0: math.pi * 1.1,
                    a1: math.pi * 1.9,
                    t: 0.5,
                    d: 0.2,
                    mx: -40.2,
                    mt: 0.5,
                    md: 1.5),
                L(59.0, 36.8, 59.0, 39.6, t: 2.2, d: 0.3),
                L(60.6, 36.8, 60.6, 39.6, t: 2.35, d: 0.3),
              ],
          alt: 'Seorang tamu asing masuk ke majelis dan duduk di hadapan Nabi'),
      // Tiga ikon masuk ke tiga kartu beserta kapsul Syariah/Akidah/Tazkiyah.
      'm06': SceneDef(2.6, () {
        const xs = [20.0, 50.0, 80.0];
        final names = [
          L3('Islam', 'Islam', 'الإسلام'),
          L3('Iman', 'Iman', 'الإيمان'),
          L3('Ihsan', 'Ihsan', 'الإحسان'),
        ];
        final caps = [
          L3('Syariah', 'Shari‘ah', 'الشريعة'),
          L3('Akidah', 'Creed', 'العقيدة'),
          L3('Tazkiyah', 'Purification', 'التزكية'),
        ];
        return [
          for (var i = 0; i < 5; i++)
            Col(12.0 + i * 4, 28, 2, 16, t: i * 0.06, d: 0.35),
          Pg(50, 20, 9, 6, t: 0.3, d: 0.5),
          D(80, 20, r: 2, t: 0.9, d: 0.2),
          R(80, 20, 6, t: 0.7, d: 0.5),
          R(80, 20, 10, t: 1.0, d: 0.5, tone: 0.5),
          for (var i = 0; i < 3; i++) ...[
            T(names[i], xs[i], 36, t: 1.0 + i * 0.2, d: 0.3, size: 4.2),
            B(xs[i], 46, 24, 7, r: 3.5, t: 1.6 + i * 0.25, d: 0.35, dy: 4),
            T(caps[i], xs[i], 46, t: 1.8 + i * 0.25, d: 0.3, size: 3.4, dy: 4),
          ],
        ];
      }, alt: 'Islam, Iman, Ihsan dan padanannya Syariah, Akidah, Tazkiyah'),
      // Waktu Kiamat: gembok mengunci.
      'm07': SceneDef(
          1.8,
          () => [
                ...petak4(filled: 3, t: 0, stag: 0.04, d: 0.2, h: 22, y: 34),
                Op(Sk.lock, petakX[3], 14,
                    w: 12, h: 18, up: true, t: 0.3, d: 0.3, mt: 0.9, md: 0.25),
                T(L3('Waktu Kiamat', 'Hour of the Day', 'وقت الساعة'),
                    petakX[3], 50,
                    t: 1.2, d: 0.3, size: 3.2),
              ],
          alt: 'Gembok mengunci waktu Kiamat'),
      // Dua tanda: tatanan yang terbalik, dan lomba meninggikan bangunan.
      'm08': SceneDef(
          3.0,
          () => [
                R(22, 14, 4,
                    t: 0, d: 0.2, fill: true, my: 22, mt: 0.1, md: 1.0),
                R(22, 36, 9,
                    t: 0, d: 0.2, fill: true, my: -22, mt: 0.1, md: 1.0),
                T(
                    L3('Tatanan terbalik', 'Order turned upside down',
                        'انقلاب الموازين'),
                    22,
                    51,
                    t: 1.2,
                    d: 0.3,
                    size: 3.2),
                L(50, 6, 50, 50, t: 0.2, d: 0.3, tone: 0.3, dash: true),
                for (var i = 0; i < 5; i++)
                  Col(60.0 + i * 8, 44, 5, [8.0, 15.0, 22.0, 29.0, 36.0][i],
                      t: 1.2 + i * 0.12, d: 0.7 + (i % 2) * 0.2),
                T(
                    L3('Berlomba meninggikan bangunan',
                        'Racing to build higher', 'التطاول في البنيان'),
                    76,
                    51,
                    t: 2.0,
                    d: 0.3,
                    size: 3.2),
              ],
          alt: 'Tatanan terbalik dan perlombaan meninggikan bangunan'),
      // Empat petak menyatu jadi Lengkung; «دِينَكُمْ» digarisbawahi.
      'm09': SceneDef(
          2.4,
          () => [
                for (var i = 0; i < 4; i++)
                  B(petakX[i], 30, 18, 26,
                      fill: true,
                      tone: 0.5,
                      t: 0,
                      d: 0.1,
                      mx: (50 - petakX[i]) * 0.2,
                      my: 8,
                      mt: 0.2,
                      md: 0.6,
                      out: 0.9),
                ...arch(x: 50, y: 42, r: 30, w: 10, t: 0.8, stag: 0.15, d: 0.4),
                T('«دِينَكُمْ»', 50, 36, t: 1.4, d: 0.4, size: 8),
                L(38, 44, 62, 44, t: 1.8, d: 0.5),
              ],
          alt: 'Empat bagian menyatu dan kata dinukum digarisbawahi'),
      'm10': SceneDef(2.2, () {
        final names = [
          L3('Islam', 'Islam', 'الإسلام'),
          L3('Iman', 'Iman', 'الإيمان'),
          L3('Ihsan', 'Ihsan', 'الإحسان'),
          L3('Tanda Zaman', 'Signs of the Hour', 'أمارات الساعة'),
        ];
        return [
          G(50, 40, 34, t: 1.6, d: 0.6, tone: 0.6),
          ...arch(x: 50, y: 42, r: 30, w: 10, t: 0, stag: 0.4, d: 0.4),
          for (var i = 0; i < 4; i++)
            T(names[i], [14.0, 38.0, 62.0, 86.0][i], 53,
                t: 0.2 + i * 0.4, d: 0.3, size: 3.3),
        ];
      }, alt: 'Keempat segmen menyala berurutan'),
      // Empat kepingan busur melayang dari empat penjuru lalu terkunci.
      'm11': SceneDef(
          2.0,
          () => [
                for (var i = 0; i < 4; i++)
                  _seg(i, 50, 44, 30, 10,
                      t: i * 0.15,
                      d: 0.9,
                      dx: [-40.0, -14.0, 14.0, 40.0][i],
                      dy: [-14.0, -30.0, -30.0, -14.0][i]),
                G(50, 36, 30, t: 1.4, d: 0.5, tone: 0.5),
              ],
          alt: 'Empat kepingan busur saling mengunci'),
      // Empat bukti: tiap bukti menyalakan satu segmen, bernomor dan bernama.
      'm12': SceneDef(3.2, () {
        final names = [
          L3('Dinamai Nabi', 'Named by the Prophet', 'سمّاه النبي'),
          L3('Dijawab rinci', 'Answered fully', 'أُجيب تفصيلًا'),
          L3('Ditanya Jibril', 'Asked by Jibril', 'سأل عنه جبريل'),
          L3('Sepakat ahli hadis', 'Hadith scholars agree', 'اتفق المحدّثون'),
        ];
        const xs = [14.0, 38.0, 62.0, 86.0];
        return [
          ...arch(
              x: 50,
              y: 34,
              r: 26,
              w: 9,
              t: 0,
              stag: 0,
              d: 0.3,
              fill: false,
              tone: 0.35),
          for (var i = 0; i < 4; i++) ...[
            _seg(i, 50, 34, 26, 9, t: 0.4 + i * 0.6, d: 0.3),
            Ck(xs[i], 45, 2.4, t: 0.8 + i * 0.6, d: 0.3),
            T('${i + 1}  ${names[i]}', xs[i], 51,
                t: 0.8 + i * 0.6, d: 0.3, size: 3.0),
          ],
        ];
      }, alt: 'Empat bukti menyalakan empat segmen bernomor'),
      // Setiap bagian melahirkan satu cabang ilmu.
      'm13': SceneDef(2.4, () {
        final names = [
          L3('Fikih', 'Fiqh', 'الفقه'),
          L3('Akidah', 'Creed', 'العقيدة'),
          L3('Tasawuf', 'Tasawwuf', 'التزكية'),
          L3('Tahawwulat', 'Tahawwulat', 'التحولات'),
        ];
        const xs = [14.0, 38.0, 62.0, 86.0];
        final ops = <Op>[
          ...arch(x: 50, y: 30, r: 24, w: 8, t: 0, stag: 0.1, d: 0.3)
        ];
        for (var i = 0; i < 4; i++) {
          final o = archPt(i, 50, 30, 24, 8);
          ops.addAll([
            L(o.dx, o.dy + 3, xs[i], 42, t: 0.7 + i * 0.35, d: 0.45),
            B(xs[i], 48, 22, 9, r: 2, t: 1.0 + i * 0.35, d: 0.3),
            if (i == 3)
              B(xs[i], 48, 22, 9,
                  r: 2, fill: true, tone: 0.18, t: 1.0 + i * 0.35, d: 0.3),
            T(names[i], xs[i], 48, t: 1.2 + i * 0.35, d: 0.3, size: 3.3),
          ]);
        }
        // text color of selected card inverted handled by dark/light? keep outline only.
        return ops;
      }, alt: 'Empat bagian melahirkan empat cabang ilmu'),
      // Waktu kiamat dikunci (jangan menebak tahun); tanda-tandanya diajarkan.
      'm14': SceneDef(
          3.0,
          () => [
                L(50, 6, 50, 52, t: 0, d: 0.3, tone: 0.3, dash: true),
                Op(Sk.cal, 25, 16, w: 18, h: 16, t: 0.1, d: 0.3),
                X(25, 16, 8, t: 0.6, d: 0.3),
                Op(Sk.lock, 25, 37, w: 13, h: 18, t: 0.9, d: 0.3),
                T(
                    L3('Waktu: rahasia Allah', 'The time: Allah\u2019s secret',
                        'الوقت: سرّ الله'),
                    25,
                    51,
                    t: 1.3,
                    d: 0.3,
                    size: 3.2),
                for (var i = 0; i < 3; i++)
                  Op(Sk.sign, 62.0 + i * 12, 22,
                      w: 8, h: 15, fill: true, t: 1.4 + i * 0.35, d: 0.3),
                W(58, 92, 40, 3.2, 2, t: 1.5, d: 0.6, tone: 0.5),
                T(
                    L3(
                        'Tanda: diajarkan Nabi',
                        'The signs: taught by the Prophet',
                        'العلامات: علّمها النبي'),
                    75,
                    51,
                    t: 2.2,
                    d: 0.3,
                    size: 3.2),
              ],
          alt:
              'Waktu kiamat dikunci; tanda-tandanya ditunjukkan sebagai rambu'),
      'm15': SceneDef(
          1.2,
          () => [
                W(12, 88, 16, 3, 3, t: 0, d: 0.6),
                ...arch(x: 50, y: 46, r: 28, w: 9, t: 0.3, stag: 0.08, d: 0.3),
              ],
          alt: 'Gelombang menyatu dengan Lengkung Empat Bagian'),
      // Sumbu kedalaman (fikih) dan arus perubahan (tahawwulat).
      'm16': SceneDef(
          2.4,
          () => [
                L(50, 4, 50, 52, t: 0, d: 0.6),
                T(L3('Fikih · kedalaman', 'Fiqh · depth', 'الفقه · العمق'), 74,
                    8,
                    t: 0.4, d: 0.3, size: 3.4),
                W(8, 92, 28, 4, 3, t: 0.7, d: 0.7),
                T(
                    L3(
                        'Tahawwulat · arus perubahan',
                        'Tahawwulat · the flow of change',
                        'التحولات · تيار التغيّر'),
                    30,
                    41,
                    t: 1.1,
                    d: 0.3,
                    size: 3.4),
                G(50, 28, 10, t: 1.6, d: 0.5),
                D(50, 28, r: 1.8, t: 1.6, d: 0.3),
                R(50, 28, 7, t: 1.7, d: 0.4, tone: 0.7),
              ],
          alt: 'Dua sumbu bersilang membentuk kompas'),
      'm17': SceneDef(
          2.0,
          () => [
                G(50, 26, 22, t: 0.5, d: 0.9),
                Op(Sk.gate, 50, 24,
                    w: 24, h: 36, t: 0, d: 0.3, mt: 0.3, md: 1.2),
                T('«فِي الدِّينِ»', 50, 49, t: 1.0, d: 0.4, size: 7),
              ],
          alt: 'Pintu terbuka menyinari kata fid-din'),
      // Wahyu menimbang arus zaman: yang selamat dan yang berbahaya dipilah.
      'm18': SceneDef(
          3.0,
          () => [
                W(4, 44, 28, 5, 2, t: 0, d: 0.7),
                T(
                    L3('Peristiwa zaman', 'The events of the age',
                        'أحداث الزمان'),
                    24,
                    40,
                    t: 0.5,
                    d: 0.3,
                    size: 3.2),
                Op(Sk.scale, 50, 20,
                    w: 14,
                    h: 24,
                    a0: 0.3,
                    a1: 0,
                    t: 0.5,
                    d: 0.3,
                    mt: 0.8,
                    md: 0.6),
                T(L3('Wahyu', 'Revelation', 'الوحي'), 50, 51,
                    t: 0.8, d: 0.3, size: 3.4),
                L(58, 28, 94, 14, t: 1.2, d: 0.5),
                T(L3('Selamat', 'Safe', 'السلامة'), 82, 9,
                    t: 1.6, d: 0.3, size: 3.5),
                W(58, 94, 42, 3, 3, t: 1.2, d: 0.5, sharp: true, tone: 0.35),
                T(L3('Bahaya', 'Danger', 'الخطر'), 82, 51,
                    t: 1.6, d: 0.3, size: 3.5, tone: 0.5),
              ],
          alt:
              'Wahyu menimbang peristiwa zaman lalu memilah yang selamat dan yang berbahaya'),
      // Wacana sensasional (bergetar, tajam) versus Fikih Tahawwulat (tenang).
      'm19': SceneDef(
          3.0,
          () => [
                L(50, 4, 50, 52, t: 0, d: 0.3, tone: 0.3, dash: true),
                for (var k = 0; k < 3; k++)
                  W(8, 44, 14.0 + k * 9, 3.6, 4 + k,
                      t: 0.2 + k * 0.2, d: 0.5, sharp: true, tone: 0.7),
                for (var k = 0; k < 7; k++)
                  D(14.0 + k * 4.6, 42 + jit(k, 3, 3),
                      r: 0.9,
                      t: 1.0 + k * 0.05,
                      d: 0.3,
                      sh: 1.2,
                      st: 1.0,
                      sd: 1.5,
                      i: k),
                T(L3('Sensasional', 'Sensational', 'مثيرٌ للفزع'), 26, 51,
                    t: 1.3, d: 0.3, size: 3.2, tone: 0.7),
                for (var k = 0; k < 3; k++)
                  W(56, 92, 14.0 + k * 9, 2.4, 2,
                      t: 0.2 + k * 0.2, d: 0.5, tone: 0.9),
                ...arch(x: 74, y: 46, r: 11, w: 4, t: 1.0, stag: 0.1, d: 0.3),
                T(L3('Fikih Tahawwulat', 'Fiqh al-Tahawwulat', 'فقه التحولات'),
                    74, 51,
                    t: 1.6, d: 0.3, size: 3.2),
              ],
          alt: 'Wacana sensasional bergetar tajam, Fikih Tahawwulat tenang'),
      // Tiga ciri: bagian sah agama, panduan sikap, bebas ramalan.
      'm20': SceneDef(
          3.2,
          () => [
                ...arch(x: 17, y: 34, r: 12, w: 4.4, t: 0, stag: 0.08, d: 0.3),
                G(17, 30, 12, t: 0.4, d: 0.4),
                Ck(17, 44, 2.6, t: 0.7, d: 0.3),
                T(L3('Bagian dari agama', 'Part of religion', 'من الدين'), 17,
                    51,
                    t: 0.8, d: 0.3, size: 3.0),
                ...compass(50, 26, 11, t: 1.1, stag: 0.1),
                Ck(50, 44, 2.6, t: 1.8, d: 0.3),
                T(L3('Panduan sikap', 'A guide to stance', 'دليل الموقف'), 50,
                    51,
                    t: 1.9, d: 0.3, size: 3.0),
                Op(Sk.cal, 83, 24, w: 16, h: 14, t: 2.1, d: 0.3),
                X(83, 24, 9, t: 2.5, d: 0.3),
                Ck(83, 44, 2.6, t: 2.7, d: 0.3),
                T(L3('Bebas ramalan', 'Free of prediction', 'خالٍ من التنبؤ'),
                    83, 51,
                    t: 2.8, d: 0.3, size: 3.0),
              ],
          alt:
              'Tiga ciri: lengkung agama, kompas sikap, dan kalender ramalan yang dicoret'),
      'm21': SceneDef(
          2.2,
          () => [
                for (var i = 0; i < 5; i++) ...[
                  G(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy, 6,
                      t: i * 0.25, d: 0.3),
                  D(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy,
                      r: 1.8, t: i * 0.25, d: 0.3),
                ],
                Pg(50, 30, 20, 5, t: 1.2, d: 0.8),
              ],
          alt: 'Lima titik membentuk Peta Segi Lima'),
      'm22': SceneDef(2.3, () {
        final p = pentaPt(3, 50, 30, 20);
        return [
          Pg(50, 30, 20, 5, t: 0, d: 0.3, tone: 0.35),
          for (var i = 0; i < 5; i++)
            D(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy,
                r: 1.4, t: 0, d: 0.2, tone: 0.4),
          R(p.dx, p.dy, 2,
              r2: 12, t: 0.2, d: 0.2, mt: 0.2, md: 0.8, out: 1.4, draw: false),
          D(p.dx, p.dy, r: 1.8, t: 0.2, d: 0.2),
          T(L3('Tanda Besar', 'Major signs', 'العلامات الكبرى'), p.dx,
              p.dy + 11,
              t: 0.8, d: 0.3, size: 3.4, out: 1.4),
          Pg(50, 30, 20, 5, t: 1.4, d: 0.5),
          for (var i = 0; i < 5; i++)
            D(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy,
                r: 1.8, t: 1.5 + i * 0.08, d: 0.2),
          G(50, 30, 28, t: 1.6, d: 0.5, tone: 0.5),
        ];
      }, alt: 'Zoom ke tanda besar lalu mundur melihat kelima simpul'),
      // Peta lima cabang: lima simpul dengan nama singkat, tanpa istilah teknis.
      'm23': SceneDef(2.8, () {
        final names = [
          L3('Penyimpangan', 'Deviation', 'الانحراف'),
          L3('Isyarat', 'Signals', 'الإشارات'),
          L3('Sains', 'Science', 'العلوم'),
          L3('Tanda alam', 'Natural signs', 'الأشراط'),
          L3('Sejarah', 'History', 'التاريخ'),
        ];
        return [
          Pg(50, 30, 17, 5, t: 0, d: 0.4, tone: 0.6),
          for (var i = 0; i < 5; i++) ...[
            G(pentaPt(i, 50, 30, 17).dx, pentaPt(i, 50, 30, 17).dy, 6,
                t: 0.5 + i * 0.25, d: 0.4),
            D(pentaPt(i, 50, 30, 17).dx, pentaPt(i, 50, 30, 17).dy,
                r: 1.9, t: 0.5 + i * 0.25, d: 0.3),
            T(
                names[i],
                pentaPt(i, 50, 30, 17).dx + [0.0, 15.0, 11.0, -11.0, -15.0][i],
                pentaPt(i, 50, 30, 17).dy + [-8.0, 0.0, 8.0, 8.0, 0.0][i],
                t: 0.7 + i * 0.25,
                d: 0.3,
                size: 3.3),
          ],
        ];
      }, alt: 'Lima simpul bernama membentuk peta lima cabang ilmu'),
      'm24': SceneDef(
          1.2,
          () => [
                R(50, 28, 22, t: 0, d: 0.5, dash: true, tone: 0.6),
                ...compass(50, 28, 13, t: 0.2, stag: 0.08),
              ],
          alt: 'Kompas Lingkar Pelindung'),
      // Bersegera: lima amal menyala menjadi lentera di tengah gelap.
      'm25': SceneDef(
          3.0,
          () => [
                B(94, 28, 34, 56,
                    fill: true,
                    tone: 0.12,
                    t: 0,
                    d: 0.3,
                    mx: -12,
                    mt: 0.1,
                    md: 1.2,
                    out: 1.4),
                for (var i = 0; i < 5; i++)
                  D(8.0 + i * 3, 28,
                      r: 1.4,
                      t: 0.2 + i * 0.1,
                      d: 0.2,
                      mx: 42 +
                          math.cos(i * 1.256 - 1.57) * 7 -
                          (8.0 + i * 3 - 8),
                      my: math.sin(i * 1.256 - 1.57) * 7,
                      mt: 0.4 + i * 0.1,
                      md: 0.8),
                G(50, 28, 10, t: 1.0, d: 0.4),
                G(50, 28, 30, t: 1.1, d: 0.8, tone: 0.7),
                T(
                    L3('Bersegeralah beramal', 'Hasten to good deeds',
                        'بادروا بالأعمال'),
                    50,
                    49,
                    t: 1.8,
                    d: 0.3,
                    size: 3.6),
              ],
          alt: 'Lima amal saleh menyala menjadi lentera yang mengusir gelap'),
      'm26': SceneDef(
          2.2,
          () => [
                W(4, 34, 28, 6, 4, t: 0, d: 0.5, sharp: true, out: 1.2),
                D(50, 28, r: 2, t: 0, d: 0.2),
                Op(Sk.arc, 50, 28,
                    r: 8,
                    a0: math.pi * 0.62,
                    a1: math.pi * 1.38,
                    t: 0.5,
                    d: 0.4,
                    draw: true),
                Op(Sk.arc, 50, 28,
                    r: 12,
                    a0: math.pi * 0.62,
                    a1: math.pi * 1.38,
                    t: 0.7,
                    d: 0.4,
                    draw: true),
                T(L3('Jaga lisan', 'Guard the tongue', 'احفظ لسانك'), 70, 12,
                    t: 0.9, d: 0.3, size: 3.4),
                T(L3('Jaga tangan', 'Guard the hand', 'احفظ يدك'), 70, 46,
                    t: 1.0, d: 0.3, size: 3.4),
                L(4, 28, 34, 28, t: 1.3, d: 0.5, tone: 0.8),
              ],
          alt: 'Provokasi berhenti di depan perisai dan menjadi garis tenang'),
      'm27': SceneDef(
          2.2,
          () => [
                Op(Sk.arc, 50, 42,
                    r: 20,
                    a0: math.pi,
                    a1: math.pi * 2,
                    t: 0,
                    d: 0.7,
                    draw: true),
                L(30, 42, 70, 42, t: 0.5, d: 0.3),
                for (var i = 0; i < 4; i++)
                  D(43.0 + i * 4.7, 37, r: 1.5, t: 0.9 + i * 0.12, d: 0.2),
                G(50, 38, 14, t: 1.0, d: 0.5, tone: 0.6),
                for (var k = 0; k < 3; k++)
                  W(-10, 110, 8.0 + k * 6, 1.4, 5,
                      t: 1.0 + k * 0.15, d: 1.0, tone: 0.45),
              ],
          alt: 'Kubah hangat menaungi keluarga dari angin di luar'),
      'm28': SceneDef(
          2.2,
          () => [
                L(10, 28, 90, 28, t: 0, d: 0.3, tone: 0.3, dash: true),
                L(10, 28, 4, 28, t: 0, d: 0.1, tone: 0.1),
                D(8, 28, r: 2, t: 0.1, d: 0.2, mx: 40, mt: 0.6, md: 1.0),
                D(92, 28, r: 2, t: 0.1, d: 0.2, mx: -40, mt: 0.6, md: 1.0),
                T(L3('ekstrem kanan', 'right extreme', 'غلو'), 14, 18,
                    t: 0.2, d: 0.3, size: 3.2, tone: 0.7),
                T(L3('ekstrem kiri', 'left extreme', 'تفريط'), 86, 18,
                    t: 0.2, d: 0.3, size: 3.2, tone: 0.7),
                T(L3('Jalan tengah', 'The middle way', 'النمط الأوسط'), 50, 42,
                    t: 1.4, d: 0.4, size: 4.2),
                G(50, 28, 10, t: 1.5, d: 0.4),
              ],
          alt: 'Dua titik kembali ke tengah menyatu di jalan tengah'),
      'm29': SceneDef(2.0, () {
        const xs = [12.0, 31.0, 50.0, 69.0, 88.0];
        final names = [
          'البَيَانُ',
          'المُحَقِّقُ',
          'المُخْتَبِرُ',
          'الحَبِيبُ',
          'الخَطِيبُ'
        ];
        return [
          R(xs[0], 26, 7, t: 0, d: 0.4),
          Pg(xs[1], 26, 8, 3, t: 0.25, d: 0.4),
          Pg(xs[2], 26, 8, 4, t: 0.5, d: 0.4, rot: math.pi / 4),
          Pg(xs[3], 26, 8, 5, t: 0.75, d: 0.4),
          Pg(xs[4], 26, 8, 6, t: 1.0, d: 0.4),
          for (var i = 0; i < 5; i++) ...[
            D(xs[i], 26, r: 1.4, t: i * 0.25, d: 0.3),
            T(names[i], xs[i], 44, t: 0.2 + i * 0.25, d: 0.3, size: 4),
          ],
        ];
      }, alt: 'Lima titik asisten dengan lima simbol berbeda'),
      'm30': SceneDef(
          1.2,
          () => [
                for (var i = 0; i < 5; i++) ...[
                  D(12.0 + i * 19, 10, r: 1.6, t: i * 0.08, d: 0.2),
                  L(12.0 + i * 19, 12, 50, 34,
                      t: 0.3 + i * 0.08, d: 0.3, tone: 0.6),
                ],
                Op(Sk.stack, 50, 42, w: 22, h: 4.4, t: 0.4, d: 0.3),
              ],
          alt: 'Lima asisten terikat pada sumber kitab'),
      // Lima asisten: lima kartu bernama.
      'm31': SceneDef(3.0, () {
        const xs = [12.0, 31.0, 50.0, 69.0, 88.0];
        final names = [
          L3('Al-Bayan', 'Al-Bayan', 'البيان'),
          L3('Al-Muhaqqiq', 'Al-Muhaqqiq', 'المحقق'),
          L3('Al-Mukhtabir', 'Al-Mukhtabir', 'المختبر'),
          L3('Al-Habib', 'Al-Habib', 'الحبيب'),
          L3('Al-Khatib', 'Al-Khatib', 'الخطيب'),
        ];
        return [
          for (var i = 0; i < 5; i++) ...[
            B(xs[i], 26, 16.5, 22, r: 3, t: i * 0.3, d: 0.4, dy: 6),
            D(xs[i], 19, r: 1.3, t: 0.2 + i * 0.3, d: 0.3),
            T(names[i], xs[i], 29, t: 0.3 + i * 0.3, d: 0.3, size: 3.0),
          ],
          L(8, 47, 92, 47, t: 1.9, d: 0.6, tone: 0.5),
          Op(Sk.stack, 50, 53, w: 18, h: 2.4, t: 2.3, d: 0.3),
        ];
      }, alt: 'Lima kartu bernama untuk lima asisten, bertumpu pada sumber kitab'),
      // Mulai belajar: lengkung menyala, lalu tiga langkah berurutan (tombol asli ada di teks).
      'm32': SceneDef(3.2, () {
        final steps = [
          L3('Pilih jalur', 'Choose a path', 'اختر مسارك'),
          L3('Tanya Al-Bayan', 'Ask Al-Bayan', 'اسأل البيان'),
          L3('Amalkan satu langkah', 'Do one step', 'اعمل بخطوة'),
        ];
        const xs = [20.0, 50.0, 80.0];
        return [
          G(50, 22, 30, t: 0.9, d: 0.5, tone: 0.8),
          ...arch(x: 50, y: 28, r: 22, w: 7.5, t: 0, stag: 0.15, d: 0.3),
          L(xs[0], 44, xs[2], 44, t: 1.3, d: 0.9, tone: 0.5),
          for (var i = 0; i < 3; i++) ...[
            D(xs[i], 44, r: 1.9, t: 1.4 + i * 0.5, d: 0.3),
            T('${i + 1}', xs[i], 38, t: 1.5 + i * 0.5, d: 0.3, size: 3.8),
            T(steps[i], xs[i], 51, t: 1.6 + i * 0.5, d: 0.3, size: 3.2),
          ],
        ];
      }, alt: 'Lengkung menyala lalu tiga langkah: pilih jalur, tanya Al-Bayan, amalkan satu langkah'),
    };
