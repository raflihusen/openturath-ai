// ignore_for_file: non_constant_identifier_names, prefer_const_constructors
import 'dart:math' as math;

import 'tahawwulat_scene.dart';
import 'tahawwulat_scene_kit.dart';

Op _seg(int i, double x, double y, double r, double w,
        {double t = 0, double d = 0.35, double tone = 1, bool fill = true, bool dash = false}) =>
    Op(Sk.seg, x, y,
        r: r, w: w, idx: i, t: t, d: d, tone: tone, fill: fill, draw: !fill, dash: dash);

/// Adegan Bab 3 (slide 40-54 naskah + dua cara membaca peristiwa).
Map<String, SceneDef> scenesC() => {
      's40': SceneDef(1.2, () => [
            W(12, 88, 16, 3, 3, t: 0, d: 0.6),
            ...arch(x: 50, y: 46, r: 28, w: 9, t: 0.3, stag: 0.08, d: 0.3),
          ], alt: 'Gelombang menyatu dengan Lengkung Empat Bagian'),
      // Sumbu kedalaman (fikih) dan arus perubahan (tahawwulat).
      's41': SceneDef(2.4, () => [
            L(50, 4, 50, 52, t: 0, d: 0.6),
            T(L3('Fikih · kedalaman', 'Fiqh · depth', 'الفقه · العمق'), 74, 8, t: 0.4, d: 0.3, size: 3.4),
            W(8, 92, 28, 4, 3, t: 0.7, d: 0.7),
            T(L3('Tahawwulat · arus perubahan', 'Tahawwulat · the flow of change', 'التحولات · تيار التغيّر'), 30, 41, t: 1.1, d: 0.3, size: 3.4),
            G(50, 28, 10, t: 1.6, d: 0.5),
            D(50, 28, r: 1.8, t: 1.6, d: 0.3),
            R(50, 28, 7, t: 1.7, d: 0.4, tone: 0.7),
          ], alt: 'Dua sumbu bersilang membentuk kompas'),
      's42': SceneDef(1.2, () => [
            R(50, 28, 25, t: 0.2, d: 0.5, dash: true, tone: 0.6),
            R(50, 28, 12, t: 0, d: 0.4, fill: true),
            T(L3('Halal & Haram', 'Halal & Haram', 'حلال وحرام'), 50, 28, t: 0.3, d: 0.3, size: 2.6),
            T(L3('Fikih sempit', 'Narrow fiqh', 'فقه ضيّق'), 50, 42, t: 0.5, d: 0.3, size: 3.3, tone: 0.7),
          ], alt: 'Lingkaran kecil halal-haram di tengah lingkaran luas'),
      's43': SceneDef(2.2, () => [
            R(50, 28, 24, r2: 8, t: 0, d: 0.3, mt: 0.2, md: 0.9, out: 1.1, dash: true),
            R(50, 28, 8, r2: 26, t: 1.1, d: 0.2, mt: 1.1, md: 0.9, draw: false),
            ...arch(x: 50, y: 40, r: 20, w: 7, t: 1.6, stag: 0.08, d: 0.25),
          ], alt: 'Makna fikih menyempit lalu mengembang kembali'),
      's44': SceneDef(2.2, () {
        const xs = [17.0, 50.0, 83.0];
        final cap = [
          L3('Paham', 'Understand', 'الفهم'),
          L3('Tepat sasaran', 'Hit the mark', 'إصابة المقصد'),
          L3('Cakupan luas', 'Wide scope', 'سعة الشمول'),
        ];
        return [
          for (var i = 0; i < 3; i++) B(xs[i], 22, 28, 30, r: 3, t: i * 0.6, d: 0.35),
          D(10, 22, r: 1.6, t: 0.3, d: 0.2), D(24, 22, r: 1.6, t: 0.4, d: 0.2),
          L(10, 22, 24, 22, t: 0.5, d: 0.3),
          R(50, 22, 9, t: 0.9, d: 0.3), R(50, 22, 4, t: 0.95, d: 0.3, tone: 0.7),
          L(40, 12, 49, 21, t: 1.2, d: 0.3), D(50, 22, r: 1.5, t: 1.45, d: 0.2),
          B(83, 22, 22, 22, r: 2, t: 1.7, d: 0.3, tone: 0.6),
          for (var k = 0; k < 4; k++)
            R(78 + (k % 2) * 10.0, 17 + (k ~/ 2) * 10.0, 3.6, t: 1.8 + k * 0.08, d: 0.25),
          for (var i = 0; i < 3; i++) T(cap[i], xs[i], 46, t: i * 0.6 + 0.3, d: 0.3, size: 3.3),
        ];
      }, alt: 'Paham, tepat sasaran, dan cakupan luas'),
      's45': SceneDef(2.2, () => [
            for (var i = 0; i < 8; i++)
              L(10, 5.0 + i * 6.2, 52, 5.0 + i * 6.2, t: i * 0.1, d: 0.25, tone: i >= 6 ? 1 : 0.4),
            G(31, 42, 14, t: 1.0, d: 0.5, tone: 0.7),
            T('7', 58, 42, t: 1.0, d: 0.2, size: 4, tone: 0.8),
            T('8', 58, 48, t: 1.1, d: 0.2, size: 4, tone: 0.8),
            R(77, 28, 15, t: 1.5, d: 0.4),
            T('«فَقِهَ»', 77, 28, t: 1.6, d: 0.3, size: 8),
          ], alt: 'Delapan ayat; dua terakhir menyala; cap faqiha'),
      's46': SceneDef(2.0, () => [
            G(50, 26, 22, t: 0.5, d: 0.9),
            Op(Sk.gate, 50, 24, w: 24, h: 36, t: 0, d: 0.3, mt: 0.3, md: 1.2),
            T('«فِي الدِّينِ»', 50, 49, t: 1.0, d: 0.4, size: 7),
          ], alt: 'Pintu terbuka menyinari kata fid-din'),
      's47': SceneDef(1.2, () => [
            ...arch(x: 50, y: 42, r: 30, w: 10, t: 0, stag: 0.1, d: 0.3, lit: 1),
          ], alt: 'Hanya segmen pertama terisi'),
      's48': SceneDef(2.2, () => [
            G(50, 38, 32, t: 1.8, d: 0.4, tone: 0.5),
            ...arch(x: 50, y: 42, r: 30, w: 10, t: 0, stag: 0.45, d: 0.4),
          ], alt: 'Empat segmen menyala menjadi satu kesatuan'),
      's49': SceneDef(2.0, () {
        final p = archPt(0, 50, 36, 22, 8);
        return [
          ...arch(x: 50, y: 36, r: 22, w: 8, t: 0, stag: 0.05, d: 0.25, tone: 0.9),
          R(p.dx, p.dy, 5.5, t: 0.4, d: 0.3, pulse: 0.1, mt: 0.7, md: 0.3),
          T(L3('5 rukun amaliah', '5 practical pillars', 'الأركان العملية'), 16, 52, t: 0.5, d: 0.3, size: 3.3),
          R(50, 36, 14, r2: 32, t: 1.0, d: 0.1, mt: 1.0, md: 0.9, dash: true, draw: false),
          T(L3('Agama Islam utuh (4 pilar)', 'The whole religion (4 pillars)', 'الدين كله (٤ أركان)'), 70, 52, t: 1.6, d: 0.3, size: 3.3),
        ];
      }, alt: 'Rukun amaliah dirangkul agama Islam yang utuh'),
      's50': SceneDef(2.2, () => [
            W(4, 44, 28, 5, 2, t: 0, d: 0.7),
            Op(Sk.scale, 50, 20, w: 14, h: 24, a0: 0.3, a1: 0, t: 0.5, d: 0.3, mt: 0.8, md: 0.6),
            L(58, 28, 94, 14, t: 1.2, d: 0.5),
            T(L3('Selamat', 'Safe', 'السلامة'), 82, 9, t: 1.6, d: 0.3, size: 3.5),
            W(58, 94, 42, 3, 3, t: 1.2, d: 0.5, sharp: true, tone: 0.35),
            T(L3('Bahaya', 'Danger', 'الخطر'), 82, 51, t: 1.6, d: 0.3, size: 3.5, tone: 0.5),
          ], alt: 'Gelombang zaman disaring timbangan wahyu'),
      's51': SceneDef(1.2, () => [
            for (var i = 0; i < 3; i++) ...[
              B(16.0 + i * 6, 14.0 + i * 12, 20, 8, r: 3, t: i * 0.12, d: 0.3),
              W(8, 38, 20.0 + i * 12, 1.8, 3, t: 0.3 + i * 0.1, d: 0.3, sharp: true, tone: 0.4),
            ],
            T('≠', 50, 28, t: 0.4, d: 0.3, size: 12),
            ...arch(x: 76, y: 38, r: 18, w: 6, t: 0.5, stag: 0.05, d: 0.25),
          ], alt: 'Obrolan kusut tidak sama dengan lengkung yang tenang'),
      's52': SceneDef(2.5, () {
        final ops = <Op>[L(50, 4, 50, 52, t: 0, d: 0.3, tone: 0.3, dash: true)];
        for (var r = 0; r < 4; r++) {
          final y = 9.0 + r * 12;
          final t0 = r * 0.5;
          switch (r) {
            case 0:
              ops.addAll([
                L(18, y + 3, 32, y - 3, t: t0, d: 0.2, mt: t0, md: 0.5, mx: 0, my: 0),
                L(18, y - 3, 32, y + 3, t: t0 + 0.1, d: 0.2),
                R(76, y, 4.5, t: t0, d: 0.3),
                L(76, y, 76, y - 3.6, t: t0 + 0.2, d: 0.2),
              ]);
            case 1:
              ops.addAll([
                Op(Sk.cal, 25, y, w: 12, h: 9, t: t0, d: 0.3),
                X(25, y, 5, t: t0 + 0.2, d: 0.2),
                Op(Sk.cal, 75, y, w: 12, h: 9, t: t0, d: 0.3),
                X(75, y, 5, t: t0 + 0.2, d: 0.2),
              ]);
            case 2:
              ops.addAll([
                W(16, 36, y, 3, 3, t: t0, d: 0.3, sharp: true),
                W(64, 86, y, 2, 2, t: t0, d: 0.3),
              ]);
            default:
              for (var k = 0; k < 6; k++) {
                ops.add(D(22.0 + jit(k, 3, 8), y + jit(k, 4, 3), r: 0.9, t: t0, d: 0.3, sh: 1.2, st: t0, sd: 0.7, i: k));
                final a = k * math.pi / 3;
                ops.add(D(75 + math.cos(a) * 5, y + math.sin(a) * 3.2, r: 0.9, t: t0, d: 0.3));
              }
              ops.add(D(75, y, r: 1.3, t: t0, d: 0.3));
          }
        }
        return ops;
      }, alt: 'Wacana sensasional bergetar, Fikih Tahawwulat tenang'),
      's53': SceneDef(2.2, () {
        return [
          ...arch(x: 17, y: 34, r: 14, w: 5, t: 0, stag: 0.05, d: 0.2, lit: 3),
          _seg(3, 17, 34, 14, 5, t: 0.3, d: 0.3),
          G(17, 30, 12, t: 0.3, d: 0.4),
          for (var i = 0; i < 3; i++) Col(40.0 + i * 8, 40, 6, 8.0 + i * 7, t: 0.8 + i * 0.2, d: 0.3, tone: 0.9),
          R(58, 18, 6, t: 1.4, d: 0.3), L(58, 18, 58, 13, t: 1.5, d: 0.2), D(58, 18, r: 0.9, t: 1.5, d: 0.2),
          for (var k = 0; k < 5; k++)
            L(72 + jit(k, 5, 4), 14 + jit(k, 6, 4), 94 + jit(k, 7, 4), 40 + jit(k, 8, 6), t: 1.5 + k * 0.05, d: 0.25, tone: 0.55),
          X(83, 28, 11, t: 1.9, d: 0.25),
        ];
      }, alt: 'Segmen keempat, jalur anak tangga, dan jaring konspirasi yang dicoret'),
      's54': SceneDef(2.2, () {
        final names = [
          L3('Al-Qur’an', 'The Qur’an', 'القرآن'),
          L3('As-Sunnah', 'The Sunnah', 'السنّة'),
          L3('Teladan Salaf bersanad', 'Chained Salaf example', 'هدي السلف بالسند'),
        ];
        return [
          for (var i = 0; i < 3; i++) ...[
            B(40, 9.0 + i * 11, 60, 8.5, r: 2.5, t: i * 0.35, d: 0.3, fill: i == 0, tone: i == 0 ? 0.2 : 1, dy: -4),
            B(40, 9.0 + i * 11, 60, 8.5, r: 2.5, t: i * 0.35, d: 0.3, dy: -4),
            T(names[i], 40, 9.0 + i * 11, t: i * 0.35 + 0.15, d: 0.3, size: 3.3, dy: -4),
          ],
          L(84, 4, 84, 40, t: 1.2, d: 0.5),
          D(84, 44, r: 1.8, t: 1.7, d: 0.2),
          R(84, 44, 5, t: 1.8, d: 0.3, tone: 0.7),
          T(L3('Peristiwa kini', 'Today’s events', 'نازلة اليوم'), 84, 52, t: 1.8, d: 0.3, size: 3.2),
        ];
      }, alt: 'Tiga lapis fondasi menimbang peristiwa masa kini'),
      // Dua cara membaca peristiwa.
      'n1': SceneDef(2.4, () => [
            T(L3('Mengekor: bersikap setelah peristiwa', 'Trailing: reacting after the event', 'اللاحق: بعد وقوع الحدث'), 50, 5, t: 0, d: 0.3, size: 3.5),
            L(10, 16, 90, 16, t: 0, d: 0.4, tone: 0.5),
            L(50, 8, 50, 24, t: 0.2, d: 0.2),
            D(50, 16, r: 2.2, t: 0.3, d: 0.2),
            D(54, 16, r: 1.3, t: 0.8, d: 0.2, mx: 28, mt: 0.9, md: 0.8, tone: 0.8),
            T(L3('Mengikuti arus', 'Swept along', 'ينجرف مع التيار'), 78, 23, t: 1.6, d: 0.3, size: 3.2, tone: 0.7),
            T(L3('Antisipatif: bersikap dengan wahyu sebelum peristiwa', 'Anticipatory: guided by revelation beforehand', 'استباقي: الموقف بنور الوحي قبل الحدث'), 50, 33, t: 0.9, d: 0.3, size: 3.5),
            L(10, 44, 90, 44, t: 1.0, d: 0.4, tone: 0.5),
            L(70, 36, 70, 52, t: 1.1, d: 0.2),
            D(70, 44, r: 2.2, t: 1.2, d: 0.2),
            G(22, 44, 8, t: 1.3, d: 0.4),
            D(14, 44, r: 1.6, t: 1.4, d: 0.2, mx: 40, mt: 1.7, md: 0.6),
            Op(Sk.spark, 36, 44, r: 3, t: 1.9, d: 0.3),
          ], alt: 'Dua garis waktu: mengekor setelah peristiwa dan antisipatif sebelum peristiwa'),
    };
