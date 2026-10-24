import 'package:shared_preferences/shared_preferences.dart';

/// Penanda "pengenalan sudah dilihat". Pengenalan hanya tampil sekali pada
/// pemasangan baru; dari Pengaturan pengguna bisa memutarnya lagi.
class OnboardingGate {
  const OnboardingGate._();

  static const _key = 'onboarding_seen_v1';

  static Future<bool> seen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (_) {
      // Bila penyimpanan gagal dibaca, jangan menahan pengguna di pengenalan.
      return true;
    }
  }

  static Future<void> markSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (_) {}
  }
}
