// WHY THIS FILE EXISTS:
// This is the blueprint for what a Lesson looks like in our app.
// Every field here matches EXACTLY a key in our ite114_content.json file.

class Lesson {
  // ─── PROPERTIES ──────────────────────────────────────────
  final int id;
  final int chapter;
  final String chapterTitle;
  final String title;
  final String explanation;
  final String example;
  final String practiceQuestion;

  // ─── CONSTRUCTOR ─────────────────────────────────────────
  const Lesson({
    required this.id,
    required this.chapter,
    required this.chapterTitle,
    required this.title,
    required this.explanation,
    required this.example,
    required this.practiceQuestion,
  });

  // ─── FROM JSON ───────────────────────────────────────────
  // WHY: Translates raw JSON map → Lesson object (Deserialization)
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      chapter: json['chapter'] as int,
      chapterTitle: json['chapter_title'] as String,
      title: json['title'] as String,
      explanation: json['explanation'] as String,
      example: json['example'] as String,
      practiceQuestion: json['practice_question'] as String,
    );
  }

  // ─── TO JSON ─────────────────────────────────────────────
  // WHY: Translates Lesson object → raw JSON map (Serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter': chapter,
      'chapter_title': chapterTitle,
      'title': title,
      'explanation': explanation,
      'example': example,
      'practice_question': practiceQuestion,
    };
  }

  // ─── TO STRING ───────────────────────────────────────────
  // WHY: Makes debugging easier — print(lesson) shows useful info
  @override
  String toString() {
    return 'Lesson(id: $id, chapter: $chapter, title: $title)';
  }
}
