import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/chapter.dart';
import '../services/lesson_service.dart';
import 'lesson_screen.dart';

// WHY THIS SCREEN EXISTS:
// This is the app's main menu — it shows all topics grouped by chapter.
// When a student taps a topic, they go to the LessonScreen.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // WHY: We store lessons and chapters in state so the UI
  // can rebuild itself once the data finishes loading.
  List<Lesson> _lessons = [];
  List<Chapter> _chapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // WHY: initState runs once when screen first appears.
  // We use it to trigger our data loading.
  Future<void> _loadData() async {
    final lessons = await LessonService.loadLessons();
    final chapters = await LessonService.loadChapters();
    setState(() {
      _lessons = lessons;
      _chapters = chapters;
      _isLoading = false;
    });
  }

  // WHY: Filter lessons by chapter number for grouping
  List<Lesson> _getLessonsForChapter(int chapterNumber) {
    return _lessons.where((lesson) => lesson.chapter == chapterNumber).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── APP BAR ───────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B00FF),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ITE114',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Linear Algebra & Matrices',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),

      // ── BODY ──────────────────────────────────────────────
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7B00FF)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome Card
                _buildWelcomeCard(),
                const SizedBox(height: 20),

                // Chapter sections
                ..._chapters.map((chapter) => _buildChapterSection(chapter)),
              ],
            ),
    );
  }

  // ── WELCOME CARD ────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B00FF), Color(0xFF9C00FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Welcome, Student!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_lessons.length} topics across ${_chapters.length} chapters',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'MSU-Tawi-Tawi • Developer: Bytes Builder.dev',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── CHAPTER SECTION ─────────────────────────────────────
  Widget _buildChapterSection(Chapter chapter) {
    final lessons = _getLessonsForChapter(chapter.chapterNumber);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chapter Header
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF7B00FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF7B00FF).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B00FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Ch. ${chapter.chapterNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  chapter.chapterTitle,
                  style: const TextStyle(
                    color: Color(0xFF7B00FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${lessons.length} topics',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),

        // Lesson Cards for this chapter
        ...lessons.map((lesson) => _buildLessonCard(lesson)),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── LESSON CARD ─────────────────────────────────────────
  Widget _buildLessonCard(Lesson lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // WHY: Navigator.push takes the user to LessonScreen
          // and passes the selected lesson as data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonScreen(lesson: lesson),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Topic Number Badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B00FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${lesson.id}',
                    style: const TextStyle(
                      color: Color(0xFF7B00FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.explanation.length > 60
                          ? '${lesson.explanation.substring(0, 60)}...'
                          : lesson.explanation,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF7B00FF),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── INFO DIALOG ─────────────────────────────────────────
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About ITE114'),
        content: const Text(
          'Linear Algebra and Matrices\n\n'
          'Instructor: Nurijam Hanna M. Mohammad\n'
          'MSU-Tawi-Tawi College of Technology\n'
          'and Oceanography\n\n'
          'Content: Chapter 1 & Chapter 2',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
