import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/routes.dart';
import '../services/auth_service.dart';
import '../services/language_gate.dart';
import '../services/onboarding_gate.dart';
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
  final Completer<void> _held = Completer<void>();
  Timer? _holdTimer;

  void _release() {
    _holdTimer?.cancel();
    if (!_held.isCompleted) _held.complete();
  }

  void _onTap() {
    if (_held.isCompleted) return;
    _skip.value = true;
    _release();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
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
    final still = mounted && MediaQuery.disableAnimationsOf(context);
    _holdTimer =
        Timer(still ? OTMotion.splashHoldStill : OTMotion.splashHold, _release);
    final hold = _held.future;
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
    // Pemasangan baru (belum masuk akun): pilih bahasa dulu, lalu pengenalan
    // aplikasi, baru masuk akun. Masing-masing hanya sekali.
    var showLanguage = false, showIntro = false;
    if (widget.resolveInitialRoute == null && targetRoute == AppRoutes.login) {
      showLanguage = !await LanguageGate.chosen();
      showIntro = !await OnboardingGate.seen();
    }
    await hold;
    if (!mounted) return;
    if (showLanguage) {
      Navigator.pushReplacementNamed(context, AppRoutes.language,
          arguments: targetRoute);
    } else if (showIntro) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding,
          arguments: targetRoute);
    } else {
      Navigator.pushReplacementNamed(context, targetRoute);
    }
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
