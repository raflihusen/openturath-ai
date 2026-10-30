import 'answer_citation.dart';

enum BookmarkDocumentKind { personalNote, aiAnswer, bookReference }

enum BookmarkVerificationStatus {
  notApplicable,
  unverified,
  needsReview,
  verified
}

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
  final DateTime? updatedAt;

  /// Tombstone for conflict-safe offline deletion. It is synchronized so an
  /// older device cannot resurrect a note that was deliberately removed.
  final DateTime? deletedAt;
  final BookmarkDocumentKind documentKind;
  final BookmarkVerificationStatus verificationStatus;

  /// Locator sumber untuk jawaban asisten; kosong untuk catatan pribadi.
  final List<AnswerCitation> citations;

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
    this.updatedAt,
    this.deletedAt,
    this.documentKind = BookmarkDocumentKind.aiAnswer,
    this.verificationStatus = BookmarkVerificationStatus.unverified,
    this.citations = const [],
  });

  DateTime get effectiveTime => updatedAt ?? createdAt;
  DateTime get syncTime => deletedAt ?? effectiveTime;
  bool get isDeleted => deletedAt != null;

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
      'updatedAt': (updatedAt ?? createdAt).toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'documentKind': documentKind.name,
      'verificationStatus': verificationStatus.name,
      if (citations.isNotEmpty)
        'citations': citations.map((citation) => citation.toJson()).toList(),
    };
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final agentId = json['agentId'] as String? ?? '';
    final fieldName = json['fieldName'] as String? ?? '';
    final kind = _documentKindFromJson(
      json['documentKind'] as String?,
      id: id,
      agentId: agentId,
      fieldName: fieldName,
    );
    return BookmarkModel(
      id: id,
      title: json['title'] as String? ?? '',
      agentId: agentId,
      agentTitle: json['agentTitle'] as String? ?? '',
      fieldName: fieldName,
      fieldId: json['fieldId'] as String? ?? 'fiqh',
      arabicExcerpt: json['arabicExcerpt'] as String? ?? '',
      fullAnswer: json['fullAnswer'] as String? ?? '',
      bookReference: json['bookReference'] as String? ?? '',
      pageNumber: json['pageNumber'] as String? ?? '',
      author: json['author'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'] as String)
          : null,
      documentKind: kind,
      verificationStatus: _verificationStatusFromJson(
        json['verificationStatus'] as String?,
        kind,
      ),
      citations: AnswerCitation.listFromJson(json['citations']),
    );
  }

  BookmarkModel copyWith({
    String? id,
    String? title,
    String? agentId,
    String? agentTitle,
    String? fieldName,
    String? fieldId,
    String? arabicExcerpt,
    String? fullAnswer,
    String? bookReference,
    String? pageNumber,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    BookmarkDocumentKind? documentKind,
    BookmarkVerificationStatus? verificationStatus,
    List<AnswerCitation>? citations,
  }) {
    return BookmarkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      agentId: agentId ?? this.agentId,
      agentTitle: agentTitle ?? this.agentTitle,
      fieldName: fieldName ?? this.fieldName,
      fieldId: fieldId ?? this.fieldId,
      arabicExcerpt: arabicExcerpt ?? this.arabicExcerpt,
      fullAnswer: fullAnswer ?? this.fullAnswer,
      bookReference: bookReference ?? this.bookReference,
      pageNumber: pageNumber ?? this.pageNumber,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      documentKind: documentKind ?? this.documentKind,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      citations: citations ?? this.citations,
    );
  }

  static BookmarkDocumentKind _documentKindFromJson(
    String? value, {
    required String id,
    required String agentId,
    required String fieldName,
  }) {
    return BookmarkDocumentKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () {
        if (id.startsWith('book_') ||
            fieldName.toLowerCase().contains('rujukan kitab')) {
          return BookmarkDocumentKind.bookReference;
        }
        if (agentId == 'catatan_mandiri' ||
            fieldName.toLowerCase().contains('catatan pribadi')) {
          return BookmarkDocumentKind.personalNote;
        }
        return BookmarkDocumentKind.aiAnswer;
      },
    );
  }

  static BookmarkVerificationStatus _verificationStatusFromJson(
    String? value,
    BookmarkDocumentKind kind,
  ) {
    return BookmarkVerificationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => kind == BookmarkDocumentKind.personalNote
          ? BookmarkVerificationStatus.notApplicable
          : kind == BookmarkDocumentKind.bookReference
              ? BookmarkVerificationStatus.needsReview
              : BookmarkVerificationStatus.unverified,
    );
  }
}
