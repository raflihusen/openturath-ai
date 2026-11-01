import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../core/app_config.dart';

/// Saklar fitur jarak jauh dari dokumen Firestore `app_config/features`.
///
/// Dipakai agar status sebuah fitur bisa diubah tanpa merilis aplikasi:
/// - [soonSubAgentIds]: id sub-AI yang berstatus "segera hadir" (tampil tetapi
///   tidak bisa dibuka), mis. `fiqh_tahawwulat_khatib`.
/// - [introductionEnabled]: apakah slide "Mengenal Fikih Tahawwulat" sudah boleh
///   dibuka. Bila false, tombolnya TETAP tampil dengan penanda "Segera hadir"
///   dan ketukannya hanya membuka dialog.
///
/// Aturan keselamatan: bila dokumen belum ada, rusak, atau tidak terbaca,
/// dipakai nilai terakhir yang diketahui, lalu [FeatureFlags.defaults]. Nilai
/// bawaan sengaja konservatif (fitur yang belum matang tetap tertutup).
@immutable
class FeatureFlags {
  const FeatureFlags({
    required this.soonSubAgentIds,
    required this.introductionEnabled,
  });

  final Set<String> soonSubAgentIds;
  final bool introductionEnabled;

  /// Bawaan di dalam aplikasi, berlaku sebelum dan tanpa dokumen jarak jauh.
  static const defaults = FeatureFlags(
    soonSubAgentIds: {
      'fiqh_tahawwulat_khatib',
      'fiqh_tahawwulat_habib',
      'fiqh_tahawwulat_mukhtabir',
    },
    introductionEnabled: false,
  );

  /// Id sub-AI yang valid: huruf kecil, angka, garis bawah; diawali huruf.
  static final RegExp _idPattern = RegExp(r'^[a-z][a-z0-9_]{0,79}$');

  /// Batas jumlah id agar dokumen yang salah ketik tidak mengunci semuanya.
  static const int maxSoonIds = 50;

  /// Membaca dokumen mentah. Nilai yang tidak valid diabaikan, bukan dipercaya.
  ///
  /// - `soon_sub_agent_ids` harus berupa list; elemen non-string atau berformat
  ///   salah dibuang. Bila kuncinya tidak ada atau bukan list, dipakai [fallback].
  /// - `introduction_enabled` harus bool murni; selain itu dipakai [fallback].
  static FeatureFlags parse(Map<String, dynamic>? data,
      {FeatureFlags fallback = defaults}) {
    if (data == null) return fallback;
    final rawSoon = data['soon_sub_agent_ids'];
    Set<String> soon = fallback.soonSubAgentIds;
    if (rawSoon is List) {
      final ids = <String>{
        for (final item in rawSoon)
          if (item is String && _idPattern.hasMatch(item.trim())) item.trim(),
      };
      if (ids.length <= maxSoonIds) soon = ids;
    }
    final rawIntro = data['introduction_enabled'];
    return FeatureFlags(
      soonSubAgentIds: soon,
      introductionEnabled:
          rawIntro is bool ? rawIntro : fallback.introductionEnabled,
    );
  }

  bool isSubAgentSoon(String id) => soonSubAgentIds.contains(id);

  @override
  bool operator ==(Object other) =>
      other is FeatureFlags &&
      other.introductionEnabled == introductionEnabled &&
      setEquals(other.soonSubAgentIds, soonSubAgentIds);

  @override
  int get hashCode => Object.hash(
      introductionEnabled, Object.hashAllUnordered(soonSubAgentIds));
}

/// Hasil keputusan saat pengguna memilih sebuah sub-AI.
enum SubAgentGate {
  /// Bisa dilanjutkan ke pemeriksaan langganan dan pembukaan sesi.
  open,

  /// Ditandai "segera hadir": hanya dijelaskan, tidak dibuka.
  comingSoon,
}

/// Aturan tunggal untuk membuka sub-AI. Dipisahkan dari layar agar bisa diuji
/// dan dipakai di semua jalur masuk.
///
/// Sub-AI "segera hadir" tidak dibuka bagi pelanggan maupun VIP karena
/// alasannya kematangan isi, bukan hak akses. Edisi Guru (build khusus atas
/// perintah Pemilik) membuka seluruh AI.
SubAgentGate gateSubAgent(String subAgentId, FeatureFlags flags) =>
    !AppConfig.isGuruEdition && flags.isSubAgentSoon(subAgentId)
        ? SubAgentGate.comingSoon
        : SubAgentGate.open;

/// Pembaca dan penyimpan sementara [FeatureFlags]. Murni statis seperti
/// `AgentService`, supaya layar mana pun bisa membaca nilai terakhir secara
/// sinkron lewat [current] tanpa menunggu jaringan.
class FeatureFlagsService {
  FeatureFlagsService._();

  static FeatureFlags _current = FeatureFlags.defaults;
  static DateTime? _lastFetch;

  /// Penanda bahwa nilai berubah; UI bisa mendengarkannya untuk menggambar ulang.
  static final ValueNotifier<FeatureFlags> notifier =
      ValueNotifier<FeatureFlags>(FeatureFlags.defaults);

  /// Nilai terakhir yang diketahui (selalu tersedia, tidak pernah null).
  static FeatureFlags get current => _current;

  /// Mengembalikan keadaan awal; hanya untuk pengujian.
  @visibleForTesting
  static void resetForTest([FeatureFlags? value]) {
    _current = value ?? FeatureFlags.defaults;
    _lastFetch = null;
    notifier.value = _current;
  }

  /// Menyegarkan dari Firestore paling sering sekali per 60 detik. Kegagalan
  /// apa pun (offline, izin, dokumen tidak ada) mempertahankan nilai terakhir.
  static Future<FeatureFlags> sync(
      {bool forceRefresh = false, FirebaseFirestore? firestore}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _lastFetch != null &&
        now.difference(_lastFetch!).inSeconds < 60) {
      return _current;
    }
    try {
      final db = firestore ??
          (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);
      if (db == null) return _current;
      final doc = await db
          .collection('app_config')
          .doc('features')
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 3));
      _lastFetch = now;
      // Dokumen yang ada menentukan hasil secara deterministik: kunci yang
      // hilang atau rusak kembali ke bawaan. Hanya kegagalan MEMBACA yang
      // mempertahankan nilai terakhir (lihat blok catch).
      if (doc.exists) _apply(FeatureFlags.parse(doc.data()));
    } catch (_) {
      // Tetap memakai nilai terakhir yang diketahui.
    }
    return _current;
  }

  static void _apply(FeatureFlags next) {
    if (next == _current) return;
    _current = next;
    notifier.value = next;
  }
}
