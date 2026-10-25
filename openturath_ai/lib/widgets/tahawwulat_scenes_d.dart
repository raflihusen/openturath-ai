// ignore_for_file: non_constant_identifier_names, prefer_const_constructors
import 'dart:math' as math;

import 'tahawwulat_scene.dart';
import 'tahawwulat_scene_kit.dart';

/// Adegan Bab 4 (lima cabang) dan Bab 5 (jalan selamat).
Map<String, SceneDef> scenesD() => {
      's58': SceneDef(2.2, () => [
            for (var i = 0; i < 5; i++) ...[
              G(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy, 6, t: i * 0.25, d: 0.3),
              D(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy, r: 1.8, t: i * 0.25, d: 0.3),
            ],
            Pg(50, 30, 20, 5, t: 1.2, d: 0.8),
          ], alt: 'Lima titik membentuk Peta Segi Lima'),
      's59': SceneDef(1.2, () => [
            Pg(50, 30, 20, 5, t: 0, d: 0.4, tone: 0.35),
            for (var i = 0; i < 5; i++)
              D(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy, r: 1.4, t: 0.1, d: 0.2, tone: i == 3 ? 1 : 0.35),
            G(pentaPt(3, 50, 30, 20).dx, pentaPt(3, 50, 30, 20).dy, 8, t: 0.5, d: 0.2, out: 0.9),
          ], alt: 'Satu simpul kecil berkedip di Peta Segi Lima'),
      's60': SceneDef(2.3, () {
        final p = pentaPt(3, 50, 30, 20);
        return [
          Pg(50, 30, 20, 5, t: 0, d: 0.3, tone: 0.35),
          for (var i = 0; i < 5; i++)
            D(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy, r: 1.4, t: 0, d: 0.2, tone: 0.4),
          R(p.dx, p.dy, 2, r2: 12, t: 0.2, d: 0.2, mt: 0.2, md: 0.8, out: 1.4, draw: false),
          D(p.dx, p.dy, r: 1.8, t: 0.2, d: 0.2),
          T(L3('Tanda Besar', 'Major signs', 'العلامات الكبرى'), p.dx, p.dy + 11, t: 0.8, d: 0.3, size: 3.4, out: 1.4),
          Pg(50, 30, 20, 5, t: 1.4, d: 0.5),
          for (var i = 0; i < 5; i++)
            D(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy, r: 1.8, t: 1.5 + i * 0.08, d: 0.2),
          G(50, 30, 28, t: 1.6, d: 0.5, tone: 0.5),
        ];
      }, alt: 'Zoom ke tanda besar lalu mundur melihat kelima simpul'),
      's61': SceneDef(2.4, () => [
            Pg(50, 30, 20, 5, t: 0, d: 0.4, tone: 0.6),
            for (var i = 0; i < 5; i++) ...[
              G(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy, 7, t: 0.6, d: 0.4),
              D(pentaPt(i, 50, 30, 20).dx, pentaPt(i, 50, 30, 20).dy, r: 2, t: 0.6, d: 0.3),
              T('${i + 1}', pentaPt(i, 50, 30, 27.5).dx, pentaPt(i, 50, 30, 27).dy + (i >= 2 && i <= 3 ? 1.5 : 0), t: 0.7 + i * 0.25, d: 0.3, size: 4.4),
            ],
          ], alt: 'Lima simpul menyala bersama nomor 1 sampai 5'),
      's62': SceneDef(2.4, () => [
            L(28, 28, 50, 28, t: 0, d: 0.3),
            L(50, 28, 72, 28, t: 0, d: 0.3, my: -3, mt: 0.5, md: 0.2),
            X(50, 28, 3, t: 0.6, d: 0.2),
            T('Nawaqidh', 50, 14, t: 0.5, d: 0.3, size: 3.6),
            D(42, 40, r: 1.6, t: 1.0, d: 0.2, mx: -30, mt: 1.3, md: 0.8),
            D(58, 40, r: 1.6, t: 1.0, d: 0.2, mx: 30, mt: 1.3, md: 0.8),
            W(42, 58, 40, 2.4, 2, t: 1.0, d: 0.3, tone: 0.6, out: 1.9),
            T('Tahrisy', 50, 49, t: 1.1, d: 0.3, size: 3.2, tone: 0.8),
            T('Naqa’idh', 12, 49, t: 2.0, d: 0.3, size: 3.4),
            T('Naqa’idh', 88, 49, t: 2.0, d: 0.3, size: 3.4),
          ], alt: 'Garis retak dan dua sikap saling berlawanan menjauh'),
      's63': SceneDef(2.0, () {
        final ops = <Op>[
          G(50, 28, 16, t: 0, d: 0.4),
          D(50, 28, r: 2.4, t: 0, d: 0.3),
          R(50, 28, 12, t: 0.2, d: 0.5),
          T('Fiqh al-Wiqayah', 50, 50, t: 1.3, d: 0.3, size: 3.5),
        ];
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3 + 0.3;
          ops.addAll([
            D(50 + math.cos(a) * 36, 28 + math.sin(a) * 24, r: 1.2, t: 0.6, d: 0.2,
                mx: -math.cos(a) * 23, my: -math.sin(a) * 15.5, mt: 0.7 + i * 0.05, md: 0.5, out: 1.25),
            D(50 + math.cos(a) * 14, 28 + math.sin(a) * 10, r: 0.9, t: 1.25, d: 0.1,
                mx: math.cos(a) * 14, my: math.sin(a) * 10, mt: 1.25, md: 0.5, out: 1.7, tone: 0.5),
          ]);
        }
        return ops;
      }, alt: 'Perisai utuh memantulkan partikel tajam'),
      's64': SceneDef(2.3, () {
        const xs = [14.0, 38.0, 62.0, 86.0];
        final names = ['Isyarat', 'Basyarat', 'Nadzarat', 'Hishanat'];
        return [
          for (var i = 0; i < 4; i++) ...[
            R(xs[i], 22, 4, r2: 11, t: 0.3 + i * 0.5, d: 0.1, mt: 0.3 + i * 0.5, md: 0.8, out: 1.0 + i * 0.5, draw: false, tone: 0.7),
            T(names[i], xs[i], 46, t: 0.3 + i * 0.5, d: 0.3, size: 3.4),
          ],
          Op(Sk.sign, xs[0] - 4, 22, w: 9, h: 12, fill: true, t: 0.2, d: 0.3),
          Op(Sk.spark, xs[1], 22, r: 4.5, t: 0.7, d: 0.3),
          Pg(xs[2], 22, 5, 3, t: 1.2, d: 0.3, fill: false),
          D(xs[2], 22.6, r: 0.7, t: 1.3, d: 0.2),
          Op(Sk.arc, xs[3], 26, r: 6, a0: math.pi, a1: math.pi * 2, t: 1.7, d: 0.3, draw: true),
          L(xs[3] - 6, 26, xs[3] + 6, 26, t: 1.7, d: 0.3),
        ];
      }, alt: 'Empat suar: isyarat, kabar gembira, peringatan, benteng'),
      's65': SceneDef(2.4, () {
        final cap = [
          L3('Sanad', 'Chain', 'السند'),
          L3('Lisan', 'Tongue', 'اللسان'),
          L3('Tangan', 'Hand', 'اليد'),
          L3('Wadah', 'Vessel', 'الوعاء'),
        ];
        return [
          for (var i = 0; i < 6; i++) ...[
            D(12.0 + i * 15.2, 16, r: 1.6, t: i * 0.2, d: 0.2),
            if (i > 0) L(12.0 + (i - 1) * 15.2, 16, 12.0 + i * 15.2, 16, t: i * 0.2, d: 0.2),
          ],
          for (var i = 0; i < 4; i++) ...[
            R(14.0 + i * 24, 38, 7, t: 1.3 + i * 0.25, d: 0.3),
            Ck(14.0 + i * 24, 38, 3.4, t: 1.5 + i * 0.25, d: 0.2),
            T(cap[i], 14.0 + i * 24, 50, t: 1.5 + i * 0.25, d: 0.3, size: 3.3),
          ],
        ];
      }, alt: 'Rantai sanad dikelilingi empat segel selamat'),
      's66': SceneDef(2.3, () => [
            Op(Sk.scale, 50, 24, w: 40, h: 26, a0: -0.28, a1: 0, t: 0, d: 0.3, mt: 1.4, md: 0.7),
            W(10, 22, 8, 2, 2, t: 0.3, d: 0.3),
            B(34, 8, 8, 6, r: 1, t: 0.6, d: 0.3, dy: -5),
            Op(Sk.gear, 20, 6, r: 4, n: 6, t: 0.9, d: 0.3, dy: -3, mt: 1.0, md: 1.0),
            T(L3('Wahyu', 'Revelation', 'الوحي'), 80, 8, t: 1.3, d: 0.3, size: 3.6),
            for (var i = 0; i < 3; i++)
              D(96, 38.0 + i * 5, r: 1.1, t: 1.6, d: 0.2, mx: -9, mt: 1.7 + i * 0.1, md: 0.4, out: 2.1, tone: 0.6),
          ], alt: 'Neraca menimbang sains dan teknologi dengan wahyu'),
      'n3': SceneDef(2.2, () => [
            Op(Sk.stack, 20, 30, w: 18, h: 5, t: 0, d: 0.4),
            L(34, 44, 46, 30, t: 0.4, d: 0.3),
            D(34, 44, r: 1, t: 0.4, d: 0.2),
            T(L3('Pena', 'Pen', 'القلم'), 36, 50, t: 0.5, d: 0.3, size: 3.4),
            W(46, 70, 30, 3, 2, t: 0.8, d: 0.5),
            G(82, 28, 16, t: 1.3, d: 0.5),
            R(82, 28, 10, t: 1.2, d: 0.4),
            Op(Sk.spark, 82, 28, r: 4, t: 1.5, d: 0.3),
            T(L3('Ilmu', 'Knowledge', 'العلم'), 82, 46, t: 1.6, d: 0.3, size: 3.4),
          ], alt: 'Pintu ilmu terbuka melalui pena dan sebab'),
      's67': SceneDef(2.5, () => [
            for (var r = 0; r < 3; r++)
              L(18, 10.0 + r * 18, 92, 10.0 + r * 18, t: r * 0.15, d: 0.3, tone: 0.5),
            T(L3('Kecil', 'Minor', 'الصغرى'), 9, 10, t: 0.1, d: 0.3, size: 3.1),
            T(L3('Tengah', 'Middle', 'الوسطى'), 9, 28, t: 0.2, d: 0.3, size: 3.1),
            T(L3('Besar', 'Major', 'الكبرى'), 9, 46, t: 0.3, d: 0.3, size: 3.1),
            for (var i = 0; i < 6; i++) D(24.0 + i * 11, 10, r: 1.4, t: 0.3 + i * 0.12, d: 0.2),
            L(64, 14, 64, 24, t: 1.0, d: 0.3), Op(Sk.arc, 76, 28, r: 12, a0: math.pi, a1: math.pi * 1.5, t: 1.1, d: 0.4, draw: true, tone: 0.6),
            for (var i = 0; i < 3; i++) D(30.0 + i * 16, 28, r: 1.2, t: 1.0 + i * 0.1, d: 0.2, tone: 0.8),
            Op(Sk.gate, 82, 48, w: 16, h: 14, t: 1.5, d: 0.3),
            L(76, 49, 88, 49, t: 1.7, d: 0.2),
            T(L3('Belum terjadi', 'Not yet', 'لم يقع بعد'), 50, 51, t: 1.9, d: 0.3, size: 3.2),
          ], alt: 'Tiga jalur tanda; tanda besar masih di balik gerbang'),
      's68': SceneDef(2.4, () => [
            for (var i = 0; i < 4; i++) ...[
              R(50, 29, 5.0 + i * 5, t: i * 0.35, d: 0.4),
              T('${i + 1}', 50 + 4.2 + i * 5, 29 - 3.8 - i * 3.5 + 0.0, t: i * 0.35 + 0.2, d: 0.3, size: 3.0, tone: 0.7),
            ],
            L(88, 5, 55, 20, t: 1.4, d: 0.4, tone: 0.8),
            G(50, 19, 6, t: 1.7, d: 0.3),
            D(50, 19, r: 1.3, t: 1.7, d: 0.2, my: -10, mt: 1.9, md: 0.5),
            T(L3('Azal · Ajal · Amad · Abad', 'Azal · Ajal · Amad · Abad', 'الأزل · الأجل · الأمد · الأبد'), 50, 54, t: 1.5, d: 0.3, size: 3.2),
          ], alt: 'Empat alam kosmik sebagai lingkaran konsentris'),
      'n2': SceneDef(2.4, () => [
            B(22, 28, 14, 34, fill: true, up: true, t: 0, d: 0.5),
            T(L3('Wahyu terjaga', 'Preserved revelation', 'الوحي المحفوظ'), 22, 51, t: 0.4, d: 0.3, size: 3.2),
            for (var i = 0; i < 3; i++) ...[
              B(68, 11.0 + i * 15, 38, 9, r: 2, dash: true, draw: true, t: 0.6 + i * 0.25, d: 0.4, dx: 10),
              X(68, 11.0 + i * 15, 4, t: 1.5 + i * 0.2, d: 0.2),
            ],
            L(40, 28, 46, 28, t: 1.2, d: 0.2),
            T(L3('Klaim sejarah', 'Historical claims', 'دعاوى تاريخية'), 68, 51, t: 1.0, d: 0.3, size: 3.2),
          ], alt: 'Wahyu terjaga didahulukan; klaim sejarah yang bertentangan gugur'),
      's70': SceneDef(2.0, () => [
            Pg(50, 28, 20, 5, t: 0, d: 0.3, tone: 0.4),
            for (var i = 0; i < 5; i++) ...[
              D(pentaPt(i, 50, 28, 20).dx, pentaPt(i, 50, 28, 20).dy, r: 1.6, t: 0, d: 0.2),
              L(pentaPt(i, 50, 28, 20).dx, pentaPt(i, 50, 28, 20).dy, 50, 28, t: 0.3 + i * 0.12, d: 0.4),
            ],
            ...compass(50, 28, 8, t: 1.0),
          ], alt: 'Lima cabang bermuara pada kompas jalan selamat'),
      's71': SceneDef(1.2, () => [
            R(50, 28, 22, t: 0, d: 0.5, dash: true, tone: 0.6),
            ...compass(50, 28, 13, t: 0.2, stag: 0.08),
          ], alt: 'Kompas Lingkar Pelindung'),
      's72': SceneDef(2.2, () => [
            B(94, 28, 34, 56, fill: true, tone: 0.12, t: 0, d: 0.3, mx: -12, mt: 0.1, md: 1.2, out: 1.4),
            for (var i = 0; i < 5; i++)
              D(8.0 + i * 3, 28, r: 1.4, t: 0.2 + i * 0.1, d: 0.2,
                  mx: 42 + math.cos(i * 1.256 - 1.57) * 7 - (8.0 + i * 3 - 8), my: math.sin(i * 1.256 - 1.57) * 7,
                  mt: 0.4 + i * 0.1, md: 0.8),
            G(50, 28, 10, t: 1.0, d: 0.4),
            G(50, 28, 30, t: 1.1, d: 0.8, tone: 0.7),
          ], alt: 'Lima amal saleh menyala menjadi lentera yang mengusir gelap'),
      's73': SceneDef(2.2, () => [
            W(4, 34, 28, 6, 4, t: 0, d: 0.5, sharp: true, out: 1.2),
            D(50, 28, r: 2, t: 0, d: 0.2),
            Op(Sk.arc, 50, 28, r: 8, a0: math.pi * 0.62, a1: math.pi * 1.38, t: 0.5, d: 0.4, draw: true),
            Op(Sk.arc, 50, 28, r: 12, a0: math.pi * 0.62, a1: math.pi * 1.38, t: 0.7, d: 0.4, draw: true),
            T(L3('Jaga lisan', 'Guard the tongue', 'احفظ لسانك'), 70, 12, t: 0.9, d: 0.3, size: 3.4),
            T(L3('Jaga tangan', 'Guard the hand', 'احفظ يدك'), 70, 46, t: 1.0, d: 0.3, size: 3.4),
            L(4, 28, 34, 28, t: 1.3, d: 0.5, tone: 0.8),
          ], alt: 'Provokasi berhenti di depan perisai dan menjadi garis tenang'),
      's74': SceneDef(2.2, () => [
            Op(Sk.arc, 50, 42, r: 20, a0: math.pi, a1: math.pi * 2, t: 0, d: 0.7, draw: true),
            L(30, 42, 70, 42, t: 0.5, d: 0.3),
            for (var i = 0; i < 4; i++) D(43.0 + i * 4.7, 37, r: 1.5, t: 0.9 + i * 0.12, d: 0.2),
            G(50, 38, 14, t: 1.0, d: 0.5, tone: 0.6),
            for (var k = 0; k < 3; k++)
              W(-10, 110, 8.0 + k * 6, 1.4, 5, t: 1.0 + k * 0.15, d: 1.0, tone: 0.45),
          ], alt: 'Kubah hangat menaungi keluarga dari angin di luar'),
      'n4': SceneDef(2.2, () => [
            R(50, 28, 25, t: 0, d: 0.3, dash: true, tone: 0.5, out: 0.9),
            T(L3('slogan besar', 'grand slogans', 'شعارات كبيرة'), 50, 6, t: 0.2, d: 0.3, size: 3.3, tone: 0.6, out: 0.9),
            R(50, 28, 7, r2: 11, t: 0.8, d: 0.4, mt: 1.0, md: 0.6),
            for (var i = 0; i < 4; i++)
              D(50 + math.cos(i * math.pi / 2 + 0.78) * 4.5, 28 + math.sin(i * math.pi / 2 + 0.78) * 4.5, r: 1.2, t: 1.0 + i * 0.1, d: 0.2),
            G(50, 28, 16, t: 1.2, d: 0.5),
            T('الخُوَيْصَةُ', 50, 48, t: 1.5, d: 0.3, size: 5.6),
          ], alt: 'Lingkaran kecil dibenahi, slogan besar memudar'),
      's75': SceneDef(2.2, () => [
            L(10, 28, 90, 28, t: 0, d: 0.3, tone: 0.3, dash: true),
            L(10, 28, 4, 28, t: 0, d: 0.1, tone: 0.1),
            D(8, 28, r: 2, t: 0.1, d: 0.2, mx: 40, mt: 0.6, md: 1.0),
            D(92, 28, r: 2, t: 0.1, d: 0.2, mx: -40, mt: 0.6, md: 1.0),
            T(L3('ekstrem kanan', 'right extreme', 'غلو'), 14, 18, t: 0.2, d: 0.3, size: 3.2, tone: 0.7),
            T(L3('ekstrem kiri', 'left extreme', 'تفريط'), 86, 18, t: 0.2, d: 0.3, size: 3.2, tone: 0.7),
            T(L3('Jalan tengah', 'The middle way', 'النمط الأوسط'), 50, 42, t: 1.4, d: 0.4, size: 4.2),
            G(50, 28, 10, t: 1.5, d: 0.4),
          ], alt: 'Dua titik kembali ke tengah menyatu di jalan tengah'),
      's76': SceneDef(2.5, () {
        const xs = [10.0, 30.0, 50.0, 70.0, 90.0];
        return [
          ...arch(x: 10, y: 28, r: 8, w: 3, t: 0.0, stag: 0.04, d: 0.2),
          L(30, 20, 30, 36, t: 0.5, d: 0.2), W(23, 37, 28, 2, 1, t: 0.55, d: 0.3),
          Op(Sk.lock, 50, 24, w: 7, h: 11, t: 1.0, d: 0.2), Op(Sk.sign, 56, 30, w: 5, h: 9, fill: true, t: 1.1, d: 0.2),
          Pg(70, 28, 8, 5, t: 1.5, d: 0.3),
          R(90, 28, 8, t: 2.0, d: 0.3), D(90, 28, r: 1.3, t: 2.0, d: 0.2),
          for (var i = 0; i < 5; i++) ...[
            Ck(xs[i], 44, 3.2, t: 0.3 + i * 0.5, d: 0.25),
            T('${i + 1}', xs[i], 12, t: 0.1 + i * 0.5, d: 0.2, size: 3.6, tone: 0.6),
          ],
        ];
      }, alt: 'Lima kunci dicentang bersama lima lambang'),
      's77': SceneDef(2.0, () {
        const xs = [12.0, 31.0, 50.0, 69.0, 88.0];
        final names = ['البَيَانُ', 'المُحَقِّقُ', 'المُخْتَبِرُ', 'الحَبِيبُ', 'الخَطِيبُ'];
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
      's78': SceneDef(1.2, () => [
            for (var i = 0; i < 5; i++) ...[
              D(12.0 + i * 19, 10, r: 1.6, t: i * 0.08, d: 0.2),
              L(12.0 + i * 19, 12, 50, 34, t: 0.3 + i * 0.08, d: 0.3, tone: 0.6),
            ],
            Op(Sk.stack, 50, 42, w: 22, h: 4.4, t: 0.4, d: 0.3),
          ], alt: 'Lima asisten terikat pada sumber kitab'),
      's79': SceneDef(2.0, () => [
            W(10, 90, 28, 9, 7, t: 0, d: 0.7, out: 1.0),
            for (var i = 0; i < 3; i++) L(10, 18.0 + i * 10, 90, 18.0 + i * 10, t: 1.0 + i * 0.2, d: 0.4),
          ], alt: 'Benang kusut terurai menjadi tiga garis lurus'),
      's80': SceneDef(2.0, () => [
            for (var i = 0; i < 3; i++) L(16, 14.0 + i * 10, 84 - i * 8, 14.0 + i * 10, t: i * 0.1, d: 0.3, tone: 0.45),
            R(20, 24, 7, t: 0.3, d: 0.3, mx: 56, mt: 0.5, md: 1.0),
            L(16, 26.5, 76, 26.5, t: 1.4, d: 0.4),
            B(50, 44, 30, 8, r: 2, t: 1.6, d: 0.3),
            T(L3('Kitab · Halaman', 'Book · Page', 'الكتاب · الصفحة'), 50, 44, t: 1.7, d: 0.3, size: 3.2),
          ], alt: 'Lensa menyorot satu baris dan menampilkan kitab dan halaman'),
      's81': SceneDef(2.2, () => [
            B(50, 10, 62, 11, r: 3, t: 0, d: 0.3),
            L(24, 10, 66, 10, t: 0.2, d: 0.3, tone: 0.5),
            B(30, 26, 28, 9, r: 2.5, t: 0.5, d: 0.3), B(70, 26, 28, 9, r: 2.5, t: 0.6, d: 0.3),
            B(70, 26, 28, 9, r: 2.5, fill: true, tone: 0.2, t: 1.0, d: 0.3),
            Ck(70, 26, 3.6, t: 1.1, d: 0.3),
            B(50, 44, 62, 11, r: 3, t: 1.5, d: 0.4, dy: 8),
            L(24, 44, 76, 44, t: 1.7, d: 0.3, tone: 0.5),
          ], alt: 'Kartu soal, pilihan benar bercentang, lalu penjelasan'),
      's82': SceneDef(2.2, () => [
            Op(Sk.bars, 50, 16, w: 36, h: 18, n: 5, t: 0, d: 0.5, mt: 0.6, md: 0.6),
            L(16, 36, 84, 36, t: 1.0, d: 0.4, tone: 0.6),
            L(16, 42, 66, 42, t: 1.2, d: 0.3, tone: 0.4),
            Pg(20, 50, 3, 3, fill: true, t: 1.6, d: 0.2, rot: math.pi / 2),
            T('02:15', 30, 50, t: 1.7, d: 0.3, size: 3.2),
          ], alt: 'Gelombang suara lalu transkrip dengan penanda waktu'),
      's83': SceneDef(2.2, () => [
            B(50, 28, 52, 50, r: 3, t: 0, d: 0.4),
            L(30, 11, 70, 11, t: 0.5, d: 0.3),
            for (var i = 0; i < 3; i++) ...[
              D(30, 20.0 + i * 7, r: 1, t: 0.9 + i * 0.25, d: 0.2),
              L(35, 20.0 + i * 7, 62 - i * 6, 20.0 + i * 7, t: 0.9 + i * 0.25, d: 0.3, tone: 0.6),
            ],
            L(38, 46, 62, 46, t: 1.8, d: 0.3, tone: 0.5),
          ], alt: 'Bingkai halaman tersusun judul, tiga butir, dan doa penutup'),
      's84': SceneDef(2.2, () => [
            G(50, 24, 34, t: 0.9, d: 0.5, tone: 0.8),
            ...arch(x: 50, y: 30, r: 24, w: 8, t: 0, stag: 0.15, d: 0.3),
            T(L3('Mulai bertanya', 'Start asking', 'ابدأ بالسؤال'), 28, 47, t: 1.6, d: 0.3, size: 3.6),
            T(L3('Pilih jalur belajar', 'Choose a study path', 'اختر مسار التعلّم'), 72, 47, t: 1.8, d: 0.3, size: 3.6),
            B(28, 47, 40, 9, r: 4.5, t: 1.5, d: 0.3, dy: 4),
            B(72, 47, 40, 9, r: 4.5, t: 1.7, d: 0.3, dy: 4),
          ], alt: 'Lengkung Empat Bagian menyala utuh'),
    };
