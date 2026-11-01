import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/design/native_design.dart';
import 'package:openturath_ai/models/field_model.dart';

void main() {
  test('setiap bidang punya nama di tiga bahasa, Arab tanpa huruf Latin', () {
    for (final code in ['id', 'en', 'ar']) {
      AppConfig.localeNotifier.value = code;
      for (final field in FieldModel.defaultFields) {
        final label = NativeCopy.text('field_${field.id}');
        expect(label.trim(), isNotEmpty, reason: '${field.id}/$code');
        if (code == 'ar') {
          expect(RegExp(r'[A-Za-z]').hasMatch(label), isFalse,
              reason: 'Latin bocor di ${field.id}: $label');
        }
      }
    }
    AppConfig.localeNotifier.value = 'id';
    debugPrint('ok');
  });
}
