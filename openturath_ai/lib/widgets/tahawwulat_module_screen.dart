import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import 'tahawwulat_artwork.dart';

/// Modul "Mengenal Fikih Tahawwulat" untuk orang awam. Isinya satu sumber
/// dengan halaman web (assets/data/modul_mengenal.json).
class TahawwulatModuleScreen extends StatefulWidget {
  const TahawwulatModuleScreen({super.key, this.onAsk});

  /// Dipanggil bila pengguna memilih bertanya kepada OpenTurath AI.
  final VoidCallback? onAsk;

  static Future<void> show(BuildContext context, {VoidCallback? onAsk}) =>
      Navigator.of(context).push<void>(MaterialPageRoute<void>(
          builder: (_) => TahawwulatModuleScreen(onAsk: onAsk)));

  @override
  State<TahawwulatModuleScreen> createState() => _TahawwulatModuleScreenState();
}

class _TahawwulatModuleScreenState extends State<TahawwulatModuleScreen> {
  Map<String, dynamic>? _data;
  Object? _galat;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/data/modul_mengenal.json').then((s) {
      if (mounted) {
        setState(() => _data = jsonDecode(s) as Map<String, dynamic>);
      }
    }).catchError((Object e) {
      if (mounted) setState(() => _galat = e);
    });
  }

  String _t(dynamic v) =>
      (v as Map)[Loc.language] as String? ?? (v)['id'] as String;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = OTColors.textPrimary(isDark),
        sub = OTColors.textSecondary(isDark);
    final d = _data;
    return Directionality(
      textDirection: Loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: OTColors.canvas(isDark),
        appBar: AppBar(
          backgroundColor: OTColors.canvas(isDark),
          title: Text(d == null ? '' : _t(d['head']['kicker']),
              style: OTTypography.cardTitle(color: fg)),
        ),
        body: d == null
            ? Center(
                child: _galat == null
                    ? const CircularProgressIndicator()
                    : Text(Loc.tr('moduleLoadFailed'),
                        style: OTTypography.body(color: sub)))
            : SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(OTSpacing.base,
                          OTSpacing.base, OTSpacing.base, OTSpacing.massive),
                      children: _sections(d, isDark, fg, sub),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _card(bool isDark, Widget child, {bool inverse = false}) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: OTSpacing.md),
        padding: const EdgeInsets.all(OTSpacing.lg),
        decoration: BoxDecoration(
          color: inverse ? OTColors.inverted(isDark) : OTColors.surface(isDark),
          borderRadius: OTRadius.cardBorder,
          border: Border.all(color: OTColors.border(isDark)),
        ),
        child: child,
      );

  Widget _head(
          String kicker, String title, String? lead, Color fg, Color sub) =>
      Padding(
        padding:
            const EdgeInsets.only(top: OTSpacing.xxl, bottom: OTSpacing.base),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(kicker.toUpperCase(),
              style: OTTypography.metadataTag(color: sub)),
          const SizedBox(height: OTSpacing.sm),
          Text(title, style: OTTypography.screenTitle(color: fg)),
          if (lead != null) ...[
            const SizedBox(height: OTSpacing.md),
            Text(lead, style: OTTypography.body(color: sub)),
          ],
        ]),
      );

  List<Widget> _sections(
      Map<String, dynamic> d, bool isDark, Color fg, Color sub) {
    final w = <Widget>[];
    final h = d['head'];
    w.add(Padding(
      padding: const EdgeInsets.only(top: OTSpacing.base),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_t(h['title']), style: OTTypography.pageTitle(color: fg)),
        const SizedBox(height: OTSpacing.md),
        Text(_t(h['lead']), style: OTTypography.body(color: sub)),
      ]),
    ));

    // 1. Pertanyaan
    final q = d['q'];
    w.add(_head(_t(q['kicker']), _t(q['title']), _t(q['lead']), fg, sub));
    for (final g in q['groups'] as List) {
      w.add(_card(
          isDark,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_t(g[0]).toUpperCase(),
                style: OTTypography.metadataTag(color: sub)),
            const SizedBox(height: OTSpacing.md),
            for (final x in g[1] as List)
              Padding(
                padding: const EdgeInsets.only(bottom: OTSpacing.md),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.help_outline_rounded,
                          size: OTSpacing.lg, color: sub),
                      const SizedBox(width: OTSpacing.md),
                      Expanded(
                          child: Text(_t(x),
                              style: OTTypography.bodyMedium(color: fg))),
                    ]),
              ),
          ])));
    }

    // 2. Apa itu
    final what = d['what'];
    w.add(_head(
        _t(what['kicker']), _t(what['title']), _t(what['lead']), fg, sub));
    final c = what['contrast'] as List;
    w.add(_card(
        isDark,
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_t(c[0]), style: OTTypography.captionMedium(color: sub)),
          const SizedBox(height: OTSpacing.xs),
          Text(_t(c[1]), style: OTTypography.cardTitle(color: fg)),
        ])));
    w.add(_card(
        isDark,
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_t(c[2]),
              style: OTTypography.captionMedium(
                  color: OTColors.onInvertedMuted(isDark))),
          const SizedBox(height: OTSpacing.xs),
          Text(_t(c[3]),
              style:
                  OTTypography.cardTitle(color: OTColors.onInverted(isDark))),
        ]),
        inverse: true));
    w.add(const Padding(
      padding: EdgeInsets.only(bottom: OTSpacing.md),
      child: TahawwulatArtwork(),
    ));
    for (final p in what['points'] as List) {
      w.add(_card(
          isDark,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_t(p[0]), style: OTTypography.cardTitle(color: fg)),
            const SizedBox(height: OTSpacing.xs),
            Text(_t(p[1]), style: OTTypography.body(color: sub)),
          ])));
    }

    // 3. Faedah
    final b = d['benefit'];
    w.add(_head(_t(b['kicker']), _t(b['title']), _t(b['lead']), fg, sub));
    var n = 0;
    for (final it in b['items'] as List) {
      n++;
      w.add(_card(
          isDark,
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: OTSpacing.xl + OTSpacing.sm,
                child: Text(n.toString().padLeft(2, '0'),
                    style: OTTypography.captionMedium(color: sub))),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t(it[0]), style: OTTypography.cardTitle(color: fg)),
                    const SizedBox(height: OTSpacing.xs),
                    Text(_t(it[1]), style: OTTypography.body(color: sub)),
                  ]),
            ),
          ])));
    }

    // 4. Cabang
    final br = d['branch'];
    w.add(_head(_t(br['kicker']), _t(br['title']), _t(br['lead']), fg, sub));
    n = 0;
    for (final it in br['items'] as List) {
      n++;
      w.add(_card(
          isDark,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$n', style: OTTypography.captionMedium(color: sub)),
            const SizedBox(height: OTSpacing.xs),
            Text(_t(it[0]), style: OTTypography.cardTitle(color: fg)),
            const SizedBox(height: OTSpacing.xs),
            Text(_t(it[1]), style: OTTypography.body(color: sub)),
            const SizedBox(height: OTSpacing.md),
            for (final x in it[2] as List)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: OTSpacing.sm),
                padding: const EdgeInsets.symmetric(
                    horizontal: OTSpacing.md, vertical: OTSpacing.sm),
                decoration: BoxDecoration(
                  borderRadius: OTRadius.xsBorder,
                  border: Border.all(color: OTColors.borderSubtle(isDark)),
                ),
                child: Text(_t(x), style: OTTypography.caption(color: fg)),
              ),
          ])));
    }

    // 5. Beda
    final df = d['diff'];
    w.add(_head(_t(df['kicker']), _t(df['title']), _t(df['lead']), fg, sub));
    final cols = df['cols'] as List;
    for (final r in df['rows'] as List) {
      w.add(_card(
          isDark,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_t(r[0]).toUpperCase(),
                style: OTTypography.metadataTag(color: sub)),
            const SizedBox(height: OTSpacing.md),
            Text(_t(cols[0]), style: OTTypography.captionMedium(color: sub)),
            Text(_t(r[1]), style: OTTypography.body(color: sub)),
            const SizedBox(height: OTSpacing.md),
            Text(_t(cols[1]), style: OTTypography.captionMedium(color: fg)),
            Text(_t(r[2]), style: OTTypography.bodyMedium(color: fg)),
          ])));
    }
    w.add(_head('', _t(df['unique_title']), null, fg, sub));
    for (final u in df['unique'] as List) {
      w.add(Padding(
        padding: const EdgeInsets.only(bottom: OTSpacing.md),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.check_circle_outline_rounded,
              size: OTSpacing.lg, color: fg),
          const SizedBox(width: OTSpacing.md),
          Expanded(child: Text(_t(u), style: OTTypography.body(color: fg))),
        ]),
      ));
    }

    // 6. Mulai
    final s = d['start'];
    w.add(_head(_t(s['kicker']), _t(s['title']), null, fg, sub));
    n = 0;
    for (final st in s['steps'] as List) {
      n++;
      w.add(_card(
          isDark,
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: OTSpacing.xl + OTSpacing.sm,
                child:
                    Text('0$n', style: OTTypography.captionMedium(color: sub))),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t(st[0]), style: OTTypography.cardTitle(color: fg)),
                    const SizedBox(height: OTSpacing.xs),
                    Text(_t(st[1]), style: OTTypography.body(color: sub)),
                  ]),
            ),
          ])));
    }
    w.add(const SizedBox(height: OTSpacing.md));
    w.add(FilledButton(
      onPressed: () {
        Navigator.of(context).maybePop();
        widget.onAsk?.call();
      },
      child: Text(_t(s['cta']), style: OTTypography.button()),
    ));
    return w;
  }
}
