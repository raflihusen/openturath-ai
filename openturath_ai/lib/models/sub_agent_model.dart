import '../core/localization.dart';

class SubAgentModel {
  final String id;
  final String _name;
  String get name => Loc.isArabic ? nameArabic : Loc.text(_name);
  final String nameArabic;
  final String _description;
  String get description =>
      Loc.isArabic ? descriptionArabic : Loc.text(_description);
  final String descriptionArabic;
  final String emoji;
  final String badge; // e.g. "Riset Mendalam", "Penjelasan Luas"

  SubAgentModel({
    required this.id,
    required String name,
    required this.nameArabic,
    required String description,
    required this.descriptionArabic,
    required this.emoji,
    required this.badge,
  })  : _name = name,
        _description = description;
}
