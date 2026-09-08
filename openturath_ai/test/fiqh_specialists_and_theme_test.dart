import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/field_model.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/core/app_config.dart';

void main() {
  group('Fikih Specialists & Theme Verification', () {
    test('FieldModel fiqh has exactly 6 specialists', () {
      final fiqhField = FieldModel.getById('fiqh');
      expect(fiqhField.specialistCount, 6);
      expect(fiqhField.agentIds.length, 6);
      expect(fiqhField.agentIds, containsAll([
        'fiqh_syafii',
        'fiqh_tahawwulat',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
      ]));
    });

    test('AgentModel defaultAgents contains exactly 6 fiqh specialists', () {
      final fiqhAgents = AgentModel.defaultAgents.where((a) => a.fieldId == 'fiqh').toList();
      expect(fiqhAgents.length, 6);

      final fiqhIds = fiqhAgents.map((a) => a.id).toSet();
      expect(fiqhIds, containsAll([
        'fiqh_tahawwulat',
        'fiqh_syafii',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
      ]));

      // Check all 6 fiqh specialists have titles
      for (final agent in fiqhAgents) {
        expect(agent.title.isNotEmpty, isTrue);
        expect(agent.titleArabic.isNotEmpty, isTrue);
      }

      // Authoritative active agents
      final activeFiqh = fiqhAgents.where((a) => a.isActive).map((a) => a.id).toList();
      expect(activeFiqh, contains('fiqh_tahawwulat'));
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
