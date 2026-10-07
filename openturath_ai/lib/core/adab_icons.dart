import 'package:flutter/material.dart';
abstract final class AdabIcons {
  static const values = [Icons.school_outlined, Icons.manage_search_rounded,
    Icons.diversity_3_outlined, Icons.verified_user_outlined, Icons.warning_amber_rounded,
    Icons.hub_outlined, Icons.speaker_notes_outlined, Icons.edit_note_rounded];
  static IconData? forSection(String id) {
    final i = int.tryParse(id.split('_').last);
    return id.startsWith('guideline_') && i != null && i >= 2 && i <= 9 ? values[i - 2] : null;
  }
}
