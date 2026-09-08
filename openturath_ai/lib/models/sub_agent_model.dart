class SubAgentModel {
  final String id;
  final String name;
  final String nameArabic;
  final String description;
  final String descriptionArabic;
  final String emoji;
  final String badge; // e.g. "Riset Mendalam", "Penjelasan Luas"

  SubAgentModel({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.descriptionArabic,
    required this.emoji,
    required this.badge,
  });
}
