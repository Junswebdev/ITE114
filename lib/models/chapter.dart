// WHY THIS FILE EXISTS:
// Blueprint for a Chapter — groups related Lessons together.
// Maps to the "chapters" array in our ite114_content.json

class Chapter {
  // ─── PROPERTIES ──────────────────────────────────────────
  final int chapterNumber;
  final String chapterTitle;
  final List<String> sections;

  // ─── CONSTRUCTOR ─────────────────────────────────────────
  const Chapter({
    required this.chapterNumber,
    required this.chapterTitle,
    required this.sections,
  });

  // ─── FROM JSON ───────────────────────────────────────────
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterNumber: json['chapter_number'] as int,
      chapterTitle: json['chapter_title'] as String,
      sections: List<String>.from(json['sections']),
    );
  }

  // ─── TO STRING ───────────────────────────────────────────
  @override
  String toString() {
    return 'Chapter(number: $chapterNumber, title: $chapterTitle)';
  }
}
