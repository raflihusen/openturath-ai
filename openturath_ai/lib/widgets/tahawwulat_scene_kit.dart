// ignore_for_file: non_constant_identifier_names, prefer_const_constructors
import 'dart:math' as math;
import 'dart:ui' show Offset;

import '../core/localization.dart';
import 'tahawwulat_scene.dart';

/// Perkakas penyusun adegan: bentuk ringkas dan beberapa lambang yang dipakai
/// berulang (Lengkung Empat Bagian, empat petak, majelis, Peta Segi Lima).
String L3(String id, String en, String ar) => switch (Loc.language) {
      'en' => en,
      'ar' => ar,
      _ => id,
    };

Op D(double x, double y,
        {double r = 0.9,
        double t = 0,
        double d = 0.35,
        double tone = 1,
        double mx = 0,
        double my = 0,
        double mt = 0,
        double md = 0.6,
        double dx = 0,
        double dy = 0,
        double sh = 0,
        double st = 0,
        double sd = 0.6,
        int i = 0,
        double out = -1,
        double r2 = -1}) =>
    Op(Sk.disc, x, y,
        r: r,
        t: t,
        d: d,
        tone: tone,
        mx: mx,
        my: my,
        mt: mt,
        md: md,
        dx: dx,
        dy: dy,
        shake: sh,
        st: st,
        sd: sd,
        idx: i,
        out: out,
        r2: r2);

Op R(double x, double y, double r,
        {double t = 0,
        double d = 0.45,
        double tone = 1,
        double r2 = -1,
        double mt = 0,
        double md = 0.6,
        bool fill = false,
        bool dash = false,
        bool draw = true,
        double out = -1,
        double mx = 0,
        double my = 0,
        double pulse = 0}) =>
    Op(Sk.ring, x, y,
        r: r,
        t: t,
        d: d,
        tone: tone,
        r2: r2,
        mt: mt,
        md: md,
        fill: fill,
        dash: dash,
        draw: draw,
        out: out,
        mx: mx,
        my: my,
        pulse: pulse);

Op L(double x, double y, double x2, double y2,
        {double t = 0,
        double d = 0.4,
        double tone = 1,
        bool dash = false,
        double mx = 0,
        double my = 0,
        double mt = 0,
        double md = 0.6,
        double out = -1}) =>
    Op(Sk.line, x, y,
        x2: x2,
        y2: y2,
        t: t,
        d: d,
        tone: tone,
        draw: true,
        dash: dash,
        mx: mx,
        my: my,
        mt: mt,
        md: md,
        out: out);

Op B(double x, double y, double w, double h,
        {double r = 1.2,
        bool fill = false,
        double t = 0,
        double d = 0.4,
        double tone = 1,
        bool dash = false,
        bool up = false,
        bool draw = false,
        double dx = 0,
        double dy = 0,
        double mx = 0,
        double my = 0,
        double mt = 0,
        double md = 0.6,
        double out = -1,
        double sh = 0,
        double st = 0,
        double sd = 0.6,
        int i = 0}) =>
    Op(Sk.rect, x, y,
        w: w,
        h: h,
        r: r,
        fill: fill,
        t: t,
        d: d,
        tone: tone,
        dash: dash,
        up: up,
        draw: draw,
        dx: dx,
        dy: dy,
        mx: mx,
        my: my,
        mt: mt,
        md: md,
        out: out,
        shake: sh,
        st: st,
        sd: sd,
        idx: i);

Op T(String s, double x, double y,
        {double t = 0,
        double d = 0.35,
        double size = 3.6,
        double tone = 1,
        double out = -1,
        double dy = 0,
        double mx = 0,
        double my = 0,
        double mt = 0,
        double md = 0.6}) =>
    Op(Sk.text, x, y,
        text: s,
        t: t,
        d: d,
        size: size,
        tone: tone,
        out: out,
        dy: dy,
        mx: mx,
        my: my,
        mt: mt,
        md: md);

Op G(double x, double y, double r,
        {double t = 0, double d = 0.6, double tone = 0.9, double out = -1}) =>
    Op(Sk.glow, x, y, r: r, t: t, d: d, tone: tone, out: out);

Op W(double x, double x2, double y, double amp, int cycles,
        {double t = 0,
        double d = 0.6,
        double tone = 1,
        bool sharp = false,
        double out = -1}) =>
    Op(Sk.wave, x, y,
        x2: x2,
        h: amp,
        n: cycles,
        t: t,
        d: d,
        tone: tone,
        sharp: sharp,
        draw: true,
        out: out);

Op Pg(double x, double y, double r, int n,
        {double t = 0,
        double d = 0.45,
        double tone = 1,
        bool fill = false,
        double rot = 0,
        double mx = 0,
        double my = 0,
        double mt = 0,
        double md = 0.6,
        double out = -1}) =>
    Op(Sk.poly, x, y,
        r: r,
        n: n,
        t: t,
        d: d,
        tone: tone,
        fill: fill,
        a0: rot,
        draw: !fill,
        mx: mx,
        my: my,
        mt: mt,
        md: md,
        out: out);

Op Ck(double x, double y, double r,
        {double t = 0, double d = 0.3, double tone = 1}) =>
    Op(Sk.tick, x, y, r: r, t: t, d: d, tone: tone, draw: true);

Op X(double x, double y, double r,
        {double t = 0, double d = 0.3, double tone = 1}) =>
    Op(Sk.cross, x, y, r: r, t: t, d: d, tone: tone, draw: true);

/// Lengkung Empat Bagian: empat segmen busur setengah lingkaran.
List<Op> arch(
        {double x = 50,
        double y = 44,
        double r = 28,
        double w = 9,
        double t = 0,
        double stag = 0.3,
        double d = 0.35,
        double tone = 1,
        bool fill = true,
        int lit = 4,
        double out = -1}) =>
    [
      for (var i = 0; i < 4; i++)
        Op(Sk.seg, x, y,
            r: r,
            w: w,
            idx: i,
            t: t + i * stag,
            d: d,
            tone: i < lit ? tone : tone * 0.35,
            fill: fill && i < lit,
            draw: !(fill && i < lit),
            out: out),
    ];

/// Titik tengah segmen ke-[i] pada lengkung.
Offset archPt(int i, double x, double y, double r, double w) {
  final a = math.pi + (i + 0.5) * math.pi / 4;
  final rr = r - w / 2;
  return Offset(x + math.cos(a) * rr, y + math.sin(a) * rr);
}

const petakX = [17.0, 39.0, 61.0, 83.0];

/// Empat petak sejajar; yang ke-[filled] pertama terisi, sisanya putus-putus.
List<Op> petak4(
        {int filled = 4,
        double y = 30,
        double h = 26,
        double t = 0,
        double stag = 0.12,
        double d = 0.35,
        double w = 18}) =>
    [
      for (var i = 0; i < 4; i++) ...[
        if (i < filled)
          B(petakX[i], y, w, h, fill: true, tone: 0.16, t: t + i * stag, d: d),
        B(petakX[i], y, w, h,
            dash: i >= filled, t: t + i * stag, d: d, draw: i >= filled),
      ],
    ];

/// Deretan empat petak kecil di atas; petak ke-[active] menyala.
List<Op> strip(int active, {double t = 0, double y = 6, int filled = 0}) => [
      for (var i = 0; i < 4; i++) ...[
        B(34.0 + i * 11, y, 9, 5.5,
            r: 1.2,
            fill: i == active || i < filled,
            tone: i == active ? 1 : 0.5,
            t: t,
            d: 0.3),
        if (i != active && i >= filled)
          B(34.0 + i * 11, y, 9, 5.5, r: 1.2, t: t, d: 0.3, tone: 0.5),
      ],
    ];

/// Majelis: sembilan titik di setengah lingkaran mengelilingi pusat bercahaya.
List<Op> majlis(
    {double t = 0,
    double d = 0.3,
    double cx = 50,
    double cy = 38,
    double rr = 21,
    double stag = 0.0,
    bool ring = true}) {
  return [
    G(cx, cy, 12, t: t, d: d + 0.3, tone: 0.8),
    if (ring) R(cx, cy, 7.5, t: t, d: d, tone: 0.6, draw: false),
    for (var i = 0; i < 9; i++)
      D(cx + math.cos(math.pi + i * math.pi / 8) * rr,
          cy + math.sin(math.pi + i * math.pi / 8) * rr * 0.85 + 6,
          r: 1.1, t: t + i * stag, d: d, i: i),
  ];
}

/// Titik-titik sebaran bergetar pseudo-acak (deterministik).
double jit(int i, int k, double amp) =>
    (((math.sin(i * 12.9898 + k * 78.233) * 43758.5453).abs() % 1) - 0.5) *
    2 *
    amp;

/// Batang vertikal berdasar di [bottom], tumbuh naik sampai tinggi [h].
Op Col(double x, double bottom, double w, double h,
        {double t = 0,
        double d = 0.45,
        double tone = 1,
        double out = -1,
        bool fill = true}) =>
    B(x, bottom - h / 2, w, h,
        r: math.min(1, w / 2),
        fill: fill,
        up: true,
        t: t,
        d: d,
        tone: tone,
        out: out);

/// Titik simpul ke-[i] Peta Segi Lima.
Offset pentaPt(int i, double cx, double cy, double r) {
  final a = -math.pi / 2 + i * 2 * math.pi / 5;
  return Offset(cx + math.cos(a) * r, cy + math.sin(a) * r);
}

/// Kompas Lingkar Pelindung: cincin pelindung, cincin arah, empat tanda, pusat.
List<Op> compass(double x, double y, double r,
        {double t = 0, double d = 0.4, double stag = 0.12}) =>
    [
      G(x, y, r * 1.5, t: t + stag * 3, d: 0.5, tone: 0.7),
      R(x, y, r, t: t, d: d),
      R(x, y, r * 0.55, t: t + stag, d: d, tone: 0.7),
      for (var k = 0; k < 4; k++)
        L(
            x + math.cos(k * math.pi / 2) * r * 0.55,
            y + math.sin(k * math.pi / 2) * r * 0.55,
            x + math.cos(k * math.pi / 2) * r * 0.85,
            y + math.sin(k * math.pi / 2) * r * 0.85,
            t: t + stag * 2,
            d: 0.25),
      D(x, y, r: r * 0.12, t: t + stag * 2, d: 0.3),
    ];
