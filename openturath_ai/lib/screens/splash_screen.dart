import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../widgets/openturath_brand.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.resolveRoute});
  final Future<String> Function()? resolveRoute;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _copyFade;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _logoFade = CurvedAnimation(parent: _controller,
      curve: const Interval(0, .5, curve: Curves.easeOutCubic));
    _copyFade = CurvedAnimation(parent: _controller,
      curve: const Interval(.4, 1, curve: Curves.easeOutCubic));
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
    _navigate();
  }

  Future<String> _resolveRoute() async {
    if (widget.resolveRoute != null) return widget.resolveRoute!();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return AppRoutes.login;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) return AppRoutes.dashboard;
    final prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 3));
    return prefs.getBool('google_session_ready') == true
      ? AppRoutes.dashboard : AppRoutes.googleSessionAuth;
  }
  Future<void> _navigate() async {
    final minimumDisplay = Future<void>.delayed(const Duration(milliseconds: 2400));
    String route;
    try {
      route = await _resolveRoute().timeout(const Duration(seconds: 5));
    } catch (_) {
      route = AppRoutes.login;
    }
    await minimumDisplay;
    if (mounted) Navigator.of(context).pushReplacementNamed(route);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(backgroundColor: OTColors.canvas(dark),
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            FadeTransition(opacity: _logoFade, child: const OpenTurathMark(size: 112)),
            const SizedBox(height: 24),
            FadeTransition(opacity: _copyFade, child: Column(children: [
              Text('OpenTurath', style: OTTypography.brandLogo(color: OTColors.textPrimary(dark))),
              const SizedBox(height: 28),
              Text(Loc.tr('splashTitle'), textAlign: TextAlign.center,
                style: OTTypography.editorialHero(color: OTColors.textPrimary(dark))),
              const SizedBox(height: 16),
              Text(Loc.tr('splashBody'), textAlign: TextAlign.center,
                style: OTTypography.body(color: OTColors.textSecondary(dark))),
            ])),
          ]),
        ),
      ))),
    );
  }
}
