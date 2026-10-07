// ignore_for_file: invalid_use_of_visible_for_testing_member
// Native fixture of actual application routes; no authentication or payments.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/core/constants.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:openturath_ai/screens/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthService.previewUser = UserModel(
      uid: 'native-cairo-fixture',
      name: 'Rafli Husen',
      email: 'contoh@openturath.id',
      photoUrl: '',
      plan: AppConstants.planTrial,
      questionsUsed: 0);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      supportedLocales: Loc.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => LocaleScope(child: child!),
      home: const MainShellScreen()));
}
