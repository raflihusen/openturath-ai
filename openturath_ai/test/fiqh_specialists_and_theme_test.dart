import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/field_model.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/theme.dart';

void main() {
  group('Fikih Specialists & Theme Verification', () {
    test('FieldModel fiqh has 6 specialists and fiqh_tahawwulat is independent field', () {
      final fiqhField = FieldModel.getById('fiqh');
      expect(fiqhField.specialistCount, 6);
      expect(fiqhField.agentIds.length, 6);
      expect(fiqhField.agentIds, containsAll([
        'fiqh_syafii',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
        'fatawa_masail',
      ]));

      final tahawwulatField = FieldModel.getById('fiqh_tahawwulat');
      expect(tahawwulatField.specialistCount, 1);
      expect(tahawwulatField.agentIds, contains('fiqh_tahawwulat'));
    });

    test('AgentModel defaultAgents contains standard fiqh specialists and independent tahawwulat', () {
      final fiqhAgents = AgentModel.defaultAgents.where((a) => a.fieldId == 'fiqh').toList();
      expect(fiqhAgents.length, 6);

      final fiqhIds = fiqhAgents.map((a) => a.id).toSet();
      expect(fiqhIds, containsAll([
        'fiqh_syafii',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
        'fatawa_masail',
      ]));

      // Check all fiqh specialists have titles
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
      expect(activeAgents.length, equals(21));
      expect(activeAgents.map((a) => a.id), contains('fiqh_tahawwulat'));
      expect(activeAgents.map((a) => a.id), contains('hadits'));
    });

    test('Default ThemeMode is system for fresh installs', () {
      expect(AppConfig.themeNotifier.value, ThemeMode.system);
    });

    test('AppTheme defines pure monochrome accent and parchment reading surface tokens', () {
      expect(AppTheme.accentDark, equals(AppTheme.accentDark));
      expect(AppTheme.accentLight, equals(AppTheme.accentLight));
      expect(AppTheme.readingCanvasParchmentLight, const Color(0xFFF6F6F3));
      expect(AppTheme.readingCanvasParchmentDark, const Color(0xFF181817));
    });
  });
}

