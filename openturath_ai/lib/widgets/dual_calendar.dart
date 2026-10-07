import '../core/design/ot_typography.dart';
import '../core/design/ot_expressive.dart';
import '../core/design/ot_colors.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/hijri_date_utils.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'tahawwulat_hero.dart';

/// Both dates always use one clock snapshot; refresh at midnight and resume.
class DualCalendar extends StatefulWidget {
  const DualCalendar({super.key, this.date});
  final DateTime? date;
  @override
  State<DualCalendar> createState() => _DualCalendarState();
}

class _DualCalendarState extends State<DualCalendar>
    with WidgetsBindingObserver {
  Timer? timer;
  late DateTime now;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  void refresh() {
    now = widget.date ?? DateTime.now();
    timer?.cancel();
    if (widget.date == null) {
      final next = DateTime(now.year, now.month, now.day + 1);
      timer = Timer(next.difference(now), () {
        if (mounted) setState(refresh);
      });
    }
  }

  @override
  void didUpdateWidget(DualCalendar old) {
    super.didUpdateWidget(old);
    if (old.date != widget.date) refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(refresh);
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final color = Theme.of(context).colorScheme.onSurface;
    Widget part(String label, ({int day, String month, int year, String era}) date) {
      return SizedBox(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
            Text(label,
                style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s12,
                    color: color.withValues(alpha: .7))),
            const SizedBox(height: 4),
            Text('${date.day}',
                style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s32,
                        fontWeight: FontWeight.w600,
                        color: color)
                    .copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()])),
            Text(date.month,
                style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s14,
                    color: color,
                    fontWeight: FontWeight.w600)),
            Text('${date.year} ${date.era}',
                style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s12,
                    color: color.withValues(alpha: .7))),
          ]));
    }

    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: OTColors.surface(
                Theme.of(context).brightness == Brightness.dark),
            borderRadius: BorderRadius.circular(OTExpressive.panelRadius)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Icon(Icons.calendar_month_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child: Text(reviewCopy('Kalender', 'التقويم', 'Calendar'),
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s12,
                        color: color.withValues(alpha: .7)))),
            IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: reviewCopy(
                    'Metode kalender', 'طريقة التقويم', 'Calendar method'),
                icon: const Icon(Icons.info_outline_rounded, size: 18),
                onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text(reviewCopy('Metode kalender',
                              'طريقة التقويم', 'Calendar method')),
                          content: Text(reviewCopy(
                              'Tanggal Hijriah menggunakan perhitungan tabular, bukan penetapan rukyat. Tanggal mengikuti waktu lokal perangkat.',
                              'يُحسب التاريخ الهجري حسابياً ولا يمثل إثبات الرؤية. يتبع التقويم الوقت المحلي للجهاز.',
                              'Hijri dates use tabular calculation, not a moon-sighting determination. Dates follow local device time.')),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(MaterialLocalizations.of(context)
                                    .closeButtonLabel))
                          ],
                        ))),
          ]),
          LayoutBuilder(builder: (context, box) {
            final h = part(reviewCopy('Hijriah', 'هجري', 'Hijri'), HijriDateUtils.hijriParts(now));
            final g = part(reviewCopy('Masehi', 'ميلادي', 'Gregorian'), HijriDateUtils.gregorianParts(now));
            if (MediaQuery.textScalerOf(context).scale(16) >= 24) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [h, const Divider(height: 24), g]);
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: h),
              SizedBox(height: 88, child: VerticalDivider(width: 24, color: OTColors.border(Theme.of(context).brightness == Brightness.dark))), Expanded(child: g)]);
          }),
        ]));
  }
}
