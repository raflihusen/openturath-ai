class BookmarkModel {
  final String id;
  final String title;
  final String agentId;
  final String agentTitle;
  final String fieldName;
  final String fieldId;
  final String arabicExcerpt;
  final String fullAnswer;
  final String bookReference;
  final String pageNumber;
  final String? author;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.title,
    required this.agentId,
    required this.agentTitle,
    required this.fieldName,
    required this.fieldId,
    required this.arabicExcerpt,
    required this.fullAnswer,
    required this.bookReference,
    required this.pageNumber,
    this.author,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'agentId': agentId,
      'agentTitle': agentTitle,
      'fieldName': fieldName,
      'fieldId': fieldId,
      'arabicExcerpt': arabicExcerpt,
      'fullAnswer': fullAnswer,
      'bookReference': bookReference,
      'pageNumber': pageNumber,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      agentId: json['agentId'] as String? ?? '',
      agentTitle: json['agentTitle'] as String? ?? '',
      fieldName: json['fieldName'] as String? ?? '',
      fieldId: json['fieldId'] as String? ?? 'fiqh',
      arabicExcerpt: json['arabicExcerpt'] as String? ?? '',
      fullAnswer: json['fullAnswer'] as String? ?? '',
      bookReference: json['bookReference'] as String? ?? '',
      pageNumber: json['pageNumber'] as String? ?? '',
      author: json['author'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
