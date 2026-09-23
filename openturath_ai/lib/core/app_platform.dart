import 'package:flutter/foundation.dart';

abstract final class AppPlatform {
  static bool get isDesktop => !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
       defaultTargetPlatform == TargetPlatform.windows ||
       defaultTargetPlatform == TargetPlatform.linux);
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
