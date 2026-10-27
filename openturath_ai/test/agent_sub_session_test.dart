import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/agent_model.dart';

void main() {
  test('sub-AI membawa id dan judulnya sendiri agar "Lanjutkan sesi" tepat',
      () {
    final parent =
        AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
    final sub =
        parent.subAgents!.firstWhere((s) => s.id == 'fiqh_tahawwulat_muhaqqiq');
    final session = parent.forSubAgent(sub);

    expect(session.id, 'fiqh_tahawwulat_muhaqqiq');
    expect(session.title, contains('Al-Muhaqqiq'));
    expect(session.title, contains('Fikih Tahawwulat'));
    expect(session.isActive, isTrue);
    // Hak akses tetap dicek pada induk: id sesi bukan id induk.
    expect(session.id, isNot(parent.id));
  });

  test('setiap sub-AI Tahawwulat bisa dicari dari id-nya', () {
    final parent =
        AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
    for (final sub in parent.subAgents!) {
      final found = AgentModel.defaultAgents
          .any((a) => a.subAgents?.any((s) => s.id == sub.id) ?? false);
      expect(found, isTrue, reason: sub.id);
    }
  });
}
