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

/// Adegan Bab 2 (slide 21-39 naskah): satu hadis, satu kesatuan.
Map<String, SceneDef> scenesB() => {
      // Empat kepingan busur melayang dari empat penjuru lalu terkunci.
      's21': SceneDef(
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
      // Ummus Sunnah: lengkung dengan cabang-cabang yang tumbuh keluar.
      's22': SceneDef(2.2, () {
        final ops = <Op>[
          ...arch(x: 50, y: 40, r: 22, w: 8, t: 0, stag: 0.12, d: 0.3)
        ];
        for (var i = 0; i < 4; i++) {
          final o = archPt(i, 50, 40, 22, 8);
          final a = math.pi + (i + 0.5) * math.pi / 4;
          final ox = o.dx + math.cos(a) * 12, oy = o.dy + math.sin(a) * 12;
          ops.addAll([
            L(o.dx + math.cos(a) * 4, o.dy + math.sin(a) * 4, ox, oy,
                t: 0.7 + i * 0.12, d: 0.4),
            D(ox, oy, r: 1.1, t: 1.0 + i * 0.12, d: 0.2),
            for (final s in [-0.5, 0.5])
              L(ox, oy, ox + math.cos(a + s) * 7, oy + math.sin(a + s) * 7,
                  t: 1.2 + i * 0.12, d: 0.35, tone: 0.7),
            for (final s in [-0.5, 0.5])
              D(ox + math.cos(a + s) * 7, oy + math.sin(a + s) * 7,
                  r: 0.7, t: 1.5 + i * 0.1, d: 0.2, tone: 0.8),
          ]);
        }
        ops.add(T('أُمُّ السُّنَّةِ', 50, 44, t: 1.7, d: 0.4, size: 6));
        return ops;
      }, alt: 'Lengkung Empat Bagian dengan cabang ilmu yang tumbuh'),
      // Tiga ikon: satu ruang, satu pusat, satu ikatan.
      's23': SceneDef(2.2, () {
        final cap = [
          L3('Satu majelis', 'One gathering', 'مجلس واحد'),
          L3('Satu pusat', 'One centre', 'مركز واحد'),
          L3('Satu ikatan', 'One bond', 'رباط واحد'),
        ];
        const xs = [17.0, 50.0, 83.0];
        final ops = <Op>[];
        for (var k = 0; k < 3; k++) {
          final t0 = k * 0.6;
          final cx = xs[k], cy = 24.0;
          if (k == 0) ops.add(R(cx, cy, 12, t: t0, d: 0.4));
          if (k == 1)
            ops.addAll([
              G(cx, cy, 14, t: t0, d: 0.5),
              D(cx, cy, r: 2.2, t: t0, d: 0.3)
            ]);
          if (k == 2) ops.add(R(cx, cy, 13, t: t0 + 0.2, d: 0.5, dash: false));
          for (var i = 0; i < 4; i++) {
            final a = i * math.pi / 2 + math.pi / 4;
            ops.add(D(cx + math.cos(a) * 6.5, cy + math.sin(a) * 6.5,
                r: 1.2, t: t0 + 0.1 + i * 0.07, d: 0.25));
            if (k == 1)
              ops.add(L(cx, cy, cx + math.cos(a) * 6.5, cy + math.sin(a) * 6.5,
                  t: t0 + 0.3, d: 0.3, tone: 0.6));
          }
          ops.add(T(cap[k], cx, 46, t: t0 + 0.3, d: 0.3, size: 3.4));
        }
        return ops;
      }, alt: 'Satu ruang, satu pusat, satu ikatan'),
      // Buku empat bab; bab keempat dirobek, bangunan miring.
      's24': SceneDef(2.2, () {
        final ops = <Op>[];
        for (var i = 0; i < 4; i++) {
          final x = 22.0 + i * 15;
          ops.add(B(x, 34, 13, 26,
              fill: true,
              tone: 0.2,
              t: i * 0.1,
              d: 0.3,
              mx: i == 3 ? 24 : 0,
              my: i == 3 ? -6 : [0.0, 2.0, 5.0][i],
              mt: 1.0,
              md: 0.7));
          ops.add(B(x, 34, 13, 26,
              t: i * 0.1,
              d: 0.3,
              mx: i == 3 ? 24 : 0,
              my: i == 3 ? -6 : [0.0, 2.0, 5.0][i],
              mt: 1.0,
              md: 0.7));
          ops.add(T('${i + 1}', x, 34,
              t: i * 0.1 + 0.2,
              d: 0.3,
              size: 6,
              mx: i == 3 ? 24 : 0,
              my: i == 3 ? -6 : [0.0, 2.0, 5.0][i],
              mt: 1.0,
              md: 0.7));
        }
        ops.add(L(16, 50, 70, 50, t: 0.5, d: 0.5, tone: 0.5));
        return ops;
      }, alt: 'Bangunan empat bab kehilangan keseimbangan saat bab keempat dicabut'),
      // Empat bukti: centang menyalakan segmen demi segmen.
      's25': SceneDef(
          2.3,
          () => [
                ...arch(
                    x: 50,
                    y: 42,
                    r: 30,
                    w: 10,
                    t: 0,
                    stag: 0,
                    d: 0.3,
                    fill: false,
                    tone: 0.35),
                for (var i = 0; i < 4; i++) ...[
                  _seg(i, 50, 42, 30, 10, t: 0.3 + i * 0.5, d: 0.3),
                  () {
                    final o = archPt(i, 50, 42, 30, 10);
                    return Ck(o.dx, o.dy, 3,
                        t: 0.5 + i * 0.5, d: 0.25, tone: 0.0 + 1);
                  }(),
                ],
              ],
          alt: 'Empat centang menyalakan empat segmen'),
      // Imam al-Bukhari: judul bab dengan dua frasa saksi digarisbawahi.
      's26': SceneDef(
          2.5,
          () => [
                Op(Sk.stack, 14, 30, w: 16, h: 4.4, t: 0, d: 0.4),
                for (var i = 0; i < 3; i++)
                  L(30, 14.0 + i * 5, i == 2 ? 70 : 90, 14.0 + i * 5,
                      t: 0.4 + i * 0.12, d: 0.4, tone: 0.45),
                T('«فِقْهُ البُخَارِيِّ فِي تَرَاجِمِهِ»', 56, 6,
                    t: 0.0, d: 0.4, size: 4.6),
                T('«وَعِلْمِ السَّاعَةِ»', 50, 34, t: 1.0, d: 0.4, size: 6.4),
                L(31, 38.5, 69, 38.5, t: 1.3, d: 0.5),
                T('«فَجَعَلَ ذَلِكَ كُلَّهُ دِينًا»', 50, 45,
                    t: 1.6, d: 0.4, size: 6.4),
                L(27, 49.5, 73, 49.5, t: 1.9, d: 0.5),
                G(50, 40, 24, t: 1.3, d: 0.8, tone: 0.5),
              ],
          alt: 'Judul bab Imam al-Bukhari dengan dua frasa kunci'),
      // Setiap bagian melahirkan satu cabang ilmu.
      's27': SceneDef(2.4, () {
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
      // Tiga segmen terang, yang keempat redup.
      's28': SceneDef(
          1.2,
          () => [
                ...arch(
                    x: 50,
                    y: 42,
                    r: 30,
                    w: 10,
                    t: 0,
                    stag: 0.1,
                    d: 0.3,
                    lit: 3),
                _seg(3, 50, 42, 30, 10,
                    t: 0.4, d: 0.3, fill: false, dash: true, tone: 0.6),
                T('?', 50, 38, t: 0.6, d: 0.3, size: 8, tone: 0.6),
              ],
          alt: 'Segmen keempat redup'),
      // Wadah tertutup lalu terbuka seiring waktu.
      's29': SceneDef(2.2, () {
        final p = archPt(3, 36, 40, 26, 9);
        return [
          ...arch(x: 36, y: 40, r: 26, w: 9, t: 0, stag: 0.05, d: 0.25, lit: 3),
          _seg(3, 36, 40, 26, 9, t: 0.2, d: 0.2, tone: 0.5),
          B(p.dx, p.dy, 20, 22, r: 2, t: 0.3, d: 0.3, out: 1.5, tone: 0.9),
          L(p.dx - 10, p.dy - 11, p.dx + 10, p.dy - 11,
              t: 0.3, d: 0.2, my: -9, mt: 1.1, md: 0.5, out: 1.6),
          G(p.dx, p.dy, 14, t: 1.5, d: 0.5),
          _seg(3, 36, 40, 26, 9, t: 1.5, d: 0.3),
          L(10, 52, 90, 52, t: 0.2, d: 0.4, tone: 0.55),
          D(10, 52, r: 1.4, t: 0.3, d: 0.2, mx: 80, mt: 0.3, md: 1.7),
          T(L3('Zaman kita', 'Our time', 'زماننا'), 80, 47,
              t: 1.6, d: 0.3, size: 3.2),
        ];
      }, alt: 'Wadah segmen keempat terbuka seiring waktu'),
      // Dua wadah ilmu Abu Hurairah.
      's30': SceneDef(2.2, () {
        final ops = <Op>[
          Op(Sk.arc, 26, 22,
              r: 13, a0: 0, a1: math.pi, t: 0, d: 0.5, draw: true),
          L(13, 22, 39, 22, t: 0.0, d: 0.3, tone: 0.4, dash: true),
          B(72, 30, 22, 24, r: 3, t: 0.2, d: 0.4),
          L(61, 21, 83, 21, t: 0.4, d: 0.3),
          Op(Sk.lock, 72, 31, w: 10, h: 15, t: 1.2, d: 0.3),
          T(L3('Disebarkan', 'Spread', 'بُثَّ'), 26, 46,
              t: 1.4, d: 0.3, size: 3.6),
          T(L3('Dijaga', 'Guarded', 'حُفِظَ'), 72, 46,
              t: 1.5, d: 0.3, size: 3.6),
        ];
        for (var i = 0; i < 9; i++) {
          final a = -math.pi + (i + 0.5) * math.pi / 9;
          ops.add(D(26 + math.cos(a) * 2, 20 + math.sin(a) * 2,
              r: 0.9,
              t: 0.5 + i * 0.07,
              d: 0.2,
              mx: math.cos(a) * 15,
              my: math.sin(a) * 14,
              mt: 0.5 + i * 0.07,
              md: 0.9,
              out: 1.8));
        }
        return ops;
      }, alt: 'Dua wadah ilmu: satu disebarkan, satu dijaga'),
      // Dahulu terlindungi, sekarang gelombang datang dan cahaya menjadi perisai.
      's31': SceneDef(
          2.4,
          () => [
                L(10, 40, 90, 40, t: 0, d: 0.5, tone: 0.5),
                D(22, 40, r: 1.4, t: 0.1, d: 0.2),
                D(78, 40, r: 1.4, t: 0.1, d: 0.2),
                T(L3('Dahulu', 'Then', 'قديمًا'), 22, 47,
                    t: 0.3, d: 0.3, size: 3.6),
                T(L3('Sekarang', 'Now', 'اليوم'), 78, 47,
                    t: 0.3, d: 0.3, size: 3.6),
                R(22, 22, 12, t: 0.3, d: 0.5, tone: 0.8),
                for (var i = 0; i < 6; i++)
                  D(22 + math.cos(i * math.pi / 3) * 6,
                      22 + math.sin(i * math.pi / 3) * 6,
                      r: 1.1, t: 0.6 + i * 0.05, d: 0.2),
                for (var i = 0; i < 6; i++)
                  D(78 + math.cos(i * math.pi / 3) * 5,
                      28 + math.sin(i * math.pi / 3) * 5,
                      r: 1.1, t: 0.9 + i * 0.05, d: 0.2),
                for (var k = 0; k < 3; k++) ...[
                  W(54, 66, 14 + k * 5.0, 1.6, 2,
                      t: 1.0 + k * 0.1, d: 0.5, tone: 0.55),
                  W(90, 100, 14 + k * 5.0, 1.6, 2,
                      t: 1.0 + k * 0.1, d: 0.5, tone: 0.55),
                ],
                Op(Sk.arc, 78, 28,
                    r: 14,
                    a0: math.pi * 1.05,
                    a1: math.pi * 1.95,
                    t: 1.7,
                    d: 0.5,
                    draw: true),
                G(78, 14, 10, t: 1.7, d: 0.6),
              ],
          alt: 'Dahulu terlindungi; sekarang cahaya menjadi perisai'),
      // Yang tetap dan yang berubah.
      's32': SceneDef(2.2, () {
        final ops = <Op>[
          ...arch(x: 50, y: 30, r: 22, w: 8, t: 0, stag: 0.08, d: 0.25, lit: 3),
          _seg(3, 50, 30, 22, 8, t: 0.2, d: 0.2, fill: false, tone: 0.5),
          L(10, 48, 90, 48, t: 0.2, d: 0.4, tone: 0.5),
          D(10, 48, r: 1.5, t: 0.5, d: 0.2, mx: 80, mt: 0.5, md: 0.7, out: 1.3),
          D(90, 48,
              r: 1.5, t: 1.2, d: 0.1, mx: -80, mt: 1.2, md: 0.7, out: 1.95),
          _seg(3, 50, 30, 22, 8, t: 2.0, d: 0.2),
          T(L3('Yang tetap', 'The constants', 'الثوابت'), 22, 40,
              t: 0.9, d: 0.3, size: 3.4),
          T(L3('Yang berubah', 'The shifting', 'المتغيرات'), 78, 40,
              t: 1.0, d: 0.3, size: 3.4),
        ];
        return ops;
      }, alt: 'Tiga segmen tetap, segmen keempat memindai yang berubah'),
      // 5, 6, 2 — tidak berubah.
      's33': SceneDef(2.0, () {
        const xs = [17.0, 50.0, 83.0];
        final nums = ['5', '6', '2'];
        final cap = [
          L3('Rukun Islam', 'Pillars of Islam', 'أركان الإسلام'),
          L3('Rukun Iman', 'Pillars of Iman', 'أركان الإيمان'),
          L3('Tingkat Ihsan', 'Levels of Ihsan', 'مراتب الإحسان'),
        ];
        return [
          for (var i = 0; i < 3; i++) ...[
            R(xs[i], 24, 12,
                t: i * 0.3, d: 0.5, pulse: 0.1, mt: 0.6 + i * 0.3, md: 0.3),
            T(nums[i], xs[i], 24, t: i * 0.3 + 0.2, d: 0.3, size: 13),
            T(cap[i], xs[i], 46, t: i * 0.3 + 0.4, d: 0.3, size: 3.3),
          ],
        ];
      }, alt: 'Lima, enam, dan dua tidak berubah'),
      // Gembok (waktu) dan rambu (tanda).
      's34': SceneDef(
          1.2,
          () => [
                Op(Sk.lock, 26, 24, w: 20, h: 30, t: 0, d: 0.35),
                Op(Sk.sign, 66, 28, w: 22, h: 30, fill: true, t: 0.3, d: 0.35),
                T(L3('Waktu Kiamat', 'The Hour', 'وقت الساعة'), 26, 46,
                    t: 0.5, d: 0.3, size: 3.4),
                T(L3('Tanda Zaman', 'Signs', 'علامات الساعة'), 74, 46,
                    t: 0.6, d: 0.3, size: 3.4),
              ],
          alt: 'Gembok untuk waktu, rambu untuk tanda'),
      's35': SceneDef(
          2.2,
          () => [
                L(50, 6, 50, 52, t: 0, d: 0.3, tone: 0.3, dash: true),
                Op(Sk.cal, 25, 17, w: 20, h: 18, t: 0, d: 0.3),
                X(25, 17, 9, t: 0.5, d: 0.3),
                Op(Sk.lock, 25, 40, w: 14, h: 20, t: 0.8, d: 0.3),
                for (var i = 0; i < 3; i++)
                  Op(Sk.sign, 60.0 + i * 14, 24,
                      w: 9, h: 16, fill: true, t: 0.7 + i * 0.4, d: 0.3),
                W(56, 94, 44, 3.5, 2, t: 0.7, d: 0.6, tone: 0.5),
                D(56, 44, r: 1.5, t: 0.9, d: 0.2, mx: 38, mt: 1.0, md: 1.1),
              ],
          alt: 'Larangan menebak tahun; tiga rambu menuntun dengan selamat'),
      // Pagar pelindung dan radar.
      's36': SceneDef(2.4, () {
        final ops = <Op>[
          ...arch(x: 50, y: 44, r: 20, w: 8, t: 0, stag: 0.1, d: 0.3, lit: 3),
          _seg(3, 50, 44, 20, 8, t: 0.3, d: 0.2, fill: false, tone: 0.6),
          Op(Sk.arc, 50, 44,
              r: 28, a0: math.pi, a1: math.pi * 2, t: 0.5, d: 0.7, draw: true),
        ];
        for (var s = 0; s < 2; s++) {
          for (var i = 0; i < 6; i++) {
            final a = math.pi * 1.0 + (i + 0.5) * math.pi / 6;
            ops.add(L(50, 44, 50 + math.cos(a) * 34, 44 + math.sin(a) * 34,
                t: 1.0 + s * 0.6 + i * 0.07,
                d: 0.05,
                tone: 0.5,
                out: 1.0 + s * 0.6 + i * 0.07 + 0.12));
          }
        }
        ops.addAll([
          D(6, 8, r: 1.4, t: 1.3, d: 0.3, mx: 8, my: 4, mt: 1.5, md: 0.6),
          D(94, 8, r: 1.4, t: 1.3, d: 0.3, mx: -8, my: 4, mt: 1.5, md: 0.6),
          X(14, 12, 2, t: 2.0, d: 0.2),
          X(86, 12, 2, t: 2.0, d: 0.2),
        ]);
        return ops;
      }, alt: 'Radar memindai dan pagar menahan bahaya'),
      // Dua tugas: memperbarui dakwah dan menjaga kemurnian ilmu.
      's37': SceneDef(
          2.4,
          () => [
                L(50, 6, 50, 50, t: 0, d: 0.3, tone: 0.3, dash: true),
                W(8, 44, 28, 6, 3, t: 0, d: 0.4, sharp: true, out: 0.8),
                W(8, 44, 28, 5, 3, t: 0.8, d: 0.9),
                Op(Sk.arc, 76, 40,
                    r: 18,
                    a0: math.pi,
                    a1: math.pi * 2,
                    t: 0.4,
                    d: 0.5,
                    draw: true),
                for (var i = 0; i < 3; i++) ...[
                  D(98, 10.0 + i * 10,
                      r: 1.2,
                      t: 0.8,
                      d: 0.2,
                      mx: -17,
                      my: 7.0 + i * 5,
                      mt: 1.0 + i * 0.15,
                      md: 0.5,
                      out: 1.7),
                  D(81, 17.0 + i * 15,
                      r: 1.2,
                      t: 1.7,
                      d: 0.1,
                      mx: 16,
                      my: -6,
                      mt: 1.7,
                      md: 0.6,
                      out: 2.4,
                      tone: 0.5),
                ],
                T(L3('Dakwah yang halus', 'Gentle outreach', 'دعوة لطيفة'), 26,
                    46,
                    t: 1.4, d: 0.3, size: 3.3),
                T(L3('Ilmu yang murni', 'Pure knowledge', 'علم نقي'), 76, 48,
                    t: 1.4, d: 0.3, size: 3.3),
              ],
          alt: 'Gelombang halus dan dinding pelindung ilmu'),
      // Dua kendali.
      's38': SceneDef(
          2.5,
          () => [
                L(50, 6, 50, 52, t: 0, d: 0.3, tone: 0.3, dash: true),
                R(14, 24, 8, t: 0, d: 0.4),
                R(36, 24, 8, t: 0.1, d: 0.4, dash: true, tone: 0.8),
                R(14, 13, 2.8, t: 0.4, d: 0.3, mx: 22, mt: 1.0, md: 0.8),
                T(L3('Ulama ahli', 'Qualified scholar', 'أهل العلم'), 14, 40,
                    t: 0.4, d: 0.3, size: 3.1),
                T(L3('Bukan ahlinya', 'Unqualified', 'غير أهله'), 36, 40,
                    t: 1.2, d: 0.3, size: 3.1),
                R(64, 24, 8, t: 0, d: 0.4),
                R(86, 24, 8, t: 0.1, d: 0.4, dash: true, tone: 0.8),
                R(64, 13, 2.8, t: 0.4, d: 0.3, mx: 22, mt: 1.3, md: 0.8),
                for (var i = 0; i < 4; i++)
                  Col(60.0 + i * 8, 52, 4, [8.0, 22.0, 12.0, 28.0][i],
                      t: 1.6 + i * 0.1, d: 0.5),
                T('«قَرَارُ العِلْمِ»', 25, 49, t: 0.5, d: 0.3, size: 4),
              ],
          alt:
              'Kendali ilmu dan kendali kekuasaan berpindah ke yang bukan ahlinya'),
      // Rantai lima mata cincin: hukum terlepas dulu, salat paling akhir.
      's39': SceneDef(2.4, () {
        final ops = <Op>[];
        for (var i = 0; i < 5; i++) {
          final y = 8.0 + i * 10.5;
          final lose = i < 3;
          ops.add(B(40, y, 7, 14,
              r: 3.5,
              t: i * 0.08,
              d: 0.3,
              mx: i == 0 ? 14 : 0,
              my: i == 0 ? -2 : 0,
              mt: 0.7 + i * 0.35,
              md: 0.6,
              tone: i == 4 ? 1 : 0.9,
              sh: lose && i > 0 ? 0.7 : 0,
              st: 0.7 + i * 0.35,
              sd: 0.6,
              i: i));
        }
        ops.addAll([
          T('«الحُكْمُ»', 66, 8, t: 0.6, d: 0.3, size: 5),
          X(54, 12, 2.2, t: 1.0, d: 0.25, tone: 0.8),
          G(40, 50.5, 12, t: 1.8, d: 0.5),
          T('«الصَّلَاةُ»', 66, 50, t: 1.9, d: 0.3, size: 5),
        ]);
        return ops;
      }, alt: 'Rantai ikatan Islam terurai satu demi satu, salat paling akhir'),
    };
