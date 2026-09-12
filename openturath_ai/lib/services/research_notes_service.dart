import 'package:firebase_auth/firebase_auth.dart';
import 'scoped_json_store.dart';

/// Model Catatan Riset / Bookmark Hasil Pencarian Kitab
class ResearchNote {
  final String id;
  final String agentId;
  final String agentTitle;
  final String title;
  final String excerpt;
  final String? bookTitle;
  final String? bookVolume;
  final String? bookPage;
  final List<String> tags;
  final DateTime createdAt;

  ResearchNote({
    required this.id,
    required this.agentId,
    required this.agentTitle,
    required this.title,
    required this.excerpt,
    this.bookTitle,
    this.bookVolume,
    this.bookPage,
    this.tags = const [],
    required this.createdAt,
  });

  String get citationFormatted {
    final buffer = StringBuffer();
    buffer.writeln('"$excerpt"');
    buffer.writeln();
    buffer.write('Sumber: OpenTurath AI ($agentTitle)');
    if (bookTitle != null && bookTitle!.isNotEmpty) {
      buffer.write(', Kitab $bookTitle');
      if (bookVolume != null && bookVolume!.isNotEmpty) buffer.write(' Juz $bookVolume');
      if (bookPage != null && bookPage!.isNotEmpty) buffer.write(' Hal $bookPage');
    }
    return buffer.toString();
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'agent_id': agentId,
        'agent_title': agentTitle,
        'title': title,
        'excerpt': excerpt,
        'book_title': bookTitle,
        'book_volume': bookVolume,
        'book_page': bookPage,
        'tags': tags,
        'created_at': createdAt.toIso8601String(),
      };

  factory ResearchNote.fromMap(Map<String, dynamic> map) => ResearchNote(
        id: map['id'] ?? '',
        agentId: map['agent_id'] ?? '',
        agentTitle: map['agent_title'] ?? '',
        title: map['title'] ?? '',
        excerpt: map['excerpt'] ?? '',
        bookTitle: map['book_title'],
        bookVolume: map['book_volume'],
        bookPage: map['book_page'],
        tags: List<String>.from(map['tags'] ?? []),
        createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      );
}

/// Service Penyimpanan Catatan & Bookmark Riset Lokal (Offline-first)
class ResearchNotesService {
  final _store = ScopedJsonListStore<ResearchNote>(
    storage: PreferencesStringStore(), decode: ResearchNote.fromMap,
    encode: (note) => note.toMap(),
  );
  String _key(String? userId) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    return uid == null || uid.isEmpty ? 'openturath_research_notes_v1' : 'openturath_${uid}_research_notes_v1';
  }
  Future<List<ResearchNote>> getNotes({String? agentId, String? userId}) async {
    final key = _key(userId);
    final notes = await _store.read(key);
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return agentId == null || agentId.isEmpty ? notes : notes.where((n) => n.agentId == agentId).toList();
  }
  Future<void> saveNote(ResearchNote note, {String? userId}) {
    final key = _key(userId);
    return _store.update(key, (notes) {
      notes.removeWhere((n) => n.id == note.id);
      notes.insert(0, note);
      return notes;
    });
  }
  Future<void> deleteNote(String noteId, {String? userId}) {
    final key = _key(userId);
    return _store.update(key, (notes) => notes..removeWhere((n) => n.id == noteId));
  }
}
