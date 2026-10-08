import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/routes.dart';
import '../services/auth_service.dart';
import '../widgets/ot_arch_motion.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.resolveInitialRoute});

  final String Function()? resolveInitialRoute;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    final hold = Future<void>.delayed(OTMotion.splashHold);
    var targetRoute = AppRoutes.login;
    try {
      if (widget.resolveInitialRoute != null) {
        targetRoute = widget.resolveInitialRoute!();
      } else {
        final restoredUser = await AuthService().restoreSession();
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (restoredUser != null ||
            (firebaseUser != null && !firebaseUser.isAnonymous)) {
          final prefs = await SharedPreferences.getInstance();
          final sessionReady = prefs.getBool('google_session_ready') ?? false;
          final sessionEmail = prefs.getString('google_session_email') ?? '';
          final currentEmail = (firebaseUser?.email ?? restoredUser?.email ?? '')
              .trim()
              .toLowerCase();
          if (sessionReady &&
              (currentEmail.isEmpty || sessionEmail.isEmpty || sessionEmail == currentEmail)) {
            targetRoute = AppRoutes.dashboard;
          } else {
            targetRoute = AppRoutes.dashboard;
          }
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
        body: Center(child: OTSplashIntro(ink: OTColors.textPrimary(dark))),
      ),
    );
  }
}
