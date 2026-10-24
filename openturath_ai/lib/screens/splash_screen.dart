import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/routes.dart';
import '../services/auth_service.dart';
import '../services/persistent_google_session.dart';
import '../widgets/ot_arch_motion.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.resolveInitialRoute});

  final String Function()? resolveInitialRoute;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ValueNotifier<bool> _skip = ValueNotifier<bool>(false);
  final Completer<void> _skipped = Completer<void>();

  void _onTap() {
    if (_skipped.isCompleted) return;
    _skip.value = true;
    _skipped.complete();
  }

  @override
  void dispose() {
    _skip.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Navigator's initial route must finish mounting before it is replaced.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // Pembuka terlihat sejenak, tetapi tidak pernah menahan lebih lama.
    final hold = Future.any<void>(
        [Future<void>.delayed(OTMotion.splashHold), _skipped.future]);
    var targetRoute = AppRoutes.login;
    try {
      if (widget.resolveInitialRoute != null) {
        targetRoute = widget.resolveInitialRoute!();
      } else {
        final restoredUser = await AuthService().restoreSession();
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (restoredUser != null ||
            (firebaseUser != null && !firebaseUser.isAnonymous)) {
          final currentEmail =
              (firebaseUser?.email ?? restoredUser?.email ?? '')
                  .trim()
                  .toLowerCase();
          if (currentEmail.isNotEmpty) {
            await PersistentGoogleSession.instance
                .restoreSessionIfAvailable(currentEmail);
          }
          targetRoute = AppRoutes.dashboard;
        }
      }
    } catch (_) {
      // Reading auth state may fail, but must not leave an endless splash.
      targetRoute = AppRoutes.login;
    }
    await hold;
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    // Mengikuti tema aplikasi, sama seperti layar luncur sistem.
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = OTColors.canvas(dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTap,
          child: Center(
              child:
                  OTSplashIntro(ink: OTColors.textPrimary(dark), skip: _skip)),
        ),
      ),
    );
  }
}
