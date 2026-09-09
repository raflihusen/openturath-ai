import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/field_model.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/core/app_config.dart';

void main() {
  group('Fikih Specialists & Theme Verification', () {
    test('FieldModel fiqh has 5 specialists and fiqh_tahawwulat is independent field', () {
      final fiqhField = FieldModel.getById('fiqh');
      expect(fiqhField.specialistCount, 5);
      expect(fiqhField.agentIds.length, 5);
      expect(fiqhField.agentIds, containsAll([
        'fiqh_syafii',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
      ]));

      final tahawwulatField = FieldModel.getById('fiqh_tahawwulat');
      expect(tahawwulatField.specialistCount, 1);
      expect(tahawwulatField.agentIds, contains('fiqh_tahawwulat'));
    });

    test('AgentModel defaultAgents contains 5 standard fiqh specialists and 1 independent tahawwulat', () {
      final fiqhAgents = AgentModel.defaultAgents.where((a) => a.fieldId == 'fiqh').toList();
      expect(fiqhAgents.length, 5);

      final fiqhIds = fiqhAgents.map((a) => a.id).toSet();
      expect(fiqhIds, containsAll([
        'fiqh_syafii',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
      ]));

      // Check all 5 fiqh specialists have titles
      for (final agent in fiqhAgents) {
        expect(agent.title.isNotEmpty, isTrue);
        expect(agent.titleArabic.isNotEmpty, isTrue);
      }

      // Sovereign Tahawwulat agent check
      final tahawwulatAgent = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
      expect(tahawwulatAgent.fieldId, 'fiqh_tahawwulat');
      expect(tahawwulatAgent.price1m, 300000);
      expect(tahawwulatAgent.isActive, isTrue);
    });

    test('AgentModel defaultAgents contains valid active specialists', () {
      final activeAgents = AgentModel.defaultAgents.where((a) => a.isActive).toList();
      expect(activeAgents.length, equals(6));
      expect(activeAgents.map((a) => a.id), contains('fiqh_tahawwulat'));
      expect(activeAgents.map((a) => a.id), contains('hadits'));
    });

    test('Default ThemeMode is dark to match Figma master design', () {
      expect(AppConfig.themeNotifier.value, ThemeMode.dark);
    });
  });
}
