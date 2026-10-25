// ignore_for_file: non_constant_identifier_names, prefer_const_constructors
import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'tahawwulat_scene.dart';
import 'tahawwulat_scene_kit.dart';

/// Adegan Bab 0 dan Bab 1 (slide 1-20 naskah).
Map<String, SceneDef> scenesA() => {
      // Satu garis -> gelombang -> tangga -> Lengkung Empat Bagian.
      's1': SceneDef(2.2, () => [
            L(20, 28, 80, 28, t: 0, d: 0.5, out: 0.5),
            W(20, 80, 28, 5, 3, t: 0.5, d: 0.7, out: 1.2),
            for (var i = 0; i < 4; i++)
              Col(32.0 + i * 12, 50, 8, [8.0, 14.0, 20.0, 26.0][i],
                  t: 1.2 + i * 0.1, d: 0.4, out: 1.75, tone: 0.8),
            ...arch(x: 50, y: 46, r: 28, w: 9, t: 1.7, stag: 0.1, d: 0.35),
          ], alt: 'Satu garis menjadi gelombang, tangga, lalu Lengkung Empat Bagian'),
      // Tujuh pertanyaan: kisi rapi -> kacau -> kabar datang -> cincin arah -> cabang.
      's2': SceneDef(3.6, () {
        final ops = <Op>[];
        for (var r = 0; r < 4; r++) {
          for (var c = 0; c < 4; c++) {
            final i = r * 4 + c;
            ops.add(D(38.0 + c * 8, 16.0 + r * 8,
                r: 1, t: i * 0.025, d: 0.3, mx: jit(i, 1, 14), my: jit(i, 2, 10),
                mt: 0.5, md: 0.7, sh: 1.3, st: 0.5, sd: 0.7, i: i, out: 1.9));
          }
        }
        ops.addAll([
          L(0, 28, 44, 28, t: 1.2, d: 0.6, tone: 0.7),
          D(2, 28, r: 1.6, t: 1.2, d: 0.2, mx: 42, mt: 1.2, md: 0.7),
          G(46, 28, 8, t: 1.5, d: 0.4),
          D(50, 28, r: 1.8, t: 1.9, d: 0.3),
          R(50, 28, 9, t: 2.0, d: 0.5, tone: 0.7),
          for (var k = 0; k < 4; k++)
            L(50 + math.cos(k * math.pi / 2) * 9, 28 + math.sin(k * math.pi / 2) * 9,
                50 + math.cos(k * math.pi / 2) * 12, 28 + math.sin(k * math.pi / 2) * 12,
                t: 2.3, d: 0.2),
          // baris 5: banyak jalur dakwah yang bercabang
          for (var k = 0; k < 3; k++) ...[
            L(50, 28, 50 + (k - 1) * 22.0, 8, t: 2.6 + k * 0.1, d: 0.35, tone: 0.6, out: 3.1),
            D(50 + (k - 1) * 22.0, 8, r: 1.2, t: 2.9 + k * 0.1, d: 0.2, out: 3.1),
          ],
          // baris 6-7: satu langkah menuju kabar Nabi
          L(50, 40, 50, 52, t: 3.1, d: 0.3),
          D(50, 52, r: 1.4, t: 3.3, d: 0.2),
          Op(Sk.spark, 50, 28, r: 5, t: 3.3, d: 0.3),
        ]);
        return ops;
      }, alt: 'Kisi titik yang kacau lalu ditenangkan oleh kabar wahyu'),
      // Gerbang lengkung terbuka memperlihatkan cahaya.
      's3': SceneDef(2.0, () => [
            G(50, 30, 20, t: 0.4, d: 0.9),
            Op(Sk.gate, 50, 30, w: 28, h: 40, t: 0, d: 0.3, mt: 0.3, md: 1.4),
          ], alt: 'Gerbang lengkung terbuka'),
      // Bab 1: empat petak kosong bergaris putus-putus.
      's4': SceneDef(1.2, () => petak4(filled: 0, t: 0, stag: 0.15),
          alt: 'Empat petak kosong menunggu diisi'),
      // Majelis: titik-titik setengah lingkaran, tamu masuk tanpa jejak.
      's5': SceneDef(2.4, () => [
            ...majlis(t: 0, d: 0.4, stag: 0.06),
            D(100, 38, r: 1.8, t: 0.5, d: 0.2, mx: -40.2, mt: 0.5, md: 1.5),
            Op(Sk.arc, 100, 36, r: 2.8, a0: math.pi * 1.1, a1: math.pi * 1.9,
                t: 0.5, d: 0.2, mx: -40.2, mt: 0.5, md: 1.5),
          ], alt: 'Tamu masuk ke majelis'),
      's6': SceneDef(2.0, () => [
            ...majlis(t: 0, d: 0.2),
            D(59.8, 38, r: 1.8, t: 0, d: 0.2),
            Op(Sk.arc, 59.8, 36, r: 2.8, a0: math.pi * 1.1, a1: math.pi * 1.9, t: 0, d: 0.2),
            L(59.0, 36.8, 59.0, 39.6, t: 1.0, d: 0.3),
            L(60.6, 36.8, 60.6, 39.6, t: 1.1, d: 0.3),
          ], alt: 'Tamu duduk menyimak, bersinggungan dengan cahaya majelis'),
      // Islam: lima tiang.
      's7': SceneDef(2.3, () {
        final names = [
          L3('Syahadat', 'Shahada', 'الشهادة'),
          L3('Salat', 'Prayer', 'الصلاة'),
          L3('Zakat', 'Zakat', 'الزكاة'),
          L3('Puasa', 'Fasting', 'الصوم'),
          L3('Haji', 'Hajj', 'الحج'),
        ];
        return [
          ...strip(0),
          for (var i = 0; i < 5; i++) ...[
            Col(16.0 + i * 17, 44, 5, 24, t: 0.2 + i * 0.35, d: 0.45),
            T(names[i], 16.0 + i * 17, 50, t: 0.5 + i * 0.35, d: 0.3, size: 3.2),
            T('${i + 1}', 16.0 + i * 17, 14, t: 0.5 + i * 0.35, d: 0.3, size: 3.4, tone: 0.6),
          ],
        ];
      }, alt: 'Lima tiang Islam'),
      // Iman: enam titik dan segi enam.
      's8': SceneDef(2.3, () {
        final names = [
          L3('Allah', 'Allah', 'الله'),
          L3('Malaikat', 'Angels', 'الملائكة'),
          L3('Kitab', 'Books', 'الكتب'),
          L3('Rasul', 'Messengers', 'الرسل'),
          L3('Hari Akhir', 'Last Day', 'اليوم الآخر'),
          L3('Takdir', 'Decree', 'القدر'),
        ];
        const cx = 50.0, cy = 35.0, rr = 12.5;
        Offset p(int i, double k) =>
            Offset(cx + math.cos(i * math.pi / 3 - math.pi / 2) * rr * k,
                cy + math.sin(i * math.pi / 3 - math.pi / 2) * rr * k);
        return [
          ...strip(1),
          Pg(cx, cy, rr, 6, t: 1.6, d: 0.6, tone: 0.9),
          for (var i = 0; i < 6; i++) ...[
            G(p(i, 1).dx, p(i, 1).dy, 4, t: 0.15 + i * 0.25, d: 0.3),
            D(p(i, 1).dx, p(i, 1).dy, r: 1.6, t: 0.15 + i * 0.25, d: 0.3),
            T(names[i], p(i, 1.7).dx, p(i, 1.7).dy, t: 0.3 + i * 0.25, d: 0.3, size: 3.2),
          ],
        ];
      }, alt: 'Enam rukun iman membentuk segi enam'),
      // Ihsan: kelopak mata terbuka, titik memancarkan gelombang.
      's9': SceneDef(2.2, () => [
            ...strip(2),
            Op(Sk.eye, 50, 28, w: 40, h: 13, r: 3.4, t: 0, d: 0.7, draw: true),
            R(50, 28, 5, r2: 17, t: 1.1, d: 0.2, mt: 1.1, md: 0.9, out: 1.7, draw: false, tone: 0.9),
            R(50, 28, 5, r2: 17, t: 1.4, d: 0.2, mt: 1.4, md: 0.9, out: 1.9, draw: false, tone: 0.7),
            T('كَأَنَّكَ تَرَاهُ', 28, 48, t: 0.7, d: 0.4, size: 4),
            T('فَإِنَّهُ يَرَاكَ', 72, 48, t: 1.3, d: 0.4, size: 4),
          ], alt: 'Mata terbuka dan titik yang memancarkan gelombang'),
      // Tiga ikon masuk ke tiga kartu beserta kapsul Syariah/Akidah/Tazkiyah.
      's10': SceneDef(2.6, () {
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
      // Tiga petak penuh, petak keempat kosong bertanda tanya.
      's11': SceneDef(1.2, () => [
            ...petak4(filled: 3, t: 0, stag: 0.1),
            T(L3('Islam', 'Islam', 'الإسلام'), petakX[0], 30, t: 0.2, d: 0.3, size: 3.6),
            T(L3('Iman', 'Iman', 'الإيمان'), petakX[1], 30, t: 0.3, d: 0.3, size: 3.6),
            T(L3('Ihsan', 'Ihsan', 'الإحسان'), petakX[2], 30, t: 0.4, d: 0.3, size: 3.6),
            T('?', petakX[3], 30, t: 0.6, d: 0.4, size: 11),
          ], alt: 'Tiga petak terisi, petak keempat masih kosong'),
      's12': SceneDef(1.2, () => [
            ...majlis(t: 0, d: 0.2),
            D(59.8, 38, r: 1.8, t: 0, d: 0.2),
            B(68, 28, 14, 8, r: 4, t: 0.3, d: 0.3),
            for (var i = 0; i < 3; i++) D(64.5 + i * 3.5, 28, r: 0.8, t: 0.5 + i * 0.12, d: 0.2),
          ], alt: 'Tamu mengajukan pertanyaan lanjutan'),
      // Waktu Kiamat: gembok mengunci.
      's13': SceneDef(1.8, () => [
            ...petak4(filled: 3, t: 0, stag: 0.04, d: 0.2, h: 22, y: 34),
            Op(Sk.lock, petakX[3], 14, w: 12, h: 18, up: true, t: 0.3, d: 0.3, mt: 0.9, md: 0.25),
            T(L3('Waktu Kiamat', 'Hour of the Day', 'وقت الساعة'), petakX[3], 50, t: 1.2, d: 0.3, size: 3.2),
          ], alt: 'Gembok mengunci waktu Kiamat'),
      // Dua tanda: terbaliknya tatanan; lomba meninggikan bangunan.
      's14': SceneDef(2.5, () => [
            R(22, 16, 4, t: 0, d: 0.2, fill: true, my: 24, mt: 0.1, md: 1.0),
            R(22, 40, 9, t: 0, d: 0.2, fill: true, my: -24, mt: 0.1, md: 1.0),
            L(50, 6, 50, 50, t: 0.2, d: 0.3, tone: 0.3, dash: true),
            for (var i = 0; i < 5; i++)
              Col(60.0 + i * 8, 50, 5, [10.0, 18.0, 26.0, 34.0, 42.0][i],
                  t: 1.2 + i * 0.12, d: 0.7 + (i % 2) * 0.2),
          ], alt: 'Tatanan terbalik dan perlombaan meninggikan bangunan'),
      's15': SceneDef(1.2, () => petak4(filled: 4, t: 0, stag: 0.12),
          alt: 'Empat petak kini terisi'),
      // Tamu pergi, garis waktu memanjang, tanda tanya di dekat satu sahabat.
      's16': SceneDef(2.2, () => [
            ...majlis(t: 0, d: 0.2),
            D(59.8, 38, r: 1.8, t: 0, d: 0.1, mx: -42, mt: 0.2, md: 0.8, out: 0.9),
            L(14, 52, 86, 52, t: 0.9, d: 0.8, tone: 0.6),
            for (var i = 0; i < 4; i++)
              D(24.0 + i * 16, 52, r: 0.9, t: 1.2 + i * 0.12, d: 0.2, tone: 0.8),
            T('?', 33, 24, t: 1.7, d: 0.3, size: 7),
          ], alt: 'Tamu pergi dan waktu berlalu'),
      // Kurung kurawal merangkul empat petak dengan tanda tanya.
      's17': SceneDef(1.8, () => [
            ...petak4(filled: 4, t: 0, stag: 0.02, d: 0.2, y: 34, h: 22),
            for (var i = 0; i < 4; i++)
              T([L3('Islam', 'Islam', 'الإسلام'), L3('Iman', 'Iman', 'الإيمان'),
                    L3('Ihsan', 'Ihsan', 'الإحسان'), L3('Tanda', 'Signs', 'أمارات')][i],
                  petakX[i], 34, t: 0.15, d: 0.3, size: 3.3),
            Op(Sk.brace, 50, 15, w: 5, h: 72, a0: -math.pi / 2, t: 0.5, d: 0.8, draw: true),
            T('?', 50, 4, t: 1.3, d: 0.3, size: 6),
          ], alt: 'Satu kurung merangkul keempat petak'),
      // Empat petak menyatu jadi Lengkung; «دِينَكُمْ» digarisbawahi.
      's18': SceneDef(2.4, () => [
            for (var i = 0; i < 4; i++)
              B(petakX[i], 30, 18, 26, fill: true, tone: 0.5, t: 0, d: 0.1,
                  mx: (50 - petakX[i]) * 0.2, my: 8, mt: 0.2, md: 0.6, out: 0.9),
            ...arch(x: 50, y: 42, r: 30, w: 10, t: 0.8, stag: 0.15, d: 0.4),
            T('«دِينَكُمْ»', 50, 36, t: 1.4, d: 0.4, size: 8),
            L(38, 44, 62, 44, t: 1.8, d: 0.5),
          ], alt: 'Empat bagian menyatu dan kata dinukum digarisbawahi'),
      's19': SceneDef(1.2, () => [
            ...arch(x: 50, y: 42, r: 30, w: 10, t: 0, stag: 0.05, d: 0.2, tone: 0.55),
            Op(Sk.seg, 50, 42, r: 30, w: 10, idx: 3, fill: true, t: 0.5, d: 0.2, out: 0.9),
          ], alt: 'Bagian keempat berkedip'),
      's20': SceneDef(2.2, () {
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
    };

// ignore: unused_element
Offset _unused() => archPt(0, 0, 0, 1, 1);
