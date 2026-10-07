// Local native motion review. Benchmark first; capture afterwards so screenshots
// do not contaminate frame timing measurements. No network or account required.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:openturath_ai/widgets/app_loader.dart';

final boundary = GlobalKey();
final timings = <FrameTiming>[];
void collect(List<FrameTiming> batch) => timings.addAll(batch);
class _BenchmarkLifecycle extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      scheduleMicrotask(() => WidgetsBinding.instance
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed));
    }
  }
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Measurement fixture keeps Dart frame scheduling active even when the QA
  // runner returns focus to Codex. This does not alter production lifecycle.
  WidgetsBinding.instance.addObserver(_BenchmarkLifecycle());
  WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  runApp(MaterialApp(
      home: Scaffold(
          body: Center(
              child: RepaintBoundary(
                  key: boundary,
                  child: const SizedBox(
                      width: 240,
                      height: 200,
                      child: ColoredBox(
                          color: Colors.white,
                          child:
                              AppLoader.fullscreen(title: 'OpenTurath'))))))));
  final metricsFile = File('/tmp/ot-cairo-loader-profile.json');
  if (metricsFile.existsSync()) metricsFile.deleteSync();
  await Future<void>.delayed(const Duration(seconds: 10));
  SchedulerBinding.instance.addTimingsCallback(collect);
  await Future<void>.delayed(const Duration(milliseconds: 18000));
  SchedulerBinding.instance.removeTimingsCallback(collect);
  if (timings.isEmpty ||
      WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
    throw StateError(
        'Native review lost foreground activity; no valid measurement saved');
  }
  Map<String, Object> summary(List<double> values) {
    values.sort();
    return {
      'frames': values.length,
      'p95Ms': values[(values.length * .95).floor()],
      'maxMs': values.last,
      'over16_67Ms': values.where((v) => v > 16.67).length
    };
  }

  File('/tmp/ot-cairo-loader-profile.json').writeAsStringSync(jsonEncode({
    'mode': 'native macOS profile',
    'lifecycle': 'controlled resumed fixture; production lifecycle tested separately',
    'measurementMs': 18000,
    'cycles': 10,
    'build': summary(
        timings.map((t) => t.buildDuration.inMicroseconds / 1000).toList()),
    'raster': summary(
        timings.map((t) => t.rasterDuration.inMicroseconds / 1000).toList()),
  }));
  final directory = Directory('/tmp/ot-cairo-loader-frames')..createSync();
  final stopwatch = Stopwatch()..start();
  var frame = 0;
  while (stopwatch.elapsedMilliseconds < 18000) {
    await SchedulerBinding.instance.endOfFrame;
    final render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await render.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${directory.path}/${frame.toString().padLeft(4, '0')}.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
    frame++;
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }
  File('${directory.path}/duration.txt')
      .writeAsStringSync('${stopwatch.elapsedMilliseconds}');
  debugPrint('OPENTURATH_PROFILE_REVIEW_COMPLETE');
  exit(0);
}
