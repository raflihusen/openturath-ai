import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _legacyKey = 'openturath_research_notes_v1';

  String _getKey([String? userId]) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      return 'openturath_${uid}_research_notes_v1';
    }
    return _legacyKey;
  }

  Future<List<ResearchNote>> getNotes({String? agentId, String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey(userId);
      var raw = prefs.getString(key);

      // Auto-migrasi data legacy
      if ((raw == null || raw.isEmpty) && key != _legacyKey) {
        final legacyRaw = prefs.getString(_legacyKey);
        if (legacyRaw != null && legacyRaw.isNotEmpty) {
          raw = legacyRaw;
          await prefs.setString(key, legacyRaw);
          await prefs.remove(_legacyKey);
        }
      }

      if (raw == null || raw.isEmpty) return [];

      final List<dynamic> list = jsonDecode(raw);
      final notes = list.map((e) => ResearchNote.fromMap(e as Map<String, dynamic>)).toList();
      
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (agentId != null && agentId.isNotEmpty) {
        return notes.where((n) => n.agentId == agentId).toList();
      }
      return notes;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNote(ResearchNote note, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(userId);
    final currentNotes = await getNotes(userId: userId);
    
    // Hapus duplikat jika ID sama
    currentNotes.removeWhere((n) => n.id == note.id);
    currentNotes.insert(0, note);

    final raw = jsonEncode(currentNotes.map((e) => e.toMap()).toList());
    await prefs.setString(key, raw);
  }

  Future<void> deleteNote(String noteId, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(userId);
    final currentNotes = await getNotes(userId: userId);
    currentNotes.removeWhere((n) => n.id == noteId);

    final raw = jsonEncode(currentNotes.map((e) => e.toMap()).toList());
    await prefs.setString(key, raw);
  }
}
