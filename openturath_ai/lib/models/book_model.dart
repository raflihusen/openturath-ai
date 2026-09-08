class BookModel {
  final String title;
  final String titleArabic;
  final String author;
  final String description;
  final String? url;

  BookModel({
    required this.title,
    required this.titleArabic,
    required this.author,
    required this.description,
    this.url,
  });
}
