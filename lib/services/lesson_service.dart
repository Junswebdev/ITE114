import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../models/chapter.dart';

// WHY THIS FILE EXISTS:
// This is the "brains" of the app — it reads our JSON file
// from assets and converts it into Dart objects our screens can use.
// Keeping this logic here means our screens stay clean and simple.

class LessonService {
  // ─── LOAD ALL LESSONS ──────────────────────────────────
  // WHY: rootBundle is Flutter's way of reading files from
  // the assets folder. We read the JSON, decode it, then
  // map each topic entry into a Lesson object.

  static Future<List<Lesson>> loadLessons() async {
    try {
      // Step 1: Read the raw JSON string from assets
      final String rawJson = await rootBundle.loadString(
        'assets/data/ite114_content.json',
      );

      // Step 2: Decode the JSON string into a Dart Map
      final Map<String, dynamic> jsonData = json.decode(rawJson);

      // Step 3: Get the "topics" array from the JSON
      final List<dynamic> topicsJson = jsonData['topics'];

      // Step 4: Convert each topic map into a Lesson object
      // using our Lesson.fromJson() blueprint method
      final List<Lesson> lessons = topicsJson
          .map((topic) => Lesson.fromJson(topic))
          .toList();

      return lessons;
    } catch (e) {
      // WHY: Always handle errors gracefully!
      // If something goes wrong, return empty list
      // instead of crashing the whole app.
      print('❌ Error loading lessons: $e');
      return [];
    }
  }

  // ─── LOAD ALL CHAPTERS ─────────────────────────────────
  // WHY: We also load the chapters array separately
  // so the HomeScreen can group lessons by chapter.

  static Future<List<Chapter>> loadChapters() async {
    try {
      final String rawJson = await rootBundle.loadString(
        'assets/data/ite114_content.json',
      );

      final Map<String, dynamic> jsonData = json.decode(rawJson);

      final List<dynamic> chaptersJson = jsonData['chapters'];

      final List<Chapter> chapters = chaptersJson
          .map((chapter) => Chapter.fromJson(chapter))
          .toList();

      return chapters;
    } catch (e) {
      print('❌ Error loading chapters: $e');
      return [];
    }
  }

  // ─── LOAD SINGLE LESSON BY ID ──────────────────────────
  // WHY: Sometimes we need just ONE lesson by its ID.
  // This is a helper method for future features.

  static Future<Lesson?> loadLessonById(int id) async {
    try {
      final lessons = await loadLessons();
      return lessons.firstWhere(
        (lesson) => lesson.id == id,
        orElse: () => throw Exception('Lesson $id not found'),
      );
    } catch (e) {
      print('❌ Error loading lesson $id: $e');
      return null;
    }
  }

  // ─── LOAD LESSONS BY CHAPTER ───────────────────────────
  // WHY: Filter lessons for a specific chapter number.

  static Future<List<Lesson>> loadLessonsByChapter(int chapterNumber) async {
    try {
      final lessons = await loadLessons();
      return lessons
          .where((lesson) => lesson.chapter == chapterNumber)
          .toList();
    } catch (e) {
      print('❌ Error loading chapter $chapterNumber lessons: $e');
      return [];
    }
  }
}
